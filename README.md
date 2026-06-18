# PasarKita — Flutter Marketplace

PasarKita adalah aplikasi marketplace berbasis Flutter dengan backend **Appwrite Cloud**. Mendukung tiga role pengguna: **Admin**, **Seller**, dan **Customer**.

## Tech Stack

- **Framework:** Flutter (Dart SDK ^3.11.4)
- **Backend:** Appwrite Cloud (Database, Storage, Account, Functions)
- **State Management:** Provider + ChangeNotifier
- **Email:** Appwrite Function (Node.js + nodemailer)

## Architecture

```
Appwrite Database → Service Layer → Model → Provider → UI (Widget)
```

## Project Structure

```
lib/
├── core/          # Appwrite config, services (18), theme, utils, widgets
├── data/          # Models (14), dummy (stub)
├── presentation/  # UI by role: admin, seller, customer, auth, checkout
├── providers/     # State management (Auth, Cart, ProductFilter)
└── main.dart      # Entry point
```

## Key Commands

| Command | Purpose |
|---|---|
| `flutter run` | Run on connected device/emulator |
| `flutter analyze` | Lint + static analysis |
| `flutter test` | Run tests |
| `flutter build apk` | Build Android APK |
| `flutter build web` | Build web release |

## Roles & Features

### Admin
Users, Verification, Orders, Transactions, Categories, Products Moderation, Reports (CSV), Promo (static), Withdrawal, Analytics Dashboard

### Seller
Dashboard (analytics), Product Management (CRUD + images), Order Management, Categories, Profile, Withdrawal

### Customer
Dashboard (products from Appwrite), Product Detail, Cart (local), Checkout (with stock lock), Orders, Notifications (TBD), Profile (TBD)

## Documentation

- `PROJECT_STATUS.md` — Module status, progress, priorities
- `penjelasan_struktur.md` — Folder structure, data flow, service/model lists
- `CHANGELOG.md` — Release history
- `AGENTS.md` — Agent/setup instructions

## Status

**Overall Progress: ~85%**

| Module | Status |
|---|---|
| Admin | 95% complete |
| Seller | 95% complete |
| Customer | 70% complete |
| Email System | 50% (function exists, not integrated) |
| Payment | Static UI only |
