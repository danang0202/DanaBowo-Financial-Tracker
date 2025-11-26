import 'package:flutter/material.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import '../utils/icon_helper.dart';

/// Budget warning card widget
class BudgetWarningCard extends StatelessWidget {
  final BudgetStatus status;
  final CategoryProvider categoryProvider;

  const BudgetWarningCard({
    super.key,
    required this.status,
    required this.categoryProvider,
  });

  @override
  Widget build(BuildContext context) {
    final category = categoryProvider.getCategoryById(status.budget.categoryId);
    final isExceeded = status.isExceeded;

    return Card(
      color: isExceeded
          ? AppColors.error.withOpacity(0.1)
          : AppColors.warning.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isExceeded ? Icons.error : Icons.warning,
              color: isExceeded ? AppColors.error : AppColors.warning,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (category != null)
                        Icon(
                          IconHelper.getIcon(category.iconName),
                          size: 16,
                          color: Color(category.colorValue),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        category?.name ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isExceeded
                        ? 'Anggaran terlampaui! (${formatPercentage(status.percentage)})'
                        : '${formatPercentage(status.percentage)} dari anggaran terpakai',
                    style: TextStyle(
                      fontSize: 12,
                      color: isExceeded ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${formatCurrency(status.spent)} / ${formatCurrency(status.budget.limitAmount)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
