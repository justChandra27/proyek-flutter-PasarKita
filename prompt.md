MODE: AUDIT

Proyek: PasarKita Flutter

Jangan mengubah source code.

Fokus audit hanya pada fitur Seller → Produk Saya → Search Kategori.

Lakukan verifikasi end-to-end:

1. Telusuri data flow kategori:
   - Appwrite products collection
   - ProductServiceAppwrite
   - ProductModel.fromMap()
   - Seller Product Builder
   - Form Produk Seller

2. Verifikasi field yang digunakan saat search:
   - apakah categoryName
   - category
   - categoryId
   - categoryIds
   - relasi kategori

3. Pastikan nilai yang dicari user sama dengan nilai yang ada pada ProductModel.

4. Tunjukkan kode exact yang melakukan pencarian kategori.

5. Simulasikan:
   - kategori = "Makanan"
   - user search = "makanan"

6. Jika search kategori gagal:
   - tunjukkan akar masalah
   - file
   - baris
   - contoh data yang menyebabkan gagal

7. Berikan status akhir:
   - BENAR-BENAR BERFUNGSI
   - BERFUNGSI SEBAGIAN
   - TIDAK BERFUNGSI

Jangan hanya membaca kondisi if/where.
Verifikasi seluruh data flow dari database sampai UI.

# berikan hasil auditnya di file prompt.md

---

## HASIL AUDIT — Search Kategori Seller → Produk Saya

### STATUS AKHIR: ✅ **BENAR-BENAR BERFUNGSI**

Search kategori bekerja end-to-end dari database Appwrite sampai UI.

---

### 1. DATA FLOW LENGKAP

```
Appwrite Products Collection (field: 'category' = String)
  │
  ▼
ProductServiceAppwrite.getSellerProducts(sellerId)
  └─ Query: [Query.equal('sellerId', sellerId), Query.limit(5000)]
  └─ File: lib/core/services/product_service_appwrite.dart:106-116
  │
  ▼
ProductModel.fromMap(id, doc.data)
  └─ category: data['category'] ?? ''
  └─ File: lib/data/models/product_model.dart:53
  │
  ▼
SellerProductBuilder (FutureBuilder)
  └─ Future<ProductServiceAppwrite().getSellerProducts(sellerId)>
  └─ builder callback → List<ProductModel>
  └─ File: lib/presentation/seller/products/widgets/seller_product_builder.dart:43-72
  │
  ▼
FormProdukSellerWeb / FormProdukSellerMobile
  └─ .where() → filter client-side
  └─ product.name.toLowerCase().contains(searchQuery)
     || product.category.toLowerCase().contains(searchQuery)
  └─ File: form_produk_seller_web.dart:316-336
  └─ File: form_produk_seller_mobile.dart:281-304
```

---

### 2. FIELD YANG DIGUNAKAN SAAT SEARCH

| Field | Ada di model? | Digunakan? | Tipe |
|-------|:---:|:---:|------|
| `category` | ✅ YA | ✅ YA | `String` — nama kategori (e.g., "Makanan") |
| `categoryName` | ❌ TIDAK | ❌ TIDAK | — |
| `categoryId` | ❌ TIDAK | ❌ TIDAK | — |
| `categoryIds` | ❌ TIDAK | ❌ TIDAK | — |
| relasi (relation) | ❌ TIDAK | ❌ TIDAK | — |

**Kesimpulan:** Hanya field `category` (string plain, menyimpan **nama** kategori, bukan ID).

---

### 3. KODE EXACT YANG MELAKUKAN PENCARIAN KATEGORI

**Web** — `form_produk_seller_web.dart:316-336`:
```dart
final filteredProducts = products.where((product) {
  final name = product.name.toLowerCase();
  final category = product.category.toLowerCase();
  final matchSearch = name.contains(searchQuery) || category.contains(searchQuery);
  final matchStatus = selectedStatus == 'Semua'
      ? true
      : selectedStatus == 'Aktif'
      ? product.active
      : !product.active;
  final matchCategory = selectedCategory == 'Semua'
      ? true
      : product.category == selectedCategory;
  return matchSearch && matchStatus && matchCategory;
}).toList();
```

