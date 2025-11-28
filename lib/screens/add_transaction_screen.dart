import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/icon_helper.dart';
import '../utils/formatters.dart';
import '../widgets/dynamic_island_notification.dart';
import '../widgets/transaction/transaction_type_button.dart';
import '../widgets/transaction/transaction_datetime_button.dart';

/// Screen for adding or editing transactions
class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _type = t.type;
      _amountController.text = NumberFormat('#,###', 'id_ID').format(t.amount);
      _selectedCategoryId = t.categoryId;
      _selectedDate = t.date;
      _selectedTime = TimeOfDay.fromDateTime(t.date);
      _noteController.text = t.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = _type == TransactionType.expense;
    final activeColor = isExpense ? AppColors.expense : AppColors.income;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  // Type Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.dividerColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TransactionTypeButton(
                            label: 'Pengeluaran',
                            icon: Icons.arrow_downward_rounded,
                            isSelected: isExpense,
                            activeColor: AppColors.expense,
                            onTap: () => setState(() {
                              _type = TransactionType.expense;
                              _selectedCategoryId = null;
                            }),
                          ),
                        ),
                        Expanded(
                          child: TransactionTypeButton(
                            label: 'Pemasukan',
                            icon: Icons.arrow_upward_rounded,
                            isSelected: !isExpense,
                            activeColor: AppColors.income,
                            onTap: () => setState(() {
                              _type = TransactionType.income;
                              _selectedCategoryId = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Amount Input
                  Column(
                    children: [
                      Text(
                        'Jumlah Uang',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountController,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                            fontSize: 40,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle:
                                theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: activeColor.withOpacity(0.7),
                            ),
                            hintText: '0',
                            hintStyle: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.disabledColor.withOpacity(0.3),
                              fontSize: 40,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CurrencyInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan jumlah';
                            }
                            if (parseCurrency(value) <= 0) {
                              return 'Jumlah harus > 0';
                            }
                            return null;
                          },
                          autofocus: !_isEditing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Category Selector
                  Text(
                    'Kategori',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      final categories = isExpense
                          ? categoryProvider.expenseCategories
                          : categoryProvider.incomeCategories;

                      if (categories.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Belum ada kategori',
                              style: TextStyle(color: theme.disabledColor),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected =
                                category.id == _selectedCategoryId;
                            final color = Color(category.colorValue);

                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedCategoryId = category.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 85,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.15)
                                      : theme.cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : theme.dividerColor.withOpacity(0.5),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color
                                            : color.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        IconHelper.getIcon(category.iconName),
                                        color:
                                            isSelected ? Colors.white : color,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? color
                                            : theme.textTheme.bodyMedium?.color,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Date & Time
                  Text(
                    'Waktu Transaksi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TransactionDateTimeButton(
                          icon: Icons.calendar_today_rounded,
                          label:
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 1)),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TransactionDateTimeButton(
                          icon: Icons.access_time_rounded,
                          label: _selectedTime.format(context),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (time != null) {
                              setState(() => _selectedTime = time);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Note
                  Text(
                    'Catatan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Tulis catatan...',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: activeColor),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [activeColor, activeColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saveTransaction,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Text(
                        _isEditing ? 'Simpan Perubahan' : 'Simpan Transaksi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      DynamicIslandNotification.show(
        context,
        message: 'Pilih kategori terlebih dahulu',
        isError: true,
      );
      return;
    }

    final amount = parseCurrency(_amountController.text);
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final note = _noteController.text.isEmpty ? null : _noteController.text;

    final transactionProvider = context.read<TransactionProvider>();

    if (_isEditing) {
      final updatedTransaction = widget.transaction!.copyWith(
        type: _type,
        amount: amount,
        categoryId: _selectedCategoryId,
        date: dateTime,
        note: note,
      );
      transactionProvider.updateTransaction(updatedTransaction);
    } else {
      transactionProvider.addTransaction(
        type: _type,
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: dateTime,
        note: note,
      );
    }

    Navigator.pop(context);
    DynamicIslandNotification.show(
      context,
      message:
          _isEditing ? 'Transaksi diperbarui' : 'Transaksi berhasil disimpan',
      color: AppColors.success,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<TransactionProvider>()
                  .deleteTransaction(widget.transaction!.id);
              Navigator.pop(context);
              Navigator.pop(context);
              DynamicIslandNotification.show(
                context,
                message: 'Transaksi dihapus',
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
