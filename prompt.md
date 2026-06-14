# Audit Pagination — Semua Method Rawan Data >100

**MODE: PLAN**

---

## 1. Klasifikasi Risiko Data >100

### 🔴 HIGH — Akan rusak saat data >100 (perlu pagination ASAP)

Metode yang mengembalikan LIST data yang bisa >100, digunakan di UI atau analytics.

| # | Method | File | Limit Saat Ini | Data | Dampak >100 |
|---|---|---|---|---|---|
| 1 | `_fetchOrders()` | `admin_analytics_service.dart:175` | `limit(100)` | Semua orders | Revenue, status, completed orders undercount |
| 2 | `_fetchOrderItems()` | `admin_analytics_service.dart:193` | `limit(100)` | Semua items | Top seller, top products, platform fee undercount |
| 3 | `getAllProductsForAdmin()` | `product_service_appwrite.dart:19` | `limit(100)` | Semua produk | Admin lihat max 100 produk |
| 4 | `getAllProducts()` | `product_service_appwrite.dart:51` | `limit(100)` | Produk aktif | Customer lihat max 100 produk |
| 5 | `getSellerProducts()` | `product_service_appwrite.dart:114` | `limit(100)` | Produk per seller | Seller lihat max 100 produk |
| 6 | `getProductsByStatus()` | `product_service_appwrite.dart:35` | `limit(100)` | Produk per status | Moderation queue max 100 |
| 7 | `getOrdersByCustomer()` | `order_service_appwrite.dart:270` | `limit(100)` | Order per customer | Customer lihat max 100 order |
| 8 | `getOrdersBySeller()` | `order_service_appwrite.dart:302` | `limit(100)` | Items per seller | Seller lihat max 100 items |
| 9 | `getOrders()` | `order_service_appwrite.dart:22` | **TANPA LIMIT** (default 25) | Semua orders | Hanya 25 orders! |
| 10 | `getProductReviews()` | `review_service_appwrite.dart:49` | `limit(100)` | Review per produk | Produk populer >100 review |
| 11 | `getProductsStats()` | `review_service_appwrite.dart:119` | `limit(100)` | Semua review seller | Seller dengan >100 review |
| 12 | `getHistory()` | `withdrawal_service_appwrite.dart:47` | `limit(100)` | Riwayat withdrawal | Seller lihat max 100 riwayat |
| 13 | `getPendingWithdrawals()` | `withdrawal_service_appwrite.dart:62` | `limit(100)` | Semua pending wd | Admin lihat max 100 pending |
| 14 | `getNotifications()` | `notification_service_appwrite.dart:36` | **TANPA LIMIT** (default 25) | Notifikasi user | Hanya 25 notifikasi! |
| 15 | `markAllAsRead()` | `notification_service_appwrite.dart:104` | **TANPA LIMIT** (default 25) | Unread notifikasi | Hanya 25 unread pertama di-mark |
| 16 | `loadUsers()` (UI) | `form_pengguna_web.dart:147` | **TANPA LIMIT** (default 25) | Semua users | Admin lihat max 25 users |
| 17 | `loadCategories()` (UI) | `form_kategori_web.dart:136` | **TANPA LIMIT** (default 25) | Semua kategori | Biasanya <25 ✅ |
| 18 | `getPendingUsers()` (UI stream) | `form_verifikasi_web.dart:23` | **TANPA LIMIT** (default 25) | User pending | Hanya 25 pending pertama terlihat |
| 19 | `getStatistik()` — berhasil | `transaksi_service.dart:66` | **`limit(5000)`** ❌ | Transaksi berhasil | **BROKEN** — free tier max 100 |

### 🟠 MEDIUM — Akan rusak, tapi volume data biasanya <100

| # | Method | Limit | Alasan Medium |
|---|---|---|---|
| 20 | `getOrderItems(orderId)` | `order_service_appwrite.dart:288` | TANPA LIMIT | Per-order, items < 25 biasanya ✅ |
| 21 | `getProductStats(productId)` | `review_service_appwrite.dart:95` | `limit(100)` | Per-product, review < 100 di awal |
| 22 | `getSellerNames()` | `admin_analytics_service.dart:224` | `limit(100)` | Seller biasanya < 100 |
| 23 | `getCategories()` | `category_service_appwrite.dart:13` | TANPA LIMIT | Kategori < 25 ✅ |
| 24 | `releaseAllLocks()` | `stock_lock_service.dart:113` | TANPA LIMIT | Locks per session < 25 ✅ |

