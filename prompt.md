MODE: IMPLEMENT

Proyek: PasarKita Flutter

Prioritas: MEDIUM

Jangan mengubah flow checkout.
Jangan mengubah SMTP.
Jangan mengubah Appwrite Function.
Jangan mengubah approvePayment().
Jangan mengubah UI pesanan.

==================================================

FITUR BARU

Saat Admin atau Seller menolak pembayaran
(rejectPayment),

customer harus menerima notifikasi
di fitur Notifikasi.

==================================================

FILE UTAMA

lib/core/services/order_service_appwrite.dart

Method:

rejectPayment()

==================================================

IMPLEMENTASI

Setelah update:

paymentStatus = 'rejected'

buat notifikasi baru untuk customer.

Gunakan NotificationService yang sudah ada
di proyek.

==================================================

ISI NOTIFIKASI

Title:

"Bukti Transfer Ditolak"

Message:

"Bukti transfer untuk pesanan {ORDER_CODE} ditolak. Silakan upload ulang bukti transfer yang valid melalui halaman pesanan."

Type:

payment_rejected

User:

customerId dari order

==================================================

VALIDATION

Scenario:

Customer upload bukti transfer
↓
paymentStatus = verification
↓
Admin reject
↓
paymentStatus = rejected
↓
Notifikasi customer dibuat
↓
Muncul di halaman Notifikasi Customer

==================================================

AUDIT

Setelah implementasi:

1. File yang diubah.
2. Service notifikasi yang digunakan.
3. Payload notifikasi yang dibuat.
4. Verifikasi customerId yang menerima notif.
5. flutter analyze.
6. Verifikasi tidak mengubah flow approve.

Output ke prompt.md

# PAYMENT REJECT NOTIFICATION REPORT

## Files Modified

| File | Change |
|------|--------|
| `lib/core/services/order_service_appwrite.dart` | Added `getOrderById()` + notification call in `rejectPayment()` |

## Notification Flow

```
rejectPayment(orderId)
  ↓
getOrderById(orderId) → customerId, orderCode
  ↓
databases.updateDocument(paymentStatus → 'rejected')
  ↓
NotificationServiceAppwrite().createNotification(
  userId: current.customerId,
  title: 'Bukti Transfer Ditolak',
  message: 'Bukti transfer untuk pesanan {orderCode} ditolak...',
  type: 'payment_rejected',
  orderId: orderId,
)
  ↓
Muncul di halaman Notifikasi Customer ✅
```

## Notification Payload

| Field | Value |
|-------|-------|
| `userId` | `current.customerId` (dari order) |
| `title` | `"Bukti Transfer Ditolak"` |
| `message` | `"Bukti transfer untuk pesanan {orderCode} ditolak. Silakan upload ulang bukti transfer yang valid melalui halaman pesanan."` |
| `type` | `"payment_rejected"` |
| `orderId` | `orderId` (parameter) |

## Validation

| Check | Status |
|-------|--------|
| Tidak mengubah flow checkout | ✅ |
| Tidak mengubah approvePayment() | ✅ |
| Notifikasi via service existing | ✅ `NotificationServiceAppwrite` |
| customerId dari order benar | ✅ via `getOrderById()` |
| Tidak mengubah UI pesanan | ✅ |

## flutter analyze

```
27 issues found (0 errors, 1 warning, 26 info)
```
Semua pre-existing — 0 issues dari perubahan ini.

## Final Verdict

✅ **IMPLEMENTASI SELESAI.** `rejectPayment()` sekarang membuat notifikasi ke customer dengan title "Bukti Transfer Ditolak", type `payment_rejected`, berisi instruksi untuk upload ulang. Tidak ada perubahan pada `approvePayment()` atau flow bisnis lain.