# penjelasan_struktur.md

# Struktur Proyek PasarKita

## Backend

Appwrite

Database:

* users
* products
* orders
* transaksi
* categories

Storage:

* product_images

---

## Folder Penting

lib/

### core/

Berisi:

* appwrite/
* services/
* controllers/
* widgets/
* utils/

---

### data/models/

Model data aplikasi.

Berisi:

* ProductModel
* UserModel
* OrderModel
* CartModel
* CategoryModel
* TransaksiModel

Model tidak berisi logika Appwrite.

---

### presentation/

Berisi seluruh UI.

Role:

* admin/
* seller/
* customer/

---

# Alur Data

Appwrite Database
↓
Service
↓
Model
↓
Controller / Provider
↓
UI

---

# Seller Flow

Seller Login
↓
Tambah Produk
↓
ProductServiceAppwrite
↓
products collection

Seller Edit Produk
↓
updateDocument

Seller Upload Gambar
↓
StorageServiceAppwrite

Status:
SUDAH TERHUBUNG APPWRITE

---

# Admin Flow

Admin Users
↓
users collection

Admin Verification
↓
users collection

Admin Orders
↓
orders collection

Admin Transactions
↓
transaksi collection

Status:
SUDAH TERHUBUNG APPWRITE

---

# Customer Flow

Saat ini sebagian besar masih dummy UI.

Dashboard Customer:
BELUM TERHUBUNG

Cart:
BELUM TERHUBUNG

Checkout:
BELUM TERHUBUNG

Orders:
BELUM TERHUBUNG

Profile:
BELUM TERHUBUNG

Prioritas pengembangan berikutnya adalah customer.

---

# Existing Appwrite Services

Gunakan service berikut:

* ProductServiceAppwrite
* OrderServiceAppwrite
* StorageServiceAppwrite
* AuthServiceAppwrite
* TransaksiService

Jangan membuat service baru jika fungsi sudah tersedia.
