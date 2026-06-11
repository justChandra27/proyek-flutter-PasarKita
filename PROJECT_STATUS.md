# PROJECT_STATUS.md

# PasarKita Project Status

Last Updated: June 2026

---

# Project Overview

PasarKita adalah aplikasi marketplace berbasis Flutter dengan backend Appwrite.

Tech Stack:

* Flutter
* Appwrite Database
* Appwrite Storage
* Provider State Management

Role:

* Admin
* Seller
* Customer

---

# Backend Status

## Appwrite

Status: ACTIVE

Digunakan untuk:

* Authentication
* Database
* Storage

---

## Firebase

Status: DEPRECATED

Migrasi ke Appwrite sudah dilakukan.

Sisa yang ditemukan:

* firebase_options.dart
* dependency firebase_storage

Tidak ditemukan penggunaan Firebase aktif pada fitur utama.

Jangan membuat fitur baru menggunakan Firebase.

---

# Current Collections

users

Menyimpan:

* profile user
* role
* status verifikasi

---

products

Menyimpan:

* produk seller
* harga
* stok
* gambar
* status aktif

---

orders

Menyimpan:

* pesanan customer
* status order
* sellerId
* customerId

---

transaksi

Menyimpan:

* pembayaran
* nominal
* status transaksi

---

categories

Menyimpan kategori produk.

---

# Module Status

## ADMIN

### Users

Status: COMPLETE

Appwrite: YES

Fitur:

* list user
* edit user
* delete user
* update role

---

### Verification

Status: COMPLETE

Appwrite: YES

Fitur:

* verifikasi seller
* update status user

---

### Orders

Status: COMPLETE

Appwrite: YES

Fitur:

* melihat seluruh order
* monitoring order

---

### Transactions

Status: COMPLETE

Appwrite: YES

Fitur:

* list transaksi
* statistik transaksi
* filter transaksi
* search transaksi

---

## SELLER

### Product Management

Status: COMPLETE

Appwrite: YES

Fitur:

* tambah produk
* edit produk
* upload gambar
* list produk seller

Storage:

* Appwrite Storage

Database:

* products collection

---

### Order Management

Status: NEED REVIEW

Belum diaudit sepenuhnya.

Perlu pengecekan sinkronisasi dengan customer checkout.

---

## CUSTOMER

### Dashboard

Status: NOT CONNECTED

Appwrite: NO

Saat ini:

* produk hardcoded
* belum membaca products collection

Target:

* menampilkan produk seller dari Appwrite

Priority: HIGH

---

### Product Detail

Status: UNKNOWN

Belum diaudit.

Priority: HIGH

---

### Cart

Status: NOT CONNECTED

Appwrite: NO

Saat ini:

* data dummy
* subtotal dummy
* checkout belum berfungsi

Priority: HIGH

---

### Checkout

Status: NOT IMPLEMENTED

Appwrite: NO

Target:

* create order
* create transaksi
* update stock

Priority: HIGH

---

### Orders

Status: NOT CONNECTED

Appwrite: NO

Saat ini:

* order dummy
* tidak membaca orders collection

Priority: HIGH

---

### Profile

Status: NOT CONNECTED

Appwrite: NO

Saat ini:

* data profile hardcoded

Target:

* membaca user login Appwrite
* update profile

Priority: MEDIUM

---

# Data Flow

Target flow sistem:

Seller
↓
Tambah Produk
↓
products collection
↓
Customer Dashboard
↓
Customer Detail Produk
↓
Cart
↓
Checkout
↓
orders collection
↓
Seller Orders

dan

orders collection
↓
Admin Orders

serta

Checkout
↓
transaksi collection
↓
Admin Transactions

---

# Existing Services

Gunakan service yang sudah ada.

JANGAN membuat service baru jika fungsi sudah tersedia.

Available:

* AuthServiceAppwrite
* ProductServiceAppwrite
* OrderServiceAppwrite
* StorageServiceAppwrite
* TransaksiService

---

# Existing Models

Gunakan model yang sudah ada.

JANGAN membuat model duplikat.

Available:

* ProductModel
* UserModel
* OrderModel
* CartModel
* CategoryModel
* TransaksiModel

---

# Critical Development Rules

DO NOT:

* overwrite file besar
* membuat service_v2
* membuat file duplicate
* membuat folder baru tanpa alasan
* menghapus file tanpa konfirmasi

ALWAYS:

* gunakan file yang sudah ada
* gunakan Appwrite
* lakukan perubahan sekecil mungkin
* jelaskan file yang diubah

---

# Next Development Priority

Priority 1

Customer Dashboard
→ ProductServiceAppwrite

Customer Cart
→ Appwrite

Customer Checkout
→ OrderServiceAppwrite

Customer Orders
→ orders collection

---

Priority 2

Customer Profile
→ users collection

---

Priority 3

Audit Seller Orders
→ sinkronisasi dengan customer checkout

---

# Definition of Done

Marketplace dianggap selesai jika:

Seller tambah produk
↓
Customer melihat produk
↓
Customer checkout
↓
Order masuk ke seller
↓
Order muncul di admin
↓
Transaksi muncul di admin
↓
Status order dapat diperbarui

Semua menggunakan Appwrite Database dan Appwrite Storage.
