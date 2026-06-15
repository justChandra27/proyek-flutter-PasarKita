MODE: IMPLEMENT

Proyek: PasarKita Flutter

Jangan membuat migration.
Jangan mengubah database.
Jangan mengubah API Appwrite.

Fokus:

Seller → Pesanan → Konsistensi Filter dan Sorting Total Pesanan

KONDISI SAAT INI

Filter Total Pesanan sudah menggunakan:

```dart
order.totalAmount
```

Namun sorting masih menggunakan:

```dart
_subtotal(entry)
```

Akibatnya:

* Filter dan sorting memakai field berbeda
* User dapat melihat hasil yang tidak sesuai ekspektasi
* UX menjadi membingungkan

TUGAS

1. Temukan implementasi sorting:

```dart
case 'total_tertinggi'
case 'total_terendah'
```

di:

```text
lib/presentation/seller/orders/form_pesanan_seller_web.dart
```

2. Ubah sorting agar menggunakan:

```dart
order.totalAmount
```

dan bukan:

```dart
_subtotal(entry)
```

3. Pastikan implementasi baru:

Sebelum:

```dart
result.sort((a, b) => _subtotal(b).compareTo(_subtotal(a)));
```

Sesudah (contoh):

```dart
final orderA = a['order'] as OrderModel;
final orderB = b['order'] as OrderModel;

result.sort(
  (a, b) => orderB.totalAmount.compareTo(orderA.totalAmount),
);
```

Lakukan hal yang sama untuk:

```dart
total_tertinggi
total_terendah
```

4. Jangan mengubah:

* search
* filter status
* filter tanggal
* export CSV
* dashboard analytics

5. Setelah implementasi lakukan audit:

Verifikasi field berikut:

| Fitur                | Field |
| -------------------- | ----- |
| Filter Total Pesanan | ?     |
| Sort Total Tertinggi | ?     |
| Sort Total Terendah  | ?     |

Target:

Semuanya harus menggunakan:

```dart
order.totalAmount
```

6. Lakukan simulasi:

Data:

* Order A = Rp350.000
* Order B = Rp75.000
* Order C = Rp600.000

Verifikasi:

* Sort tertinggi → C, A, B
* Sort terendah → B, A, C
* Filter min/max tetap bekerja

7. Output hasil implementasi ke prompt.md:

* file yang diubah
* baris yang diubah
* sebelum vs sesudah
* hasil simulasi
* hasil flutter analyze

Jangan mengubah file lain di luar scope ini.

---

# IMPLEMENTASI: Konsistensi Sorting Total Pesanan

## File yang Diubah

`lib/presentation/seller/orders/form_pesanan_seller_web.dart`

## Baris yang Diubah

**Line 187–192** — sorting `total_tertinggi` dan `total_terendah`.

### Sebelum
```dart
case 'total_tertinggi':
  result.sort((a, b) => _subtotal(b).compareTo(_subtotal(a)));
  break;
case 'total_terendah':
  result.sort((a, b) => _subtotal(a).compareTo(_subtotal(b)));
  break;
```

### Sesudah
```dart
case 'total_tertinggi':
  result.sort((a, b) => (b['order'] as OrderModel).totalAmount.compareTo((a['order'] as OrderModel).totalAmount));
  break;
case 'total_terendah':
  result.sort((a, b) => (a['order'] as OrderModel).totalAmount.compareTo((b['order'] as OrderModel).totalAmount));
  break;
```

### Perubahan Logika
| Sorting | Sebelum | Sesudah |
|---|---|---|
| total_tertinggi | `_subtotal(b) vs _subtotal(a)` | `(b['order']).totalAmount vs (a['order']).totalAmount` |
| total_terendah | `_subtotal(a) vs _subtotal(b)` | `(a['order']).totalAmount vs (b['order']).totalAmount` |

---

## Verifikasi — `flutter analyze`

✅ Tidak ada error atau warning baru (hanya 2 info pre-existing: deprecated `dart:html`).

---

## Verifikasi Konsistensi Field

| Fitur | Field | Status |
|---|---|---|
| Filter Total Pesanan | `order.totalAmount` | ✅ Sudah konsisten |
| Sort Total Tertinggi | `order.totalAmount` | ✅ **Sekarang konsisten** |
| Sort Total Terendah | `order.totalAmount` | ✅ **Sekarang konsisten** |

---

## Simulasi

Data:
- Order A = Rp350.000
- Order B = Rp75.000
- Order C = Rp600.000

### Sort Total Tertinggi
| Urutan | Order | totalAmount |
|---|---|---|
| 1 | C | Rp600.000 |
| 2 | A | Rp350.000 |
| 3 | B | Rp75.000 |

### Sort Total Terendah
| Urutan | Order | totalAmount |
|---|---|---|
| 1 | B | Rp75.000 |
| 2 | A | Rp350.000 |
| 3 | C | Rp600.000 |

✅ Sesuai ekspektasi.

### Filter Min/Max Tetap Bekerja
- Filter min=100000 → menampilkan A (350rb) dan C (600rb), menyembunyikan B (75rb) ✅
- Filter max=400000 → menampilkan A (350rb) dan B (75rb), menyembunyikan C (600rb) ✅
- Filter min=100000 & max=400000 → hanya A (350rb) ✅
