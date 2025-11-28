import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/dynamic_island_notification.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/settings_tile.dart';
import '../widgets/settings/theme_option.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Appearance Section
                      SettingsSection(
                        title: 'Tampilan',
                        children: [
                          SettingsTile(
                            icon: Icons.brightness_6_rounded,
                            title: 'Tema Aplikasi',
                            subtitle: _getThemeText(themeProvider.themeMode),
                            color: Colors.purple,
                            onTap: () =>
                                _showThemeDialog(context, themeProvider),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Data Section
                      SettingsSection(
                        title: 'Data & Penyimpanan',
                        children: [
                          SettingsTile(
                            icon: Icons.delete_sweep_rounded,
                            title: 'Hapus Semua Data',
                            subtitle: 'Hapus permanen semua transaksi',
                            color: Colors.red,
                            isDestructive: true,
                            onTap: () => _showClearDataDialog(
                              context,
                              context.read<StorageService>(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // About Section
                      SettingsSection(
                        title: 'Tentang Aplikasi',
                        children: const [
                          SettingsTile(
                            icon: Icons.info_outline_rounded,
                            title: 'Versi Aplikasi',
                            subtitle: 'v1.0.0',
                            color: Colors.blue,
                            showArrow: false,
                          ),
                          SettingsTile(
                            icon: Icons.code_rounded,
                            title: 'Pengembang',
                            subtitle: 'Danang Wisnu Prabowo',
                            color: Colors.green,
                            showArrow: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // App Logo/Footer
                      _buildAppFooter(context),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'Pengaturan',
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
    );
  }

  Widget _buildAppFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/icon.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DanaKu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Financial Tracker',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Ikuti Sistem';
      case ThemeMode.light:
        return 'Mode Terang';
      case ThemeMode.dark:
        return 'Mode Gelap';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
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
              'Pilih Tema',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ThemeOption(
              title: 'Ikuti Sistem',
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              icon: Icons.brightness_auto_rounded,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            ThemeOption(
              title: 'Mode Terang',
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              icon: Icons.light_mode_rounded,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            ThemeOption(
              title: 'Mode Gelap',
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              icon: Icons.dark_mode_rounded,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(
      BuildContext context, StorageService storageService) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Semua Data'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua data? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showFinalConfirmationDialog(context, storageService);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  void _showFinalConfirmationDialog(
      BuildContext context, StorageService storageService) {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    const String confirmationText = 'Saya yakin untuk menghapus data saya';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Akhir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ketik kalimat berikut untuk mengonfirmasi:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              confirmationText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ketik di sini...',
                ),
                validator: (value) {
                  if (value != confirmationText) {
                    return 'Kalimat tidak sesuai';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              return TextButton(
                onPressed: value.text == confirmationText
                    ? () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(dialogContext);
                          await _performDelete(context, storageService);
                        }
                      }
                    : null,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus Permanen'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(
      BuildContext context, StorageService storageService) async {
    await storageService.clearAllData();
    // Refresh providers
    if (context.mounted) {
      context.read<TransactionProvider>().refresh();
      context.read<CategoryProvider>().refresh();
      context.read<BudgetProvider>().refresh();
    }
    if (context.mounted) {
      DynamicIslandNotification.show(
        context,
        message: 'Semua data berhasil dihapus',
        icon: Icons.delete_forever_rounded,
        color: Colors.red,
      );
    }
  }
}
