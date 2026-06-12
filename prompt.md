# Implementasi Sinkronisasi Field Baru Database

## File yang diubah

| # | File | Perubahan |
|---|------|-----------|
| 1 | `lib/data/models/product_model.dart` | Tambah `weight`, `minPurchase`, `soldCount` |
| 2 | `lib/data/models/user_model.dart` | Tambah `storeName`, `storeAddress`, `city`, `province` |
| 3 | `lib/core/services/product_service_appwrite.dart` | Tambah parameter `weight`, `minPurchase` di `addProduct` & `updateProduct` |
| 4 | `lib/presentation/seller/products/product_form_page.dart` | Tambah input `Berat Produk (gram)` & `Minimal Pembelian` |

## Detail perubahan

### 1. ProductModel (`product_model.dart`)

**Field baru:**
```dart
final double weight;      // Baris 13
final int minPurchase;    // Baris 14
final int soldCount;      // Baris 15
```

**fromMap — default value:**
```dart
weight: (data['weight'] ?? 0).toDouble(),       // 0 jika tidak ada
minPurchase: data['minPurchase'] ?? 1,           // 1 jika tidak ada
soldCount: data['soldCount'] ?? 0,               // 0 jika tidak ada
```

**toMap:**
```dart
'weight': weight,
'minPurchase': minPurchase,
'soldCount': soldCount,
```

### 2. UserModel (`user_model.dart`)

**Field baru:**
```dart
final String storeName;     // Baris 10
final String storeAddress;  // Baris 11
final String city;          // Baris 12
final String province;      // Baris 13
```

**fromMap — semua default `''`:**
```dart
storeName: map['storeName'] ?? '',
storeAddress: map['storeAddress'] ?? '',
city: map['city'] ?? '',
province: map['province'] ?? '',
```

### 3. ProductServiceAppwrite (`product_service_appwrite.dart`)

**`addProduct()` — parameter baru (baris 104-105):**
```dart
required double weight,
required int minPurchase,
```

**Data create:**
```dart
'weight': weight,
'minPurchase': minPurchase,
'soldCount': 0,       // default 0 untuk produk baru
```

**`updateProduct()` — parameter baru (baris 140-141):**
```dart
required double weight,
required int minPurchase,
```

**Data update — tidak overwrite `soldCount`:**
```dart
'weight': weight,
'minPurchase': minPurchase,
// soldCount tidak di-sentuh saat update
```

### 4. ProductFormPage (`product_form_page.dart`)

**Controller baru (baris 34-36):**
```dart
final weightController = TextEditingController();
final minPurchaseController = TextEditingController();
```

**Edit mode — pre-fill (baris 60-61):**
```dart
weightController.text = widget.product!.weight.toStringAsFixed(0);
minPurchaseController.text = widget.product!.minPurchase.toString();
```

**Input fields (setelah Stok, sebelum tombol Simpan):**

```dart
TextFormField(
  controller: weightController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: 'Berat Produk (gram)',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Berat produk wajib diisi';
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) return 'Berat harus lebih dari 0';
    return null;
  },
),

TextFormField(
  controller: minPurchaseController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: 'Minimal Pembelian',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Minimal pembelian wajib diisi';
    final min = int.tryParse(value);
    if (min == null || min < 1) return 'Minimal pembelian minimal 1';
    return null;
  },
),
```

**saveProduct — pass weight & minPurchase (baris 166-167, 177-178):**
```dart
weight: double.parse(weightController.text.trim()),
minPurchase: int.parse(minPurchaseController.text.trim()),
```

## Hasil flutter analyze

```
20 issues found. (ran in 5.9s)
```

**0 errors, 0 new warnings.** Semua 20 issues pre-existing.

## Audit referensi field baru

| Field | Tersisa referensi? |
|-------|-------------------|
| `ProductModel.weight` | ❌ 0 — hanya di model & service |
| `ProductModel.minPurchase` | ❌ 0 — hanya di model & service |
| `ProductModel.soldCount` | ❌ 0 — hanya di model |
| `UserModel.storeName` | ❌ 0 — hanya di model |
| `UserModel.storeAddress` | ❌ 0 — hanya di model |
| `UserModel.city` | ❌ 0 — hanya di model |
| `UserModel.province` | ❌ 0 — hanya di model |

Semua field baru sudah tersinkronisasi. Produk lama/user lama tetap berfungsi dengan default value via `??`.
