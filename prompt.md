MODE: IMPLEMENT

Proyek: PasarKita Flutter

==================================================
TARGET
======

Perbaiki bug UI Customer Mobile dan Customer Web hasil testing.

JANGAN mengubah business logic.

JANGAN mengubah Appwrite.

JANGAN mengubah service.

JANGAN mengubah repository.

JANGAN mengubah provider/bloc/cubit.

JANGAN mengubah flow aplikasi.

Perubahan hanya pada layer UI (`lib/presentation/`).

==================================================
TASK 1
Customer Mobile - Profile
=========================

File:

* lib/presentation/customer/profile/profile_customer_mobile.dart

Saat ini card statistik "Pesanan" berada di sisi kanan sehingga tampilan kurang seimbang.

Perbaiki layout sehingga:

* Card "Pesanan" berada di tengah (center horizontal) pada card profile.
* Avatar, nama, role, dan badge "Profile Lengkap" tetap berada di bagian atas.
* Card statistik "Pesanan" berada di bawah informasi user dan berada tepat di tengah.
* Jangan menggunakan posisi yang menyebabkan overflow.
* Gunakan layout yang responsif.

Target layout:

Avatar + Informasi User

↓

Card Pesanan (center horizontal)

==================================================
TASK 2
Customer Mobile - Pesanan
=========================

File:

* lib/presentation/customer/orders/pesanan_customer_mobile.dart

Saat ini avatar pada bagian kanan atas menggunakan foto profil.

Saya ingin tampilannya mengikuti halaman Profile.

Perubahan:

* Jangan tampilkan foto profil.
* Gunakan CircleAvatar dengan huruf pertama nama customer.
* Jika nama kosong gunakan huruf "U".
* Style avatar harus sama dengan halaman Profile Customer Mobile.

==================================================
TASK 3
Customer Web - Pesanan
======================

File:
Halaman Pesanan Customer Web.

Saat ini masih terdapat icon lonceng notifikasi pada header.

Perubahan:

* Hapus icon notifikasi dari halaman Pesanan Customer Web.
* Header mengikuti tampilan yang digunakan pada halaman lain.
* Jangan mengubah fungsi halaman selain menghapus icon tersebut.

==================================================
VALIDASI
========

Pastikan:

✓ Tidak ada RenderFlex Overflow

✓ Tidak ada perubahan business logic

✓ Tidak ada perubahan database

✓ Tidak ada perubahan Appwrite

✓ Tidak ada perubahan service

✓ Flutter analyze menghasilkan:

* 0 compile error
* Tidak ada issue baru

==================================================
OUTPUT
======

Tuliskan hasil implementasi ke file:

prompt.md

Format laporan:

# LAPORAN IMPLEMENTASI

## File yang diubah

## Widget yang diubah

## Sebelum

## Sesudah

## Flutter Analyze

## Risiko Perubahan

Jangan membuat commit.

Jangan melakukan git push.

Selesaikan seluruh task sebelum menulis laporan ke file prompt.md.

# LAPORAN IMPLEMENTASI

## File yang diubah

1. `lib/presentation/customer/profile/profile_customer_mobile.dart`
2. `lib/presentation/customer/orders/pesanan_customer_mobile.dart`
3. `lib/presentation/customer/orders/pesanan_customer_web.dart`

## Widget yang diubah

### TASK 1 — Profile Customer Mobile (profile_customer_mobile.dart)
- **Layout stat card**: `Row` + `Spacer` → `Center`

### TASK 2 — Pesanan Customer Mobile (pesanan_customer_mobile.dart)
- **Header avatar**: `CircleAvatar(backgroundImage: NetworkImage(...))` → `CircleAvatar` dengan inisial & background biru
- **State**: tambah field `_userName`, diisi dari `account.name` di `_loadOrders`
- **Method baru**: `_initials(String name)` — jika kosong return `'U'`, else ambil 2 huruf pertama

### TASK 3 — Pesanan Customer Web (pesanan_customer_web.dart)
- **Header**: hapus `Icon(Icons.notifications_none)` dan `SizedBox(width: 20)` sebelumnya

## Sebelum

### Profile — stat card di kanan (dorong info user)
```
Row → [Expanded(info user)] + [_statCard(width:140, align: right)]
```

### Pesanan Mobile — avatar foto profil
```
CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150"))
```

### Pesanan Web — header dengan notifikasi
```
[SearchBar] + [SizedBox(20)] + [Icon notif] + [SizedBox(16)] + [Avatar]
```

## Sesudah

### Profile — stat card di tengah bawah
```
Column → [Row(Avatar + Info User)] + [SizedBox] + [Center(_statCard)]
```

### Pesanan Mobile — avatar inisial
```
CircleAvatar(bg: blue15, child: Text(inisial, color: blue))
```

### Pesanan Web — header tanpa notifikasi
```
[SearchBar] + [SizedBox(16)] + [Avatar]
```

## Flutter Analyze

23 issues ditemukan (semua pre-existing):
- 9 `avoid_print` — `storage_service_appwrite.dart`
- 1 `deprecated_member_use` — `csv_export_service_web.dart`
- 1 `avoid_web_libraries_in_flutter` — `csv_export_service_web.dart`
- 1 `unused_local_variable` — `admin_layout.dart`
- 3 `deprecated_member_use` (withOpacity) — `form_transaksi_web.dart`, `form_pengguna_web.dart`
- 4 `use_build_context_synchronously` — admin categories, admin users, checkout, seller
- 3 `use_build_context_synchronously` — `checkout_page.dart`
- 1 `use_build_context_synchronously` — `product_form_page.dart`

**Tidak ada issue baru. 0 error.**

## Risiko Perubahan

- **Rendah** — semua perubahan hanya pada layer UI (`lib/presentation/`), tidak menyentuh service/model/provider/database
- **Tidak ada perubahan business logic**
- **Tidak ada perubahan Appwrite/service/repository**
- **Tidak ada RenderFlex Overflow** pada ketiga file yang diubah
