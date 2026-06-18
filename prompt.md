MODE: AUDIT & PLAN

Proyek: PasarKita Flutter + Appwrite

Jangan melakukan implementasi.

Jangan mengubah source code.

Jangan membuat migration.

Jangan membuat commit.

Hanya audit dan tulis hasil ke prompt.md.

==================================================
TUJUAN AUDIT
============

Audit integrasi SellerBalances dan Withdrawals.

PasarKita menggunakan model escrow:

Customer
↓
Transfer ke rekening PasarKita
↓
Verifikasi pembayaran
↓
Seller menerima saldo
↓
Seller melakukan withdrawal

==================================================
YANG HARUS DIAUDIT
==================

1. Collection SellerBalances
2. Collection Withdrawals
3. Service seller balance
4. Service withdrawal
5. Admin withdrawal page
6. Seller withdrawal page
7. Alur approve payment

==================================================
PERTANYAAN YANG HARUS DIJAWAB
=============================

1. Apakah saat paymentStatus menjadi paid
   saldo seller sudah bertambah?

2. Jika sudah:
   file mana yang melakukannya?

3. Jika belum:
   file mana yang harus diubah?

4. Apakah sellerAmount pada order_items
   sudah digunakan?

5. Apakah platformFee sudah digunakan?

6. Risiko double credit saldo seller?

7. Cara paling aman menghindari saldo
   bertambah dua kali?

==================================================
OUTPUT
======

Tulis ke prompt.md:

1. Kondisi saat ini.
2. File terkait.
3. Flow saldo seller saat ini.
4. Gap yang ditemukan.
5. Rencana implementasi.
6. Urutan implementasi paling aman.

Jangan melakukan implementasi.

Hanya audit dan plan.

==================================================
HASIL AUDIT
===========

1. KONDISI SAAT INI
-------------------
Saldo seller BERTAMBAH hanya saat order status berubah menjadi 'completed'
(di method updateOrderStatus -> status 'shipped' -> 'completed').

Saat admin/seller menyetujui pembayaran (approvePayment -> paymentStatus='paid'),
saldo seller TIDAK bertambah. approvePayment hanya mengubah:
- paymentStatus -> 'paid'
- paymentConfirmedAt -> now()
- paymentConfirmedBy -> current userId
- updatedAt -> now()

Seller baru menerima saldo setelah barang dikirim dan customer menyelesaikan
pesanan (status='completed'). Ini tidak sesuai model escrow yang diinginkan
dimana saldo harus masuk setelah verifikasi pembayaran.

2. FILE TERKAIT
---------------
| File | Peran |
|---|---|
| lib/core/services/order_service_appwrite.dart | approvePayment(), updateOrderStatus() |
| lib/core/services/balance_service_appwrite.dart | addEarnings(), getBalance(), createIfNotExists() |
| lib/core/services/withdrawal_service_appwrite.dart | requestWithdrawal(), approveWithdrawal(), rejectWithdrawal() |
| lib/data/models/seller_balance_model.dart | SellerBalance (sellerId, balance, totalEarned, totalWithdrawn) |
| lib/data/models/withdrawal_model.dart | Withdrawal (sellerId, amount, bankName, status, dll) |
| lib/data/models/order_item_model.dart | sellerAmount & platformFee per item |
| lib/data/models/order_model.dart | paymentConfirmedAt, paymentConfirmedBy |
| lib/core/constants/fee_config.dart | serviceFee=2000, platformFeePercent=0.5 |
| lib/presentation/admin/withdrawal/form_withdrawal_admin.dart | Admin approve/reject withdrawal |
| lib/presentation/seller/withdrawal/withdrawal_page.dart | Seller request withdrawal + history |
| lib/presentation/seller/dashboard/dashboard_seller_web.dart | Tampilkan saldo seller (web) |
| lib/presentation/seller/dashboard/dashboard_seller_mobile.dart | Tampilkan saldo seller (mobile) |
| lib/core/services/seller_analytics_service.dart | Total revenue dari sellerAmount |
| lib/core/services/admin_analytics_service.dart | Pending withdrawal count |

3. FLOW SALDO SELLER SAAT INI
------------------------------
CREATE ORDER:
  subtotal = price * quantity
  platformFee = round(subtotal * 0.5 / 100)
  sellerAmount = subtotal - platformFee
  -> Simpan ke order_items collection per item

