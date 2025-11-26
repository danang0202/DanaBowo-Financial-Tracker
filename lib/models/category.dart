import 'package:hive/hive.dart';

part 'category.g.dart';

/// Category type enumeration
@HiveType(typeId: 2)
enum CategoryType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

/// Category model for organizing transactions
@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  CategoryType type;

  @HiveField(3)
  String iconName;

  @HiveField(4)
  int colorValue;

  @HiveField(5)
  int usageCount;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.iconName = 'category',
    this.colorValue = 0xFF2196F3,
    this.usageCount = 0,
  });

  /// Create a copy with modified fields
  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? iconName,
    int? colorValue,
    int? usageCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  /// Convert to Map for export
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'iconName': iconName,
      'colorValue': colorValue,
      'usageCount': usageCount,
    };
  }

  /// Create from Map for import
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: CategoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CategoryType.expense,
      ),
      iconName: map['iconName'] as String? ?? 'category',
      colorValue: map['colorValue'] as int? ?? 0xFF2196F3,
      usageCount: map['usageCount'] as int? ?? 0,
    );
  }
}

/// Default categories for new users
class DefaultCategories {
  static List<Category> getDefaultCategories() {
    return [
      // Income categories
      Category(
        id: 'salary',
        name: 'Gaji',
        type: CategoryType.income,
        iconName: 'work',
        colorValue: 0xFF4CAF50,
      ),
      Category(
        id: 'investment',
        name: 'Investasi',
        type: CategoryType.income,
        iconName: 'trending_up',
        colorValue: 0xFF8BC34A,
      ),
      Category(
        id: 'bonus',
        name: 'Bonus',
        type: CategoryType.income,
        iconName: 'card_giftcard',
        colorValue: 0xFF00BCD4,
      ),
      Category(
        id: 'other_income',
        name: 'Lainnya',
        type: CategoryType.income,
        iconName: 'attach_money',
        colorValue: 0xFF009688,
      ),
      // Expense categories
      Category(
        id: 'food',
        name: 'Makanan',
        type: CategoryType.expense,
        iconName: 'restaurant',
        colorValue: 0xFFFF5722,
      ),
      Category(
        id: 'transport',
        name: 'Transportasi',
        type: CategoryType.expense,
        iconName: 'directions_car',
        colorValue: 0xFF3F51B5,
      ),
      Category(
        id: 'shopping',
        name: 'Belanja',
        type: CategoryType.expense,
        iconName: 'shopping_cart',
        colorValue: 0xFFE91E63,
      ),
      Category(
        id: 'entertainment',
        name: 'Hiburan',
        type: CategoryType.expense,
        iconName: 'movie',
        colorValue: 0xFF9C27B0,
      ),
      Category(
        id: 'health',
        name: 'Kesehatan',
        type: CategoryType.expense,
        iconName: 'local_hospital',
        colorValue: 0xFFF44336,
      ),
      Category(
        id: 'education',
        name: 'Pendidikan',
        type: CategoryType.expense,
        iconName: 'school',
        colorValue: 0xFF2196F3,
      ),
      Category(
        id: 'bills',
        name: 'Tagihan',
        type: CategoryType.expense,
        iconName: 'receipt',
        colorValue: 0xFF795548,
      ),
      Category(
        id: 'other_expense',
        name: 'Lainnya',
        type: CategoryType.expense,
        iconName: 'more_horiz',
        colorValue: 0xFF607D8B,
      ),
    ];
  }
}
