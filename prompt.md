# AUDIT & PLAN — Sistem Pembayaran & Struk PasarKita

## 1. AUDIT KONDISI SAAT INI

### 1.1 Alur Checkout Saat Ini

```
CartProvider / BuyNow
  → CheckoutPage (lib/presentation/checkout/checkout_page.dart)
    → Input: alamat, telepon, metode pembayaran
    → Validasi: stok, status produk
    → OrderServiceAppwrite.createOrder()
      → Lock stok + cek stok
      → Buat document di `orders` collection
      → Buat document di `order_items` collection
      → Kurangi stok produk
      → Release lock
    → CartProvider.clear()
    → Navigasi ke SuccessPage
```

### 1.2 Payment Method Saat Ini

**CheckoutPage** (line 34-38) menawarkan 3 metode:
- Kartu Kredit
- Transfer Bank (default)
- E-Wallet

**Tidak ada integrasi payment gateway nyata** — metode hanya string label, tanpa logika pemrosesan pembayaran.

### 1.3 Order Status Flow

```
pending → processing → shipped → completed
    ↘ cancelled
```

Transisi diatur di `OrderServiceAppwrite.updateOrderStatus()` (`order_service_appwrite.dart:385-576`). Tidak ada logika pembayaran — status pesanan tidak terkait status pembayaran.

### 1.4 File yang Menangani Checkout

| File | Peran |
|---|---|
| `lib/presentation/checkout/checkout_page.dart` | UI checkout, input alamat & payment method, trigger createOrder |
| `lib/presentation/checkout/success_page.dart` | Tampilan sukses setelah order dibuat |
| `lib/presentation/checkout/payment_page.dart` | **LEGACY** — QR payment page, tidak dipanggil oleh checkout flow |

### 1.5 File yang Menangani Order

| File | Peran |
|---|---|
| `lib/core/services/order_service_appwrite.dart` | CRUD order + order_items + updateStatus + admin list |
| `lib/data/models/order_model.dart` | Model Order |
| `lib/data/models/order_item_model.dart` | Model OrderItem |
| `lib/data/models/processing_phase.dart` | Enum phase untuk rollback safety |

### 1.6 File yang Menangani Transaksi

| File | Peran |
|---|---|
| `lib/core/services/transaksi_service.dart` | CRUD transaksi dari collection `transaksi` |
| `lib/data/models/transaksi_model.dart` | Model Transaksi (metode: transfer_bank/e_wallet/tunai/visa/qris) |
| `lib/core/controllers/transaksi_controller.dart` | State management transaksi (Provider) |
| `lib/presentation/admin/transactions/form_transaksi_web.dart` | UI admin untuk daftar transaksi |

### 1.7 Seller Order Pages

| File | Peran |
|---|---|
| `lib/presentation/seller/orders/form_pesanan_seller_web.dart` | Manajemen pesanan seller (web) — 1374 line |
| `lib/presentation/seller/orders/form_pesanan_seller_mobile.dart` | Manajemen pesanan seller (mobile) — 878 line |

### 1.8 Collection Appwrite yang Terlibat

| Collection | Dokumen | Digunakan Oleh |
|---|---|---|
| `orders` | `orderCode, customerId, customerName, customerEmail, totalAmount, serviceFee, status, paymentMethod, paymentStatus, address, notes, createdAt, updatedAt, phone, shippingAddress, shippingCity, shippingProvince, shippingPostalCode` | OrderServiceAppwrite |
| `order_items` | `orderId, productId, productName, sellerId, price, quantity, subtotal, platformFee, sellerAmount, imageUrl, color, size` | OrderServiceAppwrite |
| `transaksi` | `customer_id, customer_name, metode, jumlah, status, created_at, items` | TransaksiService |
| `users` | `uid, name, email, role, status, storeName, storeAddress, city, province, phone, shippingAddress, ...` | AuthServiceAppwrite |
| `products` | `sellerId, name, price, stock, imageUrl, soldCount, ...` | ProductServiceAppwrite |
| `seller_balances` | `sellerId, balance, totalEarned, totalWithdrawn` | BalanceServiceAppwrite |

