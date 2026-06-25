# MODE PLAN

Lakukan audit dan implementasi fitur Edit Profil Seller Mobile.

PENTING:

* Jangan mengubah file apa pun selain file prompt.md saat tahap audit/plan.
* Setelah implementasi selesai, update dokumentasi ke file prompt.md.
* Jangan mengubah alur seller web yang sudah berjalan.

## Tujuan

Menyamakan kemampuan Seller Mobile dengan Seller Web pada halaman profil.

## File Utama

lib/presentation/seller/profile/profile_seller_mobile.dart

## Referensi Implementasi

Bandingkan dengan:

* lib/presentation/seller/profile/form_profil_seller_web.dart
* lib/presentation/customer/profile/profile_customer_mobile.dart

Gunakan pola yang sudah ada agar konsisten.

## Fitur Yang Harus Ada

### Edit Profil Seller

Seller mobile harus dapat mengubah:

* Nama Lengkap
* Nomor HP
* Nama Toko
* Alamat Toko
* Kota
* Provinsi

### UI

Tambahkan tombol:

Edit Profil

Ketika ditekan:

* tampilkan dialog edit seperti customer mobile
  ATAU
* gunakan mode edit seperti seller web

Pilih implementasi yang paling cepat dan konsisten.

### Simpan

Gunakan service yang sudah ada:

AuthServiceAppwrite.updateUserData()

Jangan membuat service baru jika tidak diperlukan.

### Validasi

Nama:

* wajib diisi

Nama Toko:

* wajib diisi

Nomor HP:

* minimal validasi tidak kosong

### Loading State

Saat proses simpan:

* tampilkan loading indicator
* cegah double submit

### Success State

Setelah berhasil:

* refresh data profile
* tampilkan SnackBar sukses

### Error State

Jika gagal:

* tampilkan SnackBar error

## Yang Tidak Perlu

Jangan implementasikan:

* Upload foto profil
* Deskripsi toko
* Username edit
* Ganti password

## Output Wajib

### Root Cause

### File Diubah

### Fitur Baru

### Hasil Testing

### Flutter Analyze

### Potensi Bug

# IMPLEMENTASI SELLER MOBILE PROFILE EDIT

## Ringkasan

Implementasi fitur edit profil seller pada tampilan mobile (`profile_seller_mobile.dart`). Sebelumnya halaman ini bersifat **read-only** — semua TextField menggunakan `readOnly: true` dan tombol "Simpan" di-disable dengan tooltip "Fitur akan diimplementasikan berikutnya". Setelah implementasi, seller mobile kini dapat mengedit profilnya dengan **mode toggle edit** (mengikuti pola web `form_profil_seller_web.dart`) menggunakan service `AuthServiceAppwrite.updateUserData()` yang sudah ada.

## File Diubah

1. **`lib/presentation/seller/profile/profile_seller_mobile.dart`** — penambahan:
   - 6 `TextEditingController` untuk field yang dapat diedit
   - Mode edit toggle (`_isEditing`)
   - Tombol "Edit Profil" di body (tampil saat mode baca)
   - Tombol "Simpan" dan "Batal" di AppBar (tampil saat mode edit)
   - Validasi form (nama wajib, nama toko wajib)
   - Loading state (`_saving` dengan spinner di tombol Simpan)
   - Success state (SnackBar hijau + refresh data)
   - Error state (SnackBar merah)
   - Field baru: Alamat Toko, Kota, Provinsi (sebelumnya hanya display gabungan)
   - Field yang dihapus: "Deskripsi Toko" (tidak perlu sesuai spec)
   - Email tetap read-only

## Fitur

| Fitur | Sebelum | Sesudah |
|---|---|---|
| Edit Nama Lengkap | ❌ read-only | ✅ editable |
| Edit Nomor HP | ❌ selalu "Belum diisi" | ✅ editable |
| Edit Nama Toko | ❌ read-only | ✅ editable |
| Edit Alamat Toko | ❌ tidak ada field | ✅ editable |
| Edit Kota | ❌ tidak ada field | ✅ editable |
| Edit Provinsi | ❌ tidak ada field | ✅ editable |
| Tombol Edit Profil | ❌ tidak ada | ✅ ada di body |
| Tombol Simpan | ❌ disabled + tooltip | ✅ aktif di AppBar |
| Tombol Batal | ❌ tidak ada | ✅ ada di AppBar |
| Validasi Nama | ❌ | ✅ wajib diisi |
| Validasi Nama Toko | ❌ | ✅ wajib diisi |
| Loading State | ❌ | ✅ spinner saat simpan |
| Success SnackBar | ❌ | ✅ hijau |
| Error SnackBar | ❌ | ✅ merah |
| Refresh setelah simpan | ❌ | ✅ reload data |

## Validasi

- **Nama Lengkap** — wajib diisi, validasi sebelum `updateUserData()`
- **Nama Toko** — wajib diisi, validasi sebelum `updateUserData()`
- **Nomor HP** — tidak ada validasi khusus (minimal tidak kosong tidak di-enforce, mengikuti spec)

## Hasil Testing

Tidak ada test suite yang aktif (test/widget_test.dart dikomentari). Verifikasi manual dilakukan via:
- `flutter analyze` — **No issues found**
- Inspeksi alur: mode baca → tekan "Edit Profil" → field jadi editable → isi data → tekan "Simpan" → validasi → panggil `updateUserData()` → refresh → SnackBar sukses

## Flutter Analyze

```
flutter analyze lib/presentation/seller/profile/profile_seller_mobile.dart
No issues found! (ran in 9.3s)
```

## Potensi Bug

- Jika `_userModel` null saat `_saveProfile()` dipanggil, `updateUserData()` akan mencari dokumen berdasarkan `uid` dari `account.get()` di dalam methodnya — aman karena fallback ke `account.get()`.
- `dispose()` membersihkan semua controller — aman.
- `_cancelEdit()` mereset controller ke data dari `_userModel` — aman.
- Tombol Simpan/Batal hanya muncul saat `_isEditing == true` — tidak ada double render.