### 🟢 LOW — Lookup 1 dokumen

| # | Method | Limit | Alasan Low |
|---|---|---|---|
| 25 | `login()` | `auth_service_appwrite.dart:63` | TANPA LIMIT | Lookup by username — 1 hasil |
| 26 | `getCurrentUserData()` | `auth_service_appwrite.dart:124` | TANPA LIMIT | Lookup by email — 1 hasil |
| 27 | `profile_customer` (UI) | `profile_customer_web.dart:40` | TANPA LIMIT | Lookup by uid — 1 hasil |
| 28 | `getBalance()` | `balance_service_appwrite.dart:11` | ✅ `limit(1)` | Lookup by sellerId — 1 hasil |
| 29 | `addEarnings()` | `balance_service_appwrite.dart:42` | ✅ `limit(1)` | Lookup by sellerId — 1 hasil |
| 30 | `hasReviewed()` | `review_service_appwrite.dart:155` | ✅ `limit(1)` | Lookup by triple — 1 hasil |
| 31 | `getUnreadCount()` | `notification_service_appwrite.dart:82` | ✅ `limit(1)+total` | Count only |

---

## 2. Pola Pagination untuk Appwrite

### Option A: Offset Pagination (`Query.offset`)

```dart
int offset = 0;
bool hasMore = true;
while (hasMore) {
  final result = await db.listDocuments(
    queries: [Query.limit(100), Query.offset(offset)],
  );
  allDocs.addAll(result.documents);
  hasMore = result.documents.length >= 100;
  offset += result.documents.length;
}
```

**Pros:**
- Sederhana, mudah diimplementasi
- Bisa lompat ke halaman tertentu

**Cons:**
- ⚠️ **Appwrite deprecating offset** untuk production
- Tidak konsisten jika ada dokumen baru selama pagination
- Performa turun pada offset besar

### Option B: Cursor Pagination (`Query.cursorAfter`)

```dart
String? cursor;
bool hasMore = true;
while (hasMore) {
  final queries = [Query.limit(100)];
  if (cursor != null) queries.add(Query.cursorAfter(cursor));
  final result = await db.listDocuments(queries: queries);
  allDocs.addAll(result.documents);
  hasMore = result.documents.length >= 100;
  if (hasMore) cursor = result.documents.last.$id;
}
```

**Pros:**
- ✅ **Cara Appwrite yang benar** — recommended oleh dokumentasi
- ✅ Konsisten — tidak terpengaruh dokumen baru
- ✅ Performa stabil pada data besar
- ✅ Sudah digunakan di `getProductsPage()`, `getProductReviewsPage()`, `getNotificationsPage()`

**Cons:**
- Wajib `orderBy` yang konsisten
- Tidak bisa lompat ke halaman tertentu

### Option C: `Query.limit` + `result.total` (count-only)

Untuk analytics yang hanya butuh count (bukan data aktual), pakai `limit(1)` + `result.total`.

### Rekomendasi: **Option B (Cursor)**

Sudah ada pattern yang terbukti di codebase. Konsisten dengan metode paginated yang sudah ada.

---

## 3. PaginationHelper — Design untuk V2

```dart
class PaginationHelper {
  static Future<List<Document>> fetchAll({
    required Databases db,
    required String databaseId,
    required String collectionId,
    List<String> queries = const [],
    int pageSize = 100,
    int maxPages = 50, // safety: max 5000 docs
  }) async {
    final allDocs = <Document>[];
    String? cursor;
    int page = 0;

    while (page < maxPages) {
      final q = [
        ...queries,
        Query.limit(pageSize),
      ];
      if (cursor != null) {
        q.add(Query.cursorAfter(cursor));
      }

      final result = await db.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: q,
      );

      allDocs.addAll(result.documents);
      page++;

      if (result.documents.length < pageSize) break;
      cursor = result.documents.last.$id;
    }

    return allDocs;
  }

  static Future<int> fetchCount({
    required Databases db,
    required String databaseId,
    required String collectionId,
    List<String> queries = const [],
  }) async {
    final result = await db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [...queries, Query.limit(1)],
    );
    return result.total;
  }
}
```

