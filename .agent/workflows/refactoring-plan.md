---
description: Refactoring Plan untuk DanaBowo Financial Tracker
---

# 🔧 Refactoring Plan - DanaBowo Financial Tracker

## 📊 Analisis File Besar
1. **budgets_screen.dart** (886 baris)
2. **categories_screen.dart** (845 baris)
3. **add_transaction_screen.dart** (606 baris)
4. **dashboard_screen.dart** (595 baris)
5. **settings_screen.dart** (562 baris)

## 🎯 Tujuan Refactoring
- Memisahkan widget besar menjadi file terpisah
- Meningkatkan reusability
- Mempermudah maintenance
- Mengikuti prinsip Single Responsibility

## 📁 Struktur Folder Baru

```
lib/
├── dialogs/                    # NEW - Dialog reusable
│   ├── budget_dialogs.dart
│   ├── category_dialogs.dart
│   └── transaction_dialogs.dart
│
├── widgets/
│   ├── budget/                 # NEW - Budget-specific widgets
│   │   ├── budget_item.dart
│   │   ├── budget_form_sheet.dart
│   │   └── budget_category_selector.dart
│   │
│   ├── category/               # NEW - Category-specific widgets
│   │   ├── category_item.dart
│   │   ├── category_list.dart
│   │   ├── category_form_sheet.dart
│   │   └── category_type_button.dart
│   │
│   ├── transaction/            # NEW - Transaction-specific widgets
│   │   ├── transaction_type_button.dart
│   │   ├── transaction_datetime_button.dart
│   │   └── transaction_amount_input.dart
│   │
│   ├── dashboard/              # NEW - Dashboard-specific widgets
│   │   ├── dashboard_header.dart
│   │   ├── quick_stats_card.dart
│   │   └── recent_transactions_list.dart
│   │
│   └── settings/               # NEW - Settings-specific widgets
│       ├── settings_section.dart
│       ├── settings_tile.dart
│       └── theme_selector.dart
│
└── [existing folders...]
```

## 🔄 Refactoring Steps

### Phase 1: Budgets Screen (886 lines)
- [x] Extract `_BudgetItem` → `lib/widgets/budget/budget_item.dart`
- [x] Extract `AddBudgetSheet` → `lib/widgets/budget/budget_form_sheet.dart`
- [x] Extract delete confirmation → `lib/dialogs/budget_dialogs.dart`
- [x] Update imports in `budgets_screen.dart`

### Phase 2: Categories Screen (845 lines)
- [x] Extract `_CategoryItem` → `lib/widgets/category/category_item.dart`
- [x] Extract `_CategoryList` → `lib/widgets/category/category_list.dart`
- [x] Extract `CategoryFormSheet` → `lib/widgets/category/category_form_sheet.dart`
- [x] Extract `_TypeSelectionButton` → `lib/widgets/category/category_type_button.dart`
- [x] Extract dialogs → `lib/dialogs/category_dialogs.dart`
- [x] Update imports in `categories_screen.dart`

### Phase 3: Add Transaction Screen (606 lines)
- [x] Extract `_TypeButton` → `lib/widgets/transaction/transaction_type_button.dart`
- [x] Extract `_DateTimeButton` → `lib/widgets/transaction/transaction_datetime_button.dart`
- [x] Extract amount input section → `lib/widgets/transaction/transaction_amount_input.dart`
- [x] Update imports in `add_transaction_screen.dart`

### Phase 4: Dashboard Screen (595 lines)
- [x] Extract header section → `lib/widgets/dashboard/dashboard_header.dart`
- [x] Extract quick stats → `lib/widgets/dashboard/quick_stats_card.dart`
- [x] Extract recent transactions → `lib/widgets/dashboard/recent_transactions_list.dart`
- [x] Update imports in `dashboard_screen.dart`

### Phase 5: Settings Screen (562 lines)
- [x] Extract settings section → `lib/widgets/settings/settings_section.dart`
- [x] Extract settings tile → `lib/widgets/settings/settings_tile.dart`
- [x] Extract theme selector → `lib/widgets/settings/theme_selector.dart`
- [x] Update imports in `settings_screen.dart`

## ✅ Benefits
- Setiap file < 300 baris
- Widget lebih reusable
- Easier testing
- Better code organization
- Faster development
