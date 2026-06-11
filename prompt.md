# Refresh Flow Audit

## ✅ Halaman dengan Refresh Otomatis

| Module | File | Mekanisme |
|---|---|---|
| Seller Orders (Web) — dropdown `_updateOrderStatus` | `form_pesanan_seller_web.dart:701` | `_loadOrders()` setelah `updateOrderStatus` |
| Admin Kategori — add/delete | `form_kategori_web.dart:64,133` | `loadCategories()` setelah mutasi |
| Admin Users — edit/delete | `form_pengguna_web.dart:89,107` | `loadUsers()` setelah mutasi |
| Admin Verifikasi (approve/reject) | `form_verifikasi_web.dart:21-33` | Stream polling 2 detik |
| Seller Produk (Web) — Tambah | `form_produk_seller_web.dart:128` | `await Navigator.push` + `setState` trigger FutureBuilder refetch |
| Cart clear setelah checkout | `success_page.dart:266,292,117` | `CartProvider.clear()` via ChangeNotifier |
| Transaksi Admin | `transaksi_controller.dart` | ChangeNotifier (read-only, tidak ada mutasi) |

## ❌ Halaman dengan Stale Data (perlu reload manual)

| # | Severity | Module | File:Line | Masalah |
|---|----------|--------|-----------|---------|
| 1 | **CRITICAL** | Customer Orders (Web & Mobile) | `pesanan_customer_web.dart:26`, `pesanan_customer_mobile.dart:26` | `_ordersFuture` di `initState` sekali. Pages adalah `const` — tidak pernah dimount ulang. Setelah checkout/status update, data tetap stale. |
| 2 | **HIGH** | Seller Orders (Mobile) | `form_pesanan_seller_mobile.dart:831` | `updateOrderStatus` dipanggil tapi tidak ada `_loadOrders()` setelahnya |
| 3 | **HIGH** | Seller Orders (Web) — tombol inline | `form_pesanan_seller_web.dart:1296` | Second inline `updateOrderStatus` tanpa `_loadOrders()` |
| 4 | **HIGH** | Customer Reviews | `detail_pesanan_customer.dart:503` | `setState` dipanggil tapi `_detailFuture` tidak di-reassign — FutureBuilder tampilkan cached data |
| 5 | **HIGH** | Product Edit (Web) | `product_table_modern.dart:275` | `Navigator.push` tidak di-await, tidak ada refresh |
| 6 | **HIGH** | Product Delete (Web modern & legacy) | `product_table_modern.dart:293`, `product_table.dart:160-218` | Delete: empty `onPressed` (modern) / tidak ada refresh setelah delete (legacy) |
| 7 | **MEDIUM** | Product Form | `product_form_page.dart:143` | `Navigator.pop(context)` tanpa result — caller tidak tahu data berubah |
| 8 | **MEDIUM** | Seller Dashboard (Web & Mobile) | `dashboard_seller_web.dart:20`, `dashboard_seller_mobile.dart:21` | `_analyticsFuture` sekali di `initState`, tidak pernah refresh |
| 9 | **MEDIUM** | Admin Dashboard | `dashboard_admin_web.dart:19` | `_analyticsFuture` sekali, tidak pernah refresh |
| 10 | **MEDIUM** | Checkout — cart clear timing | `checkout_page.dart:95-128` | Cart tidak clear di checkout, hanya di success page saat user klik tombol |

## Rekomendasi Implementasi Refresh (MVP — minimal effort)

### 1. Customer Orders — CRITICAL
**File:** `lib/presentation/customer/orders/pesanan_customer_web.dart`, `pesanan_customer_mobile.dart`
**Fix:** Pindahkan dari `initState` ke `didChangeDependencies` (StatefulWidget) + `_refresh()` callback. Saat halaman jadi aktif (tab index), panggil `_refresh()`. Atau, ubah dari `FutureBuilder` ke state manual + `setState` seperti seller mobile saat reload.

### 2. Seller Orders (Mobile) — HIGH
**File:** `form_pesanan_seller_mobile.dart:831`
**Fix:** Panggil `_loadOrders()` setelah `updateOrderStatus` sukses, sebelum SnackBar.

### 3. Seller Orders (Web) tombol inline — HIGH
**File:** `form_pesanan_seller_web.dart:1296`
**Fix:** Panggil `_loadOrders()` setelah `updateOrderStatus` sukses.

### 4. Customer Reviews — HIGH
**File:** `detail_pesanan_customer.dart:503`
**Fix:** Ganti `_detailFuture` dengan Future baru sebelum `setState`:
```dart
_detailFuture = _loadDetail();
setState(() {});
```

### 5. Seller Products — Edit refresh — HIGH
**File:** `product_table_modern.dart:275`
**Fix:** `await Navigator.push(...)` dan `setState(() {})` setelahnya.

### 6. Seller Dashboard — MEDIUM
**Fix:** Tambah metode `reload()` dan panggil dari halaman lain setelah mutasi data. Atau gunakan `FutureBuilder` dengan key yang berubah untuk trigger reload.

### 7. Product Form pop result — MEDIUM
**File:** `product_form_page.dart:143`
**Fix:** Ubah `Navigator.pop(context)` → `Navigator.pop(context, true)`. Caller cek result.

### 8. Admin Dashboard — MEDIUM
**Fix:** Sama seperti seller dashboard — tambah reload.

## Catatan untuk AGENTS.md / Developer

- **Aturan:** Setiap mutasi data (create/update/delete) harus diikuti oleh refresh UI atau `Navigator.pop(context, true)`.
- **Prioritas MVP:** Customer orders (#1) → Seller mobile refresh (#2) → Customer reviews (#4) → Product edit (#5).
- **Halaman dummy** (Admin Products, Admin Orders) belum perlu disentuh untuk MVP.

Tidak ada file yang diubah — hanya audit.
