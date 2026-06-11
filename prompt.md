## Tahap 5 — Seller Analytics & Sales Report ✅ Selesai

### 1. File yang Diubah/Dibuat

| File | Status |
|---|---|
| `lib/core/services/seller_analytics_service.dart` | **BARU** — service layer analytics |
| `lib/presentation/seller/dashboard/dashboard_seller_mobile.dart` | DIUBAH — dari dummy data ke real Appwrite analytics |
| `lib/presentation/seller/dashboard/dashboard_seller_web.dart` | DIUBAH — dari dummy data ke real Appwrite analytics |

### 2. Struktur Service Analytics

```
seller_analytics_service.dart
├── class ProductSales
│   ├── productName: String
│   └── totalSold: int
├── class SellerAnalytics
│   ├── totalProducts: int
│   ├── totalOrders: int
│   ├── completedOrders: int
│   ├── totalRevenue: int
│   ├── topProducts: List<ProductSales>
│   └── orderStatusCounts: Map<String, int>
└── class SellerAnalyticsService
    └── getAnalytics(sellerId) → Future<SellerAnalytics>
```

### 3. Query / Alur Data

```
getAnalytics(sellerId):
  ├── ProductServiceAppwrite.getSellerProducts(sellerId)
  │   └── Query.equal('sellerId', sellerId) on 'products'
  ├── OrderServiceAppwrite.getOrdersBySeller(sellerId)
  │   └── Query.equal('sellerId', sellerId) on 'order_items'
  ├── For each unique orderId:
  │   └── OrderServiceAppwrite.getOrderById(oid)
  │       └── getDocument on 'orders'
  ├── Compute totalProducts = products.length
  ├── Compute totalOrders = unique orderIds count
  ├── Compute completedOrders = orders where status == 'completed'
  ├── Compute totalRevenue = Σ subtotal dari completed order items
  ├── Compute orderStatusCounts = Map<status, count>
  └── Compute topProducts = group by productName, Σ quantity, sort DESC, take 5
```

### 4. Cuplikan Kode Utama

**Service** (`seller_analytics_service.dart:35-80`):
```dart
Future<SellerAnalytics> getAnalytics(String sellerId) async {
  final products = await _productService.getSellerProducts(sellerId);
  final items = await _orderService.getOrdersBySeller(sellerId);
  final orderIds = items.map((i) => i.orderId).toSet().toList();
  final orders = <OrderModel>[];
  for (final oid in orderIds) {
    final order = await _orderService.getOrderById(oid);
    if (order != null) orders.add(order);
  }
  // ... compute stats ...
}
```

**Mobile Dashboard** — `FutureBuilder` loading dengan empty state:
```dart
if (isEmpty) {
  Icon(Icons.store_outlined, ...)
  Text('Belum ada data penjualan')
}
```

**Web Dashboard** — stat cards dari `SellerAnalytics`:
```dart
_statCard("Total Produk", '${data.totalProducts}', ...)
_statCard("Total Pesanan", '${data.totalOrders}', ...)
_statCard("Pesanan Selesai", '${data.completedOrders}', ...)
_statCard("Total Pendapatan", _formatPrice(data.totalRevenue), ...)
```

### 5. Hasil `flutter analyze`

```
29 issues found — 100% pre-existing (info/warning):
  - avoid_print (8) — storage_service_appwrite.dart
  - use_build_context_synchronously (3) — pre-existing
  - deprecated_member_use (5) — withOpacity di admin
  - unused_local_variable (1) — admin_layout.dart
  - unnecessary_underscores (10) — cart/checkout/dashboard
  - unused_element (1) — form_produk_seller_web.dart
  - unused_label (1) — product_table.dart
```

**Tidak ada error/warning baru dari Tahap 5.**

### 6. Risiko Performa

| Risiko | Dampak | Mitigasi |
|---|---|---|
| **N+1 queries** — `getAnalytics` memanggil `getOrderById` per orderId | Seller dengan 100+ order akan lambat | Untuk MVP acceptable. Optimasi: gunakan `listDocuments` dengan `Query.equal('\$id', orderIds)` di masa depan |
| **Fetch semua produk** — `getSellerProducts` tanpa limit | Seller dengan 1000+ produk | Tambah `Query.limit()` jika perlu |
| **Tidak ada caching** — setiap render dashboard fetch ulang | Loading setiap navigasi ke dashboard | Tambah provider/caching jika dashboard sering di-refresh |
| **Completed items filter** — `completedItems` dihitung ulang dari items list | 2x iterasi data | In-memory, masih O(n) — acceptable |
