# PasarKita — Flutter Marketplace

## Stack
- **Framework:** Flutter (Dart SDK ^3.11.4, pubspec.yaml:7-8)
- **Backend:** Appwrite cloud (sgp.cloud.appwrite.io/v1, project `marketplacedb`) — see `lib/core/appwrite/appwrite_config.dart:4-8`
- **State:** Provider + ChangeNotifier per feature controller (`lib/main.dart:21-27`)

## Entrypoint
`lib/main.dart` — calls `AppwriteTest.testConnection()` on startup before `runApp`.

## Architecture
**Layer-first** (`core/`, `data/`, `presentation/`, `providers/`) with **role-based UI** (admin/seller/customer) under `presentation/`. No routing package — uses direct `Navigator.push(MaterialPageRoute(...))` and index-based widget swapping within role shells.

## Reference Docs (read before coding)
- **`PROJECT_STATUS.md`** — module completion status, priorities, data flow, dev rules
- **`penjelasan_struktur.md`** — folder structure, data flow, service/model lists
- **`skills/pasarkita_skill.md`** — agent skill rules (not yet registered in `opencode.json`)

## Key Commands
| Command | Purpose |
|---|---|
| `flutter run` | Run on connected device/emulator |
| `flutter analyze` | Lint + static analysis (uses `package:flutter_lints/flutter.yaml`) |
| `flutter test` | Run tests |
| `flutter build apk` / `flutter build web` | Build for release |

## Current System Architecture

```
Flutter UI (presentation/)
  ↓
Providers (state management)
  ↓
Services (Appwrite SDK)
  ↓
Appwrite Cloud (Database, Storage, Account, Functions)
```

### Data Flow
```
Appwrite Database → Service → Model → Provider → UI (Widget)
```

## Appwrite Services Used
| Service | Collection/Feature | Status |
|---|---|---|
| AuthServiceAppwrite | Account + users collection | Active |
| ProductServiceAppwrite | products collection | Active |
| OrderServiceAppwrite | orders + order_items collections | Active |
| TransaksiService | transaksi collection | Active |
| CategoryServiceAppwrite | categories collection | Active |
| StorageServiceAppwrite | product_images storage bucket | Active |
| ReceiptServiceAppwrite | PDF receipt + QR code generation | Active |
| ReviewServiceAppwrite | reviews collection | Active |
| EmailServiceAppwrite | Appwrite Functions (email_receipt) | Active |
| NotificationServiceAppwrite | notifications collection | Active |
| BankService | banks collection | Active |
| BalanceServiceAppwrite | seller_balances collection | Active |
| WithdrawalServiceAppwrite | withdrawals collection | Active |
| StockLockService | stock_locks collection (TTL-based) | Active |
| AdminAnalyticsService | Aggregated admin stats | Active |
| SellerAnalyticsService | Aggregated seller stats | Active |
| CsvExportService | CSV export abstraction | Active |
| CsvExportServiceMobile | CSV export (mobile) | Active |
| CsvExportServiceWeb | CSV export (web) | Active |

## External Integrations
| Integration | Status | Notes |
|---|---|---|
| Appwrite Cloud | Active | Primary backend |
| SMTP Email (Appwrite Function) | **Integrated** | Node.js + nodemailer, called via EmailServiceAppwrite after checkout |
| Firebase | Deprecated | Migrated to Appwrite, leftovers exist (firebase_options.dart) |

## Active Modules

### Admin (COMPLETE — Appwrite connected)
- Users management
- Seller verification
- Orders monitoring
- Transactions with stats, filter, search
- Categories management
- Products moderation
- Reports with CSV export
- Promo (static UI only)
- Withdrawal approval/rejection
- Analytics dashboard

### Seller (COMPLETE — Appwrite connected)
- Dashboard with analytics
- Product management (CRUD + image upload)
- Order management (view, update status)
- Category management
- Profile management
- Withdrawal requests

### Customer (PARTIALLY CONNECTED — mix of Appwrite and local)
- Dashboard: Appwrite connected (ProductFilterProvider)
- Product Detail: Appwrite connected (ProductServiceAppwrite)
- Cart: Local (SharedPreferences via CartProvider)
- Checkout: Appwrite connected (OrderServiceAppwrite with stock lock)
- Orders: Appwrite connected (OrderServiceAppwrite)
- Notifications: Not yet verified
- Profile: Not yet verified

## Deprecated Modules
- Firebase integration (migrated to Appwrite)
- Old dashboard pages (commented out: `dashboard_page.dart`, `admin_dashboard_page.dart`)
- Old product card widget (commented out: `product_card.dart`)

## Development Rules
- **DO NOT** create duplicate services, models, or widgets — reuse existing ones.
- **DO NOT** overwrite entire files or create `_v2` / `_new` variants.
- **DO NOT** delete files without asking.
- **ALWAYS** use Appwrite (not Firebase). Firebase leftovers exist but are inactive.
- **ALWAYS** use existing service classes for Appwrite operations.
- **DO NOT** create new empty stub files — fill existing stubs first.
- **DO NOT** modify the codebase for documentation-only tasks.

## Known Code Issues
- `lib/core/appwrite/appwrite_client.dart` is **dead code** — `appwrite_service.dart` is the active client.
- `lib/providers/product_provider.dart` is an **empty stub** (0 bytes).
- Firebase leftovers (commented-out `firebase_storage` dependency, `lib/firebase_options.dart`) — the project migrated to Appwrite.
- `AppTheme.darkTheme` is defined in `core/theme/app_theme.dart` but **not applied** in `MaterialApp`.
- `test/widget_test.dart` is entirely commented out — no active tests exist.
- Several core widget/utility files are empty stubs: `custom_button.dart`, `custom_textfield.dart`, `loading_widget.dart`, `currency_formatter.dart`, `app_colors.dart`, `dummy_products.dart`.
- 18 empty stub files exist across admin pages (pages subfolders) and dashboard widgets.
- `skills/pasarkita_skill.md` exists but is **not registered** in an `opencode.json` config — it won't auto-load.
- Payment page is static (QR code only, no active payment processing).
- Promo page is static (no Appwrite connection).
- SMTP email function now integrated with Flutter checkout flow (EmailServiceAppwrite).
