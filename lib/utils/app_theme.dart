// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  static const Color primary = Color(0xFF1D9E75);
  static const Color primaryDark = Color(0xFF0F6E56);
  static const Color primaryLight = Color(0xFFE1F5EE);
  static const Color dark = Color(0xFF1A1A2E);
  static const Color darkSecondary = Color(0xFF2D2D44);
  static const Color surface = Color(0xFFF8F7F4);
  static const Color white = Colors.white;
  static const Color textSecondary = Color(0xFF888780);
  static const Color danger = Color(0xFFE24B4A);
  static const Color warning = Color(0xFFEF9F27);
  static const Color info = Color(0xFF378ADD);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'DMSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: primaryDark,
          surface: surface,
          error: danger,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: dark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

class AppConstants {
  static String? userEmailId = '';
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BuildContext? get globalContext => navigatorKey.currentContext;
  static String? getEmailId() => userEmailId;
  // ⚠️ Replace with your actual Google Sheets ID
  static const String spreadsheetId =
      '1Je0K37fXvHvzGJ9tRBhqbp8ewDHIXck_8ite3mlXkDY';

  // Sheet tab names — update to match your sheet
  // Your spreadsheet tab is currently named "Expences" (per runtime diagnostics).
  // static const String expenseSheet = 'Expences';
  static const String expenseSheet = 'May';
  static const String dashboardSheet = 'Dashboard';

  // Column order in your Google Sheet
  // A=Date, B=Amount, C=Category, D=SubCategory, E=PaymentMethod, F=Note, G=ID
  // Note: Quoting the tab name makes the Sheets API range parser robust
  // (especially if you rename the tab to include spaces/special characters).
  static const String writeRange = "'$expenseSheet'!A:H";
  static const String readRange = "'$expenseSheet'!A2:I";

  static const List<ExpenseCategory> categories = [
    ExpenseCategory(
        name: 'Housing',
        emoji: '🏠',
        color: Color(0xFFE1F5EE),
        textColor: Color(0xFF085041)),
    ExpenseCategory(
        name: 'Food',
        emoji: '🍔',
        color: Color(0xFFFAEEDA),
        textColor: Color(0xFF633806)),
    ExpenseCategory(
        name: 'Transport',
        emoji: '🚗',
        color: Color(0xFFE6F1FB),
        textColor: Color(0xFF0C447C)),
    ExpenseCategory(
        name: 'Health',
        emoji: '🏥',
        color: Color(0xFFFBEAF0),
        textColor: Color(0xFF72243E)),
    ExpenseCategory(
        name: 'Utilities',
        emoji: '📱',
        color: Color(0xFFEEEDFE),
        textColor: Color(0xFF3C3489)),
    ExpenseCategory(
        name: 'Settlement',
        emoji: '💰',
        color: Color(0xFFE1F5EE),
        textColor: Color(0xFF085041)),
    ExpenseCategory(
        name: 'Leisure',
        emoji: '🎮',
        color: Color(0xFFFAECE7),
        textColor: Color(0xFF712B13)),
    ExpenseCategory(
        name: 'Savings',
        emoji: '💰',
        color: Color(0xFFE1F5EE),
        textColor: Color(0xFF085041)),
    ExpenseCategory(
        name: 'Education',
        emoji: '🎓',
        color: Color(0xFFEAF3DE),
        textColor: Color(0xFF27500A)),
    ExpenseCategory(
        name: 'Other',
        emoji: '📦',
        color: Color(0xFFF1EFE8),
        textColor: Color(0xFF444441)),
    ExpenseCategory(
        name: 'To India',
        emoji: '💰',
        color: Color(0xFFE1F5EE),
        textColor: Color(0xFF085041)),
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Cheque',
    'Online Payment',
  ];

  static const Map<String, List<String>> subCategories = {
    'Housing': ['Rent', 'Mortgage', 'Maintenance', 'Insurance', 'Furniture'],
    'Settlement': ['Settlement'],
    'Food': [
      'Groceries',
      'Vegitable',
      'Meat & Chicken',
      'Egg',
      'Fruits',
      'Takeaway',
      'Delivery'
    ],
    'Transport': [
      'Fuel',
      'Taxi/Uber',
      'Public Transport',
      'Parking',
      'Car Service'
    ],
    'Health': ['Doctor', 'Pharmacy', 'Gym', 'Insurance', 'Dental'],
    'To India': ['Home', 'Other'],
    'Utilities': [
      'Electricity (DEWA)',
      'Water',
      'Internet',
      'Mobile',
      'Shopping',
      'TV Subscription'
    ],
    'Leisure': [
      'Entertainment',
      'Sports',
      'Restaurants',
      'Travel',
      'Hobbies',
      'Shopping',
      'Coffee'
    ],
    'Education': ['Tuition', 'Books', 'Courses', 'Stationery', 'School Fees'],
    'Savings': ['Emergency Fund', 'Investment', 'Retirement', 'Goal Saving'],
    'Other': ['Gifts', 'Charity', 'Miscellaneous'],
  };
}

class ExpenseCategory {
  final String name;
  final String emoji;
  final Color color;
  final Color textColor;

  const ExpenseCategory({
    required this.name,
    required this.emoji,
    required this.color,
    required this.textColor,
  });
}
