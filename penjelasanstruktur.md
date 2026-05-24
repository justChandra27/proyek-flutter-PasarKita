# Penjelasan Struktur Proyek PasarKita

## Overview

Struktur proyek PasarKita dibuat menggunakan pendekatan:

- Modular Feature Structure
- Reusable Component
- Semi Clean Architecture
- Provider State Management Ready
- Backend/API Ready

Tujuan struktur ini adalah agar:
- kode lebih rapi
- mudah dikembangkan
- scalable
- mudah maintenance
- mudah dipahami tim developer
- siap menggunakan Firebase/API backend

---

# Struktur Utama

```bash
lib/
├── core/
├── data/
├── providers/
├── presentation/
├── routes/
└── main.dart
```

---

# 1. main.dart

File utama aplikasi Flutter.

Fungsi:
- menjalankan aplikasi
- inisialisasi Firebase
- memanggil MaterialApp
- mengatur Provider
- mengatur route utama

Contoh:
- Firebase.initializeApp()
- MultiProvider()
- MaterialApp()

---

# 2. core/

Folder global yang digunakan di seluruh aplikasi.

Folder ini berisi:
- theme
- constants
- reusable widgets
- helper
- utility

Tujuan:
- menghindari duplikasi kode
- menjaga konsistensi aplikasi

---

## core/constants/

Berisi konstanta global aplikasi.

Contoh:
- warna aplikasi
- ukuran padding
- text global
- API URL

### File:
- app_colors.dart
- app_strings.dart
- api_constants.dart

---

## core/theme/

Berisi konfigurasi tema aplikasi.

Fungsi:
- mengatur warna global
- typography
- dark mode/light mode
- style button
- style input

### File:
- app_theme.dart

---

## core/utils/

Berisi helper function dan utility.

Fungsi:
- formatting currency
- validator form
- extension helper
- helper umum

### File:
- currency_formatter.dart
- validators.dart

---

## core/services/

Berisi service global aplikasi.

Digunakan untuk:
- Firebase
- notification
- storage
- service global lain

### File:
- firebase_service.dart
- storage_service.dart
- notification_service.dart

---

## core/widgets/

Berisi reusable widget.

Widget di sini dapat dipakai ulang di banyak page.

Tujuan:
- kode lebih rapi
- UI konsisten
- mengurangi duplikasi widget

### File:
- custom_button.dart
- custom_textfield.dart
- product_card.dart
- loading_widget.dart
- empty_widget.dart
- error_widget.dart

---

# 3. data/

Folder untuk pengelolaan data aplikasi.

Berisi:
- model
- repository
- datasource
- dummy data

Folder ini menjadi penghubung antara UI dan backend.

---

## data/models/

Berisi model data aplikasi.

Model digunakan untuk:
- representasi data
- mapping JSON
- komunikasi API/Firebase

### File:
- user_model.dart
- product_model.dart
- cart_model.dart
- order_model.dart
- payment_model.dart

Contoh:
- ProductModel.fromJson()
- ProductModel.toJson()

---

## data/datasource/

Berisi sumber data aplikasi.

Datasource dibagi menjadi:
- remote
- local

---

### data/datasource/remote/

Digunakan untuk komunikasi backend/API/Firebase.

Fungsi:
- mengambil data online
- upload data
- update data
- delete data

### File:
- auth_remote_datasource.dart
- product_remote_datasource.dart
- cart_remote_datasource.dart
- order_remote_datasource.dart

Contoh:
- Firebase Auth
- Firestore
- REST API

---

### data/datasource/local/

Digunakan untuk penyimpanan lokal.

Contoh:
- SharedPreferences
- local cache
- token login

### File:
- shared_pref.dart
- local_storage.dart

---

## data/repositories/

Repository berfungsi sebagai penghubung antara:
- Provider
- Datasource

Tujuan:
- memisahkan business logic
- memudahkan maintenance
- mempermudah penggantian backend

Alur:
UI -> Provider -> Repository -> Datasource

### File:
- auth_repository.dart
- product_repository.dart
- cart_repository.dart
- order_repository.dart

