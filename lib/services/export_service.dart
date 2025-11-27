import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction.dart';
import '../models/category.dart';

/// Service for exporting financial reports
class ExportService {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Export transactions to CSV format
  Future<String> exportToCsv({
    required List<Transaction> transactions,
    required Map<String, Category> categoryMap,
    required int month,
    required int year,
  }) async {
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add(['Tanggal', 'Tipe', 'Kategori', 'Jumlah', 'Catatan']);

    // Sort transactions by date
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Data rows
    for (final transaction in sortedTransactions) {
      final category = categoryMap[transaction.categoryId];
      rows.add([
        _dateFormat.format(transaction.date),
        transaction.type == TransactionType.income
            ? 'Pemasukan'
            : 'Pengeluaran',
        category?.name ?? 'Unknown',
        transaction.amount,
        transaction.note ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(year, month));
    final fileName = 'laporan_${monthName}_$year.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);

    return file.path;
  }

  /// Export transactions to PDF format
  Future<String> exportToPdf({
    required List<Transaction> transactions,
    required Map<String, Category> categoryMap,
    required int month,
    required int year,
    required double cumulativeIncome,
    required double cumulativeExpense,
    required List<dynamic>
        budgetStatuses, // Using dynamic to avoid circular dependency if BudgetStatus is in provider
  }) async {
    final pdf = pw.Document();
    final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(year, month));

    // Calculate totals for current month
    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    // Sort transactions by date
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate category totals for expenses
    final Map<String, double> expenseCategoryTotals = {};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        expenseCategoryTotals[transaction.categoryId] =
            (expenseCategoryTotals[transaction.categoryId] ?? 0) +
                transaction.amount;
      }
    }

    // Calculate category totals for income
    final Map<String, double> incomeCategoryTotals = {};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        incomeCategoryTotals[transaction.categoryId] =
            (incomeCategoryTotals[transaction.categoryId] ?? 0) +
                transaction.amount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Title
            pw.Center(
              child: pw.Text(
                'Laporan Keuangan',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                '$monthName $year',
                style: const pw.TextStyle(fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 24),

            // Monthly Summary
            pw.Text(
              'Ringkasan Bulan Ini',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                      'Pemasukan', totalIncome, PdfColors.green700),
                  _buildSummaryItem(
                      'Pengeluaran', totalExpense, PdfColors.red700),
                  _buildSummaryItem(
                      'Saldo',
                      totalIncome - totalExpense,
                      (totalIncome - totalExpense) >= 0
                          ? PdfColors.blue700
                          : PdfColors.red700),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Cumulative Summary
            pw.Text(
              'Ringkasan Kumulatif (Sampai $monthName $year)',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                      'Total Pemasukan', cumulativeIncome, PdfColors.green700),
                  _buildSummaryItem(
                      'Total Pengeluaran', cumulativeExpense, PdfColors.red700),
                  _buildSummaryItem(
                      'Total Saldo',
                      cumulativeIncome - cumulativeExpense,
                      (cumulativeIncome - cumulativeExpense) >= 0
                          ? PdfColors.blue700
                          : PdfColors.red700),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Income Breakdown
            if (incomeCategoryTotals.isNotEmpty) ...[
              pw.Text(
                'Rincian Pemasukan per Kategori',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.green50),
                cellPadding: const pw.EdgeInsets.all(8),
                headers: ['Kategori', 'Jumlah', 'Persentase'],
                data: incomeCategoryTotals.entries.map((entry) {
                  final category = categoryMap[entry.key];
                  final percentage =
                      totalIncome > 0 ? (entry.value / totalIncome * 100) : 0;
                  return [
                    category?.name ?? 'Unknown',
                    _currencyFormat.format(entry.value),
                    '${percentage.toStringAsFixed(1)}%',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 24),
            ],

            // Expense Breakdown
            if (expenseCategoryTotals.isNotEmpty) ...[
              pw.Text(
                'Rincian Pengeluaran per Kategori',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.red50),
                cellPadding: const pw.EdgeInsets.all(8),
                headers: ['Kategori', 'Jumlah', 'Persentase'],
                data: expenseCategoryTotals.entries.map((entry) {
                  final category = categoryMap[entry.key];
                  final percentage =
                      totalExpense > 0 ? (entry.value / totalExpense * 100) : 0;
                  return [
                    category?.name ?? 'Unknown',
                    _currencyFormat.format(entry.value),
                    '${percentage.toStringAsFixed(1)}%',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 24),
            ],

            // Budget Realization
            if (budgetStatuses.isNotEmpty) ...[
              pw.Text(
                'Realisasi Anggaran',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.blue50),
                cellPadding: const pw.EdgeInsets.all(8),
                headers: ['Kategori', 'Anggaran', 'Terpakai', 'Sisa', 'Status'],
                data: budgetStatuses.map((status) {
                  // Accessing properties dynamically since we used dynamic type
                  final categoryId = status.budget.categoryId;
                  final category = categoryMap[categoryId];
                  final limit = status.budget.limitAmount;
                  final spent = status.spent;
                  final remaining = status.remaining;
                  final percentage = status.percentage * 100;

                  return [
                    category?.name ?? 'Unknown',
                    _currencyFormat.format(limit),
                    _currencyFormat.format(spent),
                    _currencyFormat.format(remaining),
                    '${percentage.toStringAsFixed(1)}%',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 24),
            ],

            // Transaction list
            pw.Text(
              'Daftar Transaksi',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
              cellPadding: const pw.EdgeInsets.all(6),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headers: ['Tanggal', 'Tipe', 'Kategori', 'Jumlah', 'Catatan'],
              data: sortedTransactions.map((t) {
                final category = categoryMap[t.categoryId];
                return [
                  DateFormat('dd/MM/yyyy').format(t.date),
                  t.type == TransactionType.income ? 'Masuk' : 'Keluar',
                  category?.name ?? 'Unknown',
                  _currencyFormat.format(t.amount),
                  t.note ?? '-',
                ];
              }).toList(),
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          );
        },
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'laporan_${monthName}_$year.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  pw.Widget _buildSummaryItem(String label, double value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 4),
        pw.Text(
          _currencyFormat.format(value),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