**Mobile** — `form_produk_seller_mobile.dart:281-304`:
```dart
var filteredProducts = products.where((product) {
  if (_searchQuery.isNotEmpty) {
    final name = product.name.toLowerCase();
    final category = product.category.toLowerCase();
    if (!name.contains(_searchQuery) && !category.contains(_searchQuery)) {
      return false;
    }
  }
  if (_selectedFilter == 'aktif' && !product.active) return false;
  if (_selectedFilter == 'nonaktif' && product.active) return false;
  if (_selectedCategory.isNotEmpty && product.category != _selectedCategory) return false;
  return true;
}).toList();
```

---

### 4. PEMBUKTIAN NILAI category = NAMA KATEGORI (BUKAN ID)

**Saat menyimpan produk** — `product_form_page.dart:393-420` (web) / `699-730` (mobile):
```dart
DropdownButtonFormField<String>(
  items: _categories.map((cat) {
    return DropdownMenuItem<String>(
      value: cat.name,    // ← NAMA kategori disimpan sebagai value
      child: Text(cat.name),
    );
  }).toList(),
  ...
)
```

**Saat POST ke Appwrite** — `product_form_page.dart:166`:
```dart
final category = _selectedCategory ?? '';
```
Dikirim ke `ProductServiceAppwrite.addProduct()` → `'category': category` (line 144) sebagai string nama.

**Saat read dari Appwrite** — `product_model.dart:53`:
```dart
category: data['category'] ?? '',
```
Langsung digunakan untuk search tanpa transformasi ID-to-name.

**Kesimpulan:** Tidak ada lookup/join/relasi. Category disimpan sebagai **string nama** di Appwrite, dibaca langsung sebagai string, dan dicocokkan dengan `.toLowerCase().contains()`.

---

### 5. SIMULASI: kategori = "Makanan", user search = "makanan"

| Langkah | Operasi | Hasil |
|---------|---------|-------|
| Data di Appwrite | `category: "Makanan"` | — |
| `ProductModel.category` | `"Makanan"` (dari `data['category']`) | ✅ |
| Search input user | `"makanan"` | — |
| `.toLowerCase()` pada model | `"Makanan".toLowerCase()` = `"makanan"` | ✅ |
| `.toLowerCase()` pada query | `"makanan"` (sudah lower) | ✅ |
| `.contains()` | `"makanan".contains("makanan")` | **`true` ✅** |

**Hasil:** Produk dengan kategori "Makanan" **MUNCUL** di hasil search. ✅

---

### 6. POTENSI MASALAH (BUKAN BUG SEARCH, TAPI DESIGN CONCERN)

| Issue | Detail | Dampak |
|-------|--------|--------|
| **No trim()** | `cat.name` tidak di-trim saat simpan (`product_form_page.dart:403`), juga tidak saat read (`product_model.dart:53`). Jika ada trailing space di DB, filter **exact match** (`product.category == selectedCategory`) bisa gagal. | **MEDIUM** — Filter kategori (bukan search) |
| **Plain string, bukan ID** | Karena kategori disimpan sebagai **nama string**, jika admin rename kategori di collection `categories`, produk lawas tetap pakai nama lama. Tidak ada mekanisme migrasi. | **LOW** — Konsistensi data jangka panjang |
| **Case sensitivity filter** | Filter kategori exact match (`==`) bersifat **case-sensitive**. `"Makanan" == "makanan"` = **false** ❌. Di search aman karena pakai `.toLowerCase()`. | **MEDIUM** — Filter kategori case-sensitive |
| **Search mencakup nama + kategori** | `name.contains(searchQuery) || category.contains(searchQuery)`. Jika user search "Makanan", produk dengan nama mengandung "Makanan" juga ikut muncul. Ini **bukan bug** — intended behavior. | Bukan bug |

---

### 7. KESIMPULAN

| Aspek | Status |
|-------|--------|
| Search kategori by nama | ✅ BERFUNGSI |
| Case-insensitive search | ✅ BERFUNGSI (via `.toLowerCase()`) |
| Partial match / substring | ✅ BERFUNGSI (via `.contains()`) |
| Kombinasi search + filter lain | ✅ BERFUNGSI |
| Flow data dari DB sampai UI | ✅ LENGKAP & SEMPURNA |
| Field `category` vs `categoryId` | ✅ Menggunakan field yang benar (`category`) |
| **Search kategori** | **BENAR-BENAR BERFUNGSI** ✅ |

**Tidak ada bug pada search kategori.** Calon masalah yang teridentifikasi (`no trim()`, `case-sensitive filter`) berada di **filter exact match**, bukan di search. Search menggunakan `toLowerCase().contains()` sudah benar dan aman.