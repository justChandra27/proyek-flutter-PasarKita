# penjelasan_struktur.md

# Struktur Proyek PasarKita

## Backend

Appwrite Cloud (sgp.cloud.appwrite.io, project `marketplacedb`)

### Database Collections:
| Collection ID | Purpose |
|---|---|
| users | User profiles, roles, verification status |
| products | Seller products, price, stock, images |
| categories | Product categories |
| orders | Customer orders, order status |
| order_items | Items per order (sellerId, productId, subtotal, fees) |
| transaksi | Payments, amounts, transaction status |
| notifications | Real-time notifications |
| reviews | Product reviews & ratings |
| seller_balances | Seller earnings balance |
| withdrawals | Seller withdrawal requests |
| stock_locks | Stock locking during checkout (TTL-based) |
| banks | Bank transfer destination list |

### Storage:
- `product_images` — Product images & PDF receipts

### Appwrite Functions:
- `email_receipt` — SMTP email via Node.js + nodemailer (not yet integrated with Flutter)

---

## Folder Penting

```
lib/
├── core/
│   ├── appwrite/          # Appwrite config, client, service singleton, test helpers
│   ├── constants/         # fee_config.dart (active), app_colors.dart (STUB)
│   ├── controllers/       # transaksi_controller.dart
│   ├── models/            # paginated_response.dart
│   ├── services/          # 18 Appwrite services (ALL ACTIVE)
│   ├── theme/             # app_theme.dart (dark theme defined but not applied)
│   ├── utils/             # format_rupiah.dart (active), currency_formatter.dart (STUB)
│   └── widgets/           # custom_button, custom_textfield, loading_widget (ALL STUBS)
├── data/
│   ├── dummy/             # dummy_products.dart (STUB 0 bytes)
│   └── models/            # 14 data models (ALL ACTIVE)
├── presentation/
│   ├── admin/             # 30+ files — full admin dashboard
│   ├── auth/              # Login & Register pages
│   ├── checkout/          # Checkout, Payment, Success pages
│   ├── customer/          # 10+ files — customer dashboard & features
│   └── seller/            # 18 files — seller dashboard & features
├── providers/             # auth_provider, cart_provider, product_filter_provider (ACTIVE), product_provider (STUB)
└── main.dart              # Entry point
```

### core/

