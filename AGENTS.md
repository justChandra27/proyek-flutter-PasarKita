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

## Development Rules
- **DO NOT** create duplicate services, models, or widgets — reuse existing ones.
- **DO NOT** overwrite entire files or create `_v2` / `_new` variants.
- **DO NOT** delete files without asking.
- **ALWAYS** use Appwrite (not Firebase). Firebase leftovers exist but are inactive.
- **ALWAYS** use existing service classes for Appwrite operations.

## Module Status
| Role | Module | Status |
|---|---|---|
| Admin | Users, Verification, Orders, Transactions | COMPLETE (Appwrite connected) |
| Seller | Product Management | COMPLETE (Appwrite connected) |
| Seller | Order Management | NEED REVIEW |
| Customer | Dashboard, Cart, Checkout, Orders, Profile | **NOT CONNECTED** (still dummy/hardcoded) |

Customer modules are the **current development priority** — they must read from Appwrite collections, not use local dummy data.

## Known Code Issues
- `lib/core/appwrite/appwrite_client.dart` is **dead code** — `appwrite_service.dart` is the active client.
- `lib/providers/auth_provider.dart` and `product_provider.dart` are **empty stubs** (0 bytes).
- Firebase leftovers (commented-out `firebase_storage` dependency, `lib/firebase_options.dart`) — the project migrated to Appwrite.
- `AppTheme.darkTheme` is defined in `core/theme/app_theme.dart` but **not applied** in `MaterialApp`.
- `test/widget_test.dart` is entirely commented out — no active tests exist.
- Several core widget/utility files are empty stubs: `custom_button.dart`, `custom_textfield.dart`, `loading_widget.dart`, `currency_formatter.dart`, `app_colors.dart`, `dummy_products.dart`.
- `skills/pasarkita_skill.md` exists but is **not registered** in an `opencode.json` config — it won't auto-load.
