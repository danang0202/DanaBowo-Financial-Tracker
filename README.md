# Danabowo - Financial Tracker

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.5.0+-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Dart-3.5.0+-blue.svg" alt="Dart Version">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
</p>

Aplikasi mobile untuk membantu pengguna mencatat, melacak, dan menganalisis pemasukan dan pengeluaran harian secara real-time. Dirancang dengan fokus pada pengalaman pengguna yang cepat, intuitif, dan tanpa hambatan.

## 📱 Fitur Utama

### A. Pencatatan Transaksi
- **Input Cepat**: Mencatat pemasukan atau pengeluaran hanya dengan beberapa ketukan
- **Detail Transaksi**: Jumlah, tanggal & waktu, kategori, dan catatan singkat
- **Dukungan Tag**: Gunakan hashtag (#) dalam catatan untuk pencarian mudah
- **Transaksi Masa Lalu**: Mendukung input transaksi dengan tanggal lampau

### B. Pengelolaan Kategori
- **Kategori Fleksibel**: Tambah, edit, hapus kategori sesuai kebutuhan
- **Kustomisasi Visual**: Pilih warna dan ikon untuk setiap kategori
- **Penyortiran**: Urutkan berdasarkan frekuensi penggunaan atau abjad
- **Kategori Default**: Kategori bawaan untuk pemasukan dan pengeluaran

### C. Dashboard & Ringkasan
- **Saldo Real-time**: Tampilan total saldo saat ini
- **Ringkasan Periodik**: Total pemasukan dan pengeluaran harian, mingguan, bulanan
- **Visualisasi Data**: Grafik pie chart untuk pengeluaran per kategori
- **Transaksi Terbaru**: Daftar transaksi terakhir dengan akses cepat

### D. Pelacakan Anggaran (Budgeting)
- **Pembuatan Anggaran**: Tetapkan batas pengeluaran bulanan per kategori
- **Notifikasi Peringatan**: Peringatan saat mendekati (80%) atau melebihi batas
- **Status Visual**: Indikator progress untuk setiap anggaran

### E. Export Laporan
- **Filter Periode**: Pilih bulan dan tahun untuk laporan
- **Format CSV**: Data mentah untuk analisis di spreadsheet
- **Format PDF**: Laporan terstruktur dengan ringkasan dan rincian

### F. Tema Gelap/Terang
- **Mode Sistem**: Mengikuti preferensi tema perangkat
- **Mode Manual**: Pilih tema terang atau gelap secara manual

## 🛠️ Teknologi

| Aspek | Teknologi | Keterangan |
|-------|-----------|------------|
| Framework | Flutter | Pengembangan aplikasi mobile lintas platform |
| Bahasa | Dart | Bahasa pemrograman utama |
| Database Lokal | Hive | NoSQL database dengan performa tinggi |
| State Management | Provider | Manajemen state yang sederhana dan efisien |
| UI/UX | Material Design 3 | Desain modern dan adaptif |
| Grafik | fl_chart | Visualisasi data interaktif |
| Export PDF | pdf | Pembuatan dokumen PDF |
| Export CSV | csv | Pembuatan file CSV |

## 📁 Struktur Proyek

```
lib/
├── main.dart                   # Entry point aplikasi
├── models/                     # Model data
│   ├── transaction.dart        # Model transaksi
│   ├── category.dart           # Model kategori
│   └── budget.dart             # Model anggaran
├── providers/                  # State management
│   ├── transaction_provider.dart
│   ├── category_provider.dart
│   ├── budget_provider.dart
│   └── theme_provider.dart
├── screens/                    # Layar/halaman UI
│   ├── dashboard_screen.dart   # Halaman utama
│   ├── add_transaction_screen.dart
│   ├── transactions_screen.dart
│   ├── categories_screen.dart
│   ├── budgets_screen.dart
│   ├── settings_screen.dart
│   └── export_screen.dart
├── widgets/                    # Komponen UI reusable
│   ├── summary_card.dart
│   ├── transaction_list_item.dart
│   ├── expense_chart.dart
│   └── budget_warning_card.dart
├── services/                   # Layanan/service
│   ├── storage_service.dart    # Service penyimpanan Hive
│   └── export_service.dart     # Service export laporan
└── utils/                      # Utilitas
    ├── constants.dart          # Konstanta dan tema
    ├── formatters.dart         # Format angka dan tanggal
    └── icon_helper.dart        # Helper untuk ikon
```

## 📊 Skema Data

### Transaksi
| Field | Tipe | Keterangan |
|-------|------|------------|
| id | String | ID unik |
| type | TransactionType | Income / Expense |
| amount | double | Jumlah transaksi |
| categoryId | String | ID kategori |
| date | DateTime | Tanggal dan waktu |
| note | String? | Catatan (opsional) |

### Kategori
| Field | Tipe | Keterangan |
|-------|------|------------|
| id | String | ID unik |
| name | String | Nama kategori |
| type | CategoryType | Income / Expense |
| iconName | String | Nama ikon Material |
| colorValue | int | Nilai warna (ARGB) |
| usageCount | int | Jumlah penggunaan |

### Anggaran
| Field | Tipe | Keterangan |
|-------|------|------------|
| id | String | ID unik |
| categoryId | String | ID kategori |
| limitAmount | double | Batas anggaran |
| period | BudgetPeriod | Periode (Monthly) |
| startDate | DateTime | Tanggal mulai |
| notificationEnabled | bool | Status notifikasi |
| notificationThreshold | double | Ambang peringatan (0-1) |

## 🚀 Panduan Pengembangan

### Prasyarat

1. **Flutter SDK** (versi 3.5.0 atau lebih baru)
   ```bash
   # Periksa versi Flutter
   flutter --version
   ```

2. **Dart SDK** (versi 3.5.0 atau lebih baru)
   - Sudah termasuk dalam Flutter SDK

3. **IDE yang Direkomendasikan**
   - [VS Code](https://code.visualstudio.com/) dengan ekstensi Flutter
   - [Android Studio](https://developer.android.com/studio) dengan plugin Flutter

4. **Perangkat/Emulator**
   - Android Emulator (API 21+)
   - iOS Simulator (iOS 12.0+)
   - Perangkat fisik Android atau iOS

### Instalasi Flutter SDK

#### Windows
```bash
# 1. Download Flutter SDK dari https://flutter.dev/docs/get-started/install/windows
# 2. Extract ke folder yang diinginkan (misal: C:\src\flutter)
# 3. Tambahkan Flutter ke PATH
setx PATH "%PATH%;C:\src\flutter\bin"

# 4. Verifikasi instalasi
flutter doctor
```

#### macOS
```bash
# Menggunakan Homebrew
brew install --cask flutter

# Atau manual download dari https://flutter.dev/docs/get-started/install/macos

# Verifikasi instalasi
flutter doctor
```

#### Linux
```bash
# 1. Download Flutter SDK
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# 2. Tambahkan ke PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Tambahkan ke ~/.bashrc atau ~/.zshrc untuk permanen
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc

# 4. Verifikasi instalasi
flutter doctor
```

### Setup Proyek

1. **Clone repository**
   ```bash
   git clone https://github.com/danang0202/DanaBowo-Financial-Tracker.git
   cd DanaBowo-Financial-Tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters** (jika diperlukan)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Jalankan aplikasi**
   ```bash
   # Untuk debug mode
   flutter run

   # Untuk release mode
   flutter run --release

   # Untuk perangkat tertentu
   flutter run -d <device_id>
   ```

### Perintah Penting

```bash
# Periksa kesehatan Flutter
flutter doctor -v

# Lihat perangkat yang tersedia
flutter devices

# Bersihkan build cache
flutter clean

# Analisis kode
flutter analyze

# Jalankan test
flutter test

# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS (hanya di macOS)
flutter build ios --release
```

### Konfigurasi IDE

#### VS Code
1. Install ekstensi:
   - Flutter
   - Dart
   - Flutter Widget Snippets (opsional)

2. Buka Command Palette (Ctrl/Cmd + Shift + P)
3. Ketik "Flutter: Run Flutter Doctor"

#### Android Studio
1. Buka File > Settings > Plugins
2. Install plugin Flutter (akan menginstall Dart juga)
3. Restart Android Studio
4. Buka File > New > New Flutter Project

## 🧪 Testing

```bash
# Jalankan semua test
flutter test

# Jalankan test spesifik
flutter test test/models_test.dart

# Jalankan test dengan coverage
flutter test --coverage
```

## 📱 Build Release

### Android

```bash
# Build APK
flutter build apk --release

# Build APK untuk arsitektur spesifik
flutter build apk --split-per-abi --release

# Build App Bundle (untuk Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (hanya di macOS)

```bash
# Build iOS
flutter build ios --release

# Buka di Xcode untuk archive
open ios/Runner.xcworkspace
```

## 🎨 Kustomisasi

### Menambah Kategori Default

Edit file `lib/models/category.dart`:

```dart
static List<Category> getDefaultCategories() {
  return [
    // Tambahkan kategori baru di sini
    Category(
      id: 'new_category',
      name: 'Kategori Baru',
      type: CategoryType.expense,
      iconName: 'icon_name', // Lihat IconHelper untuk daftar ikon
      colorValue: 0xFFHEXCOLOR,
    ),
    // ... kategori lainnya
  ];
}
```

### Menambah Ikon

Edit file `lib/utils/icon_helper.dart`:

```dart
static final Map<String, IconData> _iconMap = {
  // Tambahkan ikon baru di sini
  'nama_ikon': Icons.nama_material_icon,
  // ... ikon lainnya
};
```

### Mengubah Tema

Edit file `lib/utils/constants.dart`:

```dart
static ThemeData get lightTheme {
  return ThemeData(
    // Kustomisasi tema terang
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary, // Ganti warna utama
    ),
    // ... konfigurasi lainnya
  );
}
```

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

## 👨‍💻 Kontributor

- Danang - Developer Utama

## 📞 Kontak

Untuk pertanyaan atau masukan, silakan buat issue di repository ini.

---

<p align="center">
  Dibuat dengan ❤️ menggunakan Flutter
</p>
