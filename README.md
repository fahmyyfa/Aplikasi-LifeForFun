📜 Personal Productivity & Spiritual Tracker
Aplikasi asisten personal berbasis AI yang dirancang untuk membantu pengguna mengelola aspek finansial, kebiasaan ibadah harian, dan penjadwalan secara terpadu. Dibangun dengan teknologi terbaru untuk memastikan performa yang cepat, aman, dan antarmuka yang elegan bagi semua kalangan usia.

🌟 Fitur Utama
Finance Tracking: Pencatatan pemasukan dan pengeluaran secara mandiri untuk memantau arus kas harian.
Spiritual Habits: Checklist harian untuk Dzikir Pagi & Petang serta log aktivitas olahraga.
Fasting Reminder: Pengingat otomatis untuk puasa sunnah (Senin-Kamis, Ayyamul Bidh) yang muncul pada H-1 pukul 20:00.
Magic Schedule (AI-Powered): Integrasi Google Gemini AI untuk mengekstrak jadwal secara otomatis hanya melalui unggahan screenshot.
Wishlist Tracker: Daftar barang impian dengan fitur "Mark as Purchased" yang otomatis mencatat pembelian ke dalam histori transaksi.

🛠️ Stack Teknologi
Framework: Flutter (Dart).
State Management: Riverpod.
Navigation: GoRouter.
Backend: Supabase (PostgreSQL, Auth, & Storage).
AI Integration: Google Generative AI (Gemini SDK).

🚀 Memulai (Getting Started)
Untuk menjalankan aplikasi ini di lingkungan lokal Anda, ikuti langkah-langkah berikut:
  1. Setup Database (Supabase)
- Buat proyek baru di Supabase Dashboard.
- Buka SQL Editor dan jalankan perintah yang ada di file database_schema.sql (atau gunakan skema SQL yang terlampir di file implementation_plan.md).
- Pastikan Row Level Security (RLS) sudah aktif agar data Anda tetap aman.

  2. Konfigurasi Flutter
- Clone repositori ini:
- Bash
- git clone https://github.com/username/repository-name.git
- Buka proyek di VS Code atau Android Studio.
- Konfigurasikan API Key Anda pada file lib/core/constants/api_constants.dart:
- Masukkan supabaseUrl dan supabaseAnonKey milik Anda.
- Masukkan geminiApiKey untuk mengaktifkan fitur Magic Schedule.

- Jalankan perintah berikut di terminal:
  Bash
  flutter pub get
  flutter run

📸 Tampilan UI
Aplikasi ini menggunakan palet warna Emerald Green (Hijau Zamrud) yang memberikan kesan tenang, profesional, dan bersih, sehingga nyaman digunakan oleh pengguna dari berbagai rentang usia.

🏗️ Implementasi Teknis
Proyek ini mengikuti standar pengembangan industri:
  1. Clean Architecture: Struktur folder yang terorganisir per fitur untuk kemudahan pemeliharaan kode.
  2. Safe Data Handling: Menggunakan null safety dan penanganan error untuk mencegah aplikasi crash saat data kosong.
  3. Localization: Dukungan format mata uang Rupiah dan tanggal Indonesia menggunakan paket intl.
