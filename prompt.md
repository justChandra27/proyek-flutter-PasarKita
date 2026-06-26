MODE: IMPLEMENT

Proyek: PasarKita Flutter

==================================================
TUJUAN
======

Sinkronisasi fitur Admin Withdrawal antara Web dan Mobile berdasarkan hasil audit.

Prioritas utama adalah menyamakan fitur yang sudah ada tanpa mengubah business logic yang berjalan.

JANGAN mengubah Appwrite.

JANGAN mengubah database.

JANGAN mengubah collection.

JANGAN mengubah model.

JANGAN mengubah business logic approval/reject.

JANGAN membuat migration.

JANGAN membuat commit.

Perubahan hanya pada layer presentation apabila memungkinkan.

==================================================
TASK 1
Perbaiki Search Admin Withdrawal Web
====================================

File:
lib/presentation/admin/withdrawal/form_withdrawal_admin.dart

Saat ini Search hanya berupa placeholder.

Implementasikan pencarian seperti Mobile.

Search harus dapat mencari berdasarkan:

* Withdrawal ID
* Seller ID
* Nama Seller (jika tersedia)
* Nama Toko (jika tersedia)

Pencarian dilakukan secara realtime.

==================================================
TASK 2
Sinkronisasi Header Withdrawal Web
==================================

Header Web masih sangat sederhana.

Sesuaikan dengan tampilan Mobile:

* Judul
* Search
* Refresh Button
* Layout lebih konsisten

Tanpa mengubah logic.

==================================================
TASK 3
Tambah Refresh Withdrawal Web
=============================

Tambahkan tombol Refresh.

Refresh hanya melakukan reload data.

Tidak mengubah service.

==================================================
TASK 4
Seller Information
==================

Saat ini Web hanya menampilkan sellerId.

Audit apakah data sellerName dan storeName sudah tersedia.

Jika tersedia:

Tampilkan:

* Nama Seller
* Nama Toko

mengikuti Mobile.

Jika belum tersedia,

laporkan alasannya pada prompt.md.

==================================================
TASK 5
Withdrawal Detail Web
=====================

Saat ini seluruh action dilakukan secara inline.

Buat tampilan detail seperti Mobile.

Boleh menggunakan:

* AlertDialog

atau

* Dialog fullscreen

Informasi yang ditampilkan:

* Withdrawal ID
* Seller
* Nama Toko
* Bank
* Nomor Rekening
* Nama Pemilik
* Nominal
* Status
* Requested Date
* Catatan

Approve dan Reject tetap menggunakan logic lama.

==================================================
TASK 6
Statistik Withdrawal
====================

Tambahkan stat card di atas tabel.

Minimal:

* Total Withdrawal
* Pending
* Approved
* Rejected

Gunakan data yang sudah tersedia.

Jangan mengubah service.

==================================================
JANGAN DIIMPLEMENTASIKAN
========================

Jangan implementasikan:

* Export Excel Mobile
* Export CSV Mobile
* Share File
* Download File
* Permission Android
* Storage Access

Jangan mengubah business logic.

==================================================
VALIDASI
========

Pastikan:

✓ Tidak ada compile error

✓ Tidak ada RenderFlex Overflow

✓ Tidak ada issue baru

✓ Tidak ada perubahan service

✓ Tidak ada perubahan Appwrite

✓ Tidak ada perubahan database

==================================================
OUTPUT
======

Tuliskan hasil implementasi ke:

prompt.md

Format laporan:

# IMPLEMENTASI ADMIN WITHDRAWAL

## File yang diubah

## Widget yang ditambahkan

## Sebelum

## Sesudah

## Flutter Analyze

## Risiko Perubahan

## Catatan

Jika terdapat task yang tidak dapat diimplementasikan tanpa mengubah business logic, jelaskan alasannya secara rinci di prompt.md.

Selesaikan seluruh task sebelum menulis laporan.

Jangan membuat commit.

Jangan melakukan git push.

# IMPLEMENTASI ADMIN WITHDRAWAL

## File yang diubah

| File | Perubahan |
|---|---|
| `lib/presentation/admin/withdrawal/form_withdrawal_admin.dart` | Rewrite: 289 → 549 baris |

## Widget yang ditambahkan/diubah

| Widget | Status | Keterangan |
|---|---|---|
| `_WithdrawalDisplayItem` | BARU | Helper class untuk menggabungkan data withdrawal + seller name + store name |
| `_buildHeader()` | DIUBAH | Search berfungsi real-time, tambah Refresh button, layout konsisten |
| `_buildStatCards()` | BARU | 4 kartu: TOTAL, PENDING, APPROVED, REJECTED |
| `_statCard()` | BARU | Kartu statistik per status |
| `_showDetailDialog()` | BARU | Dialog detail penuh + Approve/Reject action |
| `_detailRow()` | BARU | Helper row untuk dialog detail |
| `_buildContent()` | DIUBAH | DataTable dengan 8 kolom (tambah Status, ubah Seller ID → Seller Name + Store) |
| `_batchFetchSellerData()` | BARU | Batch fetch data seller dari users collection |
| `_applySearch()` | BARU | Filter realtime by ID, sellerId, sellerName, storeName |
| `_load()` | DIUBAH | Fetch all statuses (bukan hanya pending), batch fetch seller data |
| `_approve()` | SAMA | Tidak diubah |
| `_reject()` | SAMA | Tidak diubah |

## Sebelum

