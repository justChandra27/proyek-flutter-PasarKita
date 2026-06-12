# Implementasi Item A — CategoryService + Dropdown Kategori

## File yang dibuat

### `lib/core/services/category_service_appwrite.dart`

Service baru untuk baca data kategori dari Appwrite collection `categories`.

```dart
class CategoryServiceAppwrite {
  final Databases databases = AppwriteService.databases;

  Future<List<CategoryModel>> getAllCategories() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.categoriesCollectionId,
    );
    return result.documents
        .map((doc) => CategoryModel.fromMap(doc.data, doc.$id))
        .toList();
  }
}
```

## File yang diubah

### `lib/presentation/seller/products/product_form_page.dart`

| Perubahan | Detail |
|-----------|--------|
| Import baru | `category_service_appwrite.dart`, `category_model.dart` |
| Hapus `categoryController` | `TextEditingController` untuk kategori diganti |
| State baru | `String? _selectedCategory`, `List<CategoryModel> _categories`, `bool _isLoadingCategories` |
| `initState` | Panggil `_loadCategories()` untuk fetch data dari Appwrite |
| Edit mode | `_selectedCategory = widget.product!.category` (pre-select dropdown) |
| Widget kategori | `TextFormField` → `DropdownButtonFormField<String>` |
| `initialValue` | `_selectedCategory` (nilai awal dropdown) |
| `items` | Map `_categories` → `DropdownMenuItem(name)` |
| `onChanged` | Update `_selectedCategory` via `setState` |
| Loading state | `_isLoadingCategories` → disable dropdown + null items |
| `saveProduct` | `final category = _selectedCategory ?? ''` → pakai selected category |
| `dispose` | Hapus `categoryController.dispose()` |

### Potongan kode — Dropdown kategori (line 274-301)

```dart
DropdownButtonFormField<String>(
  initialValue: _selectedCategory,
  decoration: const InputDecoration(
    labelText: 'Kategori',
    border: OutlineInputBorder(),
  ),
  items: _isLoadingCategories
      ? null
      : _categories.map((cat) {
          return DropdownMenuItem<String>(
            value: cat.name,
            child: Text(cat.name),
          );
        }).toList(),
  onChanged: _isLoadingCategories
      ? null
      : (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Kategori wajib diisi';
    }
    return null;
  },
),
```

### Potongan kode — Load categories (line 65-81)

```dart
Future<void> _loadCategories() async {
  try {
    final categories = await CategoryServiceAppwrite().getAllCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    }
  } catch (_) {
    if (mounted) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }
}
```

## Alur sebelum dan sesudah

### Sebelum
```
Seller → Tambah/Edit Produk → Kategori: [text field] → ketik manual
```
Kategori disimpan sebagai string free-text. Tidak ada validasi terhadap collection `categories`.

### Sesudah
```
Seller → Tambah/Edit Produk → Kategori: [dropdown] → pilih dari daftar
                          ↑
              CategoryServiceAppwrite.getAllCategories()
              → Appwrite collection `categories`
```
Kategori hanya bisa dipilih dari yang tersedia di collection. Loading state jika fetch masih berjalan.

## Hasil flutter analyze

```
20 issues found. (ran in 2.9s)
```

**0 errors, 0 new warnings.** Semua 20 issues pre-existing (`info` + 2 `warning` tidak terkait).

## Risiko yang masih tersisa

| Risiko | Status | Catatan |
|--------|--------|---------|
| Category collection kosong | ⚠️ LOW | Dropdown akan empty, form tidak bisa submit (validator). Admin harus isi kategori dulu. |
| Edit mode — kategori sudah tidak ada di collection | ⚠️ LOW | `initialValue: _selectedCategory` tetap menampilkan nama kategori yang disimpan, meskipun tidak ada di items dropdown. |
| Error fetch categories | ⚠️ LOW | `catch (_)` — dropdown disabled, form tidak bisa submit. User perlu refresh. |
| Image orphan saat edit ganti gambar | ❌ **Belum diperbaiki** | Out of scope Item A. |
