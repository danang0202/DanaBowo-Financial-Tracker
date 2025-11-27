import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/category_provider.dart';

/// Income chart widget showing income by category
class IncomeChart extends StatefulWidget {
  final Map<String, double> incomeByCategory;
  final CategoryProvider categoryProvider;

  const IncomeChart({
    super.key,
    required this.incomeByCategory,
    required this.categoryProvider,
  });

  @override
  State<IncomeChart> createState() => _IncomeChartState();
}

class _IncomeChartState extends State<IncomeChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.incomeByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = widget.incomeByCategory.values.fold(0.0, (a, b) => a + b);

    // Sort by amount descending
    final sortedEntries = widget.incomeByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie chart
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _generateSections(sortedEntries, total),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: sortedEntries.take(6).map((entry) {
                final category =
                    widget.categoryProvider.getCategoryById(entry.key);
                final percentage =
                    (entry.value / total * 100).toStringAsFixed(1);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: category != null
                            ? Color(category.colorValue)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${category?.name ?? 'Unknown'} ($percentage%)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections(
    List<MapEntry<String, double>> entries,
    double total,
  ) {
    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final category = widget.categoryProvider.getCategoryById(entry.key);
      final isTouched = index == _touchedIndex;
      final percentage = entry.value / total * 100;

      return PieChartSectionData(
        color: category != null ? Color(category.colorValue) : Colors.grey,
        value: entry.value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}
