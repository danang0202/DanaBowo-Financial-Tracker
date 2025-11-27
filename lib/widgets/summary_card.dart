import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

/// Summary card widget for displaying income/expense totals
class SummaryCard extends StatelessWidget {
  final String title;
  final double income;
  final double expense;

  const SummaryCard({
    super.key,
    required this.title,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: balance >= 0
                        ? AppColors.income.withOpacity(0.1)
                        : AppColors.expense.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        balance >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color:
                            balance >= 0 ? AppColors.income : AppColors.expense,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatCurrency(balance),
                        style: TextStyle(
                          color: balance >= 0
                              ? AppColors.income
                              : AppColors.expense,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _AmountRow(
                    icon: Icons.arrow_downward,
                    label: 'Pemasukan',
                    amount: income,
                    color: AppColors.income,
                    backgroundColor: AppColors.income.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AmountRow(
                    icon: Icons.arrow_upward,
                    label: 'Pengeluaran',
                    amount: expense,
                    color: AppColors.expense,
                    backgroundColor: AppColors.expense.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final Color backgroundColor;

  const _AmountRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          formatCurrency(amount),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