### Wrapper per tipe data (optional):

```dart
class PaginatedProducts {
  static Future<List<ProductModel>> getAll({
    required ProductServiceAppwrite service,
    required String? sellerId,
    required bool? active,
    required ModerationStatus? status,
  }) async {
    final docs = await PaginationHelper.fetchAll(
      db: AppwriteService.databases,
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: [
        if (sellerId != null) Query.equal('sellerId', sellerId),
        if (active != null) Query.equal('active', active),
        if (status != null) Query.equal('moderationStatus', status.toJson()),
      ],
    );
    return docs.map((d) => ProductModel.fromMap(d.$id, d.data)).toList();
  }
}
```

---

## 4. Dampak Pagination Loop ke Performa

| Jumlah Data | Calls | Waktu (estimasi 200ms/call) |
|---|---|---|
| 100 | 1 | 0.2 detik |
| 500 | 5 | 1 detik |
| 1000 | 10 | 2 detik |
| 5000 | 50 | 10 detik ⚠️ |
| 10000 | 100 | 20 detik ❌ |

**Masalah:**
- Calls sequential (cursor-dependent) — **tidak bisa parallel**
- Analytics jadi lambat seiring pertumbuhan data
- Cold start bisa timeout (30s di free tier)

**Mitigasi:**
- `maxPages` safety limit (default 50 → 5000 docs)
- Caching layer untuk analytics (V3)
- Tampilkan warning "Data may be partial" jika >5000 docs

---

## 5. Strategi Scaling per Tipe Method

### Count-only → `limit(1)` + `result.total`

Digunakan untuk: count products, count users by role, total transaksi.

✅ Sudah benar di:
- `_fetchProductCount()` ✅
- `_fetchUserCounts()` ✅
- `getTotalTransaksi()` ✅
- `getUnreadCount()` ✅

### Data untuk UI → Pagination cursor di UI layer

Digunakan untuk: product list, review list, notification list, order list.

✅ Sudah ada:
- `getProductsPage()` ✅
- `getProductReviewsPage()` ✅
- `getNotificationsPage()` ✅

❌ Belum:
- `getOrders()` → perlu `getOrdersPage()`
- `getUsers()` → perlu `getUsersPage()`
- `getWithdrawals()` → perlu `getWithdrawalsPage()`
- `loadUsers()` (UI) → perlu migrasi ke paginated service

### Data untuk Analytics → Pagination loop di service layer

Digunakan untuk: compute revenue, top sellers, top products, aggregated stats.

❌ Semua perlu pagination loop saat data >100.

### Batch operation → Pagination loop + chunked writes

Digunakan untuk: `markAllAsRead()`.

❌ Perlu pagination loop untuk mark >25 unread.

---

## 6. Roadmap Pagination V2

### Phase 1 — PaginationHelper Utility (1-2 jam)

Buat `lib/core/utils/pagination_helper.dart` dengan:
- `fetchAll()` — cursor-based pagination loop
- `fetchCount()` — count using `limit(1)+total`
- Type-specific wrapper classes

**File baru:** 1 file, ~80 baris

### Phase 2 — Paginated Service Methods (3-4 jam)

Tambah method paginated untuk setiap service:

| Service | Method Baru | Priority |
|---|---|---|
| `OrderServiceAppwrite` | `getOrdersPage()` | 🔴 HIGH |
| `UserServiceAppwrite` (baru) atau `form_pengguna_web.dart` | `getUsersPage()` | 🔴 HIGH |
| `WithdrawalServiceAppwrite` | `getWithdrawalsPage()` | 🟠 MEDIUM |
| `NotificationServiceAppwrite` | — ✅ sudah ada | — |

**File:** ~5 file, ~30 baris per file

### Phase 3 — Migrasi Analytics ke Pagination Loop (2-3 jam)

Ubah 4 method di `AdminAnalyticsService`:

