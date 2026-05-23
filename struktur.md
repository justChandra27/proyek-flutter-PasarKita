lib/
│
├── main.dart
│
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   ├── utils/
│   │   └── currency_formatter.dart
│   │
│   └── widgets/
│       ├── product_card.dart
│       ├── custom_button.dart
│       ├── custom_textfield.dart
│       └── loading_widget.dart
│
├── data/
│   ├── models/
│   │   ├── product_model.dart
│   │   ├── category_model.dart
│   │   ├── cart_model.dart
│   │   └── user_model.dart
│   │
│   └── dummy/
│       └── dummy_products.dart
│
├── presentation/
│   │
│   ├── navigation/
│   │   └── navigation_page.dart
│   │
│   ├── home/
│   │   ├── home_page.dart
│   │   └── widgets/
│   │       ├── banner_slider.dart
│   │       ├── category_item.dart
│   │       └── search_bar.dart
│   │
│   ├── product/
│   │   ├── product_page.dart
│   │   ├── product_detail_page.dart
│   │   └── widgets/
│   │       ├── image_slider.dart
│   │       ├── size_selector.dart
│   │       ├── color_selector.dart
│   │       └── add_to_cart_button.dart
│   │
│   ├── cart/
│   │   ├── cart_page.dart
│   │   └── widgets/
│   │       ├── cart_item.dart
│   │       └── quantity_button.dart
│   │
│   ├── checkout/
│   │   ├── checkout_page.dart
│   │   ├── payment_page.dart
│   │   └── success_page.dart
│   │
│   ├── profile/
│   │   └── profile_page.dart
│   │
│   └── auth/
│       ├── login_page.dart
│       └── register_page.dart
│
└── services/
    ├── cart_service.dart
    ├── auth_service.dart
    └── product_service.dart