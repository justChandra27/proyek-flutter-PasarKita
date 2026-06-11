# Output Implementasi: Tahap 2 — Sinkronisasi UI dengan Stok Produk

## 1. File yang Diubah

| # | File | Perubahan |
|---|---|---|
| 1 | `lib/data/models/cart_model.dart` | Tambah field `stock` |
| 2 | `lib/providers/cart_provider.dart` | Validasi `addItem()` & `updateQuantity()` terhadap stock |
| 3 | `lib/presentation/customer/dashboard/dashboard_customer_web.dart` | Badge "Stok Habis" + disable tombol |
| 4 | `lib/presentation/customer/dashboard/dashboard_customer_mobile.dart` | Badge "Stok Habis" + disable tombol |
| 5 | `lib/presentation/customer/cart/cart_customer_web.dart` | "+" check stock + SnackBar |
| 6 | `lib/presentation/customer/cart/cart_customer_mobile.dart` | "+" check stock + SnackBar |
| 7 | `lib/core/services/product_service_appwrite.dart` | Method baru `getProductById()` |
| 8 | `lib/presentation/checkout/checkout_page.dart` | Validasi stok cepat sebelum `createOrder()` |

> Tidak ada halaman detail produk customer — file tidak ditemukan. Badge hanya di dashboard.

---

## 2. Cuplikan Kode yang Ditambahkan

### 2a. `cart_model.dart` — field `stock`

```dart
class CartModel {
  final int stock;  // ← BARU

  CartModel({
    required this.productId,
    required this.sellerId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.stock = 0,           // ← BARU, default 0
  });

  factory CartModel.fromMap(...) {
    return CartModel(
      ...
      stock: data['stock'] ?? 0,  // ← BARU
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ...
      'stock': stock,             // ← BARU
    };
  }
}
```

### 2b. `cart_provider.dart` — validasi stock

```dart
void addItem(CartModel item) {
  final index = _items.indexWhere((i) => i.productId == item.productId);
  if (index >= 0) {
    final newQty = _items[index].quantity + item.quantity;
    if (newQty > _items[index].stock) return;  // ← BARU: skip jika melebihi stock
    _items[index] = CartModel(
      ...
      quantity: newQty,
      stock: _items[index].stock,               // ← BARU: bawa stock
    );
  } else {
    if (item.stock <= 0) return;                // ← BARU: tolak jika stok 0
    _items.add(item);
  }
  notifyListeners();
}

void updateQuantity(String productId, int quantity) {
  final index = _items.indexWhere((i) => i.productId == productId);
  if (index >= 0) {
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      final capped = quantity > _items[index].stock    // ← BARU: cap di stock
          ? _items[index].stock
          : quantity;
      _items[index] = CartModel(
        ...
        quantity: capped,
        stock: _items[index].stock,                    // ← BARU
      );
    }
    notifyListeners();
  }
}
```

### 2c. Dashboard — Bagian A & B (web & mobile, pola identik)

```dart
// Di _productCard(), setelah image container:
child: Stack(
  children: [
    // image (existing)
    Image.network(product.imageUrl, ...),
    // ← BARU: badge "Stok Habis"
    if (outOfStock)
      Positioned(
        top: 8, left: 8,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Stok Habis",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
  ],
),

// Di button:
onPressed: outOfStock ? null : () { ... },  // ← BARU: null jika habis
child: Text(outOfStock ? "Stok Habis" : "Tambah ke Keranjang"),  // ← BARU
```

### 2d. Cart — Bagian C (web & mobile)

```dart
// Tombol "+" di cart:
onPressed: () {
  if (item.quantity >= item.stock) {                    // ← BARU
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jumlah melebihi stok tersedia.'),
      ),
    );
    return;
  }
  context.read<CartProvider>().updateQuantity(
    item.productId,
    item.quantity + 1,
  );
},
```

### 2e. `product_service_appwrite.dart` — method baru

