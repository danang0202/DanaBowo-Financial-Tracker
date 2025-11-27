import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

/// Provider for managing transactions
class TransactionProvider with ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  // All transactions sorted by date (Source of Truth)
  List<Transaction> _allTransactions = [];

  // Transactions currently displayed in the UI (Paginated)
  List<Transaction> _displayedTransactions = [];

  // Pagination state
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  TransactionProvider(this._storageService) {
    _loadTransactions();
  }

  List<Transaction> get transactions => _displayedTransactions;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  /// Load all transactions from storage and initialize pagination
  void _loadTransactions() {
    _allTransactions = _storageService.getAllTransactions();
    _allTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Reset pagination
    _currentPage = 0;
    _hasMore = true;
    _displayedTransactions = [];

    // Load first page
    _loadNextPage();
  }

  /// Load the next page of transactions
  void loadMore() {
    if (_isLoading || !_hasMore) return;
    _loadNextPage();
  }

  void _loadNextPage() {
    _isLoading = true;
    notifyListeners();

    // Simulate a small delay for better UX (optional, but good for showing loader)
    // In a real local app, this is instant, but we want to ensure the UI updates
    Future.delayed(const Duration(milliseconds: 500), () {
      final startIndex = _currentPage * _pageSize;

      if (startIndex >= _allTransactions.length) {
        _hasMore = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final endIndex = (startIndex + _pageSize) < _allTransactions.length
          ? (startIndex + _pageSize)
          : _allTransactions.length;

      final nextChunk = _allTransactions.sublist(startIndex, endIndex);
      _displayedTransactions.addAll(nextChunk);

      _currentPage++;
      _hasMore = endIndex < _allTransactions.length;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Filter transactions (Search)
  void filterTransactions(bool Function(Transaction) predicate) {
    // Filter from all transactions
    _displayedTransactions = _allTransactions.where(predicate).toList();

    _hasMore = false; // Disable pagination for filtered results
    notifyListeners();
  }

  /// Clear filter and reset to pagination
  void clearFilter() {
    _currentPage = 0;
    _displayedTransactions = [];
    _hasMore = true;
    _loadNextPage();
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
    _loadTransactions(); // Reload and reset pagination
  }

  /// Update an existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _storageService.updateTransaction(transaction);
    _loadTransactions(); // Reload and reset pagination
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _storageService.deleteTransaction(id);
    _loadTransactions(); // Reload and reset pagination
  }

  /// Get transactions for today (Helper for Dashboard, not paginated)
  List<Transaction> getTodayTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _allTransactions.where((t) {
      return t.date.isAfter(today.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(tomorrow);
    }).toList();
  }

  /// Get transactions for this week (Helper for Dashboard)
  List<Transaction> getThisWeekTransactions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    return _allTransactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end);
    }).toList();
  }

  /// Get transactions for this month (Helper for Dashboard)
  List<Transaction> getThisMonthTransactions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    return _allTransactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end);
    }).toList();
  }

  /// Get transactions by month and year
  List<Transaction> getTransactionsByMonth(int month, int year) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    return _allTransactions.where((t) {
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
    final income = calculateTotalIncome(_allTransactions);
    final expense = calculateTotalExpense(_allTransactions);
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

  /// Get transactions for a specific date
  List<Transaction> getTransactionsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final nextDay = targetDate.add(const Duration(days: 1));

    return _allTransactions.where((t) {
      return t.date.isAfter(targetDate.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(nextDay);
    }).toList();
  }

  /// Refresh transactions from storage
  void refresh() {
    _loadTransactions();
  }
}
