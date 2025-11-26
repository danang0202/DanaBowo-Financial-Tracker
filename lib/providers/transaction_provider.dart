import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

/// Provider for managing transactions
class TransactionProvider with ChangeNotifier {
  final StorageService _storageService;
  List<Transaction> _transactions = [];
  final Uuid _uuid = const Uuid();

  TransactionProvider(this._storageService) {
    _loadTransactions();
  }

  List<Transaction> get transactions => _transactions;

  /// Load transactions from storage
  void _loadTransactions() {
    _transactions = _storageService.getAllTransactions();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// Add a new transaction
  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    final transaction = Transaction(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
    );

    await _storageService.addTransaction(transaction);
    _loadTransactions();
  }

  /// Update an existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _storageService.updateTransaction(transaction);
    _loadTransactions();
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _storageService.deleteTransaction(id);
    _loadTransactions();
  }

  /// Get transactions for today
  List<Transaction> getTodayTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _transactions.where((t) {
      return t.date.isAfter(today.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(tomorrow);
    }).toList();
  }

  /// Get transactions for this week
  List<Transaction> getThisWeekTransactions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end);
    }).toList();
  }

  /// Get transactions for this month
  List<Transaction> getThisMonthTransactions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end);
    }).toList();
  }

  /// Get transactions by month and year
  List<Transaction> getTransactionsByMonth(int month, int year) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end);
    }).toList();
  }

  /// Calculate total income for a list of transactions
  double calculateTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expense for a list of transactions
  double calculateTotalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate balance
  double get totalBalance {
    final income = calculateTotalIncome(_transactions);
    final expense = calculateTotalExpense(_transactions);
    return income - expense;
  }

  /// Get expense by category for a list of transactions
  Map<String, double> getExpenseByCategory(List<Transaction> transactions) {
    final Map<String, double> result = {};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        result[transaction.categoryId] =
            (result[transaction.categoryId] ?? 0) + transaction.amount;
      }
    }

    return result;
  }

  /// Refresh transactions from storage
  void refresh() {
    _loadTransactions();
  }
}
