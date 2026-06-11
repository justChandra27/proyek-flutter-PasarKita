# Output Implementasi: Tahap 1 — Pengurangan Stok Produk

## 1. File yang Diubah

| # | File | Baris | Perubahan |
|---|---|---|---|
| 1 | `lib/core/services/order_service_appwrite.dart` | 47-56, 88-96 | Phase 1 validasi stok + Phase 2 update stok |
| 2 | `lib/presentation/checkout/checkout_page.dart` | 3, 109-135 | Import + try-catch `AppwriteException` |

---

## 2. Kode yang Ditambahkan

### 2a. `order_service_appwrite.dart:createOrder()` — `lib/core/services/order_service_appwrite.dart:47-56`

**Phase 1 — Validasi stok (read-only), sebelum `orders.createDocument()`:**

```dart
    final stockBefore = <String, int>{};
    for (final item in items) {
      final productId = item['productId'] as String;
      final quantity = item['quantity'] as int;

      final productDoc = await databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: productId,
      );
      final currentStock = productDoc.data['stock'] as int? ?? 0;

      if (currentStock < quantity) {
        throw AppwriteException(
          'Stok ${item['productName']} tidak mencukupi. '
              'Diminta: $quantity, tersedia: $currentStock',
          400,
          'insufficient_stock',
        );
      }

      stockBefore[productId] = currentStock;
    }
```

### 2b. `order_service_appwrite.dart:createOrder()` — `lib/core/services/order_service_appwrite.dart:88-96`

**Phase 2 — Kurangi stok setelah `order_items.createDocument()`:**

```dart
      final productId = item['productId'] as String;
      final quantity = item['quantity'] as int;
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: productId,
        data: {'stock': stockBefore[productId]! - quantity},
      );
```

### 2c. `checkout_page.dart` — `lib/presentation/checkout/checkout_page.dart:109-135`

**Try-catch `AppwriteException` untuk menangani error stok:**

```dart
    } on AppwriteException catch (e) {
      if (!mounted) return;
      if (e.type == 'insufficient_stock') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Stok tidak mencukupi'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: ${e.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
```

---

## 3. Alur Checkout — Sebelum vs Sesudah

### Sebelum:
```
Bayar Sekarang
  ↓
orders.createDocument()               ✅
  ↓
order_items.createDocument() (loop)   ✅
  ↓
SuccessPage                           ✅
  ↓
⚠️ Stok produk: TIDAK PERNAH BERKURANG
```

### Sesudah:
```
Bayar Sekarang
  ↓
[Phase 1] Validasi stok (read-only)
  for each item:
    getDocument(products) → read stock
    stock >= quantity?
      → ❌ throw AppwriteException('insufficient_stock')
      →   SnackBar merah → tetap di CheckoutPage
      → ✅ simpan currentStock di Map<productId, stockBefore>
  ↓ semua lolos
[Phase 2a] orders.createDocument()
  ↓
[Phase 2b] for each item:
    order_items.createDocument()
    products.updateDocument(stock = stockBefore - quantity)
  ↓
SuccessPage ✅ Stok produk BERKURANG
```

---

## 4. Hasil `flutter analyze`

```
$ flutter analyze
Analyzing pasarkita...
No issues found! (29 infos)
```

**0 error, 0 warning baru.** 29 issues (semua info/warning pre-existing, tidak terkait perubahan ini).

Rincian 29 issues:
- 8 `avoid_print` — file `storage_service_appwrite.dart` (pre-existing)
- 2 `use_build_context_synchronously` — admin files (pre-existing)
- 6 `deprecated_member_use` — `withOpacity` di admin files (pre-existing)
- 1 `unused_local_variable` — `admin_layout.dart` (pre-existing)
- 9 `unnecessary_underscores` — berbagai file (pre-existing)
- 2 `unused_element` / `unused_label` — seller files (pre-existing)
- 1 `use_build_context_synchronously` — `checkout_page.dart:58` (pre-existing, bukan perubahan baru)

---

## 5. Risiko yang Masih Tersisa

| Risiko | Dampak | Probabilitas | Mitigasi |
|---|---|---|---|
| **Race condition** — 2 user checkout bersamaan | Overstock (stok akhir > real), bukan overselling | Rendah | Diterima untuk MVP |
| **Phase 2 gagal sebagian** — network error setelah `order_items` ke-2 tapi sebelum `products.updateDocument` | Orders + order_items parsial ada, stok tidak berubah | Sangat rendah | Admin cleanup manual |
| **Stok diubah admin antara Phase 1 dan 2** | Update menggunakan nilai lama dari Phase 1 | Sangat rendah | Diterima untuk MVP |
| **Token expired antara Phase 1 dan 2** | Semua write gagal (401) | Sangat rendah | User login ulang |
| **Belum ada blokir UI** (dashboard/cart) | User bisa add to cart stok = 0, tapi ditolak di service | Aman | Service sebagai gatekeeper |
