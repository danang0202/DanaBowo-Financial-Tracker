import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/budget.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/icon_helper.dart';
import '../dynamic_island_notification.dart';

/// Add/Edit budget bottom sheet
class BudgetFormSheet extends StatefulWidget {
  final Budget? budget;

  const BudgetFormSheet({super.key, this.budget});

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  bool _notificationEnabled = true;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final b = widget.budget!;
      _amountController.text =
          NumberFormat('#,###', 'id_ID').format(b.limitAmount);
      _selectedCategoryId = b.categoryId;
      _notificationEnabled = b.notificationEnabled;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isEditing ? 'Edit Anggaran' : 'Tambah Anggaran',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Category selector
              if (!_isEditing) ...[
                Text(
                  'Pilih Kategori',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    final expenseCategories =
                        categoryProvider.expenseCategories;
                    final budgetProvider = context.read<BudgetProvider>();
                    final existingBudgetCategories =
                        budgetProvider.budgets.map((b) => b.categoryId).toSet();

                    // Filter out categories that already have budgets
                    final availableCategories = expenseCategories
                        .where((c) => !existingBudgetCategories.contains(c.id))
                        .toList();

                    if (availableCategories.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Semua kategori pengeluaran sudah memiliki anggaran.',
                                style: TextStyle(color: Colors.orange[800]),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableCategories.length,
                        itemBuilder: (context, index) {
                          final category = availableCategories[index];
                          final isSelected = category.id == _selectedCategoryId;
                          final color = Color(category.colorValue);

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                setState(
                                    () => _selectedCategoryId = category.id);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.15)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : Theme.of(context).dividerColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: color,
                                      child: Icon(
                                        IconHelper.getIcon(category.iconName),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? color
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Amount input
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Batas Anggaran',
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Notification toggle
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: SwitchListTile(
                  title: const Text('Notifikasi Peringatan'),
                  subtitle: const Text('Peringatan saat 80% terpakai'),
                  value: _notificationEnabled,
                  onChanged: (value) {
                    setState(() => _notificationEnabled = value);
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.notifications_active,
                        color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: Text(
                    _isEditing ? 'Simpan Perubahan' : 'Buat Anggaran',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBudget() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      DynamicIslandNotification.show(
        context,
        message: 'Masukkan batas anggaran',
        isError: true,
      );
      return;
    }

    final amount = parseCurrency(amountText);
    if (amount <= 0) {
      DynamicIslandNotification.show(
        context,
        message: 'Batas anggaran harus lebih dari 0',
        isError: true,
      );
      return;
    }

    if (!_isEditing && _selectedCategoryId == null) {
      DynamicIslandNotification.show(
        context,
        message: 'Pilih kategori terlebih dahulu',
        isError: true,
      );
      return;
    }

    final budgetProvider = context.read<BudgetProvider>();

    if (_isEditing) {
      final updatedBudget = widget.budget!.copyWith(
        limitAmount: amount,
        notificationEnabled: _notificationEnabled,
      );
      budgetProvider.updateBudget(updatedBudget);
    } else {
      budgetProvider.addBudget(
        categoryId: _selectedCategoryId!,
        limitAmount: amount,
        notificationEnabled: _notificationEnabled,
      );
    }

    Navigator.pop(context);
    DynamicIslandNotification.show(
      context,
      message: _isEditing ? 'Anggaran diperbarui' : 'Anggaran ditambahkan',
    );
  }
}
