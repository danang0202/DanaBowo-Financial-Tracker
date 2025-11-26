import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';

/// Service for managing local storage using Hive
class StorageService {
  static const String transactionBoxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String budgetBoxName = 'budgets';
  static const String settingsBoxName = 'settings';

  late Box<Transaction> _transactionBox;
  late Box<Category> _categoryBox;
  late Box<Budget> _budgetBox;
  late Box<dynamic> _settingsBox;

  /// Initialize Hive and register adapters
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(BudgetAdapter());

    // Open boxes
    _transactionBox = await Hive.openBox<Transaction>(transactionBoxName);
    _categoryBox = await Hive.openBox<Category>(categoryBoxName);
    _budgetBox = await Hive.openBox<Budget>(budgetBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    // Initialize default categories if empty
    if (_categoryBox.isEmpty) {
      await _initializeDefaultCategories();
    }
  }

  /// Initialize default categories
  Future<void> _initializeDefaultCategories() async {
    final defaultCategories = DefaultCategories.getDefaultCategories();
    for (final category in defaultCategories) {
      await _categoryBox.put(category.id, category);
    }
  }

  // Transaction operations
  Box<Transaction> get transactionBox => _transactionBox;

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
    // Update category usage count
    final category = _categoryBox.get(transaction.categoryId);
    if (category != null) {
      category.usageCount++;
      await category.save();
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }

  List<Transaction> getAllTransactions() {
    return _transactionBox.values.toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactionBox.values.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactionBox.values
        .where((t) => t.categoryId == categoryId)
        .toList();
  }

  // Category operations
  Box<Category> get categoryBox => _categoryBox;

  Future<void> addCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> updateCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
  }

  List<Category> getAllCategories() {
    return _categoryBox.values.toList();
  }

  List<Category> getCategoriesByType(CategoryType type) {
    return _categoryBox.values.where((c) => c.type == type).toList();
  }

  Category? getCategoryById(String id) {
    return _categoryBox.get(id);
  }

  // Budget operations
  Box<Budget> get budgetBox => _budgetBox;

  Future<void> addBudget(Budget budget) async {
    await _budgetBox.put(budget.id, budget);
  }

  Future<void> updateBudget(Budget budget) async {
    await _budgetBox.put(budget.id, budget);
  }

  Future<void> deleteBudget(String id) async {
    await _budgetBox.delete(id);
  }

  List<Budget> getAllBudgets() {
    return _budgetBox.values.toList();
  }

  Budget? getBudgetByCategory(String categoryId) {
    try {
      return _budgetBox.values.firstWhere((b) => b.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Settings operations
  Box<dynamic> get settingsBox => _settingsBox;

  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _transactionBox.clear();
    await _categoryBox.clear();
    await _budgetBox.clear();
    await _initializeDefaultCategories();
  }
}
