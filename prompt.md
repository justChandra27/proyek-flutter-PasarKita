# Implementasi Distributed Lock + Rollback untuk createOrder() — Selesai

## 1. File yang Diubah / Dibuat

| File | Status | Perubahan |
|---|---|---|
| `lib/data/models/processing_phase.dart` | ✅ BARU | Enum `ProcessingPhase` (none, locked, orderCreated, itemsCreated, committed) |
| `lib/core/services/stock_lock_service.dart` | ✅ BARU | `StockLockService` — acquireLock, releaseLock, releaseAllLocks, expired lock cleanup |
| `lib/core/appwrite/appwrite_config.dart` | ✅ DIUBAH | Tambah `stockLocksCollectionId = 'stock_locks'` |
| `lib/core/services/order_service_appwrite.dart` | ✅ DIUBAH | `createOrder()` rewrite + method `_rollbackCreateOrder()` baru |

---

## 2. Schema Collection `stock_locks`

Collection baru di Appwrite:

| Field | Type | Keterangan |
|---|---|---|
| `productId` | string | ID produk (unique per lock) |
| `sessionId` | string | ID session `createOrder()` — untuk identifikasi ownership |
| `expiresAt` | datetime | TTL 30 detik — fallback jika release gagal |
| `createdAt` | datetime | Waktu lock dibuat |

---

## 3. Flow Final createOrder()

```
Input items → aggregateQuantities (group by productId for stock)
→ sort unique productIds (lock ordering)
→ acquire locks (sequential, sorted — no deadlock)
→ check stock (re-read under lock — TOCTOU aman)
→ create order document
→ create order items (preserve original color/size per item)
→ deduct stock (use aggregated quantity per productId)
→ release locks (best-effort, TTL backup)
→ return orderId
```

---

## 4. Semua Lokasi Rollback

| Failure Point | Phase Saat Gagal | Rollback Action |
|---|---|---|
| acquire lock (409 conflict atau network error) | `none` | `releaseAllLocks(sessionId)` — partial lock cleanup |
| check stock (insufficient) | `locked` | `releaseAllLocks(sessionId)` — tidak ada data ditulis |
| create order (network error) | `locked` | `releaseAllLocks(sessionId)` — tidak ada data ditulis |
| create order item (network error — bisa partial) | `orderCreated` | delete created items → delete order → release locks (stock belum disentuh) |
| deduct stock (network error — bisa partial) | `itemsCreated` | restore stock (untuk yg terdeduct) → delete items → delete order → release locks |
| release lock (network error) | `committed` | **Tidak perlu rollback** — data sudah konsisten, TTL cleanup |

Semua operasi rollback menggunakan **best-effort** (try/catch per sub-operasi). Partial rollback lebih baik dari no rollback.

---

## 5. Hasil `flutter analyze`

**0 issue baru** dari implementasi ini.

21 total issues — semuanya pre-existing di file lain (storage_service print, deprecated withOpacity, unused variables, dll). Tidak ada error atau warning dari:
- `order_service_appwrite.dart`
- `stock_lock_service.dart`
- `processing_phase.dart`
- `appwrite_config.dart`

---

## 6. Risiko yang Masih Tersisa

| Risiko | Dampak | Mitigasi |
|---|---|---|
| **Crash di window Step 2 (deduct) → increment** | Tidak ada — order + items sudah dibuat sebelum stock disentuh | ✅ Desain `order → items → deduct` menghilangkan phantom deduction |
| **Rollback delete order gagal** | Orphan order tanpa items | ✅ Stock aman (belum/tidak berubah). Mudah dideteksi via query `paymentStatus = unpaid`. Scheduled cleanup bisa ditambah. |
| **Lock expired sebelum selesai** | Lock dilepas session lain, data race | ✅ TTL 30 detik cukup untuk operasi <5 detik. Jika butuh lebih lama, `extendLock()` bisa ditambah. |
| **Concurrent request productId sama** | Hanya 1 session dapat lock, lainnya 409 | ✅ User diminta coba lagi. Wajar untuk produk populer. |
| **Expired lock masih terisi** | Lock lama mencegah order baru | ✅ `acquireLock()` cek `expiresAt` — jika expired, hapus dan buat ulang. |
