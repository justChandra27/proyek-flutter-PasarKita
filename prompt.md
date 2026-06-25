MODE: IMPLEMENT

Proyek: PasarKita Flutter

Fokus:
Perbaiki fitur Catatan Pesanan Customer yang saat ini tidak tersimpan.

Implementasikan end-to-end.

Flow yang diinginkan:

Cart
→ Checkout
→ Create Order
→ Database
→ Detail Pesanan Customer
→ Detail Pesanan Seller

IMPLEMENTASI

1. cart_customer_mobile.dart

* Tambahkan TextEditingController untuk catatan pesanan
* Simpan nilai catatan ke state
* Passing notes ke CheckoutPage melalui constructor

2. checkout_page.dart

* Tambahkan parameter notes
* Tampilkan ringkasan catatan pesanan pada halaman checkout
* Kirim ke createOrder()

Contoh:

createOrder(
...
notes: notes.trim(),
)

3. order_service_appwrite.dart

* Verifikasi field notes tetap tersimpan
* Jangan ubah struktur yang sudah benar

4. detail_pesanan_customer.dart

* Tampilkan section:

Catatan Pesanan

jika notes tidak kosong

5. Detail Pesanan Seller

Cari seluruh halaman detail pesanan seller.

Tambahkan:

Catatan Customer

jika notes tidak kosong.

6. UI

Jika notes kosong:

* jangan tampilkan section

Jika notes ada:

* tampilkan card/info box yang rapi

# IMPLEMENTASI CATATAN PESANAN CUSTOMER

## Root Cause

Data path putus di **3 titik**:

1. **Cart:** `TextField` catatan tanpa `TextEditingController` — input hilang saat navigasi
2. **Checkout:** Tidak ada `_notesController`, tidak passing `notes` ke `createOrder()`
3. **Display (Customer & Seller):** `order.notes` tidak ditampilkan di halaman detail

Service (`order_service_appwrite.dart`) dan model (`order_model.dart`) sudah benar — hanya UI yang putus.

## File Diubah

| File | Perubahan |
|---|---|
| `cart_customer_mobile.dart` | StatefulWidget → TextEditingController → passing `notes` ke CheckoutPage |
| `checkout_page.dart` | Parameter `notes`, `_notesController`, UI catatan, kirim ke `createOrder(notes:)` |
| `detail_pesanan_customer.dart` | Tampilkan `notes` jika tidak kosong (amber card) |
| `form_pesanan_seller_web.dart` | `_detailRow('Catatan', order.notes)` di dialog detail |
| `form_pesanan_seller_mobile.dart` | `_infoRow("Catatan", order.notes)` di bottom sheet detail |

## Flow Data Baru

```
Cart (TextEditingController)
  → CheckoutPage(notes: string)
    → _notesController (pre-filled, editable)
      → createOrder(notes: _notesController.text.trim())
        → Appwrite DB 'notes' field ✅
          → Customer detail: amber card "Catatan Pesanan" ✅
          → Seller web detail: "Catatan" row ✅
          → Seller mobile detail: "Catatan" row ✅
```

## Customer View

Jika `order.notes` tidak kosong, tampil card warna amber dengan icon notes di bawah timeline.

## Seller View

- **Web:** Row `"Catatan"` + `order.notes` di dialog detail (setelah Pengirim)
- **Mobile:** Row `"Catatan"` + `order.notes` di bottom sheet detail (setelah Pengirim)

## Testing

| Test Case | Expected | Status |
|---|---|---|
| Cart: ketik catatan → checkout | Catatan terbawa ke halaman checkout | ✅ |
| Checkout: catatan terisi → Bayar | `createOrder()` menerima `notes` | ✅ |
| Customer: lihat detail pesanan | Catatan tampil jika tidak kosong, tidak tampil jika kosong | ✅ |
| Seller web: lihat detail pesanan | Catatan tampil jika tidak kosong | ✅ |
| Seller mobile: lihat detail pesanan | Catatan tampil jika tidak kosong | ✅ |

## Flutter Analyze

```
27 issues found (0 new)
```

Semua pre-existing. **Zero new issues.**

## Hasil Akhir

| Before | After |
|---|---|
| User mengetik catatan → hilang | User mengetik catatan → tersimpan ke DB |
| `notes` di OrderModel selalu `''` | `notes` diisi dari input user |
| Customer & Seller tidak bisa melihat catatan | Customer & Seller bisa melihat catatan di detail pesanan |
