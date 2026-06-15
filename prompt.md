# Order Service Scalability Audit

## Caller Map

### `OrderServiceAppwrite.getOrders()` (line 22)

| Caller | File | Tujuan |
|--------|------|--------|
| **Tidak ada** | — | Dead code — tidak dipanggil oleh screen/service mana pun |

### `OrderServiceAppwrite.getOrderItems(String orderId)` (line 295)

| # | Caller | File:Line | Tujuan | Role |
|---|--------|-----------|--------|------|
| 1 | `_loadData` | `lib/presentation/checkout/success_page.dart:51` | Menampilkan item order di halaman sukses checkout | Customer |
| 2 | `_loadOrderDetail` | `lib/presentation/customer/orders/detail_pesanan_customer.dart:31` | Menampilkan detail item di halaman detail pesanan | Customer |
| 3 | `updateOrderStatus` | `lib/core/services/order_service_appwrite.dart:381` | Verifikasi kepemilikan seller sebelum update status | Seller |
| 4 | `updateOrderStatus` (completed) | `lib/core/services/order_service_appwrite.dart:470` | Ambil items untuk update `soldCount` + `addEarnings` | Seller/System |
| 5 | `updateOrderStatus` (cancelled) | `lib/core/services/order_service_appwrite.dart:528` | Ambil items untuk restock | Seller/System |

## Current State

### `getOrders()`
- **Query:** `listDocuments(ordersCollectionId)` — tanpa limit, tanpa filter.
- **Limit default:** 25 (Appwrite SDK default).
- **External caller:** **Tidak ada** — method ini dead code.
- **Verdict:** Hanya perlu `limit(5000)` untuk jaga-jaga jika dipakai di masa depan.

### `getOrderItems(String orderId)`
- **Query:** `listDocuments(orderItemsCollectionId, [equal('orderId', orderId)])` — tanpa limit.
- **Limit default:** 25.
- **Data scope:** Scoped ke satu `orderId` — satu order biasanya 1-20 items.
- **Risiko:** Sangat rendah — order dengan >25 items sangat jarang.
- **Verdict:** Cukup `limit(5000)` — cursor pagination tidak diperlukan karena query sudah spesifik per order.

## Recommended Fix

| Method | Fix | Alasan |
|--------|-----|--------|
| `getOrders()` | `Query.limit(5000)` | Dead code — minimal guard |
| `getOrderItems()` | `Query.limit(5000)` | Scoped per order — sangat jarang >25 items |

## Files To Modify

1. `lib/core/services/order_service_appwrite.dart` — 2 method

## Risks

- Tidak ada risiko. `getOrderItems()` sudah scoped per `orderId`. `getOrders()` adalah dead code.
- Performa tetap aman karena data per order dibatasi oleh `orderId`.

## Prioritas

**Rendah** — Tidak ada dampak langsung ke user. Bisa dikerjakan bersamaan Batch 3 sederhana.