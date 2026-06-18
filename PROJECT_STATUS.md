# PasarKita Project Status

Last Updated: June 2026

---

## Project Overview

PasarKita adalah aplikasi marketplace berbasis Flutter dengan backend Appwrite.

### Tech Stack
- Flutter (Dart SDK ^3.11.4)
- Appwrite Cloud (Database, Storage, Account, Functions)
- Provider State Management

### Roles
- Admin
- Seller
- Customer

---

## Progress Keseluruhan

| Role | Progress |
|---|---|
| Admin | 95% |
| Seller | 95% |
| Customer | 80% |
| **Overall** | **88%** |

---

## Module Status

| Module | Status | Progress | Appwrite |
|---|---|---|---|
| Authentication | **COMPLETE** | 100% | Yes |
| Admin Users | **COMPLETE** | 100% | Yes |
| Admin Verification | **COMPLETE** | 100% | Yes |
| Admin Orders | **COMPLETE** | 100% | Yes |
| Admin Transactions | **COMPLETE** | 100% | Yes |
| Admin Categories | **COMPLETE** | 100% | Yes |
| Admin Products | **COMPLETE** | 100% | Yes |
| Admin Reports | **COMPLETE** | 100% | Yes |
| Admin Analytics | **COMPLETE** | 100% | Yes |
| Admin Withdrawal | **COMPLETE** | 100% | Yes |
| Admin Promo | **STATIC UI ONLY** | 20% | No |
| Admin Settings | **STUB** | 0% | No |
| Seller Dashboard | **COMPLETE** | 100% | Yes |
| Seller Products | **COMPLETE** | 100% | Yes |
| Seller Orders | **COMPLETE** | 100% | Yes |
| Seller Categories | **COMPLETE** | 100% | Yes |
| Seller Profile | **COMPLETE** | 100% | Yes |
| Seller Withdrawal | **COMPLETE** | 100% | Yes |
| Customer Dashboard | **CONNECTED** | 100% | Yes |
| Customer Product Detail | **CONNECTED** | 100% | Yes |
| Customer Cart | **LOCAL ONLY** | 80% | No (SharedPreferences) |
| Customer Checkout | **CONNECTED** | 90% | Yes |
| Customer Orders | **CONNECTED** | 100% | Yes |
| Customer Notifications | **NOT VERIFIED** | 50% | TBD |
| Customer Profile | **NOT VERIFIED** | 50% | TBD |
| Stock Lock System | **COMPLETE** | 100% | Yes |
| PDF Receipt | **COMPLETE** | 100% | Yes |
| CSV Export | **COMPLETE** | 100% | N/A |
| Reviews & Ratings | **COMPLETE** | 100% | Yes |
| Seller Balance | **COMPLETE** | 100% | Yes |
| SMTP Email | **INTEGRATED** | 90% | Function called from Flutter after checkout |

---

## Completed Features

- Authentication (Register, Login, Logout) via AuthServiceAppwrite
- Admin full dashboard with analytics (AdminAnalyticsService)
- Admin users management (CRUD, role update, delete)
- Admin seller verification (approve/reject)
- Admin product moderation (approve/reject products)
- Admin orders monitoring (all orders, payment approval)
- Admin transactions (list, stats, filter, search)
- Admin categories management
- Admin reports with CSV export (mobile + web)
- Admin withdrawal approval/rejection
- Seller dashboard with analytics (SellerAnalyticsService)
- Seller product management (CRUD + image upload via Storage)
- Seller order management (view, update status)
- Seller categories management
- Seller profile management
- Seller withdrawal requests
- Customer dashboard (products from Appwrite via ProductFilterProvider)
- Customer product detail (reviews, add to cart, buy now)
- Customer cart (persist via SharedPreferences)
- Customer checkout (order creation with stock lock & multi-phase rollback)
- Customer orders (list from Appwrite, filter by status)
- PDF receipt generation with QR code (ReceiptServiceAppwrite)
- Stock lock system (TTL-based, prevent overselling)
- Product reviews & ratings (CRUD, stats per product)
- Seller balance & withdrawal system
- Notifications system (create, unread count)
- CSV export (platform-aware: mobile temp file, web Blob download)
- SMTP email integration (EmailServiceAppwrite + Appwrite Function email_receipt)

---

## In Progress Features

