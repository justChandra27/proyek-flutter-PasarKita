MODE: IMPLEMENT

Proyek: PasarKita Flutter

Fokus:

Sinkronisasi Seller Mobile dan Admin Mobile dengan Web.

JANGAN:

* Mengubah database
* Mengubah Appwrite
* Mengubah collection
* Mengubah service
* Mengubah repository
* Mengubah provider/bloc/cubit
* Mengubah business logic yang sudah berjalan

Gunakan logic, service, dan data yang sudah ada.

==================================================
TASK 1
SELLER MOBILE - TOMBOL BATALKAN PESANAN
=======================================

Temuan audit:

Web:

* Ada tombol "Batalkan Pesanan"

Mobile:

* Tidak ada

Implementasi:

Tambahkan tombol Batalkan Pesanan pada halaman detail pesanan seller mobile.

Persyaratan:

* Gunakan action yang sama dengan Web.
* Gunakan dialog konfirmasi yang sama jika sudah ada.
* Jangan membuat service baru.
* Jangan membuat API baru.

Verifikasi:

* Tombol hanya muncul pada status yang sama dengan Web.
* Status pesanan berubah dengan flow yang sama seperti Web.

==================================================
TASK 2
SELLER MOBILE - STATISTIK KATEGORI
==================================

Temuan audit:

Web:

* Total Kategori
* Aktif
* Nonaktif

Mobile:

* Tidak ada

Implementasi:

Tambahkan 3 stat card di halaman kategori seller mobile.

Gunakan sumber data yang sama dengan Web.

Jangan membuat query baru jika data sudah tersedia.

==================================================
TASK 3
SELLER MOBILE - DETAIL KATEGORI
===============================

Temuan audit:

Web:

* Total Produk
* Produk Aktif
* Stok Menipis
* Menunggu Review

Mobile:

* Tidak ada

Implementasi:

Tambahkan stat card yang sama pada halaman produk berdasarkan kategori.

Gunakan data yang sudah tersedia.

Jangan mengubah logic produk.

==================================================
TASK 4
SELLER PROFILE
==============

Temuan audit:

Web:
Nama
No HP
Email

Mobile:
Nama
Email
No HP

Implementasi:

Samakan dengan Web:

Nama
No HP
Email

Hanya ubah urutan tampilan.

==================================================
TASK 5
ADMIN MOBILE - LAPORAN
======================

Temuan audit:

Web:

* Search Bar
* Tombol Lihat Semua Produk

Mobile:

* Tidak ada

Implementasi:

Tambahkan:

1. Search Bar
2. Tombol "Lihat Semua Produk"

Gunakan route yang sama dengan Web jika tersedia.

==================================================
VALIDASI
========

Pastikan:

* Tidak ada compile error.
* Flutter analyze tidak menambah issue baru.
* Tidak ada perubahan database.
* Tidak ada perubahan Appwrite.
* Tidak ada perubahan business logic.

==================================================
OUTPUT
======

Laporkan:

1. File yang diubah.
2. Widget yang ditambahkan.
3. Route yang digunakan.
4. Status sebelum/sesudah.
5. Risiko perubahan.
6. Hasil flutter analyze.

## HASIL IMPLEMENTASI

### Task 1 — Tombol Batalkan Pesanan (Seller Mobile)

**File diubah:** `lib/presentation/seller/orders/form_pesanan_seller_mobile.dart`

**Widget ditambahkan:**
- `_statusActions` → method `_canCancel()` untuk deteksi status (`pending`/`processing`)
- `_confirmCancel(BuildContext)` → dialog konfirmasi sebelum cancel
- `OutlinedButton` merah "Batalkan Pesanan" di bawah tombol status utama

**Status:**
| Sebelum | Sesudah |
|---|---|
| Tidak ada tombol batalkan | Tombol muncul untuk status `pending`/`processing` (sama dgn web) |

**Risiko:** Rendah — hanya tambahan UI + call `updateOrderStatus` yang sudah ada.

---

### Task 2 — Statistik Kategori (Seller Mobile)

**File diubah:** `lib/presentation/seller/categories/form_kategori_seller_mobile.dart`

**Widget ditambahkan:**
- `_statCard(label, count, color, icon)` → kartu stat reusable (row dengan icon + angka + label)
- 3 kartu: Total Kategori, Aktif, Nonaktif (ditempatkan antara search bar & grid)

**Sumber data:** `_categories.length`, `_categories.where(c.status == 'active')`, dan kebalikannya.

**Status:**
| Sebelum | Sesudah |
|---|---|
| Tidak ada stat cards | 3 kartu stat di atas grid kategori |

**Risiko:** Rendah — hanya UI, data sudah tersedia.

---

### Task 3 — Detail Kategori Stat Cards (Seller Mobile)

**File diubah:** `lib/presentation/seller/products/form_produk_seller_mobile.dart`

**Widget ditambahkan:**
- `_detailStatCard(count, label, color, icon)` → kartu stat mini untuk inline row
- 4 kartu stat (Total Produk, Aktif, Stok Menipis, Review) muncul sebagai item pertama ListView saat `initialCategory != null`
- Indeks item list disesuaikan dengan offset stat cards

**Sumber data:** `products.where(p.category == _selectedCategory)` — data sudah tersedia dari `SellerProductBuilder`.

**Status:**
| Sebelum | Sesudah |
|---|---|
| Tidak ada stat cards di detail kategori | 4 kartu stat di atas daftar produk |

**Risiko:** Rendah — hanya UI, logika produk tidak berubah.

---

### Task 4 — Urutan Profile (Seller Mobile)

**File diubah:** `lib/presentation/seller/profile/profile_seller_mobile.dart`

**Perubahan:** Field di-cards "INFORMASI PRIBADI" diubah urutannya.

**Sebelum:** Nama → Email → No HP
**Sesudah:** Nama → No HP → Email

**Risiko:** Tidak ada — hanya perubahan urutan widget.

---

### Task 5 — Search Bar & Lihat Semua Produk (Admin Mobile)

**File diubah:** `lib/presentation/admin/mobile/pages/laporan_mobile_page.dart`

**Widget ditambahkan:**
- `TextField` search "Cari laporan..." di bagian atas halaman
- `TextButton.icon` "Lihat Semua Produk" di dalam `_buildTopProducts()` (bawah daftar produk terlaris)

**Route/navigasi:** `Lihat Semua Produk` → `Navigator.push(MaterialPageRoute(builder: (_) => const ProductsMobilePage()))`

**Status:**
| Sebelum | Sesudah |
|---|---|
| Tidak ada search bar | Search bar di bagian atas |
| Tidak ada tombol lihat semua | Tombol "Lihat Semua Produk" navigasi ke ProductsMobilePage |

**Risiko:** Rendah — UI saja, search bar dekoratif (spt web).

---

### Hasil Flutter Analyze

```
27 issues found (same 27 pre-existing — zero new issues introduced)
```

Semua task lulus validasi: ✅ Tidak ada compile error, ✅ Tidak ada issue baru, ✅ Tidak ada perubahan database/Appwrite/service/business logic.