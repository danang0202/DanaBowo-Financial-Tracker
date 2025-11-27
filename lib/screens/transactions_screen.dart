import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/transaction_list_item.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import '../models/transaction.dart';

import 'add_transaction_screen.dart';

/// Screen for displaying all transactions
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _viewEndDate = DateTime.now();
  final ScrollController _dateScrollController = ScrollController();

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      // Ensure view contains selected date
      if (date.isAfter(_viewEndDate)) {
        _viewEndDate = date;
      } else if (date
          .isBefore(_viewEndDate.subtract(const Duration(days: 4)))) {
        _viewEndDate = date.add(const Duration(days: 4));
      }
    });
  }

  void _selectDate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: Theme.of(context).scaffoldBackgroundColor,
                      onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    onDateChanged: (date) {
                      Navigator.pop(context);
                      _onDateSelected(date);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _onDateSelected(DateTime.now());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Hari Ini',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight:
                  190.0, // Increased height to accommodate title and date strip
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                    left: 16,
                    bottom: 96), // Adjusted padding to sit above date strip
                title: Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          setState(() {
                            _viewEndDate =
                                _viewEndDate.subtract(const Duration(days: 1));
                            // If the selected date is no longer in view, adjust it
                            final DateTime viewStartDate =
                                _viewEndDate.subtract(const Duration(days: 4));
                            if (_selectedDate.isBefore(viewStartDate)) {
                              _selectedDate = viewStartDate;
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            final date = _viewEndDate
                                .subtract(Duration(days: 4 - index));
                            final isSelected =
                                DateUtils.isSameDay(date, _selectedDate);

                            return GestureDetector(
                              onTap: () {
                                _onDateSelected(date);
                              },
                              child: Container(
                                width: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.4)
                                          : Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateUtils.isSameDay(date, DateTime.now())
                                          ? 'Hari ini'
                                          : DateFormat('E', 'id_ID')
                                              .format(date),
                                      style: TextStyle(
                                        fontSize: DateUtils.isSameDay(
                                                date, DateTime.now())
                                            ? 9
                                            : 10,
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: DateUtils.isSameDay(
                                _viewEndDate, DateTime.now())
                            ? null
                            : () {
                                setState(() {
                                  _viewEndDate =
                                      _viewEndDate.add(const Duration(days: 1));
                                  // If the selected date is no longer in view, adjust it
                                  final DateTime viewEndDate = _viewEndDate;
                                  if (_selectedDate.isAfter(viewEndDate)) {
                                    _selectedDate = viewEndDate;
                                  }
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_month_rounded),
                  tooltip: 'Pilih Tanggal',
                  onPressed: () => _selectDate(context),
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
            ),
          ];
        },
        body: Consumer2<TransactionProvider, CategoryProvider>(
          builder: (context, transactionProvider, categoryProvider, child) {
            final transactions =
                transactionProvider.getTransactionsForDate(_selectedDate);

            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada transaksi pada tanggal ini',
                      style: TextStyle(
                        color: Theme.of(context).disabledColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Calculate daily summary
            double dailyIncome = 0;
            double dailyExpense = 0;
            for (var t in transactions) {
              if (t.type == TransactionType.income) {
                dailyIncome += t.amount;
              } else {
                dailyExpense += t.amount;
              }
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              children: [
                // Daily Summary Card
                Container(
                  margin: const EdgeInsets.only(bottom: 24, top: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(dailyIncome),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.income,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).dividerColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(dailyExpense),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Transaction List
                ...transactions.map((transaction) {
                  return TransactionListItem(
                    transaction: transaction,
                    category: categoryProvider
                        .getCategoryById(transaction.categoryId),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTransactionScreen(
                            transaction: transaction,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
