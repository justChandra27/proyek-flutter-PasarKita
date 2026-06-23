# TUGAS HOTFIX ADMIN MOBILE ROUTING

## MASALAH

Admin Mobile sudah selesai dibuat:

* AdminMobileShell
* Dashboard Mobile
* Orders Mobile
* Returns Mobile

Namun saat aplikasi dijalankan pada perangkat mobile, sistem masih menampilkan Admin Web.

Artinya Admin Mobile belum dipanggil oleh navigation flow aplikasi.

---

# TUJUAN

Pastikan:

* Mobile → AdminMobileShell
* Tablet/Desktop/Web → Admin Web lama

Admin Mobile harus otomatis terbuka ketika admin login menggunakan perangkat mobile.

---

# AUDIT WAJIB

Cari seluruh navigasi admin pada project.

Cari penggunaan:

```dart
AdminPage(
```

```dart
AdminLayout(
```

```dart
FormDashboardAdmin(
```

```dart
role == 'admin'
```

```dart
user.role == 'admin'
```

Temukan semua lokasi yang menentukan halaman tujuan setelah login admin.

---

# IMPLEMENTASI

## 1. Login Flow

Pada login sukses:

Jika role admin:

```dart
final isMobile =
    MediaQuery.of(context).size.width < 768;
```

Jika mobile:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const AdminMobileShell(),
  ),
);
```

Jika bukan mobile:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const AdminPage(),
  ),
);
```

---

## 2. Auto Login / Session Restore

Audit:

* Splash Screen
* Auth Wrapper
* Main Page
* Initial Route

Pastikan jika admin sudah login sebelumnya:

Mobile tetap diarahkan ke:

```dart
AdminMobileShell()
```

bukan:

```dart
AdminPage()
```

---

## 3. Logout Flow

Pastikan logout dari:

```dart
AdminMobileShell
```

kembali ke:

```dart
LoginPage()
```

dan tidak menyebabkan loop.

---

## 4. Testing

Verifikasi:

### Mobile

Admin Login

↓

AdminMobileShell

↓

Dashboard Mobile

↓

Drawer Mobile

↓

Orders Mobile

↓

Returns Mobile

↓

Logout

### Desktop/Web

Admin Login

↓

Admin Web Lama

↓

Semua fitur web tetap berjalan

---

## 5. Regression Check

Pastikan:

* Customer tidak berubah
* Seller tidak berubah
* Admin Web tidak berubah

---

# OUTPUT WAJIB

Tampilkan:

## File Yang Dimodifikasi

## Lokasi Routing Lama

## Lokasi Routing Baru

## Hasil Pengujian

## Flutter Analyze

---

# DOKUMENTASI WAJIB

Update:

docs/prompt.md

Tambahkan section baru:

# IMPLEMENTASI ADMIN MOBILE V3.1

## Routing Fix

### Masalah

Admin mobile sudah dibuat tetapi masih membuka Admin Web.

### Penyebab

Tuliskan file dan kode yang menyebabkan admin tetap masuk ke Admin Web.

### Perbaikan

Tuliskan perubahan routing yang dilakukan.

### File Yang Diubah

Daftar file yang dimodifikasi.

### Hasil Testing

✅ Login Admin Mobile

✅ Login Admin Web

✅ Session Restore

✅ Logout

### Flutter Analyze

Tuliskan hasil terbaru.

---

Setelah selesai:

1. Tampilkan isi docs/prompt.md terbaru.
2. Tampilkan seluruh file yang diubah.
3. Tampilkan kode sebelum dan sesudah perbaikan routing.
4. Pastikan Admin Mobile benar-benar menjadi halaman admin default pada perangkat mobile.

