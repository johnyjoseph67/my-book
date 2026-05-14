// lib/services/expense_provider.dart
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../utils/app_theme.dart';
import 'sheets_service.dart';

enum LoadState { idle, loading, success, error }

class ExpenseProvider extends ChangeNotifier {
  final SheetsService _service = SheetsService();

  bool _isSignedIn = false;
  LoadState _loadState = LoadState.idle;
  String _errorMessage = '';
  String? _selectedEmailId;

  List<Expense> _expenses = [];
  MonthlySummary? _currentSummary;
  List<MonthlySummary> _trend = [];
  AccountInfo? _accountInfo;

  // ─── Getters ───────────────────────────────────────────────────────────────
  bool get isSignedIn => _isSignedIn;
  LoadState get loadState => _loadState;
  String get errorMessage => _errorMessage;
  List<Expense> get expenses => _expenses;
  MonthlySummary? get currentSummary => _currentSummary;
  List<MonthlySummary> get trend => _trend;
  bool get isLoading => _loadState == LoadState.loading;
  AccountInfo? get acccountInfo => _accountInfo;
  String? get selectedEmailId => _selectedEmailId;
  List<String> get availableEmails => _expenses
      .map((e) => e.emailId)
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  // ─── Auth ──────────────────────────────────────────────────────────────────
  Future<void> initAuth() async {
    final loginData = await _service.tryAutoSignIn();
    _isSignedIn = loginData.isLogIn;
    if (_isSignedIn) {
      _accountInfo = loginData;
      // Store the auto-signed-in email globally in AppConstants
      AppConstants.userEmailId = loginData.emailId;
      await loadDashboard();
    }
    notifyListeners();
  }

  Future<bool> signIn() async {
    _setLoading();
    final signIn = await _service.signIn();
    _isSignedIn = signIn.isLogIn;
    if (_isSignedIn) {
      _accountInfo = signIn;
      // Store the signed-in email globally in AppConstants
      AppConstants.userEmailId = signIn.emailId;
      await loadDashboard();
    } else {
      _setError('Sign-in failed. Please try again.');
    }
    notifyListeners();
    return _isSignedIn;
  }

  Future<void> signOut() async {
    await _service.signOut();
    _isSignedIn = false;
    _expenses = [];
    _currentSummary = null;
    _trend = [];
    _accountInfo = AccountInfo(emailId: '', name: '', isLogIn: false);
    notifyListeners();
  }

  // ─── Data Loading ──────────────────────────────────────────────────────────
  Future<void> loadDashboard({int? month, int? year}) async {
    String? authEmailID = AppConstants.getEmailId();
    _setLoading();
    try {
      final results = await Future.wait([
        _service.fetchMonthlySummary(
            month: month, year: year, emailId: authEmailID),
        _service.fetchTrend(emailId: authEmailID),
        _service.fetchAllExpenses(),
      ]);
      _currentSummary = results[0] as MonthlySummary;
      _trend = results[1] as List<MonthlySummary>;
      _expenses = results[2] as List<Expense>;
      _loadState = LoadState.success;
    } catch (e) {
      _setError(e.toString());
    }
    notifyListeners();
  }

  Future<void> refreshData({int? year, int? month}) =>
      loadDashboard(year: year, month: month);

  // ─── Add Expense ───────────────────────────────────────────────────────────
  Future<bool> addExpense(Expense expense) async {
    try {
      final success = await _service.addExpense(expense);
      if (success) {
        _expenses.insert(0, expense);
        // Update current summary locally for instant UI feedback
        if (_currentSummary != null &&
            expense.date.month == DateTime.now().month &&
            expense.date.year == DateTime.now().year &&
            expense.emailId == AppConstants.getEmailId()) {
          final updated = MonthlySummary(
            year: _currentSummary!.year,
            month: _currentSummary!.month,
            totalSpent: _currentSummary!.totalSpent + expense.amount,
            budget: _currentSummary!.budget,
            byCategory: Map.from(_currentSummary!.byCategory)
              ..[expense.category] =
                  (_currentSummary!.byCategory[expense.category] ?? 0) +
                      expense.amount,
            expenses: [expense, ..._currentSummary!.expenses],
          );
          _currentSummary = updated;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading() {
    _loadState = LoadState.loading;
    _errorMessage = '';
  }

  void _setError(String msg) {
    _loadState = LoadState.error;
    _errorMessage = msg;
  }

  List<Expense> get recentExpenses => _expenses.take(10).toList();

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final e in _expenses) {
      if (e.date.month == DateTime.now().month &&
          e.date.year == DateTime.now().year) {
        map[e.category] = (map[e.category] ?? 0) + e.amount;
      }
    }
    return map;
  }
}
