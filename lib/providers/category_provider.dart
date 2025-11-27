import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart' as models;
import '../services/storage_service.dart';

/// Sort type for categories
enum CategorySortType {
  alphabetical,
  usageFrequency,
}

/// Provider for managing categories
class CategoryProvider with ChangeNotifier {
  final StorageService _storageService;
  List<models.Category> _categories = <models.Category>[];
  CategorySortType _sortType = CategorySortType.usageFrequency;
  final Uuid _uuid = const Uuid();

  CategoryProvider(this._storageService) {
    _loadCategories();
  }

  List<models.Category> get categories => _categories;
  CategorySortType get sortType => _sortType;

  /// Load categories from storage
  void _loadCategories() {
    _categories = _storageService.getAllCategories();
    _sortCategories();
    notifyListeners();
  }

  /// Sort categories based on current sort type
  void _sortCategories() {
    switch (_sortType) {
      case CategorySortType.alphabetical:
        _categories.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CategorySortType.usageFrequency:
        _categories.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
    }
  }

  /// Set sort type
  void setSortType(CategorySortType type) {
    _sortType = type;
    _sortCategories();
    notifyListeners();
  }

  /// Add a new category
  Future<void> addCategory({
    required String name,
    required models.CategoryType type,
    String? iconName,
    int? colorValue,
  }) async {
    final category = models.Category(
      id: _uuid.v4(),
      name: name,
      type: type,
      iconName: iconName ?? 'category',
      colorValue: colorValue ?? 0xFF2196F3,
    );

    await _storageService.addCategory(category);
    _loadCategories();
  }

  /// Update an existing category
  Future<void> updateCategory(models.Category category) async {
    await _storageService.updateCategory(category);
    _loadCategories();
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    await _storageService.deleteCategory(id);
    _loadCategories();
  }

  /// Get categories by type
  List<models.Category> getCategoriesByType(models.CategoryType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  /// Get income categories
  List<models.Category> get incomeCategories =>
      getCategoriesByType(models.CategoryType.income);

  /// Get expense categories
  List<models.Category> get expenseCategories =>
      getCategoriesByType(models.CategoryType.expense);

  /// Get category by ID
  models.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category map (id -> category)
  Map<String, models.Category> get categoryMap {
    return {for (final c in _categories) c.id: c};
  }

  /// Refresh categories from storage
  void refresh() {
    _loadCategories();
  }
}
