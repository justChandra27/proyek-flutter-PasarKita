# Audit & Rencana Implementasi: Product Form Seller + Product Detail Customer

## Ringkasan Temuan

| Area | Status |
|------|--------|
| Product Form Seller Web | ✅ Menggunakan Appwrite (`ProductServiceAppwrite`), form shared `product_form_page.dart` |
| Product Form Seller Mobile | ✅ Menggunakan Appwrite, form shared `product_form_page.dart` |
| Category Collection Integration | ❌ **Kategori hardcoded / free-text** — tidak baca dari collection `categories` |
| Customer Product Detail Web | ❌ **TIDAK ADA** — halaman detail produk belum dibuat |
| Customer Product Detail Mobile | ❌ **TIDAK ADA** — halaman detail produk belum dibuat |

---

## Detail Audit

### 1. Product Form Seller Web

**File:** `lib/presentation/seller/products/form_produk_seller_web.dart`

**Service:** `ProductServiceAppwrite` (Appwrite connected)

**Category filter (line ~189-200):**
```dart
// HARDCODED categories
'Semua', 'Pakaian', 'Sepatu', 'Aksesoris'
```
Tidak membaca dari collection `categories`. Filter hanya di web — mobile tidak punya category filter.

### 2. Product Form Seller Mobile

**File:** `lib/presentation/seller/products/form_produk_seller_mobile.dart`

**Service:** `ProductServiceAppwrite` (Appwrite connected)

**Category filter:** **Tidak ada** — hanya filter by status (`Semua`, `Aktif`, `Stok Habis`, `Arsip`).

### 3. Product Form Page (shared web & mobile)

**File:** `lib/presentation/seller/products/product_form_page.dart`

**Category input:** `TextEditingController` — **free-text**. User mengetik nama kategori manual. Tidak ada dropdown atau autocomplete dari collection `categories`.

### 4. Category Collection Integration

**Collection exists:** ✅ `AppwriteConfig.categoriesCollectionId = 'categories'`

**CategoryModel exists:** ✅ `lib/data/models/category_model.dart`

**CategoryService:** ❌ **TIDAK ADA** — tidak ada service class untuk operasi CRUD categories.

**Category UI:**
| File | Appwrite? | Kategori |
|------|-----------|----------|
| `admin/categories/form_kategori_web.dart` | ✅ Ya | Baca dari Appwrite via `databases.listDocuments()` |
| `seller/categories/form_kategori_seller_web.dart` | ❌ Tidak | **Hardcoded:** Pakaian, Elektronik, Rumah Tangga, Kecantikan, Kuliner |
| `seller/categories/form_kategori_seller_mobile.dart` | ❌ Tidak | **Hardcoded:** Fashion, Elektronik, Makanan & Minuman, Peralatan, Kecantikan, Olahraga |
| `dashboard_customer_web/mobile.dart` | ⚠️ Parsial | Dari `ProductFilterProvider._extractCategories()` — extract dari data produk, bukan dari collection |

### 5. Customer Product Detail

**Halaman detail produk:** ❌ **BELUM ADA**

**Bukti:**
- `lib/core/widgets/product_card.dart` (commented out, 219 lines) — referensi ke `ProductDetailPage` yang tidak ada
- `dashboard_customer_web.dart` — tombol "Tambah ke Keranjang" langsung, tanpa navigasi ke detail
- `dashboard_customer_mobile.dart` — sama, tidak ada navigasi ke detail

**Order detail exists:** ✅ `detail_pesanan_customer.dart` — tapi ini untuk pesanan, bukan produk.

**Service untuk detail:** ✅ `ProductServiceAppwrite.getProductById(String productId)` — sudah ada, tinggal pakai.

---

## Rencana Implementasi

### Item A: CategoryService + ProductFormPage category dropdown

**Tujuan:** Ganti category free-text input dengan dropdown yang membaca dari Appwrite `categories` collection.

**File yang akan dibuat:**
| File | Isi |
|------|-----|
| `lib/core/services/category_service_appwrite.dart` | Service class: `getAllCategories()`, `addCategory()`, `deleteCategory()` |

