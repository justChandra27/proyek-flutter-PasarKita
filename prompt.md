MODE: AUDIT

Periksa ProductModel.

1. Apakah ProductModel memiliki createdAt?
2. Apakah fromMap mengisi createdAt?
3. Apakah ProductServiceAppwrite mengambil $createdAt?

Jika ya:
- sort "Terbaru" harus menggunakan createdAt desc.

Output:
# Product Sort Verification