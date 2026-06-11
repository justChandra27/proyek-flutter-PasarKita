## Tahap 4 — Hardening Order Workflow ✅ Selesai

### 1. Validasi Transisi Status (Service Layer)

**File:** `lib/core/services/order_service_appwrite.dart:207-260`

Method `updateOrderStatus()` sekarang:

- **Membaca current status** dari database via `getOrderById()` sebelum mengubah
- **Validasi seller ownership** — query `order_items` dan cocokkan `sellerId`
- **Validasi transisi status** berdasarkan allowed map

### 2. Transisi yang Diizinkan

```
pending    -> processing
processing -> shipped
shipped    -> completed
```

### 3. Transisi yang Ditolak (throw AppwriteException 400)

```
pending       -> shipped
pending       -> completed
processing    -> completed
completed     -> processing
completed     -> pending
cancelled     -> * (apa pun)
*sembarang*   -> delivered (tidak pernah diset oleh kode)
```

### 4. Seller Ownership Check

Jika `sellerId` diberikan, service akan:
- Ambil `order_items` untuk `orderId`
- Periksa apakah ada item dengan `sellerId == sellerId`
- Jika tidak cocok: throw `AppwriteException(403, 'unauthorized_order_access')`

### 5. File yang Diubah

| File | Perubahan |
|---|---|
| `lib/core/services/order_service_appwrite.dart` | Validasi transisi + owner check + parameter `sellerId` |
| `lib/presentation/seller/orders/form_pesanan_seller_mobile.dart` | Store `_sellerId`, pass ke `_OrderCard` → `_StatusActions`, exception handling `AppwriteException` (400/403) |
| `lib/presentation/seller/orders/form_pesanan_seller_web.dart` | Store `_sellerId`, pass ke `_orderItem` → `_StatusButton`, exception handling `AppwriteException` (400/403) |

### 6. Exception Handling di UI

Seller mobile (`_StatusActions`):
```dart
if (e is AppwriteException) {
  if (e.code == 400) message = 'Transisi status tidak valid';
  else if (e.code == 403) message = 'Anda tidak memiliki akses untuk mengubah pesanan ini';
}
```

Seller web (`_StatusButton`):
```dart
if (e.code == 400) message = 'Transisi status tidak valid';
else if (e.code == 403) message = 'Anda tidak memiliki akses untuk mengubah pesanan ini';
```

### 7. Hasil `flutter analyze`

```
31 issues found — semua pre-existing (info/warning):
  - avoid_print (8) — storage_service_appwrite.dart
  - use_build_context_synchronously (3) — pre-existing di file admin/checkout
  - deprecated_member_use (5) — withOpacity di file admin
  - unused_local_variable (1) — admin_layout.dart
  - unnecessary_underscores (10) — cart/checkout/dashboard (pre-existing)
  - unused_element (1) — form_produk_seller_web.dart
  - unused_label (1) — product_table.dart
```

**Tidak ada error/warning baru dari perubahan Tahap 4.**

### 8. Audit Status Lowercase

Semua status di codebase sudah menggunakan lowercase (`pending`, `processing`, `shipped`, `completed`, `cancelled`).

**Catatan:**
- `'delivered'` adalah *ghost status* — muncul di UI switch/case tapi **tidak pernah** diset oleh kode. Hanya backward-compat untuk data lama yang mungkin masih `'delivered'`.
- UI seller/customer tetap handle `'delivered'` via fallback case untuk kompatibilitas data legacy.

### 9. Risiko Tersisa

| Risiko | Dampak | Mitigasi |
|---|---|---|
| **Data legacy** — ada order di DB dengan status `'Delivered'` (capital) atau `'delivered'` yang bukan `'completed'` | Order tersebut tidak bisa diubah statusnya (tidak ada transisi dari `delivered`) | UI masih handle display, tapi tombol update tidak muncul. Aman — data legacy tetap terbaca. |
| **Race condition** — dua seller buka order yang sama dan update bersamaan | Satu update berhasil, satu kena `getOrderById()` stale tapi tetap sukses | Validasi transisi membuat update kedua hanya sukses jika status belum berubah. Risiko rendah karena status berubah searah. |
| **Order items tidak ada** — order punya item yang terhapus atau query gagal | Owner check selalu false → 403 terus | Hanya terjadi jika data korup. Order tanpa items seharusnya tidak bisa dibuat. |
| **Document Security ON** di Appwrite Console untuk collection `order_items` | Query `getOrderItems()` bisa 401 | **Solusi:** Toggle Document Security OFF di Appwrite Console untuk collection `order_items` (rekomendasi sebelumnya). |
