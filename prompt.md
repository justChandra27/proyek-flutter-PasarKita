# Feature Parity Part 2 — Detail Pesanan & Hubungi Pembeli

## Status: ✅ COMPLETED

## File
`lib/presentation/seller/orders/form_pesanan_seller_mobile.dart`

## Perubahan

### Bottom Sheet — Detail Pesanan (`_showDetailBottomSheet`)
- `DraggableScrollableSheet` via `showModalBottomSheet`
- **Informasi Pesanan:** Kode, Status, Tanggal, Customer, Email (jika ada)
- **Daftar Produk:** Nama, Qty × Harga, Subtotal per item
- **Ringkasan:** Total pesanan

### Bottom Sheet — Hubungi Pembeli (`_showContactBottomSheet`)
- `showModalBottomSheet` sederhana
- Avatar + Nama Customer + Email (jika ada)

### PopupMenuButton di `_OrderCard`
- `Icon(Icons.more_vert)` diletakkan sebelum status badge di row atas
- Menu: **Lihat Detail** (icon `receipt_long`), **Hubungi Pembeli** (icon `contact_phone`)
- Callback `onDetail` dan `onContact` dipassing dari state → menghindari duplikasi logic

### Tidak diubah
- `_StatusActions`, `_OrderCard` layout, `_buildContent`
- Search, Tab, Sort, Update Status
- Appwrite service

### Hasil `flutter analyze`
```
No issues found!
```
