# Changelog

## [1.0.0] — June 2026

### Added
- Appwrite backend integration (auth, database, storage)
- Role-based UI: Admin, Seller, Customer
- Admin module: Users, Verification, Orders, Transactions, Categories, Products, Reports, Withdrawal, Promo (static)
- Seller module: Dashboard, Product Management, Order Management, Categories, Profile, Withdrawal
- Customer module: Dashboard, Product Detail, Cart, Checkout, Orders, Notifications, Profile
- Auth system: Login, Register via AuthServiceAppwrite
- 18 Appwrite services (auth, product, order, transaksi, category, storage, review, notification, bank, balance, withdrawal, stock lock, receipt, admin analytics, seller analytics, CSV export)
- 14 data models (Product, User, Order, Cart, Category, Transaksi, OrderItem, Review, Notification, SellerBalance, Withdrawal, StockLock, Bank, PaginatedResponse)
- Provider state management (Auth, Cart, ProductFilter)
- PDF receipt generation with QR code
- CSV export (mobile & web)
- Seller analytics dashboard
- Admin analytics dashboard
- Stock lock system to prevent overselling
- Multi-phase order creation with rollback
- Product moderation (approve/reject)
- Product reviews & ratings
- Seller balance & withdrawal system
- Notifications system
- SMTP Email function (Appwrite Function, Node.js + nodemailer)
- SharedPreferences cart persistence
- Responsive web design for admin, seller, and customer modules

### Changed
- Migrated from Firebase to Appwrite (Firebase dependencies deprecated)
- Customer module transition from dummy data to Appwrite-connected services (Dashboard, Orders, Product Detail)

### Fixed
- N/A (initial release)

### Removed
- Firebase active code (commented-out firebase_storage dependency, firebase_options.dart remains as legacy)

## [1.1.0] — June 2026

### Added
- SMTP email integration: EmailServiceAppwrite calls Appwrite email_receipt function after checkout
- Appwrite Functions client added to AppwriteService (functions.createExecution)
- AppwriteConfig.emailReceiptFunctionId constant
- Dynamic email receipt template in email_receipt Appwrite Function (customer name, items table, totals)
- `email_service_appwrite.dart` service layer for sending receipt emails
- Fire-and-forget email sending in checkout_page.dart (non-blocking)

### Changed
- `appwrite_config.dart` — added emailReceiptFunctionId constant
- `appwrite_service.dart` — added `Functions` static client
- `checkout_page.dart` — sends receipt email after order creation before navigating to SuccessPage
- `functions/email_receipt/index.js` — rewrote from static test email to dynamic receipt generator

### Fixed
- Appwrite Function now accepts real customer email and order data payload

### Removed
- Static test email mode in email_receipt function (replaced with dynamic receipt)
