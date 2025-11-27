Rencana Pengembangan Aplikasi Mobile Catatan Keuangan (Danabowo - Financial Tracker)

1. Tujuan Proyek

Membuat aplikasi mobile yang intuitif dan mudah digunakan untuk membantu pengguna mencatat, melacak, dan menganalisis pemasukan dan pengeluaran harian mereka secara real-time. Tujuannya adalah mempromosikan pengelolaan keuangan yang lebih baik, membantu pengguna mencapai tujuan menabung mereka, mengurangi stres finansial, dan meningkatkan literasi keuangan pribadi melalui visualisasi data yang jelas. Aplikasi ini berfokus pada pengalaman pengguna yang cepat dan tanpa hambatan.

2. Target Pengguna

Individu, pelajar, profesional muda, atau keluarga kecil yang ingin mengelola anggaran pribadi atau rumah tangga tanpa kerumitan. Target utama adalah pengguna yang membutuhkan alat pencatatan yang fleksibel dan visual sebagai pengganti pencatatan manual atau spreadsheet yang kaku.

3. Fitur Utama (Minimum Viable Product - MVP)

A. Pencatatan Transaksi

Input Cepat: Memungkinkan pengguna mencatat Pemasukan (Income) atau Pengeluaran (Expense) hanya dengan beberapa kali ketuk. Desain antarmuka input harus memprioritaskan kecepatan dan ergonomi, idealnya dapat diselesaikan dengan satu tangan.

Detail Transaksi:

Jumlah (Amount).

Tanggal dan Waktu (Date & Time) - Mendukung input transaksi masa lalu.

Kategori (Category) - Contoh: Makanan, Transportasi, Gaji, Investasi.

Catatan Singkat (Description/Note) - Mendukung tag sederhana (#) untuk pencarian lebih lanjut.

Pengelolaan Kategori Fleksibel: Sistem kategori harus sepenuhnya fleksibel dan dapat diatur oleh pengguna.

Pengguna dapat menambah, mengedit, menghapus, dan mengatur kategori custom (baik untuk Pemasukan maupun Pengeluaran) sesuai kebutuhan mereka.

Fleksibilitas ini mencakup kemampuan untuk menetapkan warna aksen unik dan ikon yang berbeda untuk setiap kategori, meningkatkan identifikasi visual di Dashboard.

Fitur penyortiran kategori berdasarkan frekuensi penggunaan atau abjad.

B. Dashboard & Ringkasan

Saldo Real-time: Menampilkan total saldo saat ini.

Ringkasan Periodik: Menampilkan total pemasukan dan pengeluaran untuk periode hari ini, minggu ini, dan bulan ini.

Grafik Sederhana: Visualisasi pengeluaran berdasarkan kategori dalam bentuk Pie Chart atau Bar Chart.

C. Export Laporan Keuangan

Filter Periode: Pengguna dapat memilih bulan dan tahun untuk laporan yang akan diexport.

Format Export: Mendukung export data dalam format yang mudah dibaca, misalnya CSV (untuk data mentah) atau PDF (untuk ringkasan yang lebih terstruktur).

D. Pelacakan Anggaran (Budgeting)

Pembuatan Anggaran: Pengguna dapat menetapkan batas pengeluaran bulanan untuk kategori tertentu (misalnya, Anggaran Makanan Rp 2.000.000).

Notifikasi: Peringatan ketika pengeluaran mendekati atau melebihi batas anggaran (misalnya, 80% dari anggaran terpakai).

E. Penyimpanan Lokal

Penyimpanan Lokal: Data disimpan secara lokal di perangkat pengguna dan TIDAK memerlukan koneksi internet untuk operasi dasar.

4. Teknologi yang Direkomendasikan

Aspek

Teknologi/Kerangka Kerja

Catatan

Pengembangan Mobile

Flutter (Bahasa Dart)

Dipilih sebagai framework utama untuk pengembangan aplikasi mobile lintas platform.

Penyimpanan Lokal

Hive

Hive (NoSQL yang cepat) - Dipilih untuk persistensi data di perangkat pengguna karena performa tinggi dan kemudahan penggunaan.

Styling & UI

Material Design / Cupertino

Menggunakan sistem widget bawaan Flutter untuk desain yang adaptif dan konsisten.

5. Struktur Data Lokal (Contoh Skema Data)

Skema Data Lokal

Kunci Data

Fields

Transaksi

ID Unik

type (Income/Expense), amount, category, date, note

Kategori

ID Unik

name, type (Income/Expense), icon (Opsional)

Anggaran

ID Unik

category, limitAmount, period (Monthly), startDate

7. Persyaratan Desain User Interface (UI/UX)

Logo Aplikasi: Logo harus unik, modern, dan profesional, mencerminkan aspek keuangan, pelacakan, atau keseimbangan (mengambil inspirasi dari nama 'Danabowo').

Estetika Modern & Keren (Prioritas Tinggi):

Mobile-First: Desain harus optimal untuk perangkat seluler.

Minimalis & Bersih: Menggunakan skema warna yang menenangkan dan tata letak yang tidak terlalu ramai.

Interaksi Cepat: Tombol tambah transaksi (misalnya, tombol floating action) harus mudah diakses.

Visualisasi Data: Grafik dan angka harus mudah dibaca.

Mode Gelap/Terang (Dark/Light Mode): Aplikasi harus mendukung mode gelap dan terang, yang secara default mengikuti preferensi tema sistem operasi ponsel pengguna.

8. Persyaratan Dokumentasi

Buat juga dokumen readme untuk menjelaskan alur sistem, guidelinen pengembagna di local, dan teknologi yang harus diinstall dan cara install nya di laptop pengembang.