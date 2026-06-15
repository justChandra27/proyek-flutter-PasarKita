# Seller Category Improvement Report

## Root Cause

**P0 (Product Count):** `CategoryModel.productCount` di DB di-set ke 0 saat kategori dibuat dan **tidak pernah diupdate** oleh operasi CRUD produk mana pun. Semua display menggunakan nilai basi ini.

**P1 (Navigation):** `_categoryCard` (web) dan `CategoryCard` (mobile) adalah `Container` statis tanpa `onTap`. Tidak ada navigasi ke halaman produk.

## Files Modified

| # | File | Perubahan |
|---|---|---|
| 1 | `lib/presentation/seller/categories/form_kategori_seller_web.dart` | P0 + P1 |
| 2 | `lib/presentation/seller/categories/form_kategori_seller_mobile.dart` | P0 + P1 |
| 3 | `lib/presentation/seller/products/form_produk_seller_web.dart` | P1 — tambah `initialCategory` param |
| 4 | `lib/presentation/seller/products/form_produk_seller_mobile.dart` | P1 — tambah `initialCategory` param + filter kategori |

---

## Product Count Strategy

**Pendekatan:** Hitung real-time dari memory (1 query, filter in-memory).

### Flow

```
1. CategoryServiceAppwrite.getAllCategories()
        ↓
2. AppwriteService.account.get() → sellerId
        ↓
3. ProductServiceAppwrite.getSellerProducts(sellerId)
        ↓
4. Loop products → Map<String, int> countByCategory
        ↓
5. Tampilkan: _productCountByCategory[cat.name] ?? 0
```

### Keuntungan
- ✅ Data akurat (langsung dari products, bukan field basi)
- ✅ 1 query total (bukan N query per kategori — tidak N+1)
- ✅ Tidak perlu ubah DB schema
- ✅ Tidak perlu sinkronisasi productCount di create/update/delete product

---

## Navigation Flow

```
Kategori Seller (card)
    ↓ onTap
Produk Saya (halaman yang sudah ada)
    ↓ initialCategory di-set
Filter kategori otomatis terpilih
```

### Detail

**Web:**
- `_categoryCard` di-`GestureDetector` → `Navigator.push` ke `FormProdukSellerWeb(initialCategory: cat.name)`
- `FormProdukSellerWeb` menerima `initialCategory` → di-`initState`, set `selectedCategory`
- Filter existing `product.category == selectedCategory` langsung bekerja

**Mobile:**
- `CategoryCard` di-`GestureDetector` → `Navigator.push` ke `FormProdukSellerMobile(initialCategory: cat.name)`
- `FormProdukSellerMobile` menerima `initialCategory` → di-`initState`, set `_selectedCategory`
- Filter baru: `if (_selectedCategory.isNotEmpty && product.category != _selectedCategory)`

---

## Before vs After

### P0: Product Count

| File | Before | After |
|---|---|---|
| `form_kategori_seller_web.dart:284` | `'${cat.productCount}'` (dari DB — selalu 0) | `'${_productCountByCategory[cat.name] ?? 0}'` (real-time) |
| `form_kategori_seller_mobile.dart:181` | `'${cat.productCount} Produk'` (dari DB — selalu 0) | `'${_productCountByCategory[cat.name] ?? 0} Produk'` (real-time) |

### P1: Navigation

| File | Before | After |
|---|---|---|
| `form_kategori_seller_web.dart` | Card tidak bisa diklik | `GestureDetector(onTap: ...)` → navigasi ke web product list |
| `form_kategori_seller_mobile.dart` | Card tidak bisa diklik | `GestureDetector(onTap: ...)` → navigasi ke mobile product list |
| `form_produk_seller_web.dart` | Tidak ada `initialCategory` param | `initialCategory` → auto-set `selectedCategory` di initState |
| `form_produk_seller_mobile.dart` | Tidak ada filter kategori, tidak ada `initialCategory` | `initialCategory` + `_selectedCategory` + filter di `products.where(...)` |

---

## Risks

| Risk | Mitigation |
|---|---|
| N+1 query (load seller + categories + products) | Semua query independen & paralel via Future.wait di method masing-masing |
| Seller dengan banyak produk (5000+) | `Query.limit(5000)` — perlu pagination loop jika >5000 (dibahas di audit sebelumnya) |
| Product count termasuk status apapun (aktif/nonaktif/pending) | ✅ Semua produk seller dihitung — sesuai ekspektasi seller |
| `widget.initialCategory` di-set saat initState — tidak berubah setelahnya | ✅ Sesuai flow: klik card → halaman baru → filter langsung aktif |
| GestureDetector tanpa feedback visual | Diterima — container sudah memiliki warna latar dan border radius sebagai indikator |

## Manual Testing Checklist

- [ ] Buka Seller → Kategori → jumlah produk di card **sesuai** dengan jumlah produk di collection
- [ ] Tambah produk baru → kembali ke kategori → jumlah **update** (setelah refresh)
- [ ] Hapus produk → jumlah **berkurang** (setelah refresh)
- [ ] Klik card kategori web → navigasi ke Produk Saya → filter kategori **otomatis terpilih**
- [ ] Klik card kategori mobile → navigasi ke Produk Saya → hanya produk kategori tersebut yang tampil
- [ ] Pilih "Semua Kategori" → semua produk tampil
- [ ] `flutter analyze` — 0 issues (divalidasi)
