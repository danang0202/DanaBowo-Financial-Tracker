import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../services/export_service.dart';
import '../utils/formatters.dart';

/// Export screen for generating reports
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isExporting = false;

  final ExportService _exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Laporan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Periode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Month selector
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedMonth,
                            decoration: const InputDecoration(
                              labelText: 'Bulan',
                            ),
                            items: List.generate(12, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text(getMonthName(index + 1)),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedMonth = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Year selector
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Tahun',
                            ),
                            items: List.generate(5, (index) {
                              final year = DateTime.now().year - index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export options
            Text(
              'Format Export',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // CSV export
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.table_chart, color: Colors.white),
                ),
                title: const Text('CSV'),
                subtitle: const Text('Data mentah untuk spreadsheet'),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap: _isExporting ? null : () => _exportCsv(),
              ),
            ),
            const SizedBox(height: 8),

            // PDF export
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.picture_as_pdf, color: Colors.white),
                ),
                title: const Text('PDF'),
                subtitle: const Text('Laporan lengkap dengan grafik'),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap: _isExporting ? null : () => _exportPdf(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);

    try {
      final transactionProvider = context.read<TransactionProvider>();
      final categoryProvider = context.read<CategoryProvider>();

      final transactions = transactionProvider.getTransactionsByMonth(
        _selectedMonth,
        _selectedYear,
      );

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak ada transaksi untuk periode ini')),
        );
        return;
      }

      final filePath = await _exportService.exportToCsv(
        transactions: transactions,
        categoryMap: categoryProvider.categoryMap,
        month: _selectedMonth,
        year: _selectedYear,
      );

      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'Laporan Keuangan');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export: $e')),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);

    try {
      final transactionProvider = context.read<TransactionProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      final transactions = transactionProvider.getTransactionsByMonth(
        _selectedMonth,
        _selectedYear,
      );

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak ada transaksi untuk periode ini')),
        );
        return;
      }

      // Calculate cumulative totals
      final cumulativeTransactions = transactionProvider.getTransactionsUpTo(
        _selectedMonth,
        _selectedYear,
      );

      final cumulativeIncome =
          transactionProvider.calculateTotalIncome(cumulativeTransactions);
      final cumulativeExpense =
          transactionProvider.calculateTotalExpense(cumulativeTransactions);

      // Get budget statuses
      final budgetStatuses = budgetProvider.getAllBudgetStatuses(transactions);

      final filePath = await _exportService.exportToPdf(
        transactions: transactions,
        categoryMap: categoryProvider.categoryMap,
        month: _selectedMonth,
        year: _selectedYear,
        cumulativeIncome: cumulativeIncome,
        cumulativeExpense: cumulativeExpense,
        budgetStatuses: budgetStatuses,
      );

      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'Laporan Keuangan');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export: $e')),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }
}
