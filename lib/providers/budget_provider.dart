import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

/// Budget status
class BudgetStatus {
  final Budget budget;
  final double spent;
  final double remaining;
  final double percentage;
  final bool isWarning;
  final bool isExceeded;

  BudgetStatus({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.isWarning,
    required this.isExceeded,
  });
}

/// Provider for managing budgets
class BudgetProvider with ChangeNotifier {
  final StorageService _storageService;
  List<Budget> _budgets = [];
  final Uuid _uuid = const Uuid();

  BudgetProvider(this._storageService) {
    _loadBudgets();
  }

  List<Budget> get budgets => _budgets;

  /// Load budgets from storage
  void _loadBudgets() {
    _budgets = _storageService.getAllBudgets();
    notifyListeners();
  }

  /// Add a new budget
  Future<void> addBudget({
    required String categoryId,
    required double limitAmount,
    BudgetPeriod period = BudgetPeriod.monthly,
    bool notificationEnabled = true,
    double notificationThreshold = 0.8,
  }) async {
    final budget = Budget(
      id: _uuid.v4(),
      categoryId: categoryId,
      limitAmount: limitAmount,
      period: period,
      startDate: DateTime.now(),
      notificationEnabled: notificationEnabled,
      notificationThreshold: notificationThreshold,
    );

    await _storageService.addBudget(budget);
    _loadBudgets();
  }

  /// Update an existing budget
  Future<void> updateBudget(Budget budget) async {
    await _storageService.updateBudget(budget);
    _loadBudgets();
  }

  /// Delete a budget
  Future<void> deleteBudget(String id) async {
    await _storageService.deleteBudget(id);
    _loadBudgets();
  }

  /// Get budget by category ID
  Budget? getBudgetByCategory(String categoryId) {
    try {
      return _budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Calculate budget status for a category
  BudgetStatus? calculateBudgetStatus(
      String categoryId, List<Transaction> monthTransactions) {
    final budget = getBudgetByCategory(categoryId);
    if (budget == null) return null;

    final spent = monthTransactions
        .where((t) =>
            t.type == TransactionType.expense && t.categoryId == categoryId)
        .fold(0.0, (sum, t) => sum + t.amount);

    final remaining = budget.limitAmount - spent;
    final percentage = budget.limitAmount > 0 ? spent / budget.limitAmount : 0.0;
    final isWarning = percentage >= budget.notificationThreshold &&
        percentage < 1.0 &&
        budget.notificationEnabled;
    final isExceeded = percentage >= 1.0;

    return BudgetStatus(
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      isWarning: isWarning,
      isExceeded: isExceeded,
    );
  }

  /// Get all budget statuses for current month
  List<BudgetStatus> getAllBudgetStatuses(List<Transaction> monthTransactions) {
    final List<BudgetStatus> statuses = [];

    for (final budget in _budgets) {
      final status = calculateBudgetStatus(budget.categoryId, monthTransactions);
      if (status != null) {
        statuses.add(status);
      }
    }

    return statuses;
  }

  /// Get warning budgets
  List<BudgetStatus> getWarningBudgets(List<Transaction> monthTransactions) {
    return getAllBudgetStatuses(monthTransactions)
        .where((s) => s.isWarning || s.isExceeded)
        .toList();
  }
}
