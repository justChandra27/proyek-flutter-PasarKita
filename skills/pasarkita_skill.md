# PasarKita AI Skill

## Objective

Membantu pengembangan marketplace PasarKita tanpa merusak struktur proyek.

---

## Before Writing Code

Selalu lakukan:

1. Analisis file yang sudah ada.
2. Cari service yang sudah tersedia (18 services).
3. Cari model yang sudah tersedia (14 models).
4. Cari widget yang sudah tersedia.
5. Baca `AGENTS.md`, `PROJECT_STATUS.md`, dan `penjelasan_struktur.md` untuk konteks.

Baru kemudian menulis kode.

---

## Forbidden Actions

Dilarang:
- overwrite seluruh file
- membuat versi file baru (_v2, _new)
- membuat duplicate service/model/widget
- menghapus file tanpa konfirmasi
- membuat file stub/stub baru
- menggunakan Firebase (Appwrite adalah backend aktif)

---

## Existing Services (18 total)

| Service | Untuk |
|---|---|
| AuthServiceAppwrite | Register, login, logout, current user |
| ProductServiceAppwrite | CRUD produk, pagination, moderation |
| OrderServiceAppwrite | Create order (stock lock), get orders, update status |
| TransaksiService | Transaksi admin, statistik |
| CategoryServiceAppwrite | CRUD kategori |
| StorageServiceAppwrite | Upload/delete gambar & PDF |
| ReceiptServiceAppwrite | Generate PDF receipt + QR code |
| ReviewServiceAppwrite | CRUD review, stats produk |
| EmailServiceAppwrite | Send receipt email via Appwrite Function |
| NotificationServiceAppwrite | Create notif, unread count |
| BankService | Get banks list |
| BalanceServiceAppwrite | Add seller earnings |
| WithdrawalServiceAppwrite | Pending withdrawals |
| StockLockService | Lock stok saat checkout (TTL) |
| AdminAnalyticsService | Admin analytics dashboard |
| SellerAnalyticsService | Seller analytics dashboard |
| CsvExportService | Abstraksi CSV export |
| CsvExportServiceMobile | CSV export mobile |
| CsvExportServiceWeb | CSV export web |

---

## Customer Module Rules

- **Dashboard**: SUDAH terhubung Appwrite via ProductFilterProvider
- **Product Detail**: SUDAH terhubung Appwrite via ProductServiceAppwrite
- **Cart**: Menggunakan SharedPreferences (local) via CartProvider — **bukan Appwrite**
- **Checkout**: SUDAH terhubung Appwrite via OrderServiceAppwrite (stock lock + rollback)
- **Orders**: SUDAH terhubung Appwrite via OrderServiceAppwrite
- **Notifications**: Belum diverifikasi
- **Profile**: Belum diverifikasi

Jangan gunakan data hardcoded/dummy untuk customer — semua dashboard, produk, dan order sudah dari Appwrite.

---

## Output Rules

Sebelum mengubah kode, tampilkan:
- file yang akan diubah
- alasan perubahan
- risiko perubahan
