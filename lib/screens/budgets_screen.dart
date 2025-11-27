import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import '../utils/icon_helper.dart';

/// Screen for managing budgets
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggaran'),
      ),
      body: Consumer3<BudgetProvider, CategoryProvider, TransactionProvider>(
        builder: (context, budgetProvider, categoryProvider, transactionProvider, child) {
          final budgets = budgetProvider.budgets;
          final monthTransactions = transactionProvider.getThisMonthTransactions();

          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada anggaran',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambah anggaran untuk melacak pengeluaran',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final status = budgetProvider.calculateBudgetStatus(
                budget.categoryId,
                monthTransactions,
              );
              final category = categoryProvider.getCategoryById(budget.categoryId);

              return _BudgetItem(
                budget: budget,
                status: status,
                categoryName: category?.name ?? 'Unknown',
                categoryIcon: category?.iconName ?? 'category',
                categoryColor: category?.colorValue ?? 0xFF2196F3,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBudgetDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddBudgetSheet(),
    );
  }
}

/// Budget item widget
class _BudgetItem extends StatelessWidget {
  final Budget budget;
  final BudgetStatus? status;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;

  const _BudgetItem({
    required this.budget,
    required this.status,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = status?.percentage ?? 0;
    final spent = status?.spent ?? 0;
    final remaining = status?.remaining ?? budget.limitAmount;

    Color progressColor;
    if (percentage >= 1.0) {
      progressColor = AppColors.error;
    } else if (percentage >= 0.8) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.success;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(categoryColor),
                  child: Icon(
                    IconHelper.getIcon(categoryIcon),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Anggaran: ${formatCurrency(budget.limitAmount)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditBudgetDialog(context, budget);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, budget);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terpakai',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      formatCurrency(spent),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sisa',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      formatCurrency(remaining),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: remaining >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (status?.isExceeded ?? false) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: AppColors.error, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Anggaran terlampaui!',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status?.isWarning ?? false) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info, color: AppColors.warning, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${formatPercentage(percentage)} terpakai',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddBudgetSheet(budget: budget),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anggaran'),
        content: const Text('Apakah Anda yakin ingin menghapus anggaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<BudgetProvider>().deleteBudget(budget.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anggaran dihapus')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

/// Add/Edit budget bottom sheet
class _AddBudgetSheet extends StatefulWidget {
  final Budget? budget;

  const _AddBudgetSheet({this.budget});

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  bool _notificationEnabled = true;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final b = widget.budget!;
      _amountController.text = b.limitAmount.toStringAsFixed(0);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Edit Anggaran' : 'Tambah Anggaran',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Category selector
            if (!_isEditing) ...[
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final expenseCategories = categoryProvider.expenseCategories;
                  final budgetProvider = context.read<BudgetProvider>();
                  final existingBudgetCategories =
                      budgetProvider.budgets.map((b) => b.categoryId).toSet();

                  // Filter out categories that already have budgets
                  final availableCategories = expenseCategories
                      .where((c) => !existingBudgetCategories.contains(c.id))
                      .toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      hintText: 'Pilih kategori',
                    ),
                    items: availableCategories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(category.colorValue),
                              child: Icon(
                                IconHelper.getIcon(category.iconName),
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // Amount input
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Batas Anggaran',
                prefixText: 'Rp ',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Notification toggle
            SwitchListTile(
              title: const Text('Notifikasi Peringatan'),
              subtitle: const Text('Peringatan saat 80% terpakai'),
              value: _notificationEnabled,
              onChanged: (value) {
                setState(() => _notificationEnabled = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBudget,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Anggaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBudget() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan batas anggaran')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batas anggaran harus lebih dari 0')),
      );
      return;
    }

    if (!_isEditing && _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Anggaran diperbarui' : 'Anggaran ditambahkan'),
      ),
    );
  }
}
