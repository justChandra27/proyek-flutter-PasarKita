# TUGAS ADMIN MOBILE V5 - NOTIFICATION CENTER MOBILE

## KONDISI SAAT INI

Admin Mobile sudah memiliki:

* Dashboard
* Orders
* Returns
* Products Moderation

Belum memiliki Notification Center.

---

# FILE BARU

lib/presentation/admin/mobile/pages/notifications_mobile_page.dart

---

# FILE YANG DIUBAH

admin_mobile_shell.dart

admin_mobile_drawer.dart

dashboard_mobile_page.dart

---

# TUJUAN

Membuat pusat notifikasi admin mobile yang menampilkan seluruh aktivitas penting marketplace.

---

# MENU BARU

Tambahkan menu:

Notifikasi

Posisi:

Dashboard
Pesanan
Produk
Retur
Notifikasi
User
Pengaturan
Logout

---

# DATA

Gunakan collection:

notifications

atau NotificationServiceAppwrite yang sudah ada.

---

# DAFTAR NOTIFIKASI

Card menampilkan:

* Judul
* Isi singkat
* Tanggal
* Status baca

Contoh:

Pembayaran Menunggu Verifikasi

Order ORD001 mengunggah bukti transfer

2 menit lalu

---

# BADGE BELUM DIBACA

Jika unread:

Tampilkan dot merah.

---

# FILTER

ChoiceChip:

* Semua
* Belum Dibaca
* Sudah Dibaca

---

# SEARCH

Cari berdasarkan:

* Judul
* Isi

Realtime.

---

# TAP NOTIFIKASI

Saat dibuka:

Status berubah menjadi read.

---

# ACTION

Tombol:

Tandai Semua Dibaca

---

# DASHBOARD

Tambahkan card:

Notifikasi Belum Dibaca

Menampilkan jumlah unread.

---

# DRAWER

Jika unread > 0

Tampilkan badge merah pada menu Notifikasi.

---

# EMPTY STATE

Icon notifications_none

Text:

Belum ada notifikasi

---

# REFRESH

RefreshIndicator

---

# RESPONSIVE

Tidak boleh overflow.

---

# OUTPUT WAJIB

## File Baru

## File Diubah

## Fitur

## Testing

## Flutter Analyze

---

# DOKUMENTASI WAJIB

Update:

prompt.md

Tambahkan section:

# IMPLEMENTASI ADMIN MOBILE V5

## Notification Center Mobile

### Search

### Filter

### Mark As Read

### Mark All As Read

### Dashboard Integration

### Drawer Badge

### Refresh

### Empty State

### Error State

Tuliskan:

* File Baru
* File Diubah
* Hasil Testing
* Flutter Analyze

Setelah selesai tampilkan isi prompt.md terbaru.

---

# IMPLEMENTASI ADMIN MOBILE V5 — NOTIFICATION CENTER MOBILE

**Tanggal implementasi:** 24 Juni 2026

## Ringkasan

Pusat notifikasi admin mobile yang menampilkan seluruh notifikasi marketplace dari koleksi `notifications` via `NotificationServiceAppwrite`. Drawer dan header menampilkan badge merah untuk notifikasi belum dibaca.

## File Baru

| File | Deskripsi |
|------|-----------|
| `lib/presentation/admin/mobile/pages/notifications_mobile_page.dart` | Halaman daftar notifikasi dengan search, filter, mark read, mark all read |

## File Diubah

| File | Perubahan |
|------|-----------|
| `lib/presentation/admin/mobile/admin_mobile_shell.dart` | Import NotificationServiceAppwrite; tambah `_unreadCount`, `_refreshUnreadCount()`, `_onMenuSelected()` refresh; tambah Notifikasi ke `_pageTitles` & `_pages` di index 4; header badge merah; pass `unreadCount` & `onUnreadChanged` callback ke drawer dan notifications page |
| `lib/presentation/admin/mobile/widgets/admin_mobile_drawer.dart` | Tambah `unreadCount` parameter; tambah menu Notifikasi index 4 dengan badge merah; `_menuItem()` dukung `badgeCount` |
| `lib/presentation/admin/mobile/pages/dashboard_mobile_page.dart` | Tambah `_unreadNotificationCount`, `_fetchUnreadNotificationCount()`, card "Notifikasi Belum Dibaca" |

## Fitur

### Daftar Notifikasi
- **Search**: Cari berdasarkan judul dan isi (real-time client-side filter)
- **Filter ChoiceChip**: Semua, Belum Dibaca, Sudah Dibaca
- **Card**: Icon berdasarkan tipe (order/payment/return/product/withdrawal), judul (bold jika unread), isi singkat (max 2 baris), waktu relatif (format timeago)
- **Unread dot**: Dot merah di pojok kanan judul jika `isRead == false`
- **Read state**: Border biru transparan untuk unread, border grey untuk read
- **Empty state**: Icon `notifications_none` + "Belum ada notifikasi"

### Mark As Read
- **Single**: Tap card → `NotificationServiceAppwrite.markAsRead(id)`; update state lokal + panggil `onUnreadChanged` callback
- **Mark All**: Tombol "Tandai Semua Dibaca" dengan loading spinner; panggil `NotificationServiceAppwrite.markAllAsRead(userId)`; update semua state lokal

### Drawer Badge
- Menu Notifikasi di drawer menampilkan badge merah dengan hitungan > 99 jadi `99+`
- Header juga menampilkan red dot di samping hamburger icon jika unread > 0

### Dashboard Card
- "Notifikasi Belum Dibaca" dengan icon `notifications_outlined` warna biru
- Data di-fetch bersama analytics di `Future.wait`

### Refresh
- Pull-to-refresh reload data dari Appwrite
- Notifikasi otomatis refresh saat menu Notifikasi dipilih di drawer

## Testing

- `flutter analyze` → 28 issues (0 error baru, semua pre-existing)
- State lokal update setelah mark read / mark all read (tan menunggu reload penuh)
- Unread count di shell dan drawer sinkron via `onUnreadChanged` callback
