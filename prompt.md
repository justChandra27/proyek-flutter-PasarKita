MODE: IMPLEMENT

Proyek: PasarKita Flutter

PENTING:

Jangan mengubah file apa pun selain file yang terkait dengan fitur imageUrl pada order_items.

Tuliskan seluruh hasil implementasi ke prompt.md.

Gunakan hasil PLAN terakhir.

Target:

Simpan imageUrl produk ke collection order_items agar riwayat pesanan memiliki snapshot gambar produk saat transaksi dibuat.

Implementasikan:

1. OrderItemModel
2. createOrder()
3. checkout_page.dart
4. detail_pesanan_customer.dart

Untuk SuccessPage:

* Audit terlebih dahulu tipe data yang digunakan.
* Hanya implementasikan jika imageUrl sudah tersedia secara aman.
* Jika tidak aman, tuliskan alasannya di prompt.md dan jangan ubah SuccessPage.

Perubahan yang diinginkan:

## 1. OrderItemModel

File:
`lib/data/models/order_item_model.dart`

Tambahkan:

```dart
final String imageUrl;
```

Update:

* constructor
* fromMap()
* toMap()

Gunakan:

```dart
imageUrl: data['imageUrl'] ?? '',
```

untuk backward compatibility.

## 2. Checkout Flow

File:
`lib/presentation/checkout/checkout_page.dart`

Pastikan map item yang dikirim ke createOrder() ikut membawa:

```dart
'imageUrl': item.imageUrl,
```

## 3. Create Order

File:
`lib/core/services/order_service_appwrite.dart`

Saat membuat document order_items, simpan:

```dart
'imageUrl': item['imageUrl'] ?? '',
```

bersama field lain yang sudah ada.

Jangan mengubah:

* stock reduction
* soldCount
* notification
* order status flow

## 4. Detail Pesanan Customer

File:
`lib/presentation/customer/orders/detail_pesanan_customer.dart`

Ganti placeholder icon produk dengan:

```dart
Image.network(...)
```

menggunakan:

```dart
item.imageUrl
```

Tambahkan fallback:

* imageUrl kosong
* image gagal dimuat

tetap tampilkan:

```dart
Icons.inventory_2_outlined
```

seperti perilaku saat ini.

## Backward Compatibility

Data lama yang tidak memiliki imageUrl harus tetap bisa dibuka tanpa error.

Gunakan:

```dart
data['imageUrl'] ?? ''
```

dan fallback icon.

Output ke prompt.md:

# File Yang Diubah

| # | File | Perubahan |
|---|---|---|
| 1 | `lib/data/models/order_item_model.dart` | Tambah field `imageUrl` |
| 2 | `lib/core/services/order_service_appwrite.dart` | Simpan `imageUrl` di data order_items |
| 3 | `lib/presentation/checkout/checkout_page.dart` | Kirim `imageUrl` ke `createOrder()` |
| 4 | `lib/presentation/customer/orders/detail_pesanan_customer.dart` | Ganti grey placeholder dengan `Image.network` + fallback |
| 5 | `lib/presentation/checkout/success_page.dart` | Tambah thumbnail gambar di daftar produk |

# Sebelum (detail_pesanan_customer.dart:338-347)

```dart
Container(
  width: 48, height: 48,
  decoration: BoxDecoration(
    color: Colors.grey.shade200,
    borderRadius: BorderRadius.circular(10),
  ),
  child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
),
```

# Sesudah (detail_pesanan_customer.dart)

```dart
Container(
  width: 48, height: 48,
  decoration: BoxDecoration(
    color: Colors.grey.shade200,
    borderRadius: BorderRadius.circular(10),
  ),
  child: item.imageUrl.isNotEmpty
      ? ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.inventory_2_outlined, color: Colors.grey),
          ),
        )
      : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
),
```

# Backward Compatibility

- `fromMap`: `imageUrl: data['imageUrl'] ?? ''` — data lama tanpa field `imageUrl` akan bernilai string kosong
- UI fallback: jika `imageUrl.isEmpty` → tampilkan icon grey (perilaku lama)
- `errorBuilder` pada `Image.network`: jika URL broken/expired → fallback ke icon grey
- Tidak ada error untuk data lama

# Dampak

- Order baru: snapshot gambar produk tersimpan di `order_items`
- Detail Pesanan Customer: menampilkan gambar asli produk, bukan grey icon
- Success Page: menampilkan thumbnail gambar di samping nama produk
- Data lama: tetap aman, tampilkan icon grey seperti sebelumnya
- `flutter analyze` — 0 issues (1 pre-existing `use_build_context_synchronously` di luar scope perubahan)

# Catatan SuccessPage

**Audit:** `_loadOrder()` di `success_page.dart:52` memanggil `orderService.getOrderItems(widget.orderId)` yang mengembalikan `List<OrderItemModel>`. Setelah model di-update dengan `imageUrl`, data dari DB sudah包含 `imageUrl` (untuk order baru) atau fallback `''` (untuk data lama). Akses `item.imageUrl` aman karena `fromMap` selalu mengembalikan string.

**Keputusan:** ✅ Implementasi aman — thumbnail ditambahkan di `success_page.dart`.
