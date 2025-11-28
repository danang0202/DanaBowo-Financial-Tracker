import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/budget_provider.dart';
import '../../utils/constants.dart';
import '../summary_card.dart';
import '../transaction_list_item.dart';
import '../expense_chart.dart';
import '../income_chart.dart';
import '../budget_warning_card.dart';
import '../../screens/add_transaction_screen.dart';
import '../../screens/export_screen.dart';
import 'dashboard_balance_card.dart';

/// Home tab content for dashboard
class DashboardHomeTab extends StatelessWidget {
  const DashboardHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer3<TransactionProvider, CategoryProvider, BudgetProvider>(
        builder: (context, transactionProvider, categoryProvider,
            budgetProvider, child) {
          final todayTransactions = transactionProvider.getTodayTransactions();
          final weekTransactions =
              transactionProvider.getThisWeekTransactions();
          final monthTransactions =
              transactionProvider.getThisMonthTransactions();

          final todayIncome =
              transactionProvider.calculateTotalIncome(todayTransactions);
          final todayExpense =
              transactionProvider.calculateTotalExpense(todayTransactions);
          final weekIncome =
              transactionProvider.calculateTotalIncome(weekTransactions);
          final weekExpense =
              transactionProvider.calculateTotalExpense(weekTransactions);
          final monthIncome =
              transactionProvider.calculateTotalIncome(monthTransactions);
          final monthExpense =
              transactionProvider.calculateTotalExpense(monthTransactions);

          final expenseByCategory =
              transactionProvider.getExpenseByCategory(monthTransactions);
          final incomeByCategory =
              transactionProvider.getIncomeByCategory(monthTransactions);
          final warningBudgets =
              budgetProvider.getWarningBudgets(monthTransactions);
          final recentTransactions =
              transactionProvider.transactions.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh data
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance Card
                        DashboardBalanceCard(
                            balance: transactionProvider.totalBalance),
                        const SizedBox(height: 16),

                        // Budget warnings
                        if (warningBudgets.isNotEmpty) ...[
                          _buildSectionTitle(context, 'Peringatan Anggaran'),
                          const SizedBox(height: 8),
                          ...warningBudgets.map((status) => BudgetWarningCard(
                                status: status,
                                categoryProvider: categoryProvider,
                              )),
                          const SizedBox(height: 16),
                        ],

                        // Summary cards
                        _buildSectionTitle(context, 'Ringkasan'),
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

                        // Income chart
                        if (incomeByCategory.isNotEmpty) ...[
                          _buildSectionTitle(context, 'Pemasukan Bulan Ini'),
                          const SizedBox(height: 8),
                          IncomeChart(
                            incomeByCategory: incomeByCategory,
                            categoryProvider: categoryProvider,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Expense chart
                        if (expenseByCategory.isNotEmpty) ...[
                          _buildSectionTitle(context, 'Pengeluaran Bulan Ini'),
                          const SizedBox(height: 8),
                          ExpenseChart(
                            expenseByCategory: expenseByCategory,
                            categoryProvider: categoryProvider,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Recent transactions
                        _buildSectionTitle(context, 'Transaksi Terbaru'),
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
                              category: categoryProvider
                                  .getCategoryById(transaction.categoryId),
                            ),
                          ),
                        const SizedBox(height: 120), // Space for Bottom Nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/icon.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'DanaKu',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.05),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportScreen()),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: const Icon(
                Icons.file_download_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
