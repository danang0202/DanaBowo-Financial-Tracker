import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import '../utils/icon_helper.dart';

/// Transaction list item widget
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category icon
              CircleAvatar(
                backgroundColor: category != null
                    ? Color(category!.colorValue).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                child: Icon(
                  category != null
                      ? IconHelper.getIcon(category!.iconName)
                      : Icons.category,
                  color: category != null
                      ? Color(category!.colorValue)
                      : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (transaction.note != null && transaction.note!.isNotEmpty)
                      Text(
                        transaction.note!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      formatDateTime(transaction.date),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} ${formatCurrency(transaction.amount)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: color,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
