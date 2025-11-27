import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/category.dart' as models;
import '../models/budget.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/expense_chart.dart';
import '../widgets/budget_warning_card.dart';
import 'add_transaction_screen.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';
import 'budgets_screen.dart';
import 'settings_screen.dart';
import 'export_screen.dart';

/// Main dashboard screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  /// Build FloatingActionButton based on current tab
  Widget? _buildFloatingActionButton(BuildContext context) {
    switch (_currentIndex) {
      case 0: // Home
      case 1: // Transactions
        return FloatingActionButton.extended(
          heroTag: "add_transaction",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Transaksi'),
        );
      case 2: // Categories
        return FloatingActionButton.extended(
          heroTag: "add_category",
          onPressed: () {
            _showAddCategoryDialog(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Kategori'),
        );
      case 3: // Budgets
        return FloatingActionButton.extended(
          heroTag: "add_budget",
          onPressed: () {
            _showAddBudgetDialog(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Anggaran'),
        );
      case 4: // Settings
        return null; // No FAB for settings
      default:
        return null;
    }
  }

  /// Show add category dialog
  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddCategoryDialog(),
    );
  }

  /// Show add budget dialog  
  void _showAddBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddBudgetDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          TransactionsScreen(),
          CategoriesScreen(),
          BudgetsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Kategori',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Anggaran',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }
}

/// Home tab content
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danabowo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportScreen()),
              );
            },
            tooltip: 'Export Laporan',
          ),
        ],
      ),
      body: Consumer3<TransactionProvider, CategoryProvider, BudgetProvider>(
        builder: (context, transactionProvider, categoryProvider, budgetProvider, child) {
          final todayTransactions = transactionProvider.getTodayTransactions();
          final weekTransactions = transactionProvider.getThisWeekTransactions();
          final monthTransactions = transactionProvider.getThisMonthTransactions();

          final todayIncome = transactionProvider.calculateTotalIncome(todayTransactions);
          final todayExpense = transactionProvider.calculateTotalExpense(todayTransactions);
          final weekIncome = transactionProvider.calculateTotalIncome(weekTransactions);
          final weekExpense = transactionProvider.calculateTotalExpense(weekTransactions);
          final monthIncome = transactionProvider.calculateTotalIncome(monthTransactions);
          final monthExpense = transactionProvider.calculateTotalExpense(monthTransactions);

          final expenseByCategory = transactionProvider.getExpenseByCategory(monthTransactions);
          final warningBudgets = budgetProvider.getWarningBudgets(monthTransactions);
          final recentTransactions = transactionProvider.transactions.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh data
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  _BalanceCard(balance: transactionProvider.totalBalance),
                  const SizedBox(height: 16),

                  // Budget warnings
                  if (warningBudgets.isNotEmpty) ...[
                    Text(
                      'Peringatan Anggaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...warningBudgets.map((status) => BudgetWarningCard(
                          status: status,
                          categoryProvider: categoryProvider,
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Summary cards
                  Text(
                    'Ringkasan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SummaryCard(
                    title: 'Hari Ini',
                    income: todayIncome,
                    expense: todayExpense,
                  ),
                  const SizedBox(height: 8),
                  SummaryCard(
                    title: 'Minggu Ini',
                    income: weekIncome,
                    expense: weekExpense,
                  ),
                  const SizedBox(height: 8),
                  SummaryCard(
                    title: 'Bulan Ini',
                    income: monthIncome,
                    expense: monthExpense,
                  ),
                  const SizedBox(height: 24),

                  // Expense chart
                  if (expenseByCategory.isNotEmpty) ...[
                    Text(
                      'Pengeluaran Bulan Ini',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ExpenseChart(
                      expenseByCategory: expenseByCategory,
                      categoryProvider: categoryProvider,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recent transactions
                  Text(
                    'Transaksi Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (recentTransactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Belum ada transaksi',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...recentTransactions.map(
                      (transaction) => TransactionListItem(
                        transaction: transaction,
                        category: categoryProvider.getCategoryById(transaction.categoryId),
                      ),
                    ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Balance card widget
class _BalanceCard extends StatelessWidget {
  final double balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo Saat Ini',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add Category Dialog
class _AddCategoryDialog extends StatefulWidget {
  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  models.CategoryType _selectedType = models.CategoryType.expense;
  String _selectedIcon = 'category';
  Color _selectedColor = AppColors.primary;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Kategori'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  hintText: 'Contoh: Makanan',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kategori harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Type selector
              const Text('Tipe Kategori'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<models.CategoryType>(
                      title: const Text('Pemasukan'),
                      value: models.CategoryType.income,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<models.CategoryType>(
                      title: const Text('Pengeluaran'),
                      value: models.CategoryType.expense,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Color selector
              const Text('Warna'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoryColors.colors.map((color) {
                  final isSelected = _selectedColor.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saveCategory,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final categoryProvider = context.read<CategoryProvider>();
      
      await categoryProvider.addCategory(
        name: _nameController.text.trim(),
        type: _selectedType,
        iconName: _selectedIcon,
        colorValue: _selectedColor.value,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan kategori: ${e.toString()}')),
        );
      }
    }
  }
}

/// Add Budget Dialog
class _AddBudgetDialog extends StatefulWidget {
  @override
  State<_AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<_AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Anggaran'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category selector
              Consumer2<CategoryProvider, BudgetProvider>(
                builder: (context, categoryProvider, budgetProvider, child) {
                  final expenseCategories = categoryProvider.expenseCategories;
                  final existingBudgetCategories = budgetProvider.budgets
                      .map((b) => b.categoryId)
                      .toSet();
                  
                  final availableCategories = expenseCategories
                      .where((c) => !existingBudgetCategories.contains(c.id))
                      .toList();

                  if (availableCategories.isEmpty) {
                    return const Text(
                      'Semua kategori sudah memiliki anggaran',
                      style: TextStyle(color: Colors.orange),
                    );
                  }

                  // Ensure selected category is still available
                  final validSelectedCategoryId = _selectedCategoryId != null &&
                          availableCategories.any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null;

                  return DropdownButtonFormField<String>(
                    value: validSelectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      hintText: 'Pilih kategori',
                    ),
                    items: availableCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(category.colorValue),
                              child: Icon(
                                Icons.category,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih kategori';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Limit amount
              TextFormField(
                controller: _limitController,
                decoration: const InputDecoration(
                  labelText: 'Batas Anggaran',
                  prefixText: 'Rp ',
                  hintText: '1000000',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan batas anggaran';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Batas anggaran harus lebih dari 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saveBudget,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
        );
      }
      return;
    }

    try {
      final budgetProvider = context.read<BudgetProvider>();
      final limitAmount = double.tryParse(_limitController.text);
      
      if (limitAmount == null || limitAmount <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Masukkan jumlah anggaran yang valid')),
          );
        }
        return;
      }

      await budgetProvider.addBudget(
        categoryId: _selectedCategoryId!,
        limitAmount: limitAmount,
        period: BudgetPeriod.monthly,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggaran berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan anggaran: ${e.toString()}')),
        );
      }
    }
  }
}
