MODE: IMPLEMENT

Proyek: PasarKita Flutter + Appwrite

==================================================
FASE 6
QR VERIFICATION RECEIPT
=======================

Lanjutkan implementasi setelah PDF Receipt selesai.

Jangan membuat migration.

Jangan mengubah struktur database.

==================================================
TUJUAN
======

Setiap struk PDF memiliki QR Verification.

QR digunakan untuk memverifikasi keaslian struk.

==================================================
DEPENDENCY
==========

Gunakan:

qr_flutter

Jika belum ada.

==================================================
QR CONTENT
==========

Masukkan data:

receiptNumber
orderId
paymentStatus

Format JSON.

Contoh:

{
"receiptNumber":"PKT-20260618-0001",
"orderId":"ORD202606180001",
"paymentStatus":"paid"
}

==================================================
PDF RECEIPT
===========

Pada bagian bawah struk:

QR VERIFICATION

[ QR CODE ]

Scan untuk memverifikasi transaksi.

==================================================
VIEW RECEIPT
============

Customer:

* tetap bisa lihat struk

Seller:

* tetap bisa lihat struk

Admin:

* tetap bisa lihat struk

==================================================
ERROR HANDLING
==============

Jika QR gagal dibuat:

Tetap generate PDF.

Gunakan placeholder text:

QR GENERATION FAILED

==================================================
OUTPUT
======

Lakukan implementasi.

Tulis ke prompt.md:

1. File yang diubah.
2. Dependency yang ditambah.
3. Cara QR dibuat.
4. Testing checklist.
5. Potensi bug.

Fokus hanya pada QR Verification.

Jangan implementasi Email.
