// lib/screens/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/expense_provider.dart';
import '../utils/app_theme.dart';

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

    final expense = Expense(
      id: const Uuid().v4(),
      date: _selectedDate,
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
      paymentMethod: _selectedPayment,
      note: _noteController.text.trim(),
    );

    final provider = context.read<ExpenseProvider>();
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
        // subtitle: const Text(
        //   'Syncs to Google Sheets',
        //   style: TextStyle(
        //       fontSize: 11, color: Colors.white54),
        // ),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Amount Input ──────────────────────────────────────────────
              _AmountInput(controller: _amountController),
              const SizedBox(height: 24),

              // ── Category Selector ─────────────────────────────────────────
              _SectionLabel('Category'),
              const SizedBox(height: 10),
              SizedBox(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
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
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected ? Colors.white : AppTheme.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Sub-category Dropdown ─────────────────────────────────────
              const _SectionLabel('Sub-category'),
              const SizedBox(height: 8),
              _StyledDropdown<String>(
                value: _selectedSubCategory,
                items: _subCategories,
                itemLabel: (s) => s,
                onChanged: (v) => setState(() => _selectedSubCategory = v!),
                prefixEmoji: _currentCategory.emoji,
              ),
              const SizedBox(height: 20),

              // ── Date & Payment Row ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Date'),
                        const SizedBox(height: 8),
                        GestureDetector(
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
                                const Text('📅',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd MMM yyyy')
                                      .format(_selectedDate),
                                  style: const TextStyle(
                                      fontSize: 12, color: AppTheme.dark),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Payment'),
                        const SizedBox(height: 8),
                        _StyledDropdown<String>(
                          value: _selectedPayment,
                          items: AppConstants.paymentMethods,
                          itemLabel: (s) => s,
                          onChanged: (v) =>
                              setState(() => _selectedPayment = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Note ──────────────────────────────────────────────────────
              const _SectionLabel('Note (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Add a description...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 32),

              // ── Save Button ───────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _saveSuccess
                    ? ScaleTransition(
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
                              Icon(Icons.check_circle,
                                  color: Colors.white, size: 20),
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
                      )
                    : ElevatedButton(
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
                      ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  const _AmountInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Column(
        children: [
          const Text(
            'Enter Amount (AED)',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'AED ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              Flexible(
                child: TextFormField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dark,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFCCC),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter an amount';
                    final val = double.tryParse(v);
                    if (val == null || val <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? prefixEmoji;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.prefixEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary, size: 18),
          style: const TextStyle(
              fontSize: 13, color: AppTheme.dark, fontFamily: 'DMSans'),
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        if (prefixEmoji != null && item == value) ...[
                          Text(prefixEmoji!,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                        ],
                        Text(itemLabel(item)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
