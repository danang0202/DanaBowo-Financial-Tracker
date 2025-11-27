import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/icon_helper.dart';
import '../widgets/premium_fab.dart';

import '../widgets/dynamic_island_notification.dart';

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
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: CategorySortType.usageFrequency,
                      child: Text('Urutkan berdasarkan penggunaan'),
                    ),
                    const PopupMenuItem(
                      value: CategorySortType.alphabetical,
                      child: Text('Urutkan berdasarkan abjad'),
                    ),
                  ],
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
                _CategoryList(
                  categories: categoryProvider.expenseCategories,
                  type: CategoryType.expense,
                ),
                _CategoryList(
                  categories: categoryProvider.incomeCategories,
                  type: CategoryType.income,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: PremiumFAB(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        icon: Icons.add,
        label: 'Kategori',
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

/// Category list widget
class _CategoryList extends StatelessWidget {
  final List<Category> categories;
  final CategoryType type;

  const _CategoryList({
    required this.categories,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada kategori',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryItem(category: category);
      },
    );
  }
}

/// Category item widget
class _CategoryItem extends StatelessWidget {
  final Category category;

  const _CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _showEditCategoryDialog(context, category);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    IconHelper.getIcon(category.iconName),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${category.usageCount} Transaksi',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert_rounded, color: Colors.grey[400]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              color: Theme.of(context).primaryColor, size: 20),
                          const SizedBox(width: 12),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditCategoryDialog(context, category);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, category);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryFormSheet(category: category),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kategori'),
        content: Text(
            'Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(category.id);
              Navigator.pop(context);
              DynamicIslandNotification.show(
                context,
                message: 'Kategori dihapus',
                icon: Icons.delete_outline,
                color: Colors.red,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

/// Add/Edit category bottom sheet
class CategoryFormSheet extends StatefulWidget {
  final Category? category;
  final CategoryType? initialType;

  const CategoryFormSheet({
    super.key,
    this.category,
    this.initialType,
  });

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  final _nameController = TextEditingController();
  CategoryType _type = CategoryType.expense;
  String _selectedIcon = 'category';
  Color _selectedColor = CategoryColors.colors[0];

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.category!;
      _nameController.text = c.name;
      _type = c.type;
      _selectedIcon = c.iconName;
      _selectedColor = Color(c.colorValue);
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isEditing ? 'Edit Kategori' : 'Tambah Kategori',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Preview Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _selectedColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      IconHelper.getIcon(_selectedIcon),
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text.isEmpty
                        ? 'Nama Kategori'
                        : _nameController.text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _selectedColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_type == CategoryType.expense
                              ? AppColors.expense
                              : AppColors.income)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _type == CategoryType.expense
                          ? 'Pengeluaran'
                          : 'Pemasukan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _type == CategoryType.expense
                            ? AppColors.expense
                            : AppColors.income,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Contoh: Makanan, Gaji, dll',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => setState(() {}),
              autofocus: false,
            ),
            const SizedBox(height: 24),

            // Type selector
            if (!_isEditing) ...[
              Text(
                'Tipe Kategori',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TypeSelectionButton(
                      label: 'Pengeluaran',
                      icon: Icons.arrow_downward,
                      isSelected: _type == CategoryType.expense,
                      color: AppColors.expense,
                      onTap: () => setState(() => _type = CategoryType.expense),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeSelectionButton(
                      label: 'Pemasukan',
                      icon: Icons.arrow_upward,
                      isSelected: _type == CategoryType.income,
                      color: AppColors.income,
                      onTap: () => setState(() => _type = CategoryType.income),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Icon selector
            Text(
              'Pilih Ikon',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: IconHelper.availableIcons.map((iconName) {
                  final isSelected = iconName == _selectedIcon;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedIcon = iconName);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : Theme.of(context).dividerColor,
                            width: isSelected ? 0 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _selectedColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          IconHelper.getIcon(iconName),
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).iconTheme.color,
                          size: 28,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Color selector
            Text(
              'Pilih Warna',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: CategoryColors.colors.map((color) {
                  final isSelected = color.value == _selectedColor.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedColor = color);
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: isSelected ? 3 : 0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: _selectedColor.withOpacity(0.4),
                ),
                child: Text(
                  _isEditing ? 'Simpan Perubahan' : 'Buat Kategori',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      DynamicIslandNotification.show(
        context,
        message: 'Masukkan nama kategori',
        isError: true,
      );
      return;
    }

    final categoryProvider = context.read<CategoryProvider>();

    if (_isEditing) {
      final updatedCategory = widget.category!.copyWith(
        name: name,
        iconName: _selectedIcon,
        colorValue: _selectedColor.value,
      );
      categoryProvider.updateCategory(updatedCategory);
    } else {
      categoryProvider.addCategory(
        name: name,
        type: _type,
        iconName: _selectedIcon,
        colorValue: _selectedColor.value,
      );
    }

    Navigator.pop(context);
    DynamicIslandNotification.show(
      context,
      message: _isEditing ? 'Kategori diperbarui' : 'Kategori ditambahkan',
    );
  }
}

class _TypeSelectionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeSelectionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