| Method | Dari | Ke |
|---|---|---|
| `_fetchOrders()` | `limit(100)` | `PaginationHelper.fetchAll(orders)` |
| `_fetchOrderItems()` | `limit(100)` | `PaginationHelper.fetchAll(orderItems)` |
| `_fetchSellerNames()` | `limit(100)` | `PaginationHelper.fetchAll(sellers)` |
| `getProductsStats()` | `limit(100)` | `PaginationHelper.fetchAll(reviews)` |

**⚠️ Risiko:** 4 sequential pagination loops → untuk 5000 data = 200 calls ≈ 40 detik. **TIDAK OK.**

**Solusi:** Jangan migrasi semua sekaligus. Prioritaskan:
1. Orders + Items → analytics accuracy
2. Seller names → low priority (<100 seller)
3. Reviews → perlu query optimization dulu

### Phase 4 — Cache Layer untuk Analytics (3-5 jam)

Buat `lib/core/services/analytics_cache_service.dart`:

```dart
class AnalyticsCacheService {
  static final _cache = <String, AdminAnalytics>{};
  static DateTime? _lastFetch;
  static const Duration _ttl = Duration(minutes: 5);

  static Future<AdminAnalytics> getAnalytics() async {
    if (_lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _ttl) {
      return _cache['admin']!;
    }
    final data = await AdminAnalyticsService().getAnalytics();
    _cache['admin'] = data;
    _lastFetch = DateTime.now();
    return data;
  }

  static void invalidate() {
    _cache.clear();
    _lastFetch = null;
  }
}
```

Panggil `invalidate()` saat mutation (order baru, product update, dll.)

### Phase 5 — Aggregated Collection (6+ bulan, 5000+ data)

Buat collection `analytics_aggregates` dengan cron job / Appwrite Function untuk periodic computation.

---

## 7. Prioritas Implementasi

| Priority | Item | Effort | Depend On |
|---|---|---|---|
| **P0 — Segera** | Fix `getOrders()` (tanpa limit → `limit(100)`) | 1 menit | — |
| **P0 — Segera** | Fix `getNotifications()` (tanpa limit → `limit(100)`) | 1 menit | — |
| **P0 — Segera** | Fix `loadUsers()` UI (tanpa limit → `limit(100)`) | 1 menit | — |
| **P0 — Segera** | Fix `getPendingUsers()` stream (tanpa limit → `limit(100)`) | 1 menit | — |
| **P0 — Segera** | Fix `markAllAsRead()` (tanpa limit → pagination loop) | 10 menit | — |
| **P0 — Segera** | Fix `getStatistik()` (limit(5000) → limit(100) + loop) | 10 menit | — |
| **P1 — V2** | PaginationHelper utility | 1-2 jam | — |
| **P1 — V2** | `getOrdersPage()` + UI migrasi | 1 jam | PaginationHelper |
| **P1 — V2** | `getUsersPage()` + UI migrasi | 1 jam | PaginationHelper |
| **P1 — V2** | `getWithdrawalsPage()` + UI migrasi | 1 jam | PaginationHelper |
| **P2 — V2** | Analytics pagination loop (orders, items) | 2 jam | PaginationHelper |
| **P2 — V2** | Analytics pagination loop (reviews) | 1 jam | PaginationHelper |
| **P3 — V3** | Cache layer | 3-5 jam | — |
| **P4 — Future** | Aggregated collection | 3-5 hari | Appwrite Function |

---

## 8. Ringkasan

| Kategori | Jumlah Method | Status |
|---|---|---|
| ✅ Sudah paginated (cursor) | 3 | `getProductsPage`, `getProductReviewsPage`, `getNotificationsPage` |
| ✅ Sudah `limit(100)` — aman ≤100 | ~15 | Semua yang sudah difix |
| ❌ Tanpa limit — default 25 | ~8 | Perlu fix P0 segera |
| ❌ `limit(5000)` — broken di free tier | 1 | `transaksi_service.dart:66` |
| 🔄 Perlu pagination loop V2 | ~5 | Analytics methods |
| 🔄 Perlu paginated UI methods | ~3 | `getOrdersPage`, `getUsersPage`, `getWithdrawalsPage` |