```dart
Future<ProductModel?> getProductById(String productId) async {
  try {
    final doc = await databases.getDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      documentId: productId,
    );
    return ProductModel.fromMap(doc.$id, doc.data);
  } catch (_) {
    return null;
  }
}
```

### 2f. `checkout_page.dart` — Bagian D

```dart
// Sebelum createOrder(), validasi stok semua item cart:
final productService = ProductServiceAppwrite();
for (final cartItem in cart.items) {
  final product = await productService.getProductById(cartItem.productId);
  if (product == null || cartItem.quantity > product.stock) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Stok produk berubah. Silakan periksa kembali keranjang Anda.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
    setState(() => _loading = false);
    return;  // ← BATAL, tidak lanjut ke createOrder()
  }
}
```

---

## 3. Alur Sebelum dan Sesudah

### Dashboard — Produk dengan stok = 0

| Aspek | Sebelum | Sesudah |
|---|---|---|
| Tampilan stok | "Stok: 0" (abu-abu) | Badge merah "Stok Habis" overlay di image |
| Tombol | "Tambah ke Keranjang" (biru, bisa diklik) | "Stok Habis" (abu-abu, `onPressed: null`) |
| Text stok | "Stok: 0" | "Stok: Habis" (merah) |

### Cart — Quantity maksimum

| Aspek | Sebelum | Sesudah |
|---|---|---|
| Tombol "+" saat qty < stock | Aktif, tambah quantity | Aktif, tambah quantity |
| Tombol "+" saat qty = stock | Aktif, quantity bisa > stock ❌ | Tidak nambah, SnackBar "Jumlah melebihi stok tersedia." ✅ |
| Warna "+" saat qty = stock | Normal | Abu-abu |

### Checkout — Validasi stok

| Aspek | Sebelum | Sesudah |
|---|---|---|
| Stok berubah sejak masuk cart | Langsung `createOrder()` → error di service | Validasi cepat → SnackBar orange, batal sebelum API call |

---

## 4. Hasil `flutter analyze`

```
$ flutter analyze
Analyzing pasarkita...
No issues found! (29 infos)
```

**0 error, 0 warning baru.** 29 issues (semua pre-existing):

- 8 `avoid_print` — `storage_service_appwrite.dart`
- 2 `use_build_context_synchronously` — admin files
- 6 `deprecated_member_use` — `withOpacity` di admin
- 1 `unused_local_variable` — `admin_layout.dart`
- 9 `unnecessary_underscores` — berbagai file
- 2 `unused_element` / `unused_label` — seller files
- 1 `use_build_context_synchronously` — `checkout_page.dart:59` (pre-existing)

---

## 5. Risiko yang Masih Tersisa

| Risiko | Dampak | Probabilitas |
|---|---|---|
| **Stock di CartModel tidak sync** — stok di cart adalah snapshot saat add-to-cart, tidak实时 | User bisa checkout dengan quantity > stok real jika stok berkurang di antara waktu | Rendah — service layer tetap validasi (Tahap 1) |
| **CartProvider.addItem() silent return** — jika stok <= 0 atau qty > stock, fungsi return tanpa feedback | User klik tombol tapi tidak ada reaksi | Rendah — tombol sudah disabled + SnackBar dari UI layer |
| **Tidak ada halaman detail produk** — badge "Stok Habis" hanya di dashboard | Customer tidak melihat detail lebih lanjut | Tidak ada risiko — produk bisa dibeli langsung dari dashboard |
| **getProductById() return null** — jika produk dihapus antara waktu add-to-cart dan checkout | Checkout dibatalkan dengan SnackBar "Stok produk berubah" | Aman — user diminta periksa cart |
| **Race condition di checkout validation** — stok valid di Bagian D tapi berubah sebelum `createOrder()` | `createOrder()` akan throw di Phase 1 (Tahap 1) | Aman — ada double validation |
