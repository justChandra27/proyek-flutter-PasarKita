# Implementasi Sinkronisasi Field Baru Database

Database sudah memiliki field baru:

Products:

* weight
* minPurchase
* soldCount

Users:

* storeName
* storeAddress
* city
* province

Implementasikan sinkronisasi model dan form produk.

Fokus hanya pada:

1. `lib/data/models/product_model.dart`

   * Tambah field:

     * weight
     * minPurchase
     * soldCount
   * Update constructor
   * Update fromMap
   * Update toMap

2. `lib/data/models/user_model.dart`

   * Tambah field:

     * storeName
     * storeAddress
     * city
     * province
   * Update constructor
   * Update fromMap

3. `lib/core/services/product_service_appwrite.dart`

   * Tambah parameter weight dan minPurchase pada:

     * addProduct()
     * updateProduct()
   * Saat create product:

     * soldCount default 0
   * Saat update product:

     * jangan overwrite soldCount

4. `lib/presentation/seller/products/product_form_page.dart`

   * Tambah input:

     * Berat Produk (gram)
     * Minimal Pembelian
   * Support create dan edit
   * Validasi:

     * berat > 0
     * minimal pembelian >= 1

5. Jalankan flutter analyze.

Aturan:

* Jangan mengubah file selain yang disebutkan.
* Jangan membuat model baru.
* Jangan membuat service baru.
* Jangan mengubah fitur lain.
* Jangan mengubah prompt.md selain output hasil implementasi.

Output hasil ke prompt.md.
