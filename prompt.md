MODE: AUDIT + FIX

Proyek: PasarKita Flutter

Fokus:
Return vs Review Logic

====================================================
BUG #1
RETURN MUNCUL SAAT PENDING
==========================

Audit seluruh logic tombol:

"Ajukan Retur"

Periksa:

detail_pesanan_customer.dart

Pastikan tombol retur hanya muncul jika:

order.status == 'completed'

dan

belum pernah mengajukan retur untuk item tersebut.

Tombol retur tidak boleh muncul pada:

pending
processing
shipped
cancelled

====================================================
BUG #2
CUSTOMER RETURN MASIH BISA REVIEW
=================================

Audit seluruh logic review produk.

Periksa:

* form review
* tombol review
* create review
* validation review

Pastikan customer TIDAK dapat membuat review baru jika:

return.status == requested
atau
return.status == approved
atau
return.status == received
atau
return.status == refunded

====================================================
ATURAN BISNIS
=============

Kasus A:

completed
↓
review
↓
return

Review lama tetap dipertahankan.

====================================================

Kasus B:

completed
↓
return
↓
belum pernah review

Customer tidak boleh membuat review baru.

====================================================

# VALIDASI SERVER SIDE

Jangan hanya menyembunyikan tombol.

Tambahkan validasi pada service review.

Jika return aktif ditemukan:

throw exception

agar tidak bisa bypass dari client.

====================================================
OUTPUT
======

1. Bug yang ditemukan.
2. File yang diperiksa.
3. File yang diperbaiki.
4. Sebelum vs sesudah.
5. Apakah review sekarang konsisten dengan fitur retur.


## berikan hasil outputnya di file prompt.md

---

## LAPORAN AUDIT & FIX

### 1. Bug yang ditemukan

**Bug #1 — Tombol "Ajukan Retur" muncul di semua status**
- `detail_pesanan_customer.dart:594` — tombol retur ditampilkan KAPAN PUN, tidak terkondisi `isCompleted`
- Akibat: tombol "Ajukan Retur" muncul pada status `pending`, `processing`, `shipped`, `cancelled`

**Bug #2 — Review masih bisa dibuat setelah retur diajukan**
- `detail_pesanan_customer.dart:573` — tombol "Beri Ulasan" hanya cek `hasReviewed`, tidak cek apakah retur sudah diajukan
- Tidak ada validasi server-side di `ReviewServiceAppwrite.createReview`

### 2. File yang diperiksa

| File | Keterangan |
|------|-----------|
| `lib/presentation/customer/orders/detail_pesanan_customer.dart` | UI tombol retur & review |
| `lib/core/services/review_service_appwrite.dart` | Server-side logic review |
| `lib/core/services/return_service_appwrite.dart` | Service retur (method `hasReturnByOrderItem`) |
| `lib/data/models/return_model.dart` | Model retur (status: requested/approved/received/refunded) |
| `lib/data/models/review_model.dart` | Model review |
| `lib/presentation/customer/returns/form_retur_page.dart` | Halaman form retur (tidak diubah) |

### 3. File yang diperbaiki

| File | Perubahan |
|------|-----------|
| `lib/presentation/customer/orders/detail_pesanan_customer.dart` | Bug #1 + Bug #2 UI |
| `lib/core/services/return_service_appwrite.dart` | Method baru `hasReturnByProductAndOrder` |
| `lib/core/services/review_service_appwrite.dart` | Server-side validation retur + import |

### 4. Sebelum vs Sesudah

**Bug #1 — Return button**

Sebelum:
```
children: [
  if (isCompleted)   // hanya untuk review
    Padding(/* review button */),
  Padding(/* return button */),   // TANPA isCompleted!
]
```

Sesudah:
```
children: [
  if (isCompleted) ...[
    Padding(/* review button with return check */),
    Padding(/* return button */),   // DI DALAM isCompleted
  ],
]
```

**Bug #2 — Review with return check**

Sebelum (review section):
```
if (!hasReviewed) → "Beri Ulasan"
```

Sesudah (review section):
```
if (!hasReviewed) {
  if (!hasReturn) → "Beri Ulasan"
  if (hasReturn) → "Tidak bisa diulas (retur aktif)"
}
```

**Server-side (review_service_appwrite.dart):**
```
Sebelum: duplicate_review check → langsung createDocument
Sesudah: duplicate_review check → hasReturnByProductAndOrder check → createDocument
```

### 5. Apakah review sekarang konsisten dengan fitur retur?

**Ya.** Berikut kasus yang terpenuhi:

| Kasus | Flow | Hasil |
|-------|------|-------|
| A | completed → review → return | Review tetap dipertahankan ("Sudah diulas") |
| B | completed → return → review | Tombol review diganti "Tidak bisa diulas (retur aktif)" + server throw `active_return_exists` |
| C | completed → review (no return) | "Beri Ulasan" normal |
| D | pending/processing/shipped/cancelled | Semua tombol retur & review tersembunyi |

**Validasi server-side** (tidak bisa bypass lewat client):
- `hasReturnByProductAndOrder` di ReturnServiceAppwrite: cari `orderItemId` dari `productId` + `orderId`, lalu cek dokumen retur
- `ReviewServiceAppwrite.createReview` lempar `AppwriteException` jika retur aktif ditemukan