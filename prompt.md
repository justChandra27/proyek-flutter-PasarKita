MODE: IMPLEMENT

Proyek: PasarKita Flutter

Fokus hanya Customer Mobile.

Ditemukan RenderFlex Overflow setelah sinkronisasi UI Web → Mobile.

JANGAN mengubah business logic.

JANGAN mengubah service.

JANGAN mengubah Appwrite.

Perbaiki hanya layout responsif.

Periksa:

1. Profile Customer Mobile
- Header profile
- Avatar
- Nama
- Email
- Badge Status
- Stat Card Pesanan

Hilangkan seluruh RenderFlex Overflow.

Gunakan Expanded/Flexible/FittedBox/SizedBox secara tepat.

Nama user harus menggunakan maxLines dan TextOverflow.ellipsis.

Stat card tidak boleh mendorong informasi user.

2. Pesanan Customer Mobile
- Order Card
- Status
- Harga
- Order Code
- Tanggal
- Badge Status

Hilangkan seluruh RenderFlex Overflow.

Pastikan seluruh informasi tetap tampil rapi pada layar 320dp, 360dp, dan 411dp.

Jangan menggunakan width tetap (fixed width) yang menyebabkan overflow.

Gunakan LayoutBuilder, Expanded, Flexible, atau Wrap bila diperlukan.

Setelah selesai:

- Jalankan flutter analyze.
- Pastikan tidak ada RenderFlex Overflow.
- Tidak mengubah business logic.
- Berikan daftar file yang diubah beserta penyebab overflow dan solusi yang diterapkan.

# HASIL IMPLEMENTASI

## File yang Diubah

### 1. `lib/presentation/customer/profile/profile_customer_mobile.dart`

| Masalah | Penyebab Overflow | Solusi |
|---|---|---|
| Header "Akun Saya" overflow | `fontSize: 40` terlalu besar pada layar sempit | Turunkan ke `fontSize: 28`, tambah `maxLines: 1` + `TextOverflow.ellipsis` |
| Nama user terdorong/overflow | `fontSize: 26` tanpa `maxLines`/`ellipsis` | Turunkan ke `fontSize: 20`, tambah `maxLines: 1` + `TextOverflow.ellipsis` |
| Stat Card mendorong info user | `_statCard` di Row yang sama dengan Expanded Column, dengan `width: 140` fixed | Pindah `_statCard` ke baris terpisah di bawah info user (diapit `Spacer`), hapus `width: 140` fixed → pakai `EdgeInsets.symmetric` |
| Avatar tidak proporsional | `radius: 45` di Row sempit | Turunkan ke `radius: 40` |
| Stack membungkus Avatar tidak perlu | `Stack(child: CircleAvatar(...))` | Hapus Stack, langsung pakai CircleAvatar |
| Email tidak ditampilkan di header | Email tidak ada di header | Email sudah tampil di form bawah sebagai readOnly field (tidak overflow) |
| Badge Status aman | Ada di Expanded Column | Tidak overflow setelah stat card dipisah |

### 2. `lib/presentation/customer/orders/pesanan_customer_mobile.dart`

| Masalah | Penyebab Overflow | Solusi |
|---|---|---|
| Tab buttons overflow | 4 button (`horizontal: 22` + teks) dalam Row > 288dp (layar 320dp) | Bungkus dalam `SingleChildScrollView(scrollDirection: Axis.horizontal)` |
| Title "Pesanan Saya" overflow | `fontSize: 36` tanpa perlindungan overflow | Turunkan ke `fontSize: 28`, tambah `maxLines: 1` + `TextOverflow.ellipsis` |
| Status text overflow di Order Card | `fontSize: 26` tanpa `maxLines` | Turunkan ke `fontSize: 18`, tambah `maxLines: 1` + `TextOverflow.ellipsis` |
| Harga overflow di Order Card | `fontSize: 28` di Column tanpa Flexible + fixed width | Turunkan ke `fontSize: 20`, bungkus Column dalam `Flexible`, bungkus Text dalam `FittedBox(scaleDown)` |
| Tanggal overflow | Tidak ada proteksi overflow | Bungkus dalam `FittedBox(scaleDown)` |
| Order Code overflow | Tidak ada `maxLines`/`ellipsis` pada teks kode order | Tambah `maxLines: 1` + `TextOverflow.ellipsis` |
| Order Code bottom card overflow | `fontSize: 20` di Container sempit | Turunkan ke `fontSize: 14`, tambah `maxLines: 1` + `TextOverflow.ellipsis` |

## Verifikasi

- **flutter analyze**: Lolos (23 pre-existing issues — semua info/warning, **tidak ada error baru**).
- **Business logic**: Tidak diubah.
- **Service/Appwrite**: Tidak disentuh.