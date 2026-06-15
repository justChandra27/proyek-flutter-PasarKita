# Seller Dropdown Assertion Fix Report

## Root Cause

`selectedCategory` menerima `initialCategory` (`"Fashion"`) di `initState` sebelum `_loadCategories()` selesai. Build pertama hanya punya item `"Semua"` di dropdown, tapi `value` sudah `"Fashion"` → assertion error.

## Files Modified

| # | File | Diubah? | Alasan |
|---|---|---|---|
| 1 | `form_produk_seller_web.dart` | ✅ **Ya** | DropdownButton dengan value dari `selectedCategory` |
| 2 | `form_produk_seller_mobile.dart` | ❌ Tidak | Tidak punya DropdownButton — `_selectedCategory` cuma untuk filter in-memory |
| 3 | `product_form_page.dart` | ❌ Tidak | Pakai `initialValue` (bukan `value`), dan items di-null saat loading — aman |

## Before

```dart
// form_produk_seller_web.dart — line 262
DropdownButton<String>(
  value: selectedCategory,  // ← BISA "Fashion" saat items cuma ["Semua"]
  items: [
    DropdownMenuItem(value: 'Semua', child: Text('Semua Kategori')),
    if (!_isLoadingCategories) ...  // ← loading → spread skip → items = ["Semua" saja]
  ],
)
```

## After

```dart
DropdownButton<String>(
  value: selectedCategory == 'Semua' ||
        (!_isLoadingCategories && _categories.any((c) => c.name == selectedCategory))
      ? selectedCategory
      : 'Semua',  // ← fallback aman
  items: [
    DropdownMenuItem(value: 'Semua', child: Text('Semua Kategori')),
    if (!_isLoadingCategories) ...
  ],
)
```

## Edge Cases Covered

| Skenario | Behavior | Status |
|---|---|---|
| Klik card → loading → value = "Fashion" | Fallback ke "Semua", tidak error | ✅ |
| Selesai load, kategori valid | Dropdown pindah ke "Fashion" | ✅ |
| Kategori sudah dihapus admin | Dropdown tetap di "Semua", produk tidak terfilter | ✅ |
| Klik dropdown, pilih kategori lain | `onChanged` → `selectedCategory` di-update | ✅ |
| Mobile — initialCategory di-set | Filter produk berjalan, tidak ada dropdown | ✅ (not affected) |

## Manual Testing Checklist

- [ ] Seller → Kategori → klik card → tidak ada assertion error
- [ ] Setelah load, dropdown menunjukkan kategori yang benar
- [ ] Filter produk bekerja sesuai kategori yang dipilih
- [ ] Klik "Semua Kategori" → semua produk tampil
- [ ] Admin hapus kategori → seller klik card kategori itu → fallback ke "Semua"
- [ ] `flutter analyze` — 0 issues
