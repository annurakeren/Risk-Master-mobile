# Risk Master (Mobile App)

Risk Master adalah sebuah aplikasi *mobile* berbasis Flutter yang berfungsi sebagai Sistem Pendukung Keputusan (DSS) untuk manajemen dan evaluasi mitigasi risiko keamanan siber menggunakan metode **EDAS (Evaluation based on Distance from Average Solution)**. Aplikasi ini terintegrasi dengan backend Laravel REST API.

## 🌟 Fitur Utama
- **Role-Based Authentication**: Pemisahan hak akses antara `Admin` (kelola kriteria & alternatif dasar) dan `Risk Analyst` (membuat *assessment*).
- **EDAS Matrix Evaluator**: Antarmuka penilaian metrik alternatif dengan skala 0 hingga 1 yang secara dinamis membedakan kriteria *Benefit* (Hijau) dan *Cost* (Merah).
- **Automated Ranking**: Kalkulasi jarak PDA, NDA, NSP, NSN, SP, dan SN yang menghasilkan *Appraisal Score (AS)* beserta pelabelan kualitas secara *real-time*.
- **Gemini AI Insight**: Rekomendasi langkah mitigasi berbasis *Generative AI* yang menyajikan narasi cerdas berdasarkan hasil ranking EDAS.

## 🚀 Teknologi
- **Frontend**: Flutter `^3.11` (Material 3)
- **Backend API**: Laravel 11 (Sanctum Authentication)
- **State Management**: Provider
- **Networking**: Dio HTTP Client
- **AI Integration**: `google_generative_ai` (Gemini Flash)

## 📁 Dokumentasi Teknis
Untuk detail teknis mengenai struktur folder, API *endpoints*, dependensi, dan *state management*, silakan merujuk ke file **[CLAUDE.md](./CLAUDE.md)**.

## 🛠️ Cara Menjalankan Aplikasi

**1. Setup & Menjalankan Backend Laravel**
Buka terminal pada folder proyek Laravel (`riskmasterlaravel`) lalu jalankan instalasi *dependencies* (jika baru pertama kali *clone*):
```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
```
Setelah itu, jalankan *development server* dengan flag `--host=0.0.0.0` agar dapat diakses dari perangkat luar (emulator/HP fisik):
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

**2. Mencari IP Address Laptop (Windows)**
Buka *Command Prompt* atau *PowerShell* baru dan ketik perintah berikut:
```bash
ipconfig
```
Cari bagian **Wireless LAN adapter Wi-Fi** (jika pakai Wi-Fi) dan catat alamat **IPv4 Address** (contoh: `192.168.1.10`). Pastikan HP dan Laptop terhubung ke jaringan Wi-Fi yang sama.

**3. Konfigurasi IP di Flutter**
Buka file `lib/config/app_config.dart` pada proyek Flutter, lalu ubah variabel `_localIp` menjadi alamat IPv4 yang sudah dicatat tadi:
```dart
static const String _localIp = '192.168.1.10'; // Ganti dengan IP kamu!
```

**4. Menjalankan Aplikasi Flutter**
Pastikan kamu memiliki Emulator yang berjalan atau HP Android/iOS yang terhubung via USB Debugging/Wireless Debugging.
```bash
flutter pub get
flutter run
```

---

### 🔑 Akun Default (Testing)
Jika kamu menjalankan `php artisan migrate --seed` di langkah pertama, backend secara otomatis membuat akun Admin *default* berikut yang bisa digunakan untuk mencoba aplikasi:
- **Email:** `admin@riskmaster.id`
- **Password:** `password`

Kamu bisa login sebagai Admin dan membuat *User* lain lewat menu Manajemen User di dalam aplikasi.

---

## 🤝 Kontribusi & Akademik
Aplikasi ini dibangun untuk keperluan PBL (*Project Based Learning*). Dilarang keras melakukan komersialisasi dari *source code* ini tanpa izin terkait.