---

## data/dummy/

Berisi data sementara (dummy data).

Digunakan saat:
- development awal
- testing UI
- backend belum tersedia

### File:
- dummy_products.dart

---

# 4. providers/

Folder state management aplikasi.

Menggunakan:
- Provider

Fungsi:
- menyimpan state
- mengatur update UI realtime
- mengatur business state aplikasi

Contoh:
- login state
- cart state
- product state

### File:
- auth_provider.dart
- cart_provider.dart
- product_provider.dart
- checkout_provider.dart
- theme_provider.dart

---

# 5. presentation/

Folder tampilan aplikasi (UI).

Berisi:
- halaman aplikasi
- screen
- widget per fitur

Setiap fitur dipisahkan agar:
- modular
- mudah maintenance
- scalable

---

## presentation/auth/

Fitur autentikasi.

Berisi:
- login
- register
- forgot password

### File:
- login_page.dart
- register_page.dart
- forgot_password_page.dart

---

## presentation/home/

Halaman utama aplikasi.

Berisi:
- banner
- kategori
- pencarian
- rekomendasi produk

### File:
- home_page.dart

---

## presentation/product/

Fitur produk marketplace.

Berisi:
- daftar produk
- detail produk
- tambah produk
- edit produk

### File:
- product_page.dart
- product_detail_page.dart
- add_product_page.dart
- edit_product_page.dart

---

## presentation/cart/

Fitur keranjang belanja.

Fungsi:
- tambah produk
- hapus produk
- update quantity

### File:
- cart_page.dart

---

## presentation/checkout/

Fitur checkout dan pembayaran.

Berisi:
- checkout
- payment
- success order

### File:
- checkout_page.dart
- payment_page.dart
- success_page.dart

---

## presentation/orders/

Fitur order pengguna.

Berisi:
- daftar order
- detail order
- tracking order

### File:
- order_page.dart
- order_detail_page.dart

---

## presentation/profile/

Fitur profile pengguna.

Berisi:
- profile
- edit profile
- riwayat order
- pengaturan akun

### File:
- profile_page.dart
- edit_profile_page.dart
- order_history_page.dart
- settings_page.dart

---

## presentation/seller/

Fitur khusus penjual.

Berisi:
- dashboard seller
- produk seller
- order seller
- pendapatan seller

### File:
- seller_dashboard.dart
- seller_products.dart
- seller_orders.dart
- seller_income.dart

---

## presentation/search/

Fitur pencarian produk.

Berisi:
- pencarian produk
- filter pencarian
- hasil pencarian

### File:
- search_page.dart

---

# 6. routes/

Folder pengaturan route/navigation aplikasi.

Fungsi:
- mengatur navigasi halaman
- central route management

### File:
- app_routes.dart

---

# 7. firebase_options.dart

File konfigurasi Firebase.

Digunakan untuk:
- koneksi Flutter ke Firebase
- konfigurasi Android/iOS/Web

File ini dibuat otomatis oleh:
flutterfire configure

---

# Alur Arsitektur Aplikasi

```bash
UI (Presentation)
        ↓
Provider
        ↓
Repository
        ↓
Datasource
        ↓
Firebase / API
```

---

# Penjelasan Alur

## UI (Presentation)
Menampilkan tampilan aplikasi kepada user.

---

## Provider
Mengatur state aplikasi.

---

## Repository
Menjadi penghubung business logic.

---

## Datasource
Mengambil data dari backend/API.

---

## Firebase/API
Tempat penyimpanan data online.

---

# Teknologi yang Digunakan

## Frontend
- Flutter

## Backend
- Firebase

## Database
- Cloud Firestore

## Authentication
- Firebase Auth

## Storage
- Firebase Storage

## State Management
- Provider

## API Client
- Dio

---

# Tujuan Struktur Ini

Struktur ini dibuat agar aplikasi:
- scalable
- clean
- modular
- mudah dikembangkan
- siap backend
- mudah maintenance
- profesional untuk portfolio
- siap dikembangkan menjadi marketplace production