### 1.9 Dependency Terkait Pembayaran

**Tidak ada dependency payment gateway.** `pubspec.yaml` hanya berisi:
- `appwrite: ^17.0.0` — backend
- `provider: ^6.1.2` — state management
- Tidak ada Midtrans, Xendit, Stripe, atau payment SDK lainnya

---

## 2. GAP ANALYSIS — Data Struk

### 2.1 Data yang SUDAH Tersedia

| Data Struk | Sumber | Status |
|---|---|---|
| Logo PasarKita | Asset | ✅ Bisa ditambahkan |
| Judul "Bukti Pembayaran Pesanan" | Hardcoded | ✅ |
| Total Transaksi | `order.totalAmount` | ✅ |
| Nomor Referensi | `order.orderCode` | ✅ |
| ID Pesanan | `order.id` | ✅ |
| Tanggal Transaksi | `order.createdAt` | ✅ |
| Metode Pembayaran | `order.paymentMethod` | ✅ (akan diubah ke bank name) |
| Status Pembayaran | `order.paymentStatus` | ✅ |
| Nama Customer | `order.customerName` | ✅ |
| Email Customer | `order.customerEmail` | ✅ |
| Nama Produk | `orderItem.productName` | ✅ |
| Jumlah | `orderItem.quantity` | ✅ |
| Harga | `orderItem.price` | ✅ |
| Subtotal | `orderItem.subtotal` | ✅ |
| Biaya Admin | `order.serviceFee` | ✅ |
| Total | `order.totalAmount` | ✅ |

### 2.2 Data yang BELUM Tersedia

| Data Struk | Sumber | Status |
|---|---|---|
| Username Customer | `users` collection | ❌ Tidak di-pass ke order |
| Nama Toko (Seller) | `users` collection → `storeName` | ❌ Tidak di-order items |
| Nama Seller | `users` collection → `name` | ❌ Hanya `sellerId` di order_items |
| Kota Seller | `users` collection → `city` | ❌ Tidak di-order items |
| Email Seller | `users` collection → `email` | ❌ Tidak di-order items |
| QR Code Transaksi | Perlu di-generate | ❌ |
| Bank details (nama bank, no rekening) | Perlu dikonfigurasi | ❌ |

### 2.3 Collection Baru yang Diperlukan

| Collection | Tujuan | Fields |
|---|---|---|
| `payment_receipts` | Menyimpan metadata struk | `orderId, receiptNumber, pdfFileId, generatedAt, sentToCustomer, sentToSeller, sentToAdmin` |
| `email_logs` (opsional) | Tracking pengiriman email | `recipient, subject, status, sentAt, error` |

### 2.4 Apakah Perlu Appwrite Storage untuk PDF?

**Ya.** PDF struk perlu disimpan agar bisa:
- Di-download kembali oleh customer
- Dikirim via email (attachment URL)
- Direferensi oleh admin

Perlu bucket baru: `receipts` atau gunakan bucket `product_images` dengan path terpisah.

### 2.5 Apakah Perlu Appwrite Function untuk Email?

**Alternatif:**
- **Opsion A (sederhana):** Gunakan SMTP langsung dari backend function (Appwrite Function) + library Dart seperti `mailer`
- **Opsi B (external service):** SendGrid / Mailgun API via HTTP dari Appwrite Function
- **Opsi C (client-side):** Kirim dari Flutter langsung — **tidak disarankan** (API key terekspos)

**Rekomendasi:** Appwrite Function dengan SMTP atau SendGrid.

### 2.6 Apakah Sudah Ada SMTP Terkonfigurasi?

**Tidak ada.** Tidak ada konfigurasi SMTP di mana pun di kode.

### 2.7 Paket Flutter yang Diperlukan

