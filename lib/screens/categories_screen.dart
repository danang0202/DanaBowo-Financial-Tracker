import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../widgets/category/category_list.dart';
import '../widgets/category/category_form_sheet.dart';

/// Screen for managing categories
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 60),
                title: Text(
                  'Kategori',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Pengeluaran'),
                      Tab(text: 'Pemasukan'),
                    ],
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<CategorySortType>(
                  icon: const Icon(Icons.sort_rounded),
                  onSelected: (type) {
                    context.read<CategoryProvider>().setSortType(type);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: CategorySortType.usageFrequency,
                      child: Text('Urutkan berdasarkan penggunaan'),
                    ),
                    PopupMenuItem(
                      value: CategorySortType.alphabetical,
                      child: Text('Urutkan berdasarkan abjad'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      _showAddCategoryDialog(context);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
        body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                CategoryList(
                  categories: categoryProvider.expenseCategories,
                  type: CategoryType.expense,
                ),
                CategoryList(
                  categories: categoryProvider.incomeCategories,
                  type: CategoryType.income,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final initialType =
        _tabController.index == 0 ? CategoryType.expense : CategoryType.income;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryFormSheet(initialType: initialType),
    );
  }
}
