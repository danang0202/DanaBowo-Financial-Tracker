import 'package:hive/hive.dart';

part 'budget.g.dart';

/// Budget period enumeration
@HiveType(typeId: 4)
enum BudgetPeriod {
  @HiveField(0)
  monthly,
}

/// Budget model for tracking spending limits
@HiveType(typeId: 5)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double limitAmount;

  @HiveField(3)
  BudgetPeriod period;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  bool notificationEnabled;

  @HiveField(6)
  double notificationThreshold;

  Budget({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    this.period = BudgetPeriod.monthly,
    required this.startDate,
    this.notificationEnabled = true,
    this.notificationThreshold = 0.8,
  });

  /// Create a copy with modified fields
  Budget copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    BudgetPeriod? period,
    DateTime? startDate,
    bool? notificationEnabled,
    double? notificationThreshold,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationThreshold: notificationThreshold ?? this.notificationThreshold,
    );
  }

  /// Convert to Map for export
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limitAmount': limitAmount,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'notificationEnabled': notificationEnabled,
      'notificationThreshold': notificationThreshold,
    };
  }

  /// Create from Map for import
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      limitAmount: (map['limitAmount'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(map['startDate'] as String),
      notificationEnabled: map['notificationEnabled'] as bool? ?? true,
      notificationThreshold: (map['notificationThreshold'] as num?)?.toDouble() ?? 0.8,
    );
  }
}