| Kebutuhan | Package | Alasan |
|---|---|---|
| Generate PDF | [`pdf`](https://pub.dev/packages/pdf) | Dart-native PDF creation, no native dependency |
| Preview & Print PDF | [`printing`](https://pub.dev/packages/printing) | Wrapper untuk PDF preview + print |
| Generate QR Code | [`qr_flutter`](https://pub.dev/packages/qr_flutter) | QR widget Flutter |
| Download PDF | `path_provider` + `share_plus` | **Sudah tersedia** via `path_provider` (dependency appwrite) |
| Email sending | [`mailer`](https://pub.dev/packages/mailer) | SMTP client untuk Dart |

---

## 3. FILE YANG TERDAMPAK

### 3.1 File yang Perlu DIUBAH

| File | Perubahan |
|---|---|
| `lib/presentation/checkout/checkout_page.dart` | Ganti payment method dari 3 opsi menjadi daftar bank (BCA, BRI, Mandiri, BNI, BTN). Tambah field input untuk nama pengirim transfer. |
| `lib/core/services/order_service_appwrite.dart` | Tambah field `bankName`, `senderName`, `receiptUrl` ke order document. Ubah logic pembayaran — order dibuat dengan status `payment_verification`. |
| `lib/data/models/order_model.dart` | Tambah field: `bankName`, `senderName`, `receiptImage`, `paymentConfirmedAt` |
| `lib/data/models/transaksi_model.dart` | Ganti enum metode — hanya `transfer_bca`, `transfer_bri`, `transfer_mandiri`, `transfer_bni`, `transfer_btn` |
| `lib/presentation/checkout/success_page.dart` | Tambah tombol "Lihat Struk" / "Download Struk". Tampilkan ringkasan bank tujuan transfer. |
| `lib/presentation/customer/orders/pesanan_customer_mobile.dart` | Tambah tombol "Struk" di card order |
| `lib/presentation/customer/orders/detail_pesanan_customer.dart` | Tambah section struk, tombol download |
| `lib/presentation/customer/profile/profile_customer_mobile.dart` | Tambah field input email di dialog Personal Information |
| `lib/presentation/seller/profile/profile_seller_mobile.dart` | Tambah field input email |
| `lib/presentation/admin/admin_page.dart` (profile admin) | Tambah field input email |
| `lib/core/appwrite/appwrite_config.dart` | Tambah bucket ID baru untuk receipts, collection ID untuk payment_receipts |

### 3.2 File Baru yang Perlu Dibuat

| File | Tujuan |
|---|---|
| `lib/core/services/receipt_service.dart` | Generate PDF struk, upload ke Storage, simpan metadata |
| `lib/core/services/email_service.dart` | Kirim email via Appwrite Function atau SMTP client |
| `lib/presentation/struk/struk_pdf.dart` | Widget/template PDF struk menggunakan package `pdf` |
| `lib/presentation/struk/struk_viewer_page.dart` | Halaman preview struk di aplikasi |
| `lib/data/models/payment_receipt_model.dart` | Model untuk collection `payment_receipts` |
| `lib/presentation/admin/transactions/form_transaksi_web.dart` (update) | Admin juga bisa lihat struk |

### 3.3 Risk Assessment — Dampak Perubahan

| Role | Dampak |
|---|---|
| **Customer** | Checkout: hanya melihat bank, transfer manual, upload bukti. Order detail: ada tombol struk + download. Profile: bisa input email. |
| **Seller** | Menerima notifikasi & email struk. Lihat struk di detail pesanan. Profile: input email. |
| **Admin** | Transaksi: filter by bank. Verifikasi bukti transfer (manual). Menerima email struk. |

### 3.4 Risiko Kompatibilitas dengan Fitur Lama

| Risiko | Mitigasi |
|---|---|
| Order existing dengan payment method "Kartu Kredit" / "E-Wallet" — akan tetap muncul sebagai string lama | Backward compat: di UI, jika `paymentMethod` bukan nama bank, tampilkan nilai aslinya |
| Collection `orders` — field baru (`bankName`, `senderName`, etc) adalah opsional | Gunakan null check, tidak perlu migrasi data |
| Collection `transaksi` — metode lama tetap ada | Filter admin tetap bisa bacanya |
| `SuccessPage` yang sudah ada tetap jalan | Struk viewer adalah tambahan, bukan perubahan total |

---

## 4. FLOW TRANSAKSI BARU

```
Cart → CheckoutPage
  → Pilih bank (BCA/BRI/Mandiri/BNI/BTN)
  → Input nama pengirim
  → OrderServiceAppwrite.createOrder()
    → order.status = 'pending'
    → order.paymentStatus = 'unpaid'
    → order.paymentMethod = 'Transfer BCA'
    → order.bankName = 'BCA'
    → order.senderName = input user
  → Navigasi ke SuccessPage
    → Tampilkan: nomor rekening bank tujuan, total transfer
    → Tombol: "Upload Bukti Transfer"
    → Tombol: "Lihat Struk" (setelah dikonfirmasi)
    → Tombol: "Kembali ke Toko"
  → Upload bukti transfer → update order.paymentReceiptImage
    → order.paymentStatus = 'verification'
  → Admin/Seller verifikasi bukti → order.paymentStatus = 'paid'
    → order.status = 'processing' (otomatis)
  → Order berjalan normal: processing → shipped → completed
```

### Status Baru Order (terkait pembayaran)

```
[unpaid] → [verification] → [paid]
                ↓ (ditolak)
            [rejected] → [unpaid] (bisa upload ulang)
```

---

## 5. FLOW EMAIL BARU

### 5.1 Alur Email

```
Order Completed
  → ReceiptService.generateReceipt()
    → Buat PDF struk (package `pdf`)
    → Upload PDF ke Appwrite Storage (bucket: `receipts`)
    → Simpan metadata ke collection `payment_receipts`
  → EmailService.sendReceiptEmail()
    → Kirim email ke customer (dari profile customer)
    → Kirim email ke seller (dari profile seller)
    → Kirim email ke admin (dari konfigurasi)
```

### 5.2 Kapan Email Dikirim

| Momen | Ke | Fungsi |
|---|---|---|
| Order completed (status = completed) | Customer, Seller, Admin | Kirim struk + notifikasi selesai |
| Payment confirmed (status = paid) | Customer, Seller | Konfirmasi pembayaran diterima |
| Order shipped | Customer | Notifikasi pengiriman |

### 5.3 Email Service

**Pilihan Implementasi:**
1. **Appwrite Function** (Node.js) — terpisah dari Flutter code, dipanggil via HTTP
2. **SMTP Dart** (`mailer` package) — langsung dari Flutter/backend logic
3. **SendGrid/Mailgun API** — dari Appwrite Function

**Rekomendasi:** Appwrite Function dengan `nodemailer` (Node.js) untuk SMTP. Function dipanggil dari Flutter via Appwrite Functions SDK.

---

## 6. STRUKTUR DATA STRUK PEMBAYARAN

### 6.1 Struk PDF — Data Model

```
ReceiptData {
  header: {
    logo: Uint8List,
    title: "Bukti Pembayaran Pesanan"
  }
  summary: {
    totalTransaction: int
  }
  paymentDestination: {
    storeName: String,
    sellerName: String,
    sellerCity: String
  }
  transactionInfo: {
    referenceNumber: String,   // orderCode
    orderId: String,           // order.$id
    date: String,              // order.createdAt
    paymentMethod: String,     // "Transfer BCA"
    paymentStatus: String      // "LUNAS"
  }
  customerData: {
    name: String,
    username: String,
    email: String
  }
  sellerData: {
    storeName: String,
    name: String,
    email: String
  }
  products: [{
    name: String,
    quantity: int,
    price: int
  }]
  paymentSummary: {
    subtotal: int,
    adminFee: int,
    total: int
  }
  verification: {
    qrCodeData: String,       // orderCode atau URL verifikasi
  }
  footer: {
    text: "PasarKita Marketplace",
    note: "Bukti transaksi resmi sistem PasarKita"
  }
}
```

### 6.2 Collection `payment_receipts`

```json
{
  "orderId": "string",
  "receiptNumber": "string",           // auto-generated: RCP-20240618-XXXX
  "pdfFileId": "string",               // Appwrite Storage file ID
  "pdfUrl": "string",                  // URL untuk download
  "generatedAt": "datetime",
  "sentToCustomer": true,
  "sentToSeller": true,
  "sentToAdmin": true,
  "customerEmail": "string",
  "sellerEmail": "string",
  "adminEmail": "string"
}
```

---

## 7. ESTIMASI KOMPLEKSITAS IMPLEMENTASI

| Modul | File Baru | File Diubah | Kompleksitas |
|---|---|---|---|
| **A. Payment method → Bank Only** | 0 | 3 | Rendah ⭐ |
| **B. Profile email input per role** | 0 | 3 | Rendah ⭐ |
| **C. Upload bukti transfer** | 1 | 2 | Sedang ⭐⭐ |
| **D. Verifikasi pembayaran** | 0 | 2 | Sedang ⭐⭐ |
| **E. Generate PDF struk** | 2 | 0 | Sedang ⭐⭐ |
| **F. QR Code di struk** | 0 | 1 | Rendah ⭐ |
| **G. Download/Preview PDF** | 1 | 2 | Sedang ⭐⭐ |
| **H. Email sending (Appwrite Function)** | 1 (JS) + 1 | 1 | Tinggi ⭐⭐⭐ |
| **I. UI Struk Viewer** | 1 | 2 | Sedang ⭐⭐ |

**Total:** ~8 file baru, ~16 file diubah. Estimasi: **sedang-tinggi** karena email function memerlukan setup Appwrite Function + SMTP.

---

## 8. URUTAN IMPLEMENTASI PALING AMAN

### Fase 1: Payment Method + Profile Email (Rendah)

```
Step 1: Tambah field email ke profile customer, seller, admin
  → File: profile_customer_mobile.dart, profile_seller_mobile.dart, admin pages
  
Step 2: Ubah CheckoutPage — hanya bank
  → File: checkout_page.dart
  → Hapus Kartu Kredit, E-Wallet
  → Tambah daftar bank (BCA, BRI, Mandiri, BNI, BTN)
  → Tambah field input nama pengirim

Step 3: Ubah OrderModel + OrderServiceAppwrite
  → Tambah field: bankName, senderName, paymentReceiptImage
  → Ubah createOrder() untuk menerima field baru
  → Update OrderModel.fromMap() / toMap()
```

### Fase 2: Upload + Verifikasi (Sedang)

```
Step 4: Upload bukti transfer
  → Service: upload ke Appwrite Storage bucket
  → UI: tombol "Upload Bukti Transfer" di SuccessPage + order detail
  
Step 5: Verifikasi pembayaran (oleh admin/seller)
  → Status baru: verification → paid / rejected
  → UI: admin/seller bisa lihat bukti, approve/tolak
```

### Fase 3: PDF Struk + Download (Sedang)

```
Step 6: Generate PDF struk
  → Package: pdf, printing, qr_flutter
  → Service: ReceiptService.generateReceipt()
  → Template: struk_pdf.dart

Step 7: Preview + Download PDF
  → Halaman: struk_viewer_page.dart
  → Tombol download di order detail + success page
```

### Fase 4: Email Struk (Tinggi)

```
Step 8: Appwrite Function untuk email
  → Setup Appwrite Function (Node.js)
  → Konfigurasi SMTP / SendGrid API key

Step 9: Integrasi panggil Function
  → Panggil dari ReceiptService setelah PDF jadi
  → Kirim ke customer, seller, admin
```

**Rekomendasi:** Implementasi **Fase 1 → 2 → 3** terlebih dahulu. **Fase 4** bisa dilakukan terpisah karena tidak blocking alur pembayaran.