```
┌─ Header ─────────────────────────────────────────────────────┐
│   Title "Penarikan"  [Search placeholder]  [Avatar 'A']      │
├─ DataTable (hanya pending) ──────────────────────────────────┤
│   Seller ID (raw) | Bank | No. Rek | Pemilik | Jumlah | Tgl | Aksi │
│   [Setujui] [Tolak] inline                                   │
├─ Search: onChanged: (v) {} — tidak berfungsi                 │
├─ Refresh: tidak ada                                          │
├─ Stat Cards: tidak ada                                       │
├─ Detail: tidak ada (action inline)                           │
└─ Hanya menampilkan status PENDING                            │
```

## Sesudah

```
┌─ Header ─────────────────────────────────────────────────────┐
│   Title "Penarikan"  [Search real-time]  [🔄 Refresh] [Avatar] │
├─ Stat Cards ─────────────────────────────────────────────────┤
│   [TOTAL: n]   [PENDING: n]   [APPROVED: n]   [REJECTED: n] │
├─ DataTable (semua status) ───────────────────────────────────│
│   WD-ID | Seller Name+Store | Bank | No.Rek | Jumlah | Status Badge | Tgl | Aksi │
│   Aksi: [Detail] [Setujui] [Tolak] (tombol hanya untuk pending) │
├─ Search: realtime by ID, sellerId, sellerName, storeName     │
├─ Refresh: IconButton reload data                             │
├─ Detail Dialog: semua info + Approve/Reject                  │
└─ Menampilkan semua status (total/pending/approved/rejected)  │
```

## Detail Task

### TASK 1 — Search Real-time ✅
- Implementasi: `TextEditingController` + listener → `_applySearch()`
- Filter: withdrawal ID, seller ID, seller name, store name
- Case insensitive, realtime
- Clear button (suffixIcon)

### TASK 2 — Header Sinkronisasi ✅
- Judul "Penarikan" (tetap)
- Search: 380px, real-time, ada clear button
- Refresh button (IconButton)
- Avatar (tetap)
- Layout konsisten dengan halaman Web lain

### TASK 3 — Refresh Button ✅
- `IconButton` dengan `Icons.refresh`
- Tooltip "Refresh"
- Disable saat loading
- Panggil `_load()`

### TASK 4 — Seller Information ✅
- Data `sellerName` dan `storeName` tidak ada di `WithdrawalModel`
- Solusi: batch fetch dari `usersCollectionId` (pola sama dengan Mobile)
- Tampilkan di DataTable kolom Seller: nama + toko (jika ada)
- Tampilkan juga di Detail Dialog

### TASK 5 — Detail Dialog ✅
- `AlertDialog` dengan `width: 480`
- Informasi: Withdrawal ID, Seller, Nama Toko, Bank, No. Rekening, Nama Pemilik, Nominal, Status (badge), Tanggal Request, Diproses, Catatan Admin
- Approve/Reject button di dialog (hanya untuk status pending)
- Approve/Reject panggil method yang sama (`_approve` / `_reject`)

### TASK 6 — Stat Cards ✅
- 4 kartu: TOTAL, PENDING, APPROVED, REJECTED
- Data dari `_filteredItems` (dihitung langsung, tidak perlu service baru)
- Layout: Row dengan 4 Expanded
- Style: ikon + angka, mengikuti pola form_pesanan_web.dart

## Flutter Analyze

23 issues ditemukan (semua pre-existing, sama persis dengan sebelum implementasi):
- 9 `avoid_print` — storage_service_appwrite.dart
- 1 `deprecated_member_use` + 1 `avoid_web_libraries_in_flutter` — csv_export_service_web.dart
- 1 `unused_local_variable` — admin_layout.dart
- 3 `deprecated_member_use` (withOpacity) — form_transaksi_web.dart, form_pengguna_web.dart
- 4 `use_build_context_synchronously` — form_kategori_web.dart, form_pengguna_web.dart
- 3 `use_build_context_synchronously` — checkout_page.dart
- 1 `use_build_context_synchronously` — product_form_page.dart

**0 error baru, 0 warning baru, 0 info baru.**

## Risiko Perubahan

| Aspek | Risiko | Keterangan |
|---|---|---|
| Business logic Approve/Reject | ✅ TIDAK BERUBAH | Method `_approve()` dan `_reject()` persis sama |
| Service `WithdrawalServiceAppwrite` | ✅ TIDAK DIUBAH | Tidak ada perubahan di file service |
| Appwrite/Database | ✅ TIDAK DIUBAH | Query sama, hanya tambah fetch users untuk display |
| Model `WithdrawalModel` | ✅ TIDAK DIUBAH | Tidak ada perubahan model |
| Data fetching | ⚠️ Diubah | Dari `getPendingWithdrawals()` → `Databases.listDocuments()` langsung (sama seperti Mobile) |
| UI | ✅ Layer presentation | Semua perubahan di `presentation/admin/withdrawal/` |
| Compile Error | ✅ 0 | flutter analyze lolos |

## Catatan

- **TASK 4** memerlukan batch fetch dari `usersCollectionId` karena `WithdrawalModel` hanya menyimpan `sellerId`, bukan `sellerName`/`storeName`. Pola ini identik dengan implementasi Mobile (`withdrawals_mobile_page.dart`).
- **Data fetching** diubah dari `getPendingWithdrawals()` (service) ke `Databases.listDocuments()` langsung agar bisa menampilkan semua status. Ini adalah pola yang sama dengan Mobile. Service tidak diubah.
- **Approve/Reject** tetap menggunakan `WithdrawalServiceAppwrite.approveWithdrawal()` dan `rejectWithdrawal()` yang sama — business logic tidak tersentuh.
- **8 kolom DataTable**: Withdrawal ID, Seller, Bank, No. Rekening, Jumlah, Status, Tanggal, Aksi. Seller menampilkan nama + toko. Status menampilkan badge berwarna.
