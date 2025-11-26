import 'package:flutter/material.dart';

/// Icon helper to get Material icons by name
class IconHelper {
  static final Map<String, IconData> _iconMap = {
    // Income icons
    'work': Icons.work,
    'trending_up': Icons.trending_up,
    'card_giftcard': Icons.card_giftcard,
    'attach_money': Icons.attach_money,
    'account_balance': Icons.account_balance,
    'savings': Icons.savings,

    // Expense icons
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_cart': Icons.shopping_cart,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'receipt': Icons.receipt,
    'more_horiz': Icons.more_horiz,
    'home': Icons.home,
    'phone_android': Icons.phone_android,
    'flight': Icons.flight,
    'sports_esports': Icons.sports_esports,
    'fitness_center': Icons.fitness_center,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'local_cafe': Icons.local_cafe,
    'local_gas_station': Icons.local_gas_station,
    'local_parking': Icons.local_parking,
    'electric_bolt': Icons.electric_bolt,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,

    // Default
    'category': Icons.category,
  };

  /// Get IconData by name
  static IconData getIcon(String name) {
    return _iconMap[name] ?? Icons.category;
  }

  /// Get all available icon names
  static List<String> get availableIcons => _iconMap.keys.toList();

  /// Get icon map for selection
  static Map<String, IconData> get iconMap => _iconMap;
}
