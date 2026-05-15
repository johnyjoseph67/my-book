// lib/screens/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/expense_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/add_expence/amount_input.dart';
import '../widgets/add_expence/section_label.dart';
import '../widgets/add_expence/styled_dropdown.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'Food';
  String _selectedSubCategory = 'Groceries';
  String _selectedPayment = 'Credit Card';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _saveSuccess = false;

  late AnimationController _successController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _successController.dispose();
    super.dispose();
  }

  ExpenseCategory get _currentCategory => AppConstants.categories.firstWhere(
        (c) => c.name == _selectedCategory,
      );

  List<String> get _subCategories =>
      AppConstants.subCategories[_selectedCategory] ?? ['Other'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<ExpenseProvider>();
    final accountInfo = provider.acccountInfo;
    final expense = Expense(
        id: const Uuid().v4(),
        date: _selectedDate,
        amount: double.parse(_amountController.text.trim()),
        category: _selectedCategory,
        subCategory: _selectedSubCategory,
        paymentMethod: _selectedPayment,
        note: _noteController.text.trim(),
        emailId: accountInfo != null ? accountInfo.emailId : '');

    final success = await provider.addExpense(expense);
    if (mounted) {
      if (success) {
        setState(() {
          _isSaving = false;
          _saveSuccess = true;
        });
        _successController.forward(from: 0);
        HapticFeedback.mediumImpact();

        await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

        if (mounted) {
          // Reset form
          setState(() {
            _amountController.clear();
            _noteController.clear();
            _selectedDate = DateTime.now();
            _selectedCategory = 'Food';
            _selectedSubCategory = 'Groceries';
            _selectedPayment = 'Credit Card';
            _saveSuccess = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Expense saved to Google Sheets ✓'),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage.isNotEmpty
                ? provider.errorMessage
                : 'Failed to save. Please try again.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Add Expense'),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: _addExpencePageContent(),
      ),
    );
  }

  SingleChildScrollView _addExpencePageContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Amount Input ──────────────────────────────────────────────
          AmountInput(controller: _amountController),
          const SizedBox(height: 24),

          // ── Category Selector ─────────────────────────────────────────
          const SectionLabel('Category'),
          const SizedBox(height: 10),
          _category(),
          const SizedBox(height: 20),

          // ── Sub-category Dropdown ─────────────────────────────────────
          const SectionLabel('Sub-category'),
          const SizedBox(height: 8),
          StyledDropdown<String>(
            value: _selectedSubCategory,
            items: _subCategories,
            itemLabel: (s) => s,
            onChanged: (v) => setState(() => _selectedSubCategory = v!),
            prefixEmoji: _currentCategory.emoji,
          ),
          const SizedBox(height: 20),

          // ── Date & Payment Row ────────────────────────────────────────
          _paymentModeAndDate(),
          const SizedBox(height: 20),

          // ── Note ──────────────────────────────────────────────────────
          const SectionLabel('Note (optional)'),
          const SizedBox(height: 8),
          _addNote(),
          const SizedBox(height: 32),

          // ── Save Button ───────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _saveSuccess ? _saveGoogleAccountButton() : _saveButton(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _category() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = AppConstants.categories[i];
          final isSelected = cat.name == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = cat.name;
              _selectedSubCategory =
                  AppConstants.subCategories[cat.name]!.first;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.dark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.dark
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.dark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _paymentModeAndDate() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Date'),
              const SizedBox(height: 8),
              _datePicker(),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _paymentMode(),
      ],
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Text('📅', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMM yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 12, color: AppTheme.dark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMode() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Payment'),
          const SizedBox(height: 8),
          StyledDropdown<String>(
            value: _selectedPayment,
            items: AppConstants.paymentMethods,
            itemLabel: (s) => s,
            onChanged: (v) => setState(() => _selectedPayment = v!),
          ),
        ],
      ),
    );
  }

  Widget _addNote() {
    return TextFormField(
      controller: _noteController,
      maxLines: 2,
      style: const TextStyle(fontSize: 13),
      decoration: const InputDecoration(
        hintText: 'Add a description...',
        hintStyle: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _saveGoogleAccountButton() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        key: const ValueKey('success'),
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Saved to Google Sheets!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      key: const ValueKey('save'),
      onPressed: _isSaving ? null : _saveExpense,
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text('Save to Google Sheets'),
    );
  }
}
