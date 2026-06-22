MODE: IMPLEMENT

Proyek: PasarKita Flutter

Prioritas: CRITICAL

Jangan mengubah flow bisnis lain.
Jangan mengubah SMTP.
Jangan mengubah template email.
Jangan mengubah Appwrite Function.
Jangan mengubah status payment yang sudah ada.

==================================================
FIX 1
SELLER TIDAK BOLEH MEMPROSES PESANAN
SEBELUM PEMBAYARAN VALID

File:
lib/core/services/order_service_appwrite.dart

Audit menemukan:

updateOrderStatus()
masih mengizinkan:

pending
↓
processing

meskipun:

paymentStatus != paid

Target:

Seller hanya boleh memproses pesanan jika:

paymentStatus == 'paid'

Jika paymentStatus:

* unpaid
* verification
* rejected

maka:

throw AppwriteException atau Exception yang jelas.

Contoh pesan:

"Pesanan belum dapat diproses karena pembayaran belum diverifikasi."

==================================================
FIX 2
CUSTOMER TIDAK BOLEH MEMBATALKAN PESANAN
SAAT VERIFICATION ATAU PAID

File:
detail_pesanan_customer.dart

Audit menemukan:

Tombol Batalkan Pesanan
masih muncul ketika:

paymentStatus == verification

Target:

Tombol Batalkan Pesanan
HANYA muncul jika:

paymentStatus == 'unpaid'

Tombol harus disembunyikan jika:

* verification
* paid
* rejected

==================================================
VALIDATION

Pastikan:

Scenario A

paymentStatus = unpaid

Customer:

* tombol Batalkan Pesanan muncul

Seller:

* tidak bisa proses pesanan

==================================================

Scenario B

paymentStatus = verification

Customer:

* tombol Batalkan Pesanan tidak muncul

Seller:

* tidak bisa proses pesanan

==================================================

Scenario C

paymentStatus = paid

Customer:

* tombol Batalkan Pesanan tidak muncul

Seller:

* bisa proses pesanan

==================================================

Scenario D

paymentStatus = rejected

Customer:

* tombol Batalkan Pesanan tidak muncul

Seller:

* tidak bisa proses pesanan

==================================================

AUDIT

Setelah implementasi:

1. Tunjukkan file yang diubah.
2. Tunjukkan exact line yang diubah.
3. Tunjukkan guard paymentStatus yang ditambahkan.
4. Tunjukkan kondisi tombol cancel sebelum dan sesudah.
5. Verifikasi flutter analyze.
6. Verifikasi tidak ada perubahan flow lain.

Tuliskan hasil Output ke prompt.md

# PAYMENT SAFEGUARD FIX REPORT

## Files Modified

| File | Change |
|------|--------|
| `lib/core/services/order_service_appwrite.dart` | Added paymentStatus guard before `pending→processing` |
| `lib/presentation/customer/orders/detail_pesanan_customer.dart` | Added `paymentStatus == 'unpaid'` condition to cancel button |

## Seller Processing Guard

**File:** `order_service_appwrite.dart:449-456`

```dart
if (newStatus == 'processing' && current.paymentStatus != 'paid') {
  throw AppwriteException(
    'Pesanan belum dapat diproses karena pembayaran belum diverifikasi.',
    400,
    'payment_not_verified',
  );
}
```

Ditempatkan setelah validasi transisi status, sebelum notifikasi.

**Sebelum:** `pending → processing` selalu diizinkan.
**Sesudah:** hanya diizinkan jika `paymentStatus == 'paid'`.

## Customer Cancel Guard

**File:** `detail_pesanan_customer.dart:314`

**Sebelum:**
```dart
if (order.status == 'pending') ...[
```

**Sesudah:**
```dart
if (order.status == 'pending' && order.paymentStatus == 'unpaid') ...[
```

## Validation Results

| Check | Status |
|-------|--------|
| Tidak mengubah flow checkout | ✅ |
| Tidak mengubah upload bukti transfer | ✅ |
| Tidak mengubah approve/reject payment | ✅ |
| Tidak mengubah template email | ✅ |
| Tidak mengubah Appwrite Function | ✅ |
| Tidak mengubah SMTP | ✅ |
| Tidak mengubah status payment | ✅ |

## Test Scenarios

| Scenario | paymentStatus | Customer: Cancel? | Seller: Process? | Status |
|----------|:-------------:|:---:|:---:|:------:|
| A | `unpaid` | ✅ Muncul | ❌ `payment_not_verified` | ✅ |
| B | `verification` | ❌ Sembunyi | ❌ `payment_not_verified` | ✅ |
| C | `paid` | ❌ Sembunyi | ✅ Diproses normal | ✅ |
| D | `rejected` | ❌ Sembunyi | ❌ `payment_not_verified` | ✅ |

## flutter analyze

```
27 issues found (0 errors, 1 warning, 26 info)
```
Semua pre-existing — 0 issues dari perubahan ini.

## Final Verdict

✅ **IMPLEMENTASI SELESAI.** Kedua safeguard berhasil ditambahkan tanpa mengubah flow bisnis lain.