- Customer notifications integration (not yet verified)
- Customer profile integration (not yet verified)

---

## Pending Features

- Admin promo page (static UI only — no Appwrite connection)
- Admin settings page (stub)
- Payment page (static QR code — no payment processing)
- Unit tests (all tests commented out)
- 18 stub files need implementation or cleanup
- SMTP email receipt delivery to customers
- `AppTheme.darkTheme` not applied in `MaterialApp`
- Register `skills/pasarkita_skill.md` in `opencode.json`

---

## Technical Debt

- `lib/core/appwrite/appwrite_client.dart` — dead code (use `appwrite_service.dart` instead)
- `lib/providers/product_provider.dart` — empty stub (0 bytes)
- Firebase leftovers: `firebase_options.dart`, commented-out `firebase_storage` dependency
- `AppTheme.darkTheme` defined but not applied
- `test/widget_test.dart` — entirely commented out, no active tests
- 18 empty stub files across admin pages and dashboard widgets
- `skills/pasarkita_skill.md` not registered in `opencode.json`
- Payment page is static (QR code only, no active payment processing)
- Promo page is static (no Appwrite connection)
- Customer cart uses local storage (SharedPreferences), not Appwrite

---

## Data Flow

```
Seller → Add Product → products collection
    ↓
Customer Dashboard → ProductFilterProvider → products collection
    ↓
Customer Detail Product → ProductServiceAppwrite
    ↓
Cart → CartProvider (SharedPreferences)
    ↓
Checkout → OrderServiceAppwrite + StockLockService → orders + order_items + stock_locks
    ↓
Seller Orders → OrderServiceAppwrite
    ↓
Admin Orders → OrderServiceAppwrite
    ↓
Transaksi → TransaksiService → transaksi collection
    ↓
Admin Transactions → TransaksiService
```

---

## Existing Services

Gunakan service yang sudah ada. JANGAN membuat service baru jika fungsi sudah tersedia.

**Available (19 services):**
- AuthServiceAppwrite
- ProductServiceAppwrite
- OrderServiceAppwrite
- TransaksiService
- CategoryServiceAppwrite
- StorageServiceAppwrite
- ReceiptServiceAppwrite
- ReviewServiceAppwrite
- EmailServiceAppwrite
- NotificationServiceAppwrite
- BankService
- BalanceServiceAppwrite
- WithdrawalServiceAppwrite
- StockLockService
- AdminAnalyticsService
- SellerAnalyticsService
- CsvExportService
- CsvExportServiceMobile
- CsvExportServiceWeb

---

## Existing Models

Gunakan model yang sudah ada. JANGAN membuat model duplikat.

**Available (14 models):**
- ProductModel
- UserModel
- OrderModel
- CartModel
- CategoryModel
- TransaksiModel
- OrderItemModel
- ReviewModel
- NotificationModel
- SellerBalanceModel
- WithdrawalModel
- StockLockModel
- BankModel
- PaginatedResponse

---

## Development Rules

DO NOT:
- Overwrite entire files or create `_v2` / `_new` variants
- Create duplicate services, models, or widgets
- Delete files without asking
- Create new empty stub files
- Use Firebase (migrated to Appwrite)

ALWAYS:
- Use existing files and services
- Use Appwrite for all backend operations
- Make minimal, focused changes

---

## Next Development Priority

### Priority 1
- Customer Profile → users collection (verify & complete)
- Customer Notifications → notifications collection (verify & complete)

### Priority 2
- Payment page → implement payment processing

### Priority 3
- Admin Promo → connect to Appwrite
- Admin Settings → implement
- Clean up 18 stub files (fill or remove)
- Add unit tests
- Apply `AppTheme.darkTheme` in `MaterialApp`

---

## Definition of Done

Marketplace dianggap selesai jika:

```
Seller tambah produk → products collection
    ↓
Customer melihat produk → ProductFilterProvider
    ↓
Customer checkout → OrderServiceAppwrite
    ↓
Order masuk ke seller → OrderServiceAppwrite
    ↓
Order muncul di admin → OrderServiceAppwrite
    ↓
Transaksi muncul di admin → TransaksiService
    ↓
Status order dapat diperbarui → OrderServiceAppwrite
```

Semua menggunakan Appwrite Database, Appwrite Storage, dan Appwrite Functions.
