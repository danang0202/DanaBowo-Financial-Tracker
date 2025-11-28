import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

enum TrendPeriod { month, year }

class TrendChart extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime startDate;
  final DateTime endDate;
  final TrendPeriod period;
  final ValueChanged<TrendPeriod> onPeriodChanged;

  const TrendChart({
    super.key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  List<Map<String, dynamic>> _chartData = [];
  double _maxY = 0;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant TrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.period != widget.period) {
      _processData();
    }
  }

  void _processData() {
    _chartData = [];
    _maxY = 0;

    if (widget.period == TrendPeriod.month) {
      _processMonthlyData();
    } else {
      _processYearlyData();
    }

    // Add some padding to maxY
    _maxY = _maxY * 1.2;
    if (_maxY == 0) _maxY = 100; // Default scale if no data
  }

  void _processMonthlyData() {
    final days = widget.endDate.difference(widget.startDate).inDays + 1;

    for (int i = 0; i < days; i++) {
      final date = widget.startDate.add(Duration(days: i));
      final dayTransactions = widget.transactions.where((t) {
        return t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day;
      }).toList();

      _calculateAndAddDataPoint(dayTransactions, date);
    }
  }

  void _processYearlyData() {
    for (int i = 1; i <= 12; i++) {
      final date = DateTime(widget.startDate.year, i, 1);
      final monthTransactions = widget.transactions.where((t) {
        return t.date.year == widget.startDate.year && t.date.month == i;
      }).toList();

      _calculateAndAddDataPoint(monthTransactions, date);
    }
  }

  void _calculateAndAddDataPoint(
      List<Transaction> transactions, DateTime date) {
    double income = 0;
    double expense = 0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    if (income > _maxY) _maxY = income;
    if (expense > _maxY) _maxY = expense;

    _chartData.add({
      'date': date,
      'income': income,
      'expense': expense,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Keuangan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PeriodButton(
                      label: 'Bulan',
                      isSelected: widget.period == TrendPeriod.month,
                      onTap: () => widget.onPeriodChanged(TrendPeriod.month),
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                    _PeriodButton(
                      label: 'Tahun',
                      isSelected: widget.period == TrendPeriod.year,
                      onTap: () => widget.onPeriodChanged(TrendPeriod.year),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendItem(color: AppColors.income, label: 'Masuk'),
              const SizedBox(width: 12),
              _LegendItem(color: AppColors.expense, label: 'Keluar'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: widget.period == TrendPeriod.month
                          ? (_chartData.length / 5).ceil().toDouble()
                          : 2, // Show every 2 months for yearly view
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _chartData.length) {
                          final date = _chartData[index]['date'] as DateTime;
                          String text;
                          if (widget.period == TrendPeriod.month) {
                            text = DateFormat('d').format(date);
                          } else {
                            text = DateFormat('MMM').format(date);
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              text,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: _chartData.length.toDouble() - 1,
                minY: 0,
                maxY: _maxY,
                lineBarsData: [
                  // Income Line
                  LineChartBarData(
                    spots: List.generate(_chartData.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        _chartData[index]['income'],
                      );
                    }),
                    isCurved: true,
                    color: AppColors.income,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.income.withOpacity(0.1),
                    ),
                  ),
                  // Expense Line
                  LineChartBarData(
                    spots: List.generate(_chartData.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        _chartData[index]['expense'],
                      );
                    }),
                    isCurved: true,
                    color: AppColors.expense,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.expense.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        Theme.of(context).cardColor,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipBorder: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isIncome = spot.barIndex == 0;
                        final index = spot.x.toInt();
                        final date = _chartData[index]['date'] as DateTime;
                        String dateStr;
                        if (widget.period == TrendPeriod.month) {
                          dateStr = DateFormat('d MMM').format(date);
                        } else {
                          dateStr = DateFormat('MMMM').format(date);
                        }

                        return LineTooltipItem(
                          '$dateStr\n${formatCurrency(spot.y)}',
                          TextStyle(
                            color:
                                isIncome ? AppColors.income : AppColors.expense,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
