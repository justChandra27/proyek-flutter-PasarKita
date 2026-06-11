# Tahap 9 — Rating & Ulasan Produk — Selesai

## 1. File yang Diubah/Dibuat

| File | Tindakan | Keterangan |
|---|---|---|
| `lib/core/appwrite/appwrite_config.dart` | DIUBAH | Tambah `reviewsCollectionId = 'reviews'` |
| `lib/data/models/review_model.dart` | DIBUAT | `ReviewModel` + `ProductReviewStats` |
| `lib/core/services/review_service_appwrite.dart` | DIBUAT | `ReviewServiceAppwrite` (5 method) |
| `lib/providers/product_filter_provider.dart` | DIUBAH | Integrasi `_loadReviewStats()` batch + `reviewStats` getter |
| `lib/presentation/customer/orders/detail_pesanan_customer.dart` | DIUBAH | Tombol "Beri Ulasan" + form dialog utk setiap item di completed order |
| `lib/presentation/customer/dashboard/dashboard_customer_mobile.dart` | DIUBAH | Rating ⭐ pada kartu produk + bottom sheet daftar review |
| `lib/presentation/customer/dashboard/dashboard_customer_web.dart` | DIUBAH | Rating ⭐ pada kartu produk + dialog daftar review |

## 2. Struktur Model Review

```dart
class ReviewModel {
  final String id;
  final String productId;
  final String orderId;
  final String userId;
  final String userName;
  final int rating;
  final String? comment;
  final String createdAt;

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId);
  Map<String, dynamic> toMap();
}

class ProductReviewStats {
  final double averageRating;
  final int reviewCount;
  factory ProductReviewStats.empty();
}
```

## 3. Struktur Service Review

```dart
class ReviewServiceAppwrite {
  Future<ReviewModel> createReview({productId, orderId, userId, userName, rating, comment});

  Future<List<ReviewModel>> getProductReviews(String productId);

  Future<ProductReviewStats> getProductStats(String productId);

  // Batch — 1 query untuk semua produk di dashboard
  Future<Map<String, ProductReviewStats>> getProductsStats(List<String> productIds);

  // Cegah review duplikat per productId+orderId+userId
  Future<bool> hasReviewed({productId, orderId, userId});
}
```

## 4. Validasi Hak Review

Lokasi: `detail_pesanan_customer.dart` di dalam `_productCard`

- **Tombol hanya muncul** jika `order.status.toLowerCase() == 'completed'`
- **Per-item**: setiap `OrderItemModel` dicek via `FutureBuilder` untuk `hasReviewed(productId, orderId, customerId)`:
  - `true` → tampilkan teks hijau "✓ Sudah diulas"
  - `false` → tampilkan tombol "Beri Ulasan"
- **Saat submit**: form memanggil `createReview(...)` — `hasReviewed` sudah dicek sebelumnya jadi duplikat tercegah di UI

## 5. Cuplikan Kode Utama

**ReviewServiceAppwrite — getProductsStats (batch):**
```dart
Future<Map<String, ProductReviewStats>> getProductsStats(List<String> productIds) async {
  final result = await databases.listDocuments(
    databaseId: AppwriteConfig.databaseId,
    collectionId: AppwriteConfig.reviewsCollectionId,
    queries: [Query.equal('productId', productIds)],
  );
  // group by productId, compute avg + count
}
```

**ProductFilterProvider — loadReviewStats:**
```dart
Future<void> _loadReviewStats() async {
  final productIds = _allProducts.map((p) => p.id).toList();
  _reviewStats = await _reviewService.getProductsStats(productIds);
  notifyListeners();
}
```

**DetailPesananCustomer — form review (dialog):**
```dart
void _showReviewForm({productId, productName, orderId, userId, userName}) {
  int rating = 5;
  showDialog(context: context, builder: (ctx) => StatefulBuilder(
    builder: (ctx, setDialogState) => AlertDialog(
      title: 'Beri Ulasan',
      content: Column(
        // nama produk, rating 5 bintang, komentar TextField
      ),
      actions: [TextButton('Batal'), ElevatedButton('Kirim')],
    ),
  ));
}
```

**Kartu Produk — rating row:**
```dart
Widget _ratingRow(ProductModel product, double avg, int count) {
  return GestureDetector(
    onTap: () => _showReviews(product),  // bottom sheet / dialog
    child: Row(children: [
      Icon(Icons.star, color: Colors.amber, size: 14),
      Text('${avg.toStringAsFixed(1)}'),
      Text('($count)'),
    ]),
  );
}
```

