lib/
│
├── main.dart
│
├── core/
│   │
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_sizes.dart
│   │   └── api_constants.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── validators.dart
│   │   ├── extensions.dart
│   │   └── helper.dart
│   │
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   │
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_textfield.dart
│       ├── loading_widget.dart
│       ├── product_card.dart
│       ├── empty_widget.dart
│       └── error_widget.dart
│
├── data/
│   │
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── category_model.dart
│   │   ├── cart_model.dart
│   │   ├── order_model.dart
│   │   └── payment_model.dart
│   │
│   ├── datasource/
│   │   │
│   │   ├── remote/
│   │   │   ├── auth_remote_datasource.dart
│   │   │   ├── product_remote_datasource.dart
│   │   │   ├── cart_remote_datasource.dart
│   │   │   └── order_remote_datasource.dart
│   │   │
│   │   └── local/
│   │       ├── local_storage.dart
│   │       └── shared_pref.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── product_repository.dart
│   │   ├── cart_repository.dart
│   │   └── order_repository.dart
│   │
│   └── dummy/
│       └── dummy_products.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   ├── checkout_provider.dart
│   └── theme_provider.dart
│
├── routes/
│   └── app_routes.dart
│
├── presentation/
│   │
│   ├── splash/
│   │   └── splash_page.dart
│   │
│   ├── onboarding/
│   │   └── onboarding_page.dart
│   │
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   ├── forgot_password_page.dart
│   │   └── widgets/
│   │
│   ├── navigation/
│   │   └── navigation_page.dart
│   │
│   ├── home/
│   │   ├── home_page.dart
│   │   └── widgets/
│   │
│   ├── product/
│   │   ├── product_page.dart
│   │   ├── product_detail_page.dart
│   │   ├── add_product_page.dart
│   │   ├── edit_product_page.dart
│   │   └── widgets/
│   │
│   ├── cart/
│   │   ├── cart_page.dart
│   │   └── widgets/
│   │
│   ├── checkout/
│   │   ├── checkout_page.dart
│   │   ├── payment_page.dart
│   │   ├── address_page.dart
│   │   └── success_page.dart
│   │
│   ├── orders/
│   │   ├── order_page.dart
│   │   ├── order_detail_page.dart
│   │   └── widgets/
│   │
│   ├── seller/
│   │   ├── seller_dashboard.dart
│   │   ├── seller_products.dart
│   │   ├── seller_orders.dart
│   │   └── seller_income.dart
│   │
│   ├── profile/
│   │   ├── profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   ├── order_history_page.dart
│   │   └── settings_page.dart
│   │
│   └── search/
│       ├── search_page.dart
│       └── widgets/
│
└── firebase_options.dart