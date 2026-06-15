MODE: AUDIT

Proyek: PasarKita Flutter

Jangan mengubah file apa pun.

Lakukan audit seluruh createDocument() dan updateDocument().

Buat tabel:

1. Collection
2. Field yang ditulis
3. Tipe Dart
4. Tipe Appwrite yang seharusnya

Kemudian buat checklist migrasi Appwrite lengkap untuk:

- users
- products
- orders
- order_items
- notifications
- withdrawals
- reviews
- transaksi
- categories

Tandai field yang kemungkinan belum ada di Appwrite dan berpotensi menghasilkan:

Unknown attribute (400)

Tujuan:
membuat daftar migrasi schema final sebelum demo sehingga tidak muncul error Unknown attribute lagi.

# berikan hasil auditnya di file prompt.md

---

## HASIL AUDIT LENGKAP — Semua Collection

### 1. `users` (usersCollectionId)

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `uid` | String | string | register() | ✅ |
| `name` | String | string | register(), updateUserData(), form_pengguna_web, form_profil_seller_web | ✅ |
| `email` | String | string | register() | ✅ |
| `username` | String | string | register() | ✅ |
| `role` | String | string | register(), form_pengguna_web | ✅ |
| `status` | String | string | register(), form_verifikasi_web, form_pengguna_web | ✅ |
| `active` | bool | boolean | register() | ✅ |
| `phone` | String | string | register() | ❌ optional |
| `shippingAddress` | String | string | register() | ❌ optional |
| `shippingCity` | String | string | register() | ❌ optional |
| `shippingProvince` | String | string | register() | ❌ optional |
| `shippingPostalCode` | String | string | register() | ❌ optional |
| `storeName` | String | string | form_profil_seller_web | ❌ optional |
| `storeAddress` | String | string | form_profil_seller_web | ❌ optional |
| `city` | String | string | form_profil_seller_web | ❌ optional |
| `province` | String | string | form_profil_seller_web | ❌ optional |

> **FIELD BERPOTENSI MISSING:** `storeName`, `storeAddress`, `city`, `province` — hanya ditulis oleh profile seller page. Jika belum ada di Appwrite, update profil seller akan error.

---

### 2. `products` (productsCollectionId)

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `sellerId` | String | string | addProduct() | ✅ |
| `name` | String | string | addProduct(), updateProduct() | ✅ |
| `description` | String | string | addProduct(), updateProduct() | ✅ |
| `category` | String | string | addProduct(), updateProduct() | ✅ |
| `price` | double | double | addProduct(), updateProduct() | ✅ |
| `stock` | int | integer | addProduct(), updateProduct(), rollback, cancel | ✅ |
| `imageUrl` | String | string | addProduct(), updateProduct() | ✅ |
| `active` | bool | boolean | addProduct(), updateProduct(), updateModerationStatus() | ✅ |
| `weight` | double | double | addProduct(), updateProduct() | ✅ |
| `minPurchase` | int | integer | addProduct(), updateProduct() | ✅ |
| `soldCount` | int | integer | addProduct(), complete order | ✅ |
| `colors` | List\<String\> | string[] | addProduct(), updateProduct() | ❌ optional |
| `sizes` | List\<String\> | string[] | addProduct(), updateProduct() | ❌ optional |
| `moderationNote` | String | string | addProduct(), updateProduct(), updateModerationStatus() | ❌ optional |
| **`moderationStatus`** | String | string | **addProduct(), updateModerationStatus()** | ✅ |
| `moderatedBy` | String | string | addProduct(), updateModerationStatus() | ❌ optional |
| `moderatedAt` | String (datetime) | string | updateModerationStatus() | ❌ optional |

> **ROOT CAUSE:** `moderationStatus` ❌ belum ada.
> **BERPOTENSI ERROR:** `moderationNote`, `moderatedBy`, `moderatedAt` jika belum ditambahkan.

---

### 3. `orders` (ordersCollectionId)

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `orderCode` | String | string | createOrder() | ✅ |
| `customerId` | String | string | createOrder() | ✅ |
| `customerName` | String | string | createOrder() | ✅ |
| `customerEmail` | String | string | createOrder() | ✅ |
| `totalAmount` | int | integer | createOrder() | ✅ |
| `serviceFee` | int | integer | createOrder() | ✅ |
| `status` | String | string | createOrder(), updateOrderStatus() | ✅ |
| `paymentMethod` | String | string | createOrder() | ✅ |
| `paymentStatus` | String | string | createOrder() | ✅ |
| `address` | String | string | createOrder() | ✅ |
| `notes` | String | string | createOrder() | ❌ optional |
| `createdAt` | String (datetime) | string | createOrder() | ✅ |
| `updatedAt` | String (datetime) | string | createOrder(), updateOrderStatus() | ✅ |
| `phone` | String | string | createOrder() | ❌ optional |
| `shippingAddress` | String | string | createOrder() | ❌ optional |
| `shippingCity` | String | string | createOrder() | ❌ optional |
| `shippingProvince` | String | string | createOrder() | ❌ optional |
| `shippingPostalCode` | String | string | createOrder() | ❌ optional |

> **RISIKO RENDAH** — orders adalah collection inti, kemungkinan semua field sudah ada. Tapi periksa `phone`, `shippingAddress`, `shippingCity`, `shippingProvince`, `shippingPostalCode`, `notes` jika belum dibuat saat migrasi awal.

---

### 4. `order_items` (orderItemsCollectionId)

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `orderId` | String | string | createOrder() | ✅ |
| `productId` | String | string | createOrder() | ✅ |
| `productName` | String | string | createOrder() | ✅ |
| `sellerId` | String | string | createOrder() | ✅ |
| `price` | int | integer | createOrder() | ✅ |
| `quantity` | int | integer | createOrder() | ✅ |
| `subtotal` | int | integer | createOrder() | ✅ |
| `platformFee` | int | integer | createOrder() | ✅ |
| `sellerAmount` | int | integer | createOrder() | ✅ |
| `imageUrl` | String | string | createOrder() | ❌ optional |
| `color` | String | string | createOrder() | ❌ optional |
| `size` | String | string | createOrder() | ❌ optional |

> **RISIKO RENDAH** — collection inti. Periksa `platformFee`, `sellerAmount`, `imageUrl`, `color`, `size`.

---

### 5. `notifications` (notificationsCollectionId)

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `userId` | String | string | createNotification() | ✅ |
| `title` | String | string | createNotification() | ✅ |
| `message` | String | string | createNotification() | ✅ |
| `type` | String | string | createNotification() | ✅ |
| `orderId` | String | string | createNotification() | ✅ |
| `isRead` | bool | boolean | createNotification(), markAsRead(), markAllAsRead() | ✅ |

> **RISIKO SEDANG** — jika collection `notifications` belum dibuat sama sekali, semua field ini akan error.

---

### 6. `withdrawals` (withdrawalsCollectionId)

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `sellerId` | String | string | requestWithdrawal() | ✅ |
| `amount` | int | integer | requestWithdrawal() | ✅ |
| `bankName` | String | string | requestWithdrawal() | ✅ |
| `bankAccount` | String | string | requestWithdrawal() | ✅ |
| `accountName` | String | string | requestWithdrawal() | ✅ |
| `status` | String | string | requestWithdrawal(), approveWithdrawal(), rejectWithdrawal() | ✅ |
| `adminNote` | String | string | requestWithdrawal(), rejectWithdrawal() | ❌ optional |
| `requestedAt` | String (datetime) | string | requestWithdrawal() | ✅ |
| `processed_at` | String (datetime) | string | requestWithdrawal(), approveWithdrawal(), rejectWithdrawal() | ❌ optional |
| `processed_by` | String | string | requestWithdrawal(), approveWithdrawal(), rejectWithdrawal() | ❌ optional |

> **RISIKO SEDANG.** Field `processed_at` (snake_case) tidak konsisten dengan gaya camelCase kode lain — pastikan attribute ini ada persis dengan nama `processed_at`.

---

### 7. `reviews` (reviewsCollectionId)

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `productId` | String | string | createReview() | ✅ |
| `orderId` | String | string | createReview() | ✅ |
| `userId` | String | string | createReview() | ✅ |
| `userName` | String | string | createReview() | ✅ |
| `rating` | int | integer | createReview() | ✅ |
| `comment` | String? | string | createReview() | ❌ optional |

> **RISIKO SEDANG** — jika collection `reviews` belum dibuat.

---

### 8. `transaksi` (transaksiCollection)

> **Tidak ada `createDocument()` atau `updateDocument()`** dalam codebase. Collection ini hanya dibaca (read-only via `listDocuments`, `getDocument`). Data kemungkinan diisi oleh sistem eksternal atau migration manual. Tidak berpotensi error Unknown attribute dari sisi Flutter.

---

### 9. `categories` (categoriesCollectionId)

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `name` | String | string | showAddCategoryDialog() | ✅ |
| `description` | String | string | showAddCategoryDialog() | ❌ optional |
| `productCount` | int | integer | showAddCategoryDialog() | ✅ |
| `status` | String | string | showAddCategoryDialog() | ✅ |

> **RISIKO RENDAH** — collection sederhana, kemungkinan sudah ada.

---

### 10. `seller_balances` (sellerBalancesCollectionId) — bonus

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `sellerId` | String | string | createIfNotExists() | ✅ |
| `balance` | int | integer | createIfNotExists(), approveWithdrawal(), addEarnings() | ✅ |
| `totalEarned` | int | integer | createIfNotExists(), addEarnings() | ✅ |
| `totalWithdrawn` | int | integer | createIfNotExists(), approveWithdrawal() | ✅ |

> **RISIKO SEDANG** — jika collection ini belum dibuat.

---

### 11. `stock_locks` (stockLocksCollectionId) — bonus

| Field | Tipe Dart | Tipe Appwrite | Ditulis oleh | Wajib |
|---|---|---|---|---|
| `productId` | String | string | acquireLock() | ✅ |
| `sessionId` | String | string | acquireLock() | ✅ |
| `expiresAt` | String (datetime) | string | acquireLock() | ✅ |

> **RISIKO SEDANG** — jika collection ini belum dibuat. Tapi sifatnya sementara (TTL), error tidak terlalu kritis.

---

## RINGKASAN PRIORITAS MIGRASI

| Prioritas | Collection | Field | Alasan |
|---|---|---|---|
| 🔴 **P1** | `products` | `moderationStatus`, `moderationNote`, `moderatedBy`, `moderatedAt` | **Error sudah terjadi** — seller tidak bisa tambah produk |
| 🟡 **P2** | `users` | `storeName`, `storeAddress`, `city`, `province` | Seller tidak bisa update profil |
| 🟡 **P2** | `notifications` | semua field | Notifikasi tidak bisa dikirim |
| 🟡 **P2** | `reviews` | semua field | Review tidak bisa dibuat |
| 🟡 **P2** | `withdrawals` | semua field, terutama `processed_at` (snake_case) | Withdrawal tidak bisa diproses |
| 🟡 **P2** | `seller_balances` | semua field | Saldo seller tidak tercatat |
| 🟢 **P3** | `categories` | `productCount`, `status` | Admin tidak bisa tambah kategori |
| 🟢 **P3** | `stock_locks` | semua field | Lock stok tidak berfungsi (fallback) |
| ⚪ **P4** | `orders` | `phone`, `shippingAddress`, `notes`, dll | Order sudah mungkin jalan, periksa saja |
| ⚪ **P4** | `order_items` | `platformFee`, `sellerAmount`, `imageUrl`, `color`, `size` | Order sudah mungkin jalan, periksa saja |
| ⚪ **P4** | `transaksi` | — | Read-only, tidak perlu migrasi |