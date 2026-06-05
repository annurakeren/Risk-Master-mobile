# RiskMaster — Flutter App Documentation (CLAUDE.md)

Aplikasi mobile untuk evaluasi dan manajemen risiko berbasis metode **EDAS (Evaluation based on Distance from Average Solution)**.
Dibangun dengan Flutter, terhubung ke backend Laravel via REST API.

---

## Daftar Isi

1. [Gambaran Proyek](#1-gambaran-proyek)
2. [Struktur Folder](#2-struktur-folder)
3. [Dependensi](#3-dependensi)
4. [Konfigurasi & Environment](#4-konfigurasi--environment)
5. [Arsitektur App](#5-arsitektur-app)
6. [Models](#6-models)
7. [Services — ApiService](#7-services--apiservice)
8. [Providers (State Management)](#8-providers-state-management)
9. [Screens](#9-screens)
10. [Design System](#10-design-system)
11. [Alur Fitur Utama](#11-alur-fitur-utama)
12. [Backend Laravel (Referensi)](#12-backend-laravel-referensi)
13. [Cara Menjalankan Lokal](#14-cara-menjalankan-lokal)

---

## 1. Gambaran Proyek

| Field | Detail |
|-------|--------|
| **Nama** | Risk Master |
| **Package** | `riskmaster` |
| **Versi** | `1.0.0+1` |
| **Flutter SDK** | `^3.11.4` |
| **Platform Target** | Android (HP fisik & emulator), Web (Chrome) |
| **Backend** | Laravel 11 + Sanctum Auth (folder: `f:\pbl4\framework\riskmasterlaravel`) |
| **Database** | MySQL (`risk_master`) |
| **Metode DSS** | EDAS (Evaluation based on Distance from Average Solution) |
| **Analyze Status** | ✅ 0 issues (per 4 Juni 2026) |

### Fitur Utama
- **Login** dengan autentikasi Sanctum Bearer Token
- **Role-based access**: `admin` vs `user`
- **Admin**: Kelola user, kriteria, alternatif
- **User**: Buat assessment, input matrix nilai, kalkulasi EDAS, lihat hasil ranking
- **EDAS Result**: Ranking alternatif dengan skor AS, NSP, NSN, SP, SN + label kualitas

### Fitur TIDAK Tersedia
- **Self-registration**: Backend tidak punya endpoint `/auth/register`. User dibuat oleh admin via User Management
- **Report download (PDF/Excel)**: Endpoint tersedia di backend tapi belum diimplementasi di Flutter

---

## 2. Struktur Folder

```
lib/
├── main.dart                    # Entry point, MultiProvider setup, SplashRouter
├── config/
│   ├── app_config.dart          # URL backend (local/production toggle)
│   └── app_theme.dart           # Design tokens, ThemeData, AppColors, AppSpacing, AppRadius
├── models/
│   ├── user.dart                # User { id, name, email, role }
│   ├── criteria.dart            # Criteria { id, name, description, type, weight }
│   ├── alternative.dart         # Alternative { id, name, description, source, createdBy }
│   └── assessment.dart          # Assessment + AlternativeValue + EdasResult
├── providers/
│   ├── auth_provider.dart       # Login, logout, checkAuthStatus
│   ├── criteria_provider.dart   # Fetch & CRUD kriteria
│   ├── alternative_provider.dart# Fetch & CRUD alternatif
│   └── assessment_provider.dart # Fetch, create, submitValues, calculateEdas, getEdasResults
├── services/
│   └── api_service.dart         # Singleton Dio HTTP client, semua endpoint method
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart   # Placeholder — menampilkan pesan "tidak tersedia"
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── criteria_screen.dart
│   │   ├── alternative_screen.dart
│   │   └── user_management_screen.dart
│   └── user/
│       ├── user_dashboard.dart      # List assessment + create assessment sheet
│       ├── input_nilai_screen.dart  # Matrix input grid
│       └── edas_result_screen.dart  # Hasil ranking EDAS
└── widgets/
    └── app_widgets.dart         # Shared widgets (LoadingOverlay, SectionHeader, StatusBadge, dll)
```

---

## 3. Dependensi

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.1              # State management (ChangeNotifier)
  dio: ^5.4.0                   # HTTP client
  flutter_secure_storage: ^9.0.0# Simpan token di keystore/keychain
  shimmer: ^3.0.0               # Loading skeleton (tersedia, belum dipakai semua)
  material_design_icons_flutter: ^7.0.7296
  google_fonts: ^6.1.0          # Font Inter
  cupertino_icons: ^1.0.8
```

---

## 4. Konfigurasi & Environment

### `lib/config/app_config.dart`

```dart
class AppConfig {
  static const String _localIp = '192.168.1.10'; // IP WiFi laptop (cek via ipconfig)
  static const String _productionUrl = 'https://api.riskmaster.com/api';
  static const bool isProduction = false;         // false = local, true = production

  static String get baseUrl {
    if (isProduction) return _productionUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api';  // Chrome
    return 'http://$_localIp:8000/api';               // HP fisik / emulator
  }
}
```

**Untuk ganti environment:**
- Local → `isProduction = false`, update `_localIp` dengan IP WiFi laptop
- Production → `isProduction = true`, update `_productionUrl`

> ⚠️ Laravel harus dijalankan dengan `--host=0.0.0.0` agar bisa diakses dari HP/emulator.

---

## 5. Arsitektur App

### Startup Flow

```
main() → ApiService().init() → MultiProvider → RiskMasterApp
  └─ _SplashRouter (animasi fade+slide)
       └─ _checkAuth() setelah 1.2 detik
            ├─ Token ada → role=admin → AdminDashboard
            ├─ Token ada → role=user  → UserDashboard
            └─ Tidak ada token        → LoginScreen
```

### State Management — Provider Pattern

```
AuthProvider       → status login, currentUser, isAdmin
CriteriaProvider   → list kriteria (admin)
AlternativeProvider→ list alternatif
AssessmentProvider → list assessment, create, submit, calculate, results
```

Semua Provider menggunakan `ApiService()` (singleton) untuk HTTP calls.

### Autentikasi

- Token disimpan di **`flutter_secure_storage`** dengan key:
  - `token` — Bearer token Sanctum
  - `user_id` — ID user
  - `user_role` — `admin` atau `user`
  - `user_name` — nama user
- Token di-attach otomatis via Dio interceptor di setiap request
- Header `Accept: application/json` dikirim otomatis
- Jika response 401 → storage dihapus semua (auto-logout)

---

## 6. Models

### `User`
```dart
{ id, name, email, role }
bool get isAdmin => role == 'admin';
```

### `Criteria`
```dart
{ id, name, description, type, weight }
// type: 'benefit' | 'cost'
bool get isBenefit => type == 'benefit';
```

### `Alternative`
```dart
{ id, name, description, source, createdBy }
// source: 'admin' | 'user' — ditentukan otomatis oleh backend berdasarkan role
bool get isFromAdmin => source == 'admin';
```

### `Assessment`
```dart
{ id, userId, title, description, status, alternativesCount,
  expectedCount, filledCount, isComplete, ownerName }
// status: 'draft' | 'completed'
// userId diambil dari owner?.id (AssessmentResource tidak expose user_id langsung)
bool get isCompleted => status == 'completed';
```

### `AlternativeValue`
```dart
{ id?, assessmentId, alternativeId, criteriaId, value }
```

### `EdasResult`
```dart
{ alternativeId, alternativeName, pda, nda, sp, sn, nsp, nsn, asScore, rank, qualityLabel }
// pda & nda: optional (default 0) — hanya ada di POST /calculate response, tidak di GET /results
// alternativeName: diambil dari alternative?.name (nested object dari Laravel)
```

---

## 7. Services — ApiService

Singleton: `ApiService()` — diinit di `main()` via `ApiService().init()`.

### Format Response Laravel

Semua response Laravel menggunakan format:
```json
{ "status": "success", "message": "...", "data": { ... } }
{ "status": "error",   "message": "...", "errors": { ... } }
```

ApiService menggunakan helper `_isSuccess(res)` yang cek `res.data['status'] == 'success'`.

### AUTH

| Method | Endpoint | Return |
|--------|----------|--------|
| `login(email, password)` | `POST /auth/login` | `Map {success, user/message}` |
| `logout()` | `POST /auth/logout` | `void` (hapus storage) |
| `getMe()` | `GET /auth/me` | `Map {success, data}` |

### USERS (Admin only)

| Method | Endpoint | Return |
|--------|----------|--------|
| `getUsers()` | `GET /users` → `data.users[]` | `List<User>` |
| `createUser(name, email, password, role)` | `POST /users` | `bool` |
| `updateUser(id, name, email, role)` | `PUT /users/{id}` | `bool` |
| `deleteUser(id)` | `DELETE /users/{id}` | `bool` |

### CRITERIA (Admin only)

| Method | Endpoint | Return |
|--------|----------|--------|
| `getCriteria()` | `GET /criteria` → `data.criteria[]` | `List<Criteria>` |
| `createCriteria(name, desc, type, weight)` | `POST /criteria` | `bool` |
| `updateCriteria(id, ...)` | `PUT /criteria/{id}` | `bool` |
| `deleteCriteria(id)` | `DELETE /criteria/{id}` | `bool` |

### ALTERNATIVES

| Method | Endpoint | Return |
|--------|----------|--------|
| `getAlternatives()` | `GET /alternatives?per_page=100` | `List<Alternative>` |
| `createAlternative(name, description)` | `POST /alternatives` | `bool` |
| `updateAlternative(id, name, desc)` | `PUT /alternatives/{id}` | `bool` |
| `deleteAlternative(id)` | `DELETE /alternatives/{id}` | `bool` |

> ⚠️ `createAlternative` TIDAK menerima parameter `source` — backend tentukan sendiri dari role user yang login.

### ASSESSMENTS

| Method | Endpoint | Return |
|--------|----------|--------|
| `getAssessments()` | `GET /assessments?per_page=50` | `List<Assessment>` |
| `getAssessmentDetail(id)` | `GET /assessments/{id}` | `Map {success, data: {assessment, criteria, matrix, ...}}` |
| `createAssessment(title, desc, altIds)` | `POST /assessments` → 201 | `Map {success, assessment/message}` |
| `updateAssessment(id, ...)` | `PUT /assessments/{id}` | `bool` |
| `deleteAssessment(id)` | `DELETE /assessments/{id}` | `bool` |
| `submitValues(assessmentId, values)` | `POST /assessments/{id}/values` | `Map {success, data: {filled_count, ...}}` |
| `attachAlternatives(assessmentId, ids)` | `POST /assessments/{id}/alternatives` | `bool` |
| `detachAlternative(assessmentId, altId)` | `DELETE /assessments/{id}/alternatives/{altId}` | `bool` |

### EDAS

| Method | Endpoint | Return |
|--------|----------|--------|
| `calculateEdas(id)` | `POST /assessments/{id}/calculate` | `Map {success, message, data}` |
| `getEdasResults(id)` | `GET /assessments/{id}/results` | `Map {success, data: {assessment, results[], top_recommendation}}` |

### Matrix Format

GET `/assessments/{id}` mengembalikan matrix sebagai nested object:
```json
{
  "matrix": {
    "1": { "1": 0.8, "2": 0.5 },   // alt_id: { crit_id: value }
    "2": { "1": 0.6, "2": 0.9 }
  }
}
```

`InputNilaiScreen` mem-parse format ini di `_load()` untuk auto-fill nilai yang sudah diinput.

---

## 8. Providers (State Management)

### `AuthProvider`
```dart
User? currentUser    // null = belum login
bool isLoggedIn      // currentUser != null
bool isAdmin         // currentUser?.isAdmin
bool isLoading
String? errorMessage

checkAuthStatus()    // dipanggil saat splash, baca dari secure storage
login(email, pass)   // return bool
logout()             // hapus storage + set currentUser = null
```

> ❌ `register()` telah dihapus — backend tidak punya endpoint register.

### `AssessmentProvider`
```dart
List<Assessment> assessments
bool isLoading

fetchAssessments()                        → void
createAssessment(title, desc, altIds)     → Map {success, assessment/message}
submitValues(assessmentId, values)        → Map {success, data/message}
getAssessmentDetail(id)                   → Map {success, data}
calculateEdas(id)                         → Map {success, message, data}
getEdasResults(id)                        → Map {success, data}
```

### `AlternativeProvider`
```dart
addAlternative(name, desc)     → bool   // hanya 2 parameter, tanpa source
editAlternative(id, name, desc) → bool
removeAlternative(id)           → bool
```

### `CriteriaProvider`
```dart
addCriteria(name, desc, type, weight)        → bool
editCriteria(id, name, desc, type, weight)   → bool
removeCriteria(id)                           → bool
double get totalWeight   // total bobot semua kriteria
```

---

## 9. Screens

### Auth

**`LoginScreen`** — Form email + password, pakai `AuthProvider.login()`.
Redirect ke `AdminDashboard` atau `UserDashboard` berdasarkan role.
Tidak ada link ke register (karena fitur tidak tersedia).

**`RegisterScreen`** — Placeholder screen yang menampilkan pesan "Registrasi tidak tersedia, hubungi admin".

### Admin

| Screen | Fungsi |
|--------|--------|
| `AdminDashboard` | Menu navigasi ke 3 fitur admin (grid 2×2) |
| `CriteriaScreen` | List + CRUD kriteria (nama, deskripsi, tipe benefit/cost, bobot) |
| `AlternativeScreen` | List + CRUD alternatif — bisa diakses user juga |
| `UserManagementScreen` | List + CRUD user (admin only) |

### User

**`UserDashboard`**
- Greeting card dengan inisial nama
- Stats row: Selesai / Draft / Total assessment
- Tombol "Lihat Alternatif" & "Assessment Baru"
- List assessment dengan `_AssessmentCard`
- Pull-to-refresh
- `_CreateAssessmentSheet` (bottom sheet): form judul + deskripsi + checkbox pilih alternatif

**`InputNilaiScreen`**
- Menerima `Assessment` object
- Load detail via `getAssessmentDetail()` → unwrap `{success, data}`
- Ambil kriteria dari detail response (fallback: `getCriteria()`)
- Grid matrix: baris = alternatif, kolom = kriteria
- **Auto-fill** dari `data.matrix` (format `{altId: {critId: value}}`)
- Progress bar + counter `filledCount / totalCount`
- Jika status `completed`: matrix read-only + tombol "Lihat Hasil"
- Tombol "Simpan & Hitung EDAS": submit values → calculate → push ke EdasResultScreen

**`EdasResultScreen`**
- Menerima `assessmentId` + `title`
- Load via `getEdasResults()`
- Top Recommendation card (gradient biru)
- List ranking: badge rank, nama alternatif, label kualitas, progress bar AS score
- Sub-scores: NSP, NSN, SP, SN
- Legend kualitas di bawah

---

## 10. Design System

### `AppColors` (lib/config/app_theme.dart)

```dart
primary            = Color(0xFF004AC6)  // Biru institusional
primaryContainer   = Color(0xFF2563EB)
success            = Color(0xFF059669)  // Hijau
warning            = Color(0xFFD97706)  // Amber
error              = Color(0xFFDC2626)  // Merah
background         = Color(0xFFF8FAFF)  // Putih kebiruan
surface            = Color(0xFFFFFFFF)
surfaceVariant     = Color(0xFFF1F5F9)
textPrimary        = Color(0xFF0F172A)
textSecondary      = Color(0xFF475569)
textTertiary       = Color(0xFF94A3B8)
```

### `AppSpacing`
```dart
xs=4, sm=8, md=16, lg=24, xl=32, xxl=48
```

### `AppRadius`
```dart
sm=8, md=12, lg=16, xl=20, full=999
```

### Typography
- Font: **Inter** via `google_fonts`
- Material 3 (`useMaterial3: true`)

### Shared Widgets (`app_widgets.dart`)

| Widget | Fungsi |
|--------|--------|
| `LoadingOverlay` | Overlay semi-transparan + spinner + "Memproses..." |
| `InfoCard` | Card dengan icon, title, value |
| `TypeBadge` | Badge "Benefit" (hijau) / "Cost" (merah) |
| `SourceBadge` | Badge "Admin" (biru) / "User" (amber) |
| `RoleBadge` | Badge role admin/user |
| `StatusBadge` | Badge "Selesai" (hijau) / "Draft" (amber) |
| `SectionHeader` | Label section uppercase dengan trailing widget opsional |
| `showDeleteDialog()` | Dialog konfirmasi hapus |
| `showSnackBar()` | Helper snackbar sukses/error |

### Label Kualitas EDAS

| AS Score | Label | Warna |
|----------|-------|-------|
| ≥ 0.80 | Sangat Direkomendasikan | `AppColors.success` |
| ≥ 0.60 | Direkomendasikan | `AppColors.primary` |
| ≥ 0.40 | Cukup | `AppColors.warning` |
| < 0.40 | Tidak Direkomendasikan | `AppColors.error` |

---

## 11. Alur Fitur Utama

### Alur User — Membuat & Menghitung Assessment

```
UserDashboard
  → [+ Assessment Baru]
  → _CreateAssessmentSheet
      ├─ Isi judul + deskripsi
      ├─ Centang alternatif (checkbox list dari API)
      └─ [Buat Assessment] → POST /assessments → refresh dashboard

  → [tap assessment card]
  → InputNilaiScreen
      ├─ Load: GET /assessments/{id} → unwrap {success, data}
      ├─ Ambil alternatif dari data.assessment.alternatives
      ├─ Ambil kriteria dari data.criteria (fallback: GET /criteria)
      ├─ Auto-fill dari data.matrix (format nested object)
      ├─ Isi grid nilai (matrix alternatif × kriteria)
      └─ [Simpan & Hitung EDAS]
           ├─ POST /assessments/{id}/values (submit semua nilai)
           ├─ POST /assessments/{id}/calculate (kalkulasi EDAS)
           └─ → EdasResultScreen

EdasResultScreen
  ← GET /assessments/{id}/results
  └─ Tampilkan ranking, skor, label kualitas, top recommendation
```

### Alur Admin — Setup Kriteria & Alternatif

```
AdminDashboard → CriteriaScreen
  ├─ GET /criteria (tampilkan list)
  ├─ POST /criteria (tambah — via bottom sheet form)
  ├─ PUT /criteria/{id} (edit)
  └─ DELETE /criteria/{id} (hapus — via dialog konfirmasi)

AdminDashboard → AlternativeScreen
  ├─ GET /alternatives (tampilkan list)
  ├─ POST /alternatives (tambah — tanpa field source!)
  └─ ...edit/hapus

⚠️ Total bobot semua kriteria HARUS = 1.0 sebelum bisa kalkulasi EDAS
```

---

## 12. Backend Laravel (Referensi)

**Lokasi:** `f:\pbl4\framework\riskmasterlaravel`

### Setup Local
```bash
cd f:\pbl4\framework\riskmasterlaravel

# 1. Buat database MySQL: risk_master
# 2. Migrate + seed
php artisan migrate --seed

# 3. Jalankan server (wajib --host=0.0.0.0 agar HP bisa akses)
php artisan serve --host=0.0.0.0 --port=8000
```

### Konfigurasi `.env`
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=risk_master
DB_USERNAME=root
DB_PASSWORD=
```

### Endpoint Summary

| Method | Endpoint | Auth | Role |
|--------|----------|------|------|
| POST | `/api/auth/login` | ❌ | - |
| POST | `/api/auth/logout` | ✅ | - |
| POST | `/api/auth/logout-all` | ✅ | - |
| GET | `/api/auth/me` | ✅ | - |
| GET/POST | `/api/users` | ✅ | Admin |
| GET/PUT/DELETE | `/api/users/{id}` | ✅ | Admin |
| GET/POST | `/api/criteria` | ✅ | Admin |
| GET/PUT/DELETE | `/api/criteria/{id}` | ✅ | Admin |
| GET/POST | `/api/alternatives` | ✅ | All |
| GET/PUT/DELETE | `/api/alternatives/{id}` | ✅ | All |
| GET/POST | `/api/assessments` | ✅ | All |
| GET/PUT/DELETE | `/api/assessments/{id}` | ✅ | Owner/Admin |
| GET/POST | `/api/assessments/{id}/values` | ✅ | Owner/Admin |
| POST | `/api/assessments/{id}/alternatives` | ✅ | Owner/Admin |
| DELETE | `/api/assessments/{id}/alternatives/{alt_id}` | ✅ | Owner/Admin |
| POST | `/api/assessments/{id}/calculate` | ✅ | Owner/Admin |
| GET | `/api/assessments/{id}/results` | ✅ | Owner/Admin |
| GET | `/api/assessments/{id}/report/pdf` | ✅ | Owner/Admin |
| GET | `/api/assessments/{id}/report/excel` | ✅ | Owner/Admin |

### Aturan Bisnis Penting

- `POST /calculate` hanya bisa jika: matrix lengkap (semua cell terisi) **AND** total bobot kriteria = 1.0
- Jika matrix belum lengkap → HTTP 422
- Jika assessment sudah `completed` dan coba submit nilai lagi → HTTP 422
- `GET /results` pada assessment status `draft` → HTTP 409
- `source` pada alternatif ditentukan otomatis oleh backend dari role user (`admin` → `SOURCE_ADMIN`, `user` → `SOURCE_USER`)

---

## 13. Cara Menjalankan Lokal

### Backend Laravel
```powershell
# Di terminal pertama (folder riskmasterlaravel)
cd f:\pbl4\framework\riskmasterlaravel
php artisan serve --host=0.0.0.0 --port=8000
```

### Flutter App
```powershell
# Di terminal kedua (folder riskmaster)
cd f:\pbl4\mobprog\riskmaster
flutter pub get
flutter run
```

### Konfigurasi IP (app_config.dart)
- **Emulator Android** → ubah `_localIp` ke IP laptop (misal `192.168.1.10`)
- **HP fisik (WiFi sama)** → ubah `_localIp` ke IP laptop
- **Chrome/Web** → otomatis pakai `127.0.0.1:8000`
- **Production** → set `isProduction = true` + isi `_productionUrl`

### Tips
- Saat develop dengan HP fisik, HP dan laptop harus 1 WiFi, dan server harus `--host=0.0.0.0`
- Jika login 401 terus, cek `device_name` field — Laravel Sanctum buat token per device name
- Cek IP via `ipconfig` di PowerShell, ambil yang adapter WiFi (biasanya `192.168.x.x`)
