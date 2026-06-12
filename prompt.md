# Revisi Rencana — Tanpa Varian Produk

## Widget yang Perlu Dibuat (Revisi)

| Widget | File Baru | Dipakai di | Perubahan dari sebelumnya |
|--------|-----------|------------|--------------------------|
| `ProductFormSection` | `widgets/product_form_section.dart` | Web (4 card) + Mobile (opsional) | ✅ Sama |
| `ProductImageUpload` | `widgets/product_image_upload.dart` | Web + Mobile | ✅ Sama |
| ~~`ProductVariantSection`~~ | — | — | ❌ **DIHAPUS** |
| `ProductStockInfoCard` | `widgets/product_stock_info_card.dart` | Web + Mobile | ✅ **BARU** — gabungan stok + berat + min pembelian |
| `SellerTipCard` | `widgets/seller_tip_card.dart` | Mobile only | ✅ **BARU** — card tips penjualan (static) |

**Total widget baru:** 4 (turun dari 4 → sebenarnya tadinya 4 juga ya karena varian dihapus tapi stock info dan tip card ditambahkan)

---

## File yang Diubah

### 1 file diubah — `product_form_page.dart`

### 4 widget baru:

| Widget | File | Baris (estimasi) | Isi |
|--------|------|------------------|-----|
| `ProductFormSection` | `widgets/product_form_section.dart` | ~40 | Wrapper card putih: title, icon, child. Padding 24, radius 16/24. |
| `ProductImageUpload` | `widgets/product_image_upload.dart` | ~100 | Upload area dashed border, icon cloud, preview thumbnail, tombol ganti/hapus. Callback: `onImagePicked(Uint8List?)`. |
| `ProductStockInfoCard` | `widgets/product_stock_info_card.dart` | ~80 | Input: stok (number), berat (number + "gram" suffix), min pembelian (number). Validasi sama seperti sekarang. |
| `SellerTipCard` | `widgets/seller_tip_card.dart` | ~50 | Static card: icon tips + text "Gunakan foto berkualitas tinggi... Daftarkan produk di kategori yang tepat...". |

---

## Layout Final

### WEB — `product_form_page.dart:_buildWebForm()`

```
ConstrainedBox(maxWidth: 700)
  └── SingleChildScrollView
       └── Column
            ├── ProductFormSection("Informasi Dasar")
            │    ├── Nama Produk (TextFormField, full width)
            │    ├── Row
            │    │    ├── Harga (Expanded, prefix Rp)
            │    │    └── Kategori (Expanded, DropdownButtonFormField)
            │
            ├── ProductFormSection("Media")
            │    └── ProductImageUpload (onImagePicked → setState selectedImage)
            │
            ├── ProductFormSection("Deskripsi Produk")
            │    └── Deskripsi (TextFormField, maxLines: 6)
            │
            ├── ProductFormSection("Stok & Informasi Produk")
            │    └── ProductStockInfoCard (stok, berat, min pembelian)
            │
            └── Area Simpan
                 └── Row
                      ├── [Spacer]
                      └── ElevatedButton.icon("Simpan Produk", width: 320)
```

**Tidak ada perubahan pada:** Scaffold, AppBar, backgroundColor, formKey, controller, validator, saveProduct(), pickImage(), dispose().

### MOBILE — `product_form_page.dart:_buildMobileForm()`

```
Scaffold (sama, AppBar tetap)
  └── SingleChildScrollView
       └── Column (padding: 16)
            ├── ProductImageUpload (full width, paling atas)
            ├── Nama Produk (TextFormField)
            ├── Row
            │    ├── Harga (Expanded)
            │    └── Stok (Expanded)
            ├── Kategori (DropdownButtonFormField)
            ├── Berat (TextFormField + suffix "gram")
            ├── Minimum Pembelian (TextFormField)
            ├── Deskripsi (TextFormField, maxLines: 5)
            ├── SellerTipCard
            └── ElevatedButton.icon("Simpan Produk", full width)
```

---

## Ringkasan Perubahan

| Item | Sebelum | Sesudah |
|------|---------|---------|
| **File diubah** | `product_form_page.dart` | `product_form_page.dart` ✅ |
| **Widget baru** | 4 (`ProductFormSection`, `ProductImageUpload`, `ProductStockInfoCard`, `SellerTipCard`) | Sama ✅ |
| **Metrik** | Satu `build()` untuk semua platform | `_buildWebForm()` + `_buildMobileForm()` — dipilih via `MediaQuery` / breakpoint |
| **Card web** | 0 (form flat) | 4 card terpisah |
| **Upload gambar** | Container + OutlinedButton | `ProductImageUpload` modern (dashed border, preview, cloud icon) |
| **Harga + Stok row** | Stacked terpisah | **Web:** Harga + Kategori 1 row. **Mobile:** Harga + Stok 1 row |
| **Tips penjualan** | Tidak ada | ✅ Mobile: card tips statis di atas tombol simpan |
| **Varian** | Direncanakan | ❌ **Dihapus** dari scope |
| **Berat & Min Pembelian** | Field terpisah | ✅ Masuk dalam `ProductStockInfoCard` |