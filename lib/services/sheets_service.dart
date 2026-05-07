// lib/services/sheets_service.dart
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:logger/logger.dart';
import '../models/expense_model.dart';
import '../utils/app_theme.dart';

class SheetsService {
  static final SheetsService _instance = SheetsService._internal();
  factory SheetsService() => _instance;
  SheetsService._internal();

  final Logger _logger = Logger();
  sheets.SheetsApi? _sheetsApi;
  bool _isInitialized = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [sheets.SheetsApi.spreadsheetsScope],
  );

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) return false;
      _sheetsApi = sheets.SheetsApi(authClient);
      _isInitialized = true;
      _logger.i('Google Sign-In successful: ${account.email}');
      return true;
    } catch (e) {
      _logger.e('Sign-in failed: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _sheetsApi = null;
    _isInitialized = false;
  }

  Future<bool> tryAutoSignIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return false;
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) return false;
      _sheetsApi = sheets.SheetsApi(authClient);
      _isInitialized = true;
      return true;
    } catch (e) {
      _logger.w('Auto sign-in failed: $e');
      return false;
    }
  }

  bool get isSignedIn => _isInitialized && _sheetsApi != null;

  // ─── Write Expense ─────────────────────────────────────────────────────────

  Future<bool> addExpense(Expense expense) async {
    if (!_isInitialized || _sheetsApi == null) {
      throw Exception('Not authenticated. Please sign in first.');
    }
    try {
      final valueRange = sheets.ValueRange(
        values: [expense.toSheetRow()],
      );
      await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        AppConstants.spreadsheetId,
        AppConstants.writeRange,
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );
      _logger.i('Expense added: ${expense.category} - ${expense.amount}');
      return true;
    } catch (e) {
      _logger.e('Failed to add expense: $e');
      rethrow;
    }
  }

  // ─── Read All Expenses ─────────────────────────────────────────────────────

  Future<List<Expense>> fetchAllExpenses() async {
    if (!_isInitialized || _sheetsApi == null) {
      throw Exception('Not authenticated.');
    }
    try {
      final response = await _sheetsApi!.spreadsheets.values.get(
        AppConstants.spreadsheetId,
        AppConstants.readRange,
      );
      final rows = response.values ?? [];
      return rows
          .where((row) => row.isNotEmpty && row.length >= 3)
          .map((row) => Expense.fromSheetRow(row))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _logger.e('Failed to fetch expenses: $e');
      rethrow;
    }
  }

  // ─── Monthly Summary ───────────────────────────────────────────────────────

  Future<MonthlySummary> fetchMonthlySummary({int? year, int? month}) async {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    final all = await fetchAllExpenses();
    final filtered = all
        .where((e) => e.date.year == targetYear && e.date.month == targetMonth)
        .toList();

    final byCategory = <String, double>{};
    for (final e in filtered) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }

    return MonthlySummary(
      year: targetYear,
      month: targetMonth,
      totalSpent: filtered.fold(0, (sum, e) => sum + e.amount),
      budget: 6000, // TODO: read budget from a Settings sheet row
      byCategory: byCategory,
      expenses: filtered,
    );
  }

  // ─── Last 6 Months Trend ───────────────────────────────────────────────────

  Future<List<MonthlySummary>> fetchTrend() async {
    final all = await fetchAllExpenses();
    final now = DateTime.now();
    final results = <MonthlySummary>[];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final filtered = all
          .where((e) => e.date.year == date.year && e.date.month == date.month)
          .toList();
      final byCategory = <String, double>{};
      for (final e in filtered) {
        byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
      }
      results.add(MonthlySummary(
        year: date.year,
        month: date.month,
        totalSpent: filtered.fold(0, (sum, e) => sum + e.amount),
        budget: 6000,
        byCategory: byCategory,
        expenses: filtered,
      ));
    }
    return results;
  }
}
