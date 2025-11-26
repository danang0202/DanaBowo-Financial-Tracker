import 'package:flutter_test/flutter_test.dart';
import 'package:danabowo_financial_tracker/models/transaction.dart';
import 'package:danabowo_financial_tracker/models/category.dart';
import 'package:danabowo_financial_tracker/models/budget.dart';
import 'package:danabowo_financial_tracker/utils/formatters.dart';

void main() {
  group('Transaction Model', () {
    test('should create a transaction correctly', () {
      final transaction = Transaction(
        id: '1',
        type: TransactionType.expense,
        amount: 50000,
        categoryId: 'food',
        date: DateTime(2024, 1, 15),
        note: 'Lunch #meal',
      );

      expect(transaction.id, '1');
      expect(transaction.type, TransactionType.expense);
      expect(transaction.amount, 50000);
      expect(transaction.categoryId, 'food');
      expect(transaction.note, 'Lunch #meal');
    });

    test('should convert transaction to map', () {
      final transaction = Transaction(
        id: '1',
        type: TransactionType.income,
        amount: 5000000,
        categoryId: 'salary',
        date: DateTime(2024, 1, 1),
        note: 'Monthly salary',
      );

      final map = transaction.toMap();

      expect(map['id'], '1');
      expect(map['type'], 'income');
      expect(map['amount'], 5000000);
      expect(map['categoryId'], 'salary');
      expect(map['note'], 'Monthly salary');
    });

    test('should create transaction from map', () {
      final map = {
        'id': '2',
        'type': 'expense',
        'amount': 25000,
        'categoryId': 'transport',
        'date': '2024-01-15T10:30:00.000',
        'note': 'Taxi',
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.id, '2');
      expect(transaction.type, TransactionType.expense);
      expect(transaction.amount, 25000);
      expect(transaction.categoryId, 'transport');
      expect(transaction.note, 'Taxi');
    });
  });

  group('Category Model', () {
    test('should create a category correctly', () {
      final category = Category(
        id: 'food',
        name: 'Makanan',
        type: CategoryType.expense,
        iconName: 'restaurant',
        colorValue: 0xFFFF5722,
      );

      expect(category.id, 'food');
      expect(category.name, 'Makanan');
      expect(category.type, CategoryType.expense);
      expect(category.iconName, 'restaurant');
      expect(category.colorValue, 0xFFFF5722);
      expect(category.usageCount, 0);
    });

    test('should get default categories', () {
      final defaultCategories = DefaultCategories.getDefaultCategories();

      expect(defaultCategories.isNotEmpty, true);

      // Check for income categories
      final incomeCategories = defaultCategories
          .where((c) => c.type == CategoryType.income)
          .toList();
      expect(incomeCategories.isNotEmpty, true);

      // Check for expense categories
      final expenseCategories = defaultCategories
          .where((c) => c.type == CategoryType.expense)
          .toList();
      expect(expenseCategories.isNotEmpty, true);
    });
  });

  group('Budget Model', () {
    test('should create a budget correctly', () {
      final budget = Budget(
        id: '1',
        categoryId: 'food',
        limitAmount: 2000000,
        startDate: DateTime(2024, 1, 1),
      );

      expect(budget.id, '1');
      expect(budget.categoryId, 'food');
      expect(budget.limitAmount, 2000000);
      expect(budget.period, BudgetPeriod.monthly);
      expect(budget.notificationEnabled, true);
      expect(budget.notificationThreshold, 0.8);
    });

    test('should convert budget to map', () {
      final budget = Budget(
        id: '1',
        categoryId: 'food',
        limitAmount: 2000000,
        startDate: DateTime(2024, 1, 1),
        notificationEnabled: false,
        notificationThreshold: 0.9,
      );

      final map = budget.toMap();

      expect(map['id'], '1');
      expect(map['categoryId'], 'food');
      expect(map['limitAmount'], 2000000);
      expect(map['notificationEnabled'], false);
      expect(map['notificationThreshold'], 0.9);
    });
  });

  group('Formatters', () {
    test('should format currency correctly', () {
      expect(formatCurrency(1000000), contains('1.000.000'));
      expect(formatCurrency(50000), contains('50.000'));
    });

    test('should parse tags from note', () {
      final tags = parseTags('Lunch with friends #meal #friends');
      expect(tags, ['meal', 'friends']);
    });

    test('should return empty list for no tags', () {
      final tags = parseTags('Just a regular note');
      expect(tags, isEmpty);
    });

    test('should return empty list for null note', () {
      final tags = parseTags(null);
      expect(tags, isEmpty);
    });

    test('should format percentage correctly', () {
      expect(formatPercentage(0.5), '50.0%');
      expect(formatPercentage(0.8), '80.0%');
      expect(formatPercentage(1.0), '100.0%');
    });

    test('should get month name in Indonesian', () {
      expect(getMonthName(1), 'Januari');
      expect(getMonthName(7), 'Juli');
      expect(getMonthName(12), 'Desember');
    });
  });
}
