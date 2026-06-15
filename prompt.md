# Seller Mobile Back Navigation Audit

## Current Structure

| Aspek | Detail |
|---|---|
| AppBar? | ❌ Tidak — pakai custom `Container` header |
| Back button saat ini? | ❌ Tidak ada |
| Header components | `Row` with "PasarKita" + profile avatar + title + search + filter chips |

## Entry Points

| Dari | Kode | initialCategory |
|---|---|---|
| Menu seller | `seller_mobile_page.dart:27` → `FormProdukSellerMobile()` | `null` |
| Kategori (card klik) | `form_kategori_seller_mobile.dart:213` → `FormProdukSellerMobile(initialCategory: category)` | `"Fashion"` dll |

## Strategy

Gunakan `widget.initialCategory != null` sebagai trigger:

- **`null`** (dari menu) → tidak ada back button (perilaku existing)
- **`"Fashion"`** (dari kategori) → tampilkan `Icon(arrow_back)` di kiri header

## Files Modified

1 file: `lib/presentation/seller/products/form_produk_seller_mobile.dart`

## Before

```dart
Row(
  children: [
    const Expanded(child: Text("PasarKita", ...)),
    GestureDetector(child: CircleAvatar(...)),
  ],
)
```

## After

```dart
Row(
  children: [
    if (widget.initialCategory != null) ...[
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back, ...),
      ),
      SizedBox(width: 8),
    ],
    const Expanded(child: Text("PasarKita", ...)),
    GestureDetector(child: CircleAvatar(...)),
  ],
)
```

## Edge Cases

| Skenario | initialCategory | Back button? | Perilaku |
|---|---|---|---|
| Menu → Produk Saya | `null` | ❌ | Sama seperti sebelum perubahan |
| Kategori → klik card → Produk Saya | `"Fashion"` | ✅ | `Navigator.pop` → kembali ke kategori |
| Refresh/rebuild | tetap `initialCategory` | ✅ konsisten | Sesuai parameter widget |

`flutter analyze` — 0 issues.
