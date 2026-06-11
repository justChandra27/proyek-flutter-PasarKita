# skills/pasarkita_skill.md

# PasarKita AI Skill

## Objective

Membantu pengembangan marketplace PasarKita tanpa merusak struktur proyek.

---

## Before Writing Code

Selalu lakukan:

1. Analisis file yang sudah ada.
2. Cari service yang sudah tersedia.
3. Cari model yang sudah tersedia.
4. Cari widget yang sudah tersedia.

Baru kemudian menulis kode.

---

## Forbidden Actions

Dilarang:

* overwrite seluruh file
* membuat versi file baru
* membuat duplicate service
* membuat duplicate model
* membuat duplicate widget
* menghapus file

---

## Existing Services

Gunakan:

ProductServiceAppwrite

Untuk:

* list produk
* tambah produk
* edit produk
* hapus produk

---

OrderServiceAppwrite

Untuk:

* create order
* get orders
* update status

---

StorageServiceAppwrite

Untuk:

* upload gambar produk

---

TransaksiService

Untuk:

* transaksi admin
* statistik transaksi

---

## Customer Development Rules

Dashboard Customer:

Harus membaca products collection dari Appwrite.

Jangan gunakan data hardcoded.

---

Cart Customer:

Harus membaca data database.

Jangan gunakan list lokal.

---

Orders Customer:

Harus membaca order berdasarkan customerId.

Jangan gunakan data statis.

---

Profile Customer:

Harus membaca akun login Appwrite.

Gunakan:

AppwriteService.account.get()

---

## Output Rules

Sebelum mengubah kode:

Tampilkan:

* file yang akan diubah
* alasan perubahan
* risiko perubahan

Setelah itu baru berikan implementasi.
