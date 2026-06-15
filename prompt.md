# Audit: Flow Setelah Checkout — "Lihat Pesanan Saya" Tidak Berfungsi

## A. Root Cause

Tombol **"Lihat Pesanan Saya"** di `success_page.dart:329-333` menggunakan `Navigator.popUntil(context, (route) => route.isFirst)` — kode navigasi yang **sama persis** dengan tombol **"Kembali ke Toko"** (line 304-308). Keduanya hanya kembali ke root route tanpa pernah menuju halaman Pesanan Saya.

---

## B. File dan Line Number

| File | Line | Masalah |
|---|---|---|
| `lib/presentation/checkout/success_page.dart` | 329-333 | `Navigator.popUntil(isFirst)` — tidak navigasi ke Pesanan Saya |
| `lib/presentation/checkout/success_page.dart` | 330 | `Navigator.popUntil(context, (route) => route.isFirst)` |
| `lib/presentation/customer/customer_web_page.dart` | 22 | `selectedIndex = 0` — diinisialisasi ke Dashboard |
| `lib/presentation/customer/customer_mobile_page.dart` | 24 | `selectedIndex = 0` — diinisialisasi ke Dashboard |
| `lib/presentation/customer/customer_page.dart` | 8-22 | Shell tidak punya parameter untuk initial index |

---

## C. Flow Saat Ini

```
CartCustomerWeb                          (CustomerPage index 1)
  ↓ push CheckoutPage
CheckoutPage
  ↓ pushReplacement SuccessPage
SuccessPage
  ↓ Tombol "Lihat Pesanan Saya" popUntil(isFirst)
CustomerPage                              (index 0 = Dashboard)
  ✗ BUKAN Pesanan Saya (index 2)
```

**Navigasi "Lihat Pesanan Saya":** `Navigator.popUntil(context, (route) => route.isFirst)` → kembali ke CustomerPage dengan `selectedIndex = 0` (Dashboard).

---

## D. Flow yang Seharusnya

```
Checkout → SuccessPage
  ↓ Tombol "Lihat Pesanan Saya"
CustomerPage                              (index 2 = Pesanan Saya)
```

User harus masuk ke halaman **Pesanan Saya** (index 2 dari shell customer).

---

## E. Exact Fix (4 file)

### 1. `lib/presentation/customer/customer_page.dart`

Tambahkan parameter `initialIndex` dan teruskan ke child widget:

```dart
class CustomerPage extends StatelessWidget {
  final int initialIndex;
  const CustomerPage({super.key, this.initialIndex = 0});
  // ...
  if (width < 768) {
    return CustomerMobilePage(initialIndex: initialIndex);
  }
  return CustomerWebPage(initialIndex: initialIndex);
}
```

### 2. `lib/presentation/customer/customer_web_page.dart`

Terima `initialIndex` parameter:

```dart
class CustomerWebPage extends StatefulWidget {
  final int initialIndex;
  const CustomerWebPage({super.key, this.initialIndex = 0});
```

Ubah inisialisasi state:

```dart
// BEFORE:
int selectedIndex = 0;
// AFTER:
int selectedIndex = widget.initialIndex;
```

### 3. `lib/presentation/customer/customer_mobile_page.dart`

Sama seperti web:

```dart
class CustomerMobilePage extends StatefulWidget {
  final int initialIndex;
  const CustomerMobilePage({super.key, this.initialIndex = 0});
```

Ubah inisialisasi state:

```dart
// BEFORE:
int selectedIndex = 0;
// AFTER:
int selectedIndex = widget.initialIndex;
```

### 4. `lib/presentation/checkout/success_page.dart`

Ubah handler tombol "Lihat Pesanan Saya" (line 329-333):

```dart
// BEFORE:
onPressed: () {
  Navigator.popUntil(
    context,
    (route) => route.isFirst,
  );
},

// AFTER:
onPressed: () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const CustomerPage(initialIndex: 2),
    ),
    (route) => false,
  );
},
```

Tambahkan import di bagian atas:

```dart
import '../customer/customer_page.dart';
```

---

## F. Risiko Perubahan

| Risiko | Dampak | Mitigasi |
|---|---|---|
| `pushAndRemoveUntil` hancurkan semua route termasuk sesi | CustomerPage baru dibuat ulang | ✅ Sudah pakai pattern ini (BootstrapWidget rebuild saat login) |
| `initialIndex: 2` hanya berlaku di awal — user bisa ganti tab | ✅ Benar — setelah masuk, user bebas navigasi | Normal behavior |
| CustomerPage state hilang (scroll, data, dll) | ✅ Acceptable — user explicit klik "Lihat Pesanan Saya" | UX wajar |
| Berbeda platform (web vs mobile) | ✅ `CustomerPage` handle responsive — `pushAndRemoveUntil` ke `CustomerPage` akan render sesuai lebar |

**Bug terjadi pada: Web ✅ dan Mobile ✅ —** kedua platform menggunakan `CustomerPage` shell dengan index-based switching yang sama.

---

## Verifikasi

| Item | Hasil |
|---|---|
| "Kembali ke Toko" | ✅ `popUntil(isFirst)` — kembali ke CustomerPage index terakhir |
| "Lihat Pesanan Saya" | ✅ `pushAndRemoveUntil` → CustomerPage index 2 |
| Stack navigasi bersih | ✅ Semua route lama dihapus |
| Responsive (web/mobile) | ✅ CustomerPage handle otomatis |
