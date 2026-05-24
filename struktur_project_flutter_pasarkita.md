# Struktur Project PasarKita — Production Ready

## Overview

Struktur project PasarKita dibuat menggunakan pendekatan:

- Feature First Architecture
- Clean Architecture
- Modular Scalable Structure
- Riverpod State Management
- Laravel REST API Ready
- Midtrans Ready
- Firebase Messaging Ready
- Production Ready

Tujuan struktur ini:

- scalable
- clean
- modular
- mudah maintenance
- mudah dikembangkan tim
- siap production
- reusable component
- backend ready
- testing friendly

---

# Struktur Flutter Frontend

```bash
lib/
│
├── main.dart
│
├── core/
│   │
│   ├── config/
│   │   ├── env.dart
│   │   ├── flavor.dart
│   │   └── app_config.dart
│   │
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_sizes.dart
│   │   ├── app_assets.dart
│   │   └── api_constants.dart
│   │
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── api_interceptor.dart
│   │   ├── api_exception.dart
│   │   └── api_response.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── dark_theme.dart
│   │   └── light_theme.dart
│   │
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── notification_service.dart
│   │   ├── storage_service.dart
│   │   ├── midtrans_service.dart
│   │   └── location_service.dart
│   │
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── validators.dart
│   │   ├── extensions.dart
│   │   ├── helper.dart
│   │   └── debounce.dart
│   │
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   │
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_textfield.dart
│   │   ├── loading_widget.dart
│   │   ├── empty_widget.dart
│   │   ├── error_widget.dart
│   │   ├── product_card.dart
│   │   ├── shimmer_loading.dart
│   │   └── custom_appbar.dart
│   │
│   └── di/
│       └── injection.dart
│
├── shared/
│   ├── models/
│   ├── widgets/
│   └── providers/
│
├── routes/
│   ├── app_routes.dart
│   └── route_names.dart
│
├── features/
│   │
│   ├── splash/
│   │   └── presentation/
│   │       └── pages/
│   │           └── splash_page.dart
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       └── pages/
│   │           └── onboarding_page.dart
│   │
│   ├── auth/
│   │   │
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   │
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   │
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   │
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   │
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       │
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── register_page.dart
│   │       │   └── forgot_password_page.dart
│   │       │
│   │       └── widgets/
│   │
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │
│   ├── product/
│   │   │
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       │   ├── product_page.dart
│   │       │   ├── product_detail_page.dart
│   │       │   ├── add_product_page.dart
│   │       │   └── edit_product_page.dart
│   │       └── widgets/
│   │
│   ├── cart/
│   │   │
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       │   └── cart_page.dart
│   │       └── widgets/
│   │
│   ├── checkout/
│   │   │
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       │   ├── checkout_page.dart
│   │       │   ├── address_page.dart
│   │       │   ├── payment_page.dart
│   │       │   └── success_page.dart
│   │       └── widgets/
│   │
│   ├── payment/
│   │   │
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── orders/
│   │   │
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       │   ├── order_page.dart
│   │       │   └── order_detail_page.dart
│   │       └── widgets/
│   │
│   ├── search/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── search_page.dart
│   │       └── widgets/
│   │
│   ├── profile/
│   │   │
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       │   ├── profile_page.dart
│   │       │   ├── edit_profile_page.dart
│   │       │   ├── order_history_page.dart
│   │       │   └── settings_page.dart
│   │       └── widgets/
│   │
│   ├── notification/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── admin/
│   │   │
│   │   ├── dashboard/
│   │   ├── products/
│   │   ├── categories/
│   │   ├── orders/
│   │   ├── banners/
│   │   ├── flash_sale/
│   │   ├── settings/
│   │   └── users/
│   │
│   └── seller/
│       └── presentation/
│           ├── pages/
│           └── widgets/
│
└── firebase_options.dart
```

---

# Struktur Backend Laravel

```bash
app/
│
├── Http/
│   ├── Controllers/
│   │   ├── API/
│   │   └── Admin/
│   │
│   ├── Middleware/
│   └── Requests/
│
├── Models/
│
├── Repositories/
│
├── Services/
│
├── Helpers/
│
├── Traits/
│
├── Notifications/
│
├── Events/
│
├── Jobs/
│
└── Providers/
│
config/
│
├── midtrans.php
└── services.php
│
routes/
│
├── api.php
├── web.php
└── admin.php
│
database/
│
├── migrations/
├── seeders/
└── factories/
│
public/
│
├── bootstrap/
└── uploads/
│
storage/
│
├── logs/
├── framework/
└── app/
```

---

# Database Tables

```bash
users
categories
products
product_images
product_sizes
product_colors
carts
cart_items
orders
order_items
payments
shipping_costs
bank_accounts
banners
pages
settings
flash_sales
notifications
wishlists
reviews
```

---

# Teknologi Frontend

- Flutter terbaru
- Riverpod
- Dio
- SharedPreferences
- Firebase Messaging
- Clean Architecture
- Responsive UI
- Material 3
- Skeleton Loading
- Infinite Scroll
- Cached Network Image

---

# Teknologi Backend

- Laravel terbaru
- REST API
- Sanctum Authentication
- MySQL
- Midtrans Snap API
- Queue Database
- Cache Database
- Session Database
- Repository Pattern
- Service Layer
- API Resource

---

# Alur Architecture

```bash
Presentation Layer
        ↓
Provider / Riverpod
        ↓
Usecase
        ↓
Repository
        ↓
Datasource
        ↓
Laravel REST API
        ↓
MySQL Database
```

---

# UI/UX Concept

Tema aplikasi:

- Premium Fashion Store
- Elegant Black & Gold
- Modern Minimalis
- Smooth Animation
- Responsive

Komponen:

- Bottom Navigation
- Hero Banner Slider
- Flash Sale Countdown
- Product Grid
- Glassmorphism Card
- Gradient Gold Accent
- Loading Skeleton
- Empty State
- Error State

---

# Fitur Utama

## User

- Authentication
- Product Catalog
- Product Detail
- Cart
- Checkout
- Midtrans Payment
- Manual Transfer
- Tracking Order
- Notification
- Profile User

## Admin

- Dashboard Statistik
- CRUD Produk
- CRUD Kategori
- Manajemen Pesanan
- Pengaturan Toko
- Banner Promo
- Flash Sale
- Payment Management

---

# Tujuan Struktur Ini

Struktur ini dibuat agar project:

- production-ready
- scalable
- clean
- mudah maintenance
- siap teamwork
- mudah testing
- siap deployment
- siap dikembangkan menjadi startup marketplace

# struktur project yang sudah disesuaikan dengan:

- penjelasan struktur sebelumnya,
- requirement E-Commerce Fashion Store fullstack,
- clean architecture,
- Laravel API,
- Riverpod,
- Midtrans,
- production-ready architecture.

# Isi file tersebut mencakup:

- struktur Flutter terbaru,
- struktur Laravel backend,
- clean architecture,
- feature-first architecture,
- folder modular,
- database tables,
- teknologi frontend/backend,
- alur architecture,
- konsep UI/UX premium black & gold.