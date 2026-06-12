Implementasikan penghapusan imageUrl dari fitur kategori.

Tujuan:
- Hapus input "Image URL" pada dialog Tambah Kategori Admin.
- Hapus imageController.
- Hapus field imageUrl dari createDocument categories.
- Hapus field imageUrl dari CategoryModel.
- Hapus parsing imageUrl dari fromMap/toMap jika ada.
- Jangan mengubah fitur kategori lain.
- Jangan mengubah ProductFormPage.
- Jangan mengubah CategoryServiceAppwrite.
- Jangan mengubah collection selain categories.

Setelah implementasi:
1. Jalankan flutter analyze.
2. Audit ulang semua referensi imageUrl kategori.
3. Tulis hasil implementasi ke prompt.md.

Aturan:
- Jangan membuat file _v2 atau _new.
- Jangan melakukan refactor di luar scope.
- Jangan mengubah file selain yang memang memakai imageUrl kategori.