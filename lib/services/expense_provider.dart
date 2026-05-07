// lib/services/expense_provider.dart
import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import 'sheets_service.dart';

enum LoadState { idle, loading, success, error }

class ExpenseProvider extends ChangeNotifier {
  final SheetsService _service = SheetsService();

  bool _isSignedIn = false;
  LoadState _loadState = LoadState.idle;
  String _errorMessage = '';

  List<Expense> _expenses = [];
  MonthlySummary? _currentSummary;
  List<MonthlySummary> _trend = [];

  // ─── Getters ───────────────────────────────────────────────────────────────
  bool get isSignedIn => _isSignedIn;
  LoadState get loadState => _loadState;
  String get errorMessage => _errorMessage;
  List<Expense> get expenses => _expenses;
  MonthlySummary? get currentSummary => _currentSummary;
  List<MonthlySummary> get trend => _trend;
  bool get isLoading => _loadState == LoadState.loading;

  // ─── Auth ──────────────────────────────────────────────────────────────────
  Future<void> initAuth() async {
    _isSignedIn = await _service.tryAutoSignIn();
    if (_isSignedIn) await loadDashboard();
    notifyListeners();
  }

  Future<bool> signIn() async {
    _setLoading();
    try {
      _isSignedIn = await _service.signIn();
      if (_isSignedIn) {
        await loadDashboard();
      } else {
        _setError('Sign-in cancelled.');
      }
    } catch (e) {
      _setError(e.toString());
      _isSignedIn = false;
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
    notifyListeners();
  }

  // ─── Data Loading ──────────────────────────────────────────────────────────
  Future<void> loadDashboard() async {
    _setLoading();
    try {
      final results = await Future.wait([
        _service.fetchMonthlySummary(),
        _service.fetchTrend(),
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

  Future<void> refreshData() => loadDashboard();

  // ─── Add Expense ───────────────────────────────────────────────────────────
  Future<bool> addExpense(Expense expense) async {
    try {
      final success = await _service.addExpense(expense);
      if (success) {
        _expenses.insert(0, expense);
        // Update current summary locally for instant UI feedback
        if (_currentSummary != null &&
            expense.date.month == DateTime.now().month &&
            expense.date.year == DateTime.now().year) {
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
