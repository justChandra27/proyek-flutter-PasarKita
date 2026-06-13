MODE: AUDIT

Fokus:
Cart Persistence via SharedPreferences

Audit:

1. Dependency yang perlu ditambahkan
2. File yang harus diubah
3. Apakah CartModel.toMap()/fromMap() sudah cukup
4. Kapan save dipanggil
   - addItem
   - removeItem
   - updateQuantity
   - clear
5. Kapan load dipanggil
   - startup
6. Dampak ke Product Variant
7. Backward compatibility
8. Risiko terhadap cart lama

Jangan implementasi.
Tulis hasil ke prompt.md.

PENTING:
Jangan mengubah file apa pun selain prompt.md.

---

# HASIL AUDIT — Cart Persistence via SharedPreferences

## 1. Dependency

```yaml
# pubspec.yaml
shared_preferences: ^2.3.0
```

✅ Support web (localStorage), Android, iOS, desktop.

## 2. File yang Harus Diubah

| File | Perubahan |
|------|-----------|
| `pubspec.yaml` | + `shared_preferences: ^2.3.0` |
| `lib/providers/cart_provider.dart` | + `_loadCart()`, `_saveCart()`, import `dart:convert` + `shared_preferences` |
| `lib/main.dart` | + `provider.loadCart()` setelah create |

**Tidak perlu ubah**: `CartModel`, halaman cart, checkout — `toMap()`/`fromMap()` sudah siap.

## 3. CartModel.toMap() / fromMap() ✅ Siap

Kedua method sudah mencakup `selectedColor` dan `selectedSize` (dari Product Variant E2E).

## 4. Kapan save() Dipanggil

Semua mutation di `CartProvider` → panggil `_saveCart()` (fire-and-forget, async):

| Method | Baris | Trigger |
|--------|-------|---------|
| `addItem()` | 14 | User tambah item |
| `removeItem()` | 42 | User hapus item |
| `updateQuantity()` | 56 | User ubah qty |
| `clear()` | 91 | User kosongkan cart |

Strategy: `_saveCart()` setelah `notifyListeners()` — UI tidak terblokir.

## 5. Kapan load() Dipanggil

**Startup** — di `main.dart` setelah `CartProvider` dibuat:

```dart
ChangeNotifierProvider(
  create: (_) {
    final cp = CartProvider();
    cp.loadCart();          // ← fire-and-forget, async
    return cp;
  },
),
```

Atau di constructor `CartProvider()` langsung.

## 6. Dampak Product Variant

✅ **Aman**. `selectedColor`/`selectedSize` sudah di `toMap()`/`fromMap()` dengan default `''` → backward-compatible.

## 7. Backward Compatibility

| Skenario | Status |
|----------|--------|
| Belum ada data tersimpan | `prefs.getString` return `null` → `_items = []` ✅ |
| Data lama (sebelum variant) | `fromMap` pakai `?? ''` → fallback ✅ |
| Data baru (setelah variant) | Semua field tersimpan ✅ |
| Upgrade baru | Tidak ada data lama → aman ✅ |

## 8. Risiko Cart Lama

🔵 **Tidak ada risiko** — cart saat ini 100% in-memory, tidak ada data lama yang perlu dimigrasi.

## Ringkasan Perubahan Kode

| File | Baris tambah |
|------|-------------|
| `pubspec.yaml` | 1 |
| `cart_provider.dart` | ~25 |
| `main.dart` | ~3 |
| **Total** | **~29 baris** |

## Catatan Implementasi

Gunakan `setStringList` dengan `jsonEncode` tiap item untuk menyimpan cart, bukan `setString` dengan satu JSON besar — lebih mudah debug dan partial update.