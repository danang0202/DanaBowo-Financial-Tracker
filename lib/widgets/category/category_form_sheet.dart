import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';
import '../../utils/icon_helper.dart';
import '../dynamic_island_notification.dart';
import 'category_type_button.dart';

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
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          shrinkWrap: true,
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
            _buildPreviewSection(context),
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
                    child: CategoryTypeButton(
                      label: 'Pengeluaran',
                      icon: Icons.arrow_downward,
                      isSelected: _type == CategoryType.expense,
                      color: AppColors.expense,
                      onTap: () => setState(() => _type = CategoryType.expense),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CategoryTypeButton(
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
            _buildIconSelector(),
            const SizedBox(height: 24),

            // Color selector
            Text(
              'Pilih Warna',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildColorSelector(),
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

  Widget _buildPreviewSection(BuildContext context) {
    return Center(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (_type == CategoryType.expense
                      ? AppColors.expense
                      : AppColors.income)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _type == CategoryType.expense ? 'Pengeluaran' : 'Pemasukan',
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
    );
  }

  Widget _buildIconSelector() {
    return SizedBox(
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
                  color:
                      isSelected ? _selectedColor : Theme.of(context).cardColor,
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
    );
  }

  Widget _buildColorSelector() {
    return SizedBox(
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