**File yang akan diubah:**
| File | Perubahan |
|------|-----------|
| `product_form_page.dart` | Ganti `TextFormField` category → `DropdownButtonFormField` yang loaded dari `CategoryServiceAppwrite.getAllCategories()` |

**Alur:**
1. `ProductFormPage.initState()` → `CategoryServiceAppwrite().getAllCategories()` → simpan di `List<CategoryModel> _categories`
2. `build()` → `DropdownButtonFormField<String>` dengan items dari `_categories`
3. `saveProduct()` → ambil selected category name → simpan ke `ProductServiceAppwrite`

**Risiko:** Perubahan di `product_form_page.dart` — file shared oleh web & mobile. Perlu testing di kedua platform.

---

### Item B: Customer Product Detail Page

**Tujuan:** Buat halaman detail produk untuk customer (web + mobile) dengan navigasi dari dashboard card.

**File yang akan dibuat:**
| File | Isi |
|------|-----|
| `lib/presentation/customer/products/detail_produk_customer_web.dart` | Web: tampilan detail produk + tombol "Tambah ke Keranjang" |
| `lib/presentation/customer/products/detail_produk_customer_mobile.dart` | Mobile: tampilan detail produk + tombol "Tambah ke Keranjang" |

**File yang akan diubah:**
| File | Perubahan |
|------|-----------|
| `dashboard_customer_web.dart` | Tambah navigasi ke `DetailProdukCustomerWeb` dari product card |
| `dashboard_customer_mobile.dart` | Tambah navigasi ke `DetailProdukCustomerMobile` dari product card |

**Service:** ✅ `ProductServiceAppwrite.getProductById(String productId)` — sudah ada

**Model:** ✅ `ProductModel` — sudah ada

**Isi halaman detail:**
- Gambar produk (full width)
- Nama produk
- Harga
- Kategori
- Deskripsi
- Stok
- Tombol "Tambah ke Keranjang" (panggil `CartProvider.addToCart(product)`)

---

### Item C: Seller Category Page — Baca dari Appwrite

**Tujuan:** Ganti hardcoded categories di seller category pages dengan data dari Appwrite.

**File yang akan diubah:**
| File | Perubahan |
|------|-----------|
| `form_kategori_seller_web.dart` | Ganti hardcoded list → `FutureBuilder` dari `CategoryServiceAppwrite` |
| `form_kategori_seller_mobile.dart` | Ganti hardcoded list → `FutureBuilder` dari `CategoryServiceAppwrite` |

---

## Prioritas

| # | Item | Prioritas | Effort | Dependencies |
|---|------|-----------|--------|-------------|
| A | CategoryService + dropdown di form | **HIGH** | Medium | None |
| B | Customer product detail page | **HIGH** | Medium | None |
| C | Seller category page from Appwrite | **LOW** | Low | Item A (CategoryService) |

---

## File Referensi

| File | Path |
|------|------|
| Appwrite config | `lib/core/appwrite/appwrite_config.dart` |
| Appwrite service | `lib/core/appwrite/appwrite_service.dart` |
| Product service | `lib/core/services/product_service_appwrite.dart` |
| Storage service | `lib/core/services/storage_service_appwrite.dart` |
| Product model | `lib/data/models/product_model.dart` |
| Category model | `lib/data/models/category_model.dart` |
| Admin kategori (reference) | `lib/presentation/admin/categories/form_kategori_web.dart` |
| Shared product form | `lib/presentation/seller/products/product_form_page.dart` |
| Seller web products | `lib/presentation/seller/products/form_produk_seller_web.dart` |
| Seller mobile products | `lib/presentation/seller/products/form_produk_seller_mobile.dart` |
| Customer dashboard web | `lib/presentation/customer/dashboard/dashboard_customer_web.dart` |
| Customer dashboard mobile | `lib/presentation/customer/dashboard/dashboard_customer_mobile.dart` |
| Cart provider | `lib/providers/cart_provider.dart` |
