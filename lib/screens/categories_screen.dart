import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/icon_helper.dart';

/// Screen for managing categories
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kategori'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pengeluaran'),
              Tab(text: 'Pemasukan'),
            ],
          ),
          actions: [
            PopupMenuButton<CategorySortType>(
              icon: const Icon(Icons.sort),
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
        body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            return TabBarView(
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddCategoryDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddCategorySheet(),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.colorValue),
          child: Icon(
            IconHelper.getIcon(category.iconName),
            color: Colors.white,
          ),
        ),
        title: Text(category.name),
        subtitle: Text('${category.usageCount} transaksi'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
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
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddCategorySheet(category: category),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(category.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kategori dihapus')),
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
class _AddCategorySheet extends StatefulWidget {
  final Category? category;

  const _AddCategorySheet({this.category});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Edit Kategori' : 'Tambah Kategori',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Masukkan nama kategori',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Type selector
            if (!_isEditing) ...[
              Text(
                'Tipe',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Pengeluaran'),
                      selected: _type == CategoryType.expense,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _type = CategoryType.expense);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Pemasukan'),
                      selected: _type == CategoryType.income,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _type = CategoryType.income);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Icon selector
            Text(
              'Ikon',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: IconHelper.availableIcons.map((iconName) {
                  final isSelected = iconName == _selectedIcon;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedIcon = iconName);
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: CircleAvatar(
                        backgroundColor: isSelected
                            ? _selectedColor
                            : Colors.grey.shade200,
                        child: Icon(
                          IconHelper.getIcon(iconName),
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Color selector
            Text(
              'Warna',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: CategoryColors.colors.map((color) {
                  final isSelected = color.value == _selectedColor.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedColor = color);
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: CircleAvatar(
                        backgroundColor: color,
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCategory,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Kategori'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama kategori')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Kategori diperbarui' : 'Kategori ditambahkan'),
      ),
    );
  }
}
