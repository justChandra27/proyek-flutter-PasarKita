// lib/core/appwrite/appwrite_config.dart

class AppwriteConfig {
  static const String endpoint =
      'https://sgp.cloud.appwrite.io/v1';

  static const String projectId =
      'marketplacedb';

  static const String databaseId =
      'marketplace_db';

  // Collections
  static const String usersCollectionId =
      'users';

  static const String productsCollectionId =
      'products';

  static const String categoriesCollectionId =
      'categories';

  static const String ordersCollectionId =
      'orders';

  static const String orderItemsCollectionId =
      'order_items';

  static const String transaksiCollection =
      'transaksi';

  static const String notificationsCollectionId =
      'notifications';

  static const String reviewsCollectionId =
      'reviews';

  static const String sellerBalancesCollectionId =
      'seller_balances';

  static const String withdrawalsCollectionId =
      'withdrawals';

  static const String stockLocksCollectionId =
      'stock_locks';

  static const String banksCollectionId =
      'banks';

  // Storage
  static const String productBucketId =
      'product_images';

  // Functions
  static const String emailReceiptFunctionId =
      '6a3391a0002b2bc09e2b';
}