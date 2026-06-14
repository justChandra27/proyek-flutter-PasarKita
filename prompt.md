# Implementasi Seller Analytics Dashboard V1 — Selesai

## 1. File yang Diubah

| File | Perubahan |
|---|---|
| `lib/core/services/seller_analytics_service.dart` | Tambah 4 field + import ReviewServiceAppwrite + compute review stats |
| `lib/presentation/seller/dashboard/dashboard_seller_web.dart` | 6 overview cards + Reviews section |
| `lib/presentation/seller/dashboard/dashboard_seller_mobile.dart` | 6 mini cards (2 baris) + Reviews section |

**Tidak ada file baru.** Semua data dihitung di `SellerAnalyticsService`, dashboard hanya menerima final data.

---

## 2. Data Flow Final

```
SellerDashboard._load(sellerId)
  │
  └── SellerAnalyticsService.getAnalytics(sellerId)     ← 1 call, semua data
        │
        ├── getSellerProducts(sellerId)                  ← 1 query
        │     ├── totalProducts                          ← .length
        │     ├── activeProducts                         ← .where(active)
        │     └── pendingReviewProducts                  ← .where(moderationStatus == 'pending')
        │
        ├── getOrdersBySeller(sellerId)                  ← 1 query (order_items)
        │     └── for each unique orderId:
        │           └── getOrderById(oid)                 ← N queries (N+1 problem)
        │                 ├── totalOrders                 ← unique order IDs
        │                 ├── completedOrders             ← filter status
        │                 ├── totalRevenue                ← sum sellerAmount
        │                 ├── orderStatusCounts           ← group by status
        │                 └── topProducts                 ← top 5 by quantity
        │
        └── getProductsStats(productIds)                  ← 1 batch query
              ├── totalReviews                            ← sum reviewCount
              └── averageRating                           ← weighted average
```

**Total query per load: 3 + N** (products + order_items + N×orders + review_stats).

---

## 3. `SellerAnalytics` — Field Baru

| Field | Tipe | Sumber |
|---|---|---|
| `activeProducts` | `int` | `products.where((p) => p.active).length` |
| `pendingReviewProducts` | `int` | `products.where((p) => p.moderationStatus == 'pending').length` |
| `totalReviews` | `int` | Sum `reviewCount` dari `getProductsStats()` |
| `averageRating` | `double` | Weighted average dari `getProductsStats()` |

---

## 4. Layout Dashboard

### Web — 6 overview cards + Top Products + Reviews

```
┌─────────────────────────────────────────────────────────────┐
│ Ringkasan Merchant                                           │
├──────────┬──────────┬──────────┬──────────┬──────────┬──────┤
│ Revenue  │ Orders   │ Selesai  │ Produk   │ Aktif    │Review│
│ Rp X     │ N        │ M        │ K        │ L        │  P   │
├──────────┴──────────┴──────────┴──────────┴──────────┴──────┤
│ Saldo Tersedia (Rp Y)                           [Tarik]     │
├─────────────────────────────────────────────────────────────┤
│ Status Pesanan: [Perlu Diproses:3] [Diproses:1] ...         │
├──────────────────────────────┬──────────────────────────────┤
│ PRODUK TERLARIS              │ ULASAN                       │
│ Product A — 5 terjual       │ Total Review: X              │
│ Product B — 3 terjual       │ ★ Average: X.X               │
│ ...                          │                              │
│                              │ QUICK MENU                   │
│                              │ [Tambah] [Laporan] ...       │
└──────────────────────────────┴──────────────────────────────┘
```

### Mobile — Gradient Revenue + 6 mini cards (2 baris)

```
┌──────────────────────────────┐
│ TOTAL PENDAPATAN             │
│ Rp XX.XXX                    │
│ N pesanan selesai            │
├──────────────────────────────┤
│ Saldo Tersedia     [Tarik]   │
├──────────┬──────────┬───────┤
│ Revenue  │ Orders   │ Selesai│
├──────────┼──────────┼───────┤
│ Produk   │ Aktif    │Review │
├──────────┴──────────┴───────┤
│ Status Pesanan               │
├──────────────────────────────┤
│ Produk Terlaris              │
├──────────────────────────────┤
│ Ulasan — Total Review + ★   │
└──────────────────────────────┘
```

---

## 5. Hasil `flutter analyze`

**0 new issues.** 21 total — semuanya pre-existing.

---

## 6. Risiko yang Masih Tersisa

| Risiko | Dampak | Catatan |
|---|---|---|
| **N+1 query orders** | Seller dengan 200 order → 202+ query Appwrite | Pre-existing. Belum dioptimasi di V1. |
| **getProductsStats untuk 0 produk** | Query tetap jalan | Dijaga dengan `if (products.isNotEmpty)` — safe. |
| **weighted average rating** | Bisa NaN jika 0 review | Dijaga dengan `totalReviews > 0` — fallback ke 0. |
| **Refresh manual** | Data tidak auto-refresh | Perlu pull-to-refresh atau periodic refresh di V2. |