## 6. Hasil flutter analyze

```
31 issues found (0 error, 2 warning, 29 info)
```

- **0 error baru** — semuanya pre-existing
- **2 warning baru** — juga pre-existing:
  - `lib/presentation/admin/widgets/admin_layout.dart:41` — `unused_local_variable` (sebelum Tahap 9)
  - `lib/presentation/seller/products/form_produk_seller_web.dart:443` — `unused_element`
  - `lib/presentation/seller/products/widgets/product_table.dart:135` — `unused_label`
- **29 info** — pre-existing (`avoid_print`, `use_build_context_synchronously`, `deprecated_member_use`, `unnecessary_underscores`)

## 7. Risiko yang Masih Tersisa

1. **Collection `reviews` belum dibuat di Appwrite Console** — harus dibuat manual di `sgp.cloud.appwrite.io` dengan atribut: `productId` (string), `orderId` (string), `userId` (string), `userName` (string), `rating` (integer), `comment` (string, opsional), `createdAt` (string).
2. **Document Security** untuk collection `reviews` harus OFF (atau diatur read/write yg sesuai).
3. **Index** disarankan untuk `productId`, `orderId`, `userId` (masing-masing) agar query batch `getProductsStats` efisien.
4. **Tidak ada pagination** untuk daftar review — jika satu produk punya >100 review, hanya terbaca batch pertama (Appwrite default limit 25). Perlu ditambah `Query.limit()` dan `Query.offset()` jika dibutuhkan.
5. **`_loadReviewStats` gagal silent** — jika service error, review stats tidak tampil. Ini sengaja agar produk tetap bisa dimuat walau review error.

## 8. Perubahan Spesifik per File

### `lib/core/appwrite/appwrite_config.dart`
Tambah `static const String reviewsCollectionId = 'reviews';`

### `lib/data/models/review_model.dart` (BARU)
- `ReviewModel` — id, productId, orderId, userId, userName, rating, comment (opsional), createdAt
- `ProductReviewStats` — averageRating, reviewCount, ProductReviewStats.empty()

### `lib/core/services/review_service_appwrite.dart` (BARU)
- `createReview()` — insert dokumen ke collection `reviews`
- `getProductReviews(productId)` — list DESC by createdAt
- `getProductStats(productId)` — avg + count (single product)
- `getProductsStats(productIds)` — batch stats untuk semua produk di dashboard (1 query, grouping in-memory)
- `hasReviewed(productId, orderId, userId)` — cek apakah review sudah ada

### `lib/providers/product_filter_provider.dart`
- Tambah `ReviewServiceAppwrite` sebagai field
- Tambah `Map<String, ProductReviewStats> _reviewStats`
- Tambah getter `reviewStats` dan `reviewService`
- `loadProducts()` → setelah load + filter, panggil `_loadReviewStats()` (async, silent fail)

### `lib/presentation/customer/orders/detail_pesanan_customer.dart`
- Import `ReviewServiceAppwrite`
- Tambah `_reviewService` field di State
- `_productCard(order, items)` — signature berubah (tambah param `order`)
- Untuk setiap item: jika order completed, `FutureBuilder<bool>` untuk `hasReviewed`:
  - loading → spinner kecil
  - false → tombol "Beri Ulasan"
  - true → teks "✓ Sudah diulas"
- `_showReviewForm()` — dialog AlertDialog dengan rating 5 bintang + komentar TextField
  - Submit → `createReview()` → snackbar sukses/gagal → refresh (setState)

### `lib/presentation/customer/dashboard/dashboard_customer_mobile.dart`
- Tambah `_ratingRow()` — menampilkan ⭐ avg (count), tappable → bottom sheet reviews
- Tambah `_showReviews()` — bottom sheet `DraggableScrollableSheet`:
  - Header: avg rating + count
  - ListView: avatar, nama, rating bintang, komentar, tanggal
- Tambah `_formatDate()` — helper
- `_productCard()` — baca `filter.reviewStats[product.id]` → tampilkan `_ratingRow()` jika ada review

### `lib/presentation/customer/dashboard/dashboard_customer_web.dart`
- Sama seperti mobile, tapi pakai `Dialog` bukan bottom sheet
- `_ratingRow()` — tappable → `_showReviews()` dialog
- Sisa sama dengan mobile