SELLER PROCESS:
  pending -> processing -> shipped

ADMIN APPROVE PAYMENT: (via approvePayment di order_service_appwrite.dart:598)
  paymentStatus: unpaid -> paid
  paymentConfirmedAt, paymentConfirmedBy diisi
  -> TIDAK ada kredit saldo

SELLER COMPLETE ORDER: (via updateOrderStatus di order_service_appwrite.dart:483)
  shipped -> completed
  -> Untuk setiap order item:
      Product.soldCount += quantity
      BalanceServiceAppwrite().addEarnings(sellerId, sellerAmount)
  -> Saldo seller bertambah

SELLER WITHDRAWAL:
  requestWithdrawal() -> cek balance >= amount -> simpan status='pending'
  Admin approveWithdrawal() -> lock 'balance:$sellerId' -> kurangi balance,
    tambah totalWithdrawn -> status='approved'
  Admin rejectWithdrawal() -> status='rejected' + adminNote (balance tidak berubah)

4. GAP YANG DITEMUKAN
---------------------

GAP #1 [KRITIKAL] Saldo tidak bertambah saat payment diverifikasi
  approvePayment() tidak memanggil addEarnings(). Saldo baru bertambah
  saat status='completed'. Ini TIDAK sesuai model escrow.

GAP #2 [KRITIKAL] approvePayment Fase 3 tidak sesuai model escrow
  Implementasi approvePayment() di Fase 3 hanya update paymentStatus.
  Tidak ada kredit saldo seller sama sekali di situ.

GAP #3 [SEDANG] sellerAmount digunakan di completed, bukan approvePayment
  Di updateOrderStatus -> completed, sudah benar menggunakan sellerAmount:
    item.sellerAmount > 0 ? item.sellerAmount : item.subtotal
  Tapi ini terjadi setelah shipped, bukan setelah payment verified.

GAP #4 [RENDAH] Tidak ada field earningsCredited
  Tidak ada field boolean untuk menandai apakah earnings sudah dikredit.
  Risiko double credit jika kode berubah di masa depan.

GAP #5 [RENDAH] Tidak ada ledger/riwayat transaksi saldo
  Tidak ada collection/log yang mencatat setiap transaksi saldo
  (kapan earning masuk, kapan withdrawal keluar).

5. RENCANA IMPLEMENTASI
-----------------------

OPSI A [RECOMMENDED] Pindahkan addEarnings ke approvePayment
  Sesuai model escrow: pembayaran diverifikasi -> saldo langsung masuk.
  - Di approvePayment(), setelah update paymentStatus, panggil addEarnings
    untuk setiap order item (gunakan getOrderItems(orderId)).
  - Di updateOrderStatus -> completed, HAPUS panggilan addEarnings().
  - HAPUS kredit saldo di completed agar tidak double credit.

OPSI B [SAFETY] Tambahkan di approvePayment + guard di completed
  - approvePayment() panggil addEarnings() + set field earningsCredited=true.
  - updateOrderStatus -> completed: cek earningsCredited dulu,
    jika false baru panggil addEarnings() (fallback safety).
  - Lebih aman tapi butuh field baru di collection orders.

OPSI C [NOT RECOMMENDED] Biarkan di completed (tidak sesuai escrow)
  Tidak perlu perubahan. Tapi ini TIDAK sesuai model escrow.

6. URUTAN IMPLEMENTASI PALING AMAN (OPSI A)
--------------------------------------------
Langkah 1: Edit approvePayment di order_service_appwrite.dart
  - Setelah update paymentStatus, panggil getOrderItems(orderId)
  - Loop items, panggil BalanceServiceAppwrite().addEarnings(sellerId, sellerAmount)
  - Gunakan sellerAmount jika > 0, fallback ke subtotal

Langkah 2: Edit updateOrderStatus di order_service_appwrite.dart
  - Di blok status == 'completed' (line 483-540),
    HAPUS panggilan BalanceServiceAppwrite().addEarnings()
  - Biarkan: update status, soldCount, notification

Langkah 3: Verifikasi
  - Flutter analyze: 0 errors
  - Test: approve payment -> cek seller_balances collection
  - Test: complete order -> cek saldo tidak bertambah dua kali
  - Test: seller withdrawal -> saldo berkurang sesuai