# Seller Category Filter Sync Report

## Root Cause

Filter kategori di Seller → Produk Saya (`form_produk_seller_web.dart`) menggunakan **hardcoded list** `['Pakaian', 'Sepatu', 'Aksesoris']` sebagai opsi dropdown, bukan membaca dari Appwrite `categories` collection.

Akibatnya:
- Admin menambah kategori baru → filter seller **tidak menampilkannya**
- Admin menghapus kategori → filter seller **masih menampilkannya**
- Seller tidak bisa memfilter produk dengan kategori yang bukan di list tersebut

## Audit Findings

### 1. Apakah filter kategori juga ada di mobile?

**Tidak.** `form_produk_seller_mobile.dart` hanya memiliki search, status filter (Semua/aktif/nonaktif), dan sort — **tidak ada** dropdown filter kategori. Hanya web yang memiliki filter kategori hardcoded.

### 2. Bagaimana Product Form mengambil kategori?

`product_form_page.dart:93-109` — `_loadCategories()`:
```dart
final categories = await CategoryServiceAppwrite().getAllCategories();
```

Pattern: async load di `initState`, simpan di `List<CategoryModel> _categories`, tampilkan di `DropdownButtonFormField` via `_categories.map((cat) => DropdownMenuItem(value: cat.name, child: Text(cat.name)))`.

Implementasi baru menggunakan **pola yang sama persis**.

## Files Modified

Hanya 1 file:
- `lib/presentation/seller/products/form_produk_seller_web.dart`

## Before

```dart
// form_produk_seller_web.dart
class _FormProdukSellerWebState extends State<FormProdukSellerWeb> {
  String selectedCategory = 'Semua';
  // TIDAK ADA _categories atau _loadCategories

  @override
  void initState() {
    super.initState();
    _loadSeller();  // HANYA load seller
  }

  // Di build method:
  DropdownButton<String>(
    value: selectedCategory,
    items: const [
      DropdownMenuItem(value: 'Semua', child: Text('Semua Kategori')),
      DropdownMenuItem(value: 'Pakaian', child: Text('Pakaian')),      // HARDCODED
      DropdownMenuItem(value: 'Sepatu', child: Text('Sepatu')),        // HARDCODED
      DropdownMenuItem(value: 'Aksesoris', child: Text('Aksesoris')),  // HARDCODED
    ],
    onChanged: (value) { setState(() { selectedCategory = value!; }); },
  ),
```

## After

```dart
class _FormProdukSellerWebState extends State<FormProdukSellerWeb> {
  String selectedCategory = 'Semua';
  List<CategoryModel> _categories = [];     // BARU
  bool _isLoadingCategories = true;         // BARU

  @override
  void initState() {
    super.initState();
    _loadSeller();
    _loadCategories();                      // BARU
  }

  Future<void> _loadCategories() async {    // BARU — pola dari product_form_page
    try {
      final categories = await CategoryServiceAppwrite().getAllCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _isLoadingCategories = false; });
    }
  }

  // Di build method:
  DropdownButton<String>(
    value: selectedCategory,
    items: [
      const DropdownMenuItem(value: 'Semua', child: Text('Semua Kategori')),
      if (!_isLoadingCategories)                              // BARU
        ..._categories.map((cat) => DropdownMenuItem(          // BARU — dari collection
          value: cat.name,
          child: Text(cat.name),
        )),
    ],
    onChanged: (value) { setState(() { selectedCategory = value!; }); },
  ),
```

## Data Flow

```
Admin creates/edits/deletes categories
        │
        ▼
Appwrite "categories" collection
        │
        ▼
CategoryServiceAppwrite.getAllCategories()
        │
        ▼
form_produk_seller_web.dart _loadCategories()
        │
        ▼
Dropdown items ← _categories.map((cat) => cat.name)
        │
        ▼
Seller selects category → filter: product.category == selectedCategory
```

Tidak ada perubahan pada logika filtering (line 349-351). String comparison `product.category == selectedCategory` sudah bekerja untuk nama kategori apapun.

## Risks

| Risk | Mitigation |
|---|---|
| Category collection kosong → dropdown hanya "Semua Kategori" | ✅ Diterima — filter tetap berfungsi, tidak error |
| Kategori dihapus admin saat seller sedang di halaman ini | ✅ Minimal — hanya dropdown yang tidak update (perlu refresh) |
| Nama kategori berubah → produk tetap menggunakan nama lama | ✅ Pre-existing — tidak ada FK constraint, bukan masalah baru |
| `_isLoadingCategories` = true → dropdown tidak nampak | ✅ Aman — hanya "Semua Kategori" yang muncul sementara loading |
| Network error saat load categories | ✅ Caught by try/catch — dropdown tetap berfungsi dengan "Semua Kategori" |

## Manual Testing Checklist

- [ ] Buka Seller → Produk Saya → dropdown kategori menampilkan "Semua Kategori" + semua dari `categories` collection
- [ ] Tidak ada kategori hardcoded (Pakaian, Sepatu, Aksesoris tidak muncul di kode)
- [ ] Pilih kategori → produk terfilter sesuai
- [ ] Pilih "Semua Kategori" → semua produk tampil
- [ ] Admin tambah kategori baru → muncul di dropdown seller (setelah refresh halaman)
- [ ] Admin hapus kategori → hilang dari dropdown seller (setelah refresh halaman)
- [ ] Error saat load → dropdown hanya "Semua Kategori", tidak crash
- [ ] `flutter analyze` — 0 issues (divalidasi)
