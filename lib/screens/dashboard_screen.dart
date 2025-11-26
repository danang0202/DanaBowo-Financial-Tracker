import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
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
      floatingActionButton: FloatingActionButton.extended(
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
      ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terbaru',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to transactions tab
                        },
                        child: const Text('Lihat Semua'),
                      ),
                    ],
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
