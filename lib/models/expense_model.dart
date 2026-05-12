// lib/models/expense_model.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
class AccountInfo {
  final String? name;
  final String emailId;
  final bool isLogIn;

  AccountInfo({required this.name,required this.emailId, required this.isLogIn});
  
}
class Expense {
  final String id;
  final DateTime date;
  final double amount;
  final String category;
  final String subCategory;
  final String paymentMethod;
  final String note;

  Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    required this.subCategory,
    required this.paymentMethod,
    this.note = '',
  });

  // Convert to Google Sheets row (list of values)
  List<dynamic> toSheetRow() {
    return [
      '${date.day}/${date.month}/${date.year}',
      amount.toStringAsFixed(2),
      category,
      subCategory,
      paymentMethod,
      note,
      id,
    ];
  }

  // Parse from Google Sheets row
  factory Expense.fromSheetRow(List<dynamic> row) {
    final parts = (row[0] as String).split('/');
    return Expense(
      id: row.length > 6 ? row[6].toString() : DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])),
      amount: double.tryParse(row[1].toString()) ?? 0.0,
      category: row[2].toString(),
      subCategory: row.length > 3 ? row[3].toString() : '',
      paymentMethod: row.length > 4 ? row[4].toString() : 'Cash',
      note: row.length > 5 ? row[5].toString() : '',
    );
  }

  ExpenseCategory get categoryData {
    return AppConstants.categories.firstWhere(
      (c) => c.name == category,
      orElse: () => AppConstants.categories.last,
    );
  }

  Color get categoryColor => categoryData.color;
  String get categoryEmoji => categoryData.emoji;
}

class MonthlySummary {
  final int year;
  final int month;
  final double totalSpent;
  final double budget;
  final Map<String, double> byCategory;
  final List<Expense> expenses;

  MonthlySummary({
    required this.year,
    required this.month,
    required this.totalSpent,
    required this.budget,
    required this.byCategory,
    required this.expenses,
  });

  double get remaining => budget - totalSpent;
  double get percentUsed => budget > 0 ? (totalSpent / budget * 100).clamp(0, 100) : 0;

  String get monthName {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
