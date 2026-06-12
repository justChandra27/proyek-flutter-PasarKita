# Audit Image URL — Admin Kategori

## Ringkasan

| Item | Status | Detail |
|------|--------|--------|
| File dialog "Tambah Kategori" | ✅ | `form_kategori_web.dart:70-141` — `showAddCategoryDialog()` |
| Method submit | ✅ | `databases.createDocument()` di dialog onPressed |
| Attribute dikirim | ✅ | `name`, `description`, `imageUrl`, `productCount`, `status` |
| imageUrl wajib di schema? | ⚠️ **Tidak diketahui** | Tidak ada info schema Appwrite; di kode opsional (bisa kosong) |
| imageUrl digunakan di UI? | ❌ **TIDAK** | Tidak ada UI yang membaca `category.imageUrl` |
| Aman hapus? | ✅ **Ya** | Tidak ada dependensi ke field `imageUrl` |

---

## Detail per Item

### 1. File yang membuat dialog "Tambah Kategori"

**File:** `lib/presentation/admin/categories/form_kategori_web.dart`

**Method:** `showAddCategoryDialog()` (line 70-141)

Membuat `AlertDialog` dengan 3 field input:
- `nameController` — Nama Kategori
- `descriptionController` — Deskripsi
- `imageController` — Image URL

### 2. Method submit kategori

**File:** `form_kategori_web.dart:115-134` — `onPressed` tombol "Simpan" di dialog:

```dart
await databases.createDocument(
  databaseId: AppwriteConfig.databaseId,
  collectionId: AppwriteConfig.categoriesCollectionId,
  documentId: ID.unique(),
  data: {
    "name": nameController.text,
    "description": descriptionController.text,
    "imageUrl": imageController.text,
    "productCount": 0,
    "status": "active",
  },
);
```

### 3. Attribute yang dikirim ke collection categories

| Attribute | Nilai | Sumber |
|-----------|-------|--------|
| `name` | `nameController.text` | Input user (wajib) |
| `description` | `descriptionController.text` | Input user (opsional) |
| `imageUrl` | `imageController.text` | Input user (opsional, bisa kosong) |
| `productCount` | `0` | Hardcoded |
| `status` | `"active"` | Hardcoded |

### 4. Apakah imageUrl wajib di schema Appwrite?

**Tidak diketahui secara pasti.** Tidak ada definisi schema collection `categories` di codebase. Namun:

- Di kode, `imageController.text` bisa kosong — tidak ada validasi
- `CategoryModel.fromMap` menggunakan `map['imageUrl'] ?? ''` — default string kosong
- Jika schema Appwrite mewajibkan `imageUrl`, create akan throw error saat `imageController.text` kosong

**Rekomendasi:** Cek schema `categories` di Appwrite Console → jika required, ubah jadi optional.

### 5. Apakah imageUrl digunakan di halaman kategori mana pun?

**Tidak.** `category.imageUrl` tidak pernah dibaca untuk ditampilkan.

Semua penggunaan `CategoryModel` di UI:

| File | Line | Penggunaan |
|------|------|------------|
| `form_kategori_web.dart` | 342-344 | `category.name`, `category.productCount`, `category.description` — **tidak pakai imageUrl** |
| `product_form_page.dart` | 282-286 | `cat.name` — hanya nama untuk dropdown |

**CategoryCard** (line 411-535) menampilkan area gambar sebagai grey placeholder:
```dart
Container(
  height: 120,
  decoration: BoxDecoration(
    color: Colors.grey.shade300,  // hanya grey — tidak ada gambar
    borderRadius: BorderRadius.only(...),
  ),
),
```

### 6. Rencana penghapusan imageUrl

**Aman dilakukan.** Tidak ada dependensi ke field `imageUrl` di UI mana pun.

| Langkah | File | Perubahan |
|---------|------|-----------|
| 1 | `CategoryModel` | Hapus field `imageUrl` dari constructor & `fromMap` |
| 2 | `form_kategori_web.dart` | Hapus `imageController` + `TextField` dari dialog; hapus `"imageUrl"` dari `createDocument` data |
| 3 | Appwrite Console | Hapus attribute `imageUrl` dari collection `categories` (atau biarkan — tidak dipakai) |

**Tidak ada file lain yang perlu diubah.** `category_service_appwrite.dart` dan `product_form_page.dart` tidak menyentuh `imageUrl`.

**Risiko:** Rendah. Field tidak dipakai di mana pun. Hapus dari model dan UI tanpa dampak ke fungsionalitas lain.