**appwrite/**
- `appwrite_config.dart` — Database/settings config (Appwrite collections & buckets)
- `appwrite_service.dart` — **Active singleton** — client SDK untuk semua operasi Appwrite
- `appwrite_client.dart` — **Dead code** — tidak dipakai
- `appwrite_test.dart` — Test koneksi Appwrite
- `login_test.dart` / `register_test.dart` — Helper test login/register

**services/** (19 files — ALL ACTIVE & APPWRITE-CONNECTED)
| Service | Collection | Fungsi Utama |
|---|---|---|
| AuthServiceAppwrite | Account + users | Register, login, logout, getCurrentUser, update profile |
| ProductServiceAppwrite | products | CRUD produk, pagination, moderation, filter seller |
| OrderServiceAppwrite | orders + order_items | Create order (stock lock multi-phase), update status, approve/reject payment |
| TransaksiService | transaksi | CRUD transaksi |
| CategoryServiceAppwrite | categories | CRUD kategori |
| StorageServiceAppwrite | Storage | Upload/delete gambar & PDF |
| ReceiptServiceAppwrite | Storage + orders | Generate PDF receipt + QR code, upload ke Storage |
| ReviewServiceAppwrite | reviews | CRUD review, stats per produk, pagination |
| EmailServiceAppwrite | Functions (email_receipt) | Send receipt email via Appwrite Function |
| NotificationServiceAppwrite | notifications | Create notif, get unread count |
| BankService | banks | Get banks list |
| BalanceServiceAppwrite | seller_balances | Add earnings |
| WithdrawalServiceAppwrite | withdrawals | Pending withdrawals |
| StockLockService | stock_locks | Acquire/release lock dengan TTL |
| AdminAnalyticsService | orders, products, users | Analytics dashboard admin |
| SellerAnalyticsService | products, orders, reviews | Analytics dashboard seller |
| CsvExportService | N/A | Abstraksi export CSV |
| CsvExportServiceMobile | N/A | Export CSV mobile |
| CsvExportServiceWeb | N/A | Export CSV web |

### data/models/

14 model files — ALL ACTIVE:
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

Model tidak berisi logika Appwrite — hanya data classes.

### presentation/

Berisi seluruh UI berdasarkan role.

**admin/** — 30+ files
| Halaman | Status |
|---|---|
| Dashboard | Active (AdminAnalyticsService) |
| Users | Active (users collection) |
| Verification | Active (users collection) |
| Products | Active (products collection) |
| Orders | Active (orders collection) |
| Transactions | Active (transaksi collection) |
| Categories | Active (categories collection) |
| Promo | Static UI only (not Appwrite-connected) |
| Reports | Active (CSV export) |
| Withdrawal | Active (withdrawals collection) |
| Settings | Stub |

**seller/** — 18 files
| Halaman | Status |
|---|---|
| Dashboard | Active (SellerAnalyticsService) |
| Products | Active (ProductServiceAppwrite + Storage) |
| Orders | Active (OrderServiceAppwrite) |
| Categories | Active (CategoryServiceAppwrite) |
| Profile | Active (users collection) |
| Withdrawal | Active (withdrawal + balance) |

**customer/** — 10+ files
| Halaman | Status |
|---|---|
| Dashboard | Active (ProductFilterProvider → Appwrite) |
| Product Detail | Active (ProductServiceAppwrite) |
| Cart | Active (CartProvider → SharedPreferences) |
| Checkout | Active (OrderServiceAppwrite + stock lock) |
| Orders | Active (OrderServiceAppwrite) |
| Notifications | Not yet verified |
| Profile | Not yet verified |

**auth/** — 2 files
| Halaman | Status |
|---|---|
| Login | Active (AuthServiceAppwrite) |
| Register | Active (AuthServiceAppwrite) |

### providers/

| Provider | Status |
|---|---|
| AuthProvider | Active — session, login state, current user |
| CartProvider | Active — CRUD cart, persist SharedPreferences |
| ProductFilterProvider | Active — load products paginated, filter, sort, search |
| ProductProvider | Stub (0 bytes) |

---

# Alur Data

```
Appwrite Database
↓
Service Layer (18 services)
↓
Model (14 models)
↓
Provider (state management)
↓
UI (presentation/)
```

---

# Existing Appwrite Services

Gunakan service berikut. JANGAN membuat service baru jika fungsi sudah tersedia.

**Available Services:**
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

# Status Koneksi Appwrite per Role

## Admin Flow — SUDAH TERHUBUNG APPWRITE
```
Admin Users → users collection
Admin Verification → users collection
Admin Orders → orders collection
Admin Transactions → transaksi collection
Admin Products → products collection
Admin Categories → categories collection
Admin Reports → CSV export
Admin Withdrawal → withdrawals collection
Admin Analytics → aggregated stats
```

## Seller Flow — SUDAH TERHUBUNG APPWRITE
```
Seller Dashboard → SellerAnalyticsService
Seller Products → ProductServiceAppwrite + Storage
Seller Orders → OrderServiceAppwrite
Seller Categories → CategoryServiceAppwrite
Seller Profile → users collection
Seller Withdrawal → withdrawal + balance services
```

## Customer Flow — SUDAH TERHUBUNG APPWRITE (partial)
```
Customer Dashboard → ProductFilterProvider (Appwrite products)
Customer Product Detail → ProductServiceAppwrite
Customer Cart → CartProvider (SharedPreferences — local)
Customer Checkout → OrderServiceAppwrite (with stock lock)
Customer Orders → OrderServiceAppwrite
Customer Notifications → Not yet verified
Customer Profile → Not yet verified
```

---

# File Stub / Kosong (18 file — 0 bytes)

| Path | File |
|---|---|
| lib/core/constants/ | app_colors.dart |
| lib/core/utils/ | currency_formatter.dart |
| lib/core/widgets/ | custom_button.dart, custom_textfield.dart, loading_widget.dart |
| lib/data/dummy/ | dummy_products.dart |
| lib/providers/ | product_provider.dart |
| lib/presentation/admin/users/pages/ | users_page.dart |
| lib/presentation/admin/products/pages/ | products_page.dart |
| lib/presentation/admin/orders/pages/ | orders_page.dart |
| lib/presentation/admin/transactions/pages/ | transactions_page.dart |
| lib/presentation/admin/categories/pages/ | categories_page.dart |
| lib/presentation/admin/promo/pages/ | promos_page.dart |
| lib/presentation/admin/reports/pages/ | reports_page.dart |
| lib/presentation/admin/settings/pages/ | settings_page.dart |
| lib/presentation/admin/dashboard/widgets/ | statistics_grid.dart, dashboard_header.dart, dashboard_empty_state.dart |
