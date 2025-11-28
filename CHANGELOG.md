# Changelog

All notable changes to DanaKu Financial Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-11-28

### Changed
- **Major Code Refactoring**: Improved code modularity and maintainability
  - Reduced codebase by 2,173 lines (62% reduction in major screens)
  - Extracted 16 reusable widget components
  - Reorganized file structure for better organization
  
### Improved
- **Code Quality**: 
  - Better separation of concerns
  - Improved widget reusability
  - Enhanced code readability
  - Easier maintenance and testing
  
### Technical
- Refactored Budgets Screen (81% reduction)
- Refactored Categories Screen (80% reduction)
- Refactored Dashboard Screen (83% reduction)
- Refactored Add Transaction Screen (17% reduction)
- Refactored Settings Screen (33% reduction)

### Added
- Comprehensive refactoring documentation in REFACTORING_REPORT.md
- New widget folder structure:
  - `lib/widgets/budget/` - Budget-related widgets
  - `lib/widgets/category/` - Category-related widgets
  - `lib/widgets/transaction/` - Transaction-related widgets
  - `lib/widgets/dashboard/` - Dashboard-related widgets
  - `lib/widgets/settings/` - Settings-related widgets

---

## [1.0.0] - 2025-11-27

### Added
- Initial release of DanaKu Financial Tracker
- Transaction management (income and expense tracking)
- Category management with custom icons and colors
- Budget tracking with warnings and alerts
- Dashboard with financial overview
- Charts for income and expense visualization
- Export functionality (CSV and PDF)
- Dark mode support
- Data persistence with Hive
- Beautiful and modern UI design

### Features
- **Transaction Management**
  - Add, edit, and delete transactions
  - Support for income and expense types
  - Date and time tracking
  - Notes for each transaction
  - Category-based organization

- **Category Management**
  - Custom categories for income and expense
  - Icon and color customization
  - Usage tracking
  - Sort by usage frequency or alphabetically

- **Budget Management**
  - Set monthly budgets per category
  - Real-time budget tracking
  - Warning alerts at 80% usage
  - Exceeded budget notifications
  - Visual progress indicators

- **Dashboard**
  - Total balance display
  - Daily, weekly, and monthly summaries
  - Income and expense charts
  - Recent transactions list
  - Budget warning cards

- **Settings**
  - Theme selection (Light/Dark/System)
  - Data management
  - App information

- **Export**
  - Export transactions to CSV
  - Export transactions to PDF
  - Date range filtering
  - Category filtering

---

## Version History

- **v1.0.1** (2025-11-28) - Code Refactoring & Optimization
- **v1.0.0** (2025-11-27) - Initial Release
