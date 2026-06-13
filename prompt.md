MODE: AUDIT — COMPLETE

# ADMIN PRODUCTS — Deep Audit

## Kondisi Saat Ini
- **File**: `lib/presentation/admin/products/form_produk_web.dart` (393 lines)
- **Type**: `StatelessWidget` — tidak ada state, semua data statis
- **Layout**: Header + search + action bar + GridView 4 kolom (8 card) + pagination statis
- **Data**: 8 produk hardcoded dengan Unsplash URL gambar

## Data Hardcoded
| Item | Detail |
|------|--------|
| 8 produk | Semua nama, kategori, harga, stok, URL gambar hardcoded |
| "Menampilkan 128 Produk" | Angka 128 hardcoded |
| Pagination | Tombol halaman 1-12 statis (no-op) |
| Tombol "Tambah Produk" | `onPressed: () {}` — no-op |
| Tombol "Filter" | `onPressed: () {}` — no-op |
| Avatar header | `"https://i.pravatar.cc/150"` — hardcoded |
| Search field | `TextField` tanpa controller/onChanged — tidak fungsional |
| `ProductCard` class | Widget reusable dengan props: image, category, title, price, stock, badge |

## Service yang Bisa Dipakai
| Service | Method | Keterangan |
|---------|--------|------------|
| `ProductServiceAppwrite` | `getAllProducts()` → `List<ProductModel>` | Ambil semua produk aktif |
| `ProductServiceAppwrite` | `getProductsPage({cursor, limit})` → `PaginatedResponse` | Paginated products |
| `ProductServiceAppwrite` | `getProductById(id)` → `ProductModel?` | Detail produk |
| `ProductServiceAppwrite` | `getSellerProducts(sellerId)` → list | Produk per seller |
| `StorageServiceAppwrite` | `getImageUrl(fileId)` | URL gambar dari file ID |

## Model yang Bisa Dipakai
| Model | Field Kunci |
|-------|-------------|
| `ProductModel` | `id`, `sellerId`, `name`, `description`, `category`, `price` (double), `stock` (int), `imageUrl`, `active`, `weight`, `minPurchase`, `soldCount`, `colors`, `sizes` |

## Collection yang Digunakan
- **Collection**: `products` (Appwrite)
- **Collection ID**: `AppwriteConfig.productsCollectionId` = `'products'`

## Perubahan Minimum Agar Menjadi Real Data
1. Ubah `StatelessWidget` → `StatefulWidget` dengan state `List<ProductModel>`
2. Panggil `ProductServiceAppwrite().getAllProducts()` di `initState()`
3. Ganti GridView hardcoded → `product.map()` dengan `ProductCard` (gunakan `ProductModel` sebagai data source)
4. Ubah `ProductCard` untuk menerima `ProductModel` bukan 5 string terpisah, atau buat adapter
5. Setel "Menampilkan X Produk" dari `products.length`
6. Terapkan `StorageServiceAppwrite().getImageUrl()` untuk gambar (jika `imageUrl` adalah file ID)
7. Tambah pagination logic (bisa dari `PaginatedResponse`)
8. Hubungkan search field ke filter list produk (client-side atau server-side)
9. Tombol "Tambah Produk" → navigasi ke `ProductFormPage` (reuse dari seller)
10. Nama admin dari `AuthServiceAppwrite.getCurrentUserData()` ganti hardcoded "Admin Utama"

## Estimasi Kompleksitas
- **Rendah-Sedang** (3-4 jam)
- Semua service sudah ada. Tinggal connect UI ke service.

---

# ADMIN ORDERS — Deep Audit

## Kondisi Saat Ini
- **File**: `lib/presentation/admin/orders/form_pesanan_web.dart` (444 lines)
- **Type**: `StatelessWidget` — semua data statis
- **Layout**: Header + search + title + action bar + 4 stat card + DataTable (5 rows) + pagination statis

## Data Hardcoded
| Item | Detail |
|------|--------|
| 5 pesanan | Order ID, pelanggan, tanggal, amount, status — semua hardcoded |
| Stat card values | "1,284", "43", "156", "1,085" — hardcoded |
| "Menampilkan 1–5 dari 1,284 pesanan" | Angka hardcoded |
| Pagination | Tombol < 1 2 3 > statis (no-op) |
| Tombol "Filter" & "Ekspor CSV" | `onPressed: () {}` — no-op |
| Aksi (more_vert) | Icon saja, tidak ada menu |
| Avatar + "Admin Utama / Administrator" | Hardcoded |
| Search field | `TextField` tanpa controller/onChanged — tidak fungsional |

## Service yang Bisa Dipakai
| Service | Method | Keterangan |
|---------|--------|------------|
| `OrderServiceAppwrite` | `getOrders()` → `List<OrderModel>` | Semua orders |
| `OrderServiceAppwrite` | `getOrderById(id)` → `OrderModel?` | Detail order |
| `OrderServiceAppwrite` | `getOrderItems(orderId)` → `List<OrderItemModel>` | Item dalam order |
| `AdminAnalyticsService` | `getAnalytics()` → `AdminAnalytics` | Punya `orderStatusCounts`, `totalOrders`, `completedOrders` |
| `AuthServiceAppwrite` | `getCurrentUserData()` | Untuk nama admin |

## Model yang Bisa Dipakai
| Model | Field Kunci |
|-------|-------------|
| `OrderModel` | `id`, `orderCode`, `customerId`, `customerName`, `customerEmail`, `totalAmount`, `serviceFee`, `status`, `paymentMethod`, `paymentStatus`, `address`, `notes`, `createdAt`, `updatedAt` |
| `OrderItemModel` | `id`, `orderId`, `productId`, `productName`, `sellerId`, `price`, `quantity`, `subtotal`, `platformFee`, `sellerAmount`, `imageUrl`, `color`, `size` |

## Collection yang Digunakan
- **Collections**: `orders`, `order_items` (Appwrite)
- **Collection ID**: `AppwriteConfig.ordersCollectionId` = `'orders'`, `AppwriteConfig.orderItemsCollectionId` = `'order_items'`

## Perubahan Minimum Agar Menjadi Real Data
1. Ubah `StatelessWidget` → `StatefulWidget` dengan state `List<OrderModel>`
2. Panggil `OrderServiceAppwrite().getOrders()` di `initState()`
3. Hitung stat card dari `orders.length` dan group `order.status` (gunakan `AdminAnalyticsService.getAnalytics()` untuk reuse atau hitung manual)
4. Ganti DataTable hardcoded → `orders.map()` dengan `_orderRow()`
5. Ubah `_orderRow()` untuk menerima `OrderModel`
6. Format `totalAmount` dan `createdAt` dari model (bukan string hardcoded)
7. Setel "Menampilkan X–Y dari Z pesanan" dinamis dengan pagination
8. Hubungkan search field ke filter `orders` by `orderCode`/`customerName`
9. Tombol "Filter" → dialog filter (status, date range) atau minimal filter dropdown
10. Aksi (more_vert) → menu: Lihat Detail (tampilkan items dari `getOrderItems()`)
11. Nama admin dari `AuthServiceAppwrite.getCurrentUserData()`
12. Hapus `_pageButton` static atau jadikan dinamis dengan pagination state

## Estimasi Kompleksitas
- **Rendah-Sedang** (3-4 jam)
- Sama dengan produk — service sudah ada, tinggal connect.

---

# ADMIN REPORTS — Deep Audit

## Kondisi Saat Ini
- **File**: `lib/presentation/admin/reports/form_laporan_web.dart` (510 lines)
- **Type**: `StatelessWidget` — semua data statis
- **Layout**: Header + 4 stat card + Grafik Pendapatan (bar chart) + Produk Terlaris + Pertumbuhan Pengguna + Proporsi Kategori

## Data Hardcoded
| Item | Detail |
|------|--------|
| Total Penjualan "Rp 128.4M" | Hardcoded +12.5% |
| Pesanan Selesai "1,240" | Hardcoded +4.2% |
| Pengguna Baru "482" | Hardcoded "Stabil" |
| Rata Transaksi "Rp 103rb" | Hardcoded -1.8% |
| Grafik Pendapatan | 7 bar height hardcoded (90, 160, 120, 210, 175, 225, 145) |
| Produk Terlaris | Nike Air Zoom Rp 1.4M, Apple Watch S8 Rp 980jt, Sony WH-1000XM5 Rp 720jt |
| "Fashion • 242 terjual" | Hardcoded subtitle |
| Pertumbuhan Pengguna "+4,210" | Hardcoded |
| Proporsi Kategori "Elektronik 45% / Fashion 25% / Hobi & Lainnya 30%" | Hardcoded |
| Tombol "Lihat Semua Produk" | `onPressed: () {}` — no-op |
| Search "Cari laporan..." | `TextField` tanpa controller — tidak fungsional |
| Avatar + "Admin Utama / Administrator" | Hardcoded |

## Service yang Bisa Dipakai
| Service | Method | Data Tersedia |
|---------|--------|--------------|
| `AdminAnalyticsService` | `getAnalytics()` | `totalRevenue`, `totalOrders`, `completedOrders`, `totalCustomers`, `totalSellers`, `totalProducts`, `totalPlatformRevenue`, `orderStatusCounts`, `topSellers` (5), `topProducts` (5) |
| `ProductServiceAppwrite` | `getAllProducts()` | Untuk kategori — bisa group by `product.category` |
| `CategoryServiceAppwrite` | `getAllCategories()` | Daftar kategori + `productCount` |
| `OrderServiceAppwrite` | `getOrders()` | Bisa dihitung per bulan untuk tren |
| `AuthServiceAppwrite` | `getCurrentUserData()` | Nama admin |

## Model yang Bisa Dipakai
| Model | Field Kunci |
|-------|-------------|
| `AdminAnalytics` | `totalRevenue`, `totalOrders`, `completedOrders`, `orderStatusCounts`, `topSellers`, `topProducts`, `totalCustomers`, `totalSellers`, `totalProducts`, `totalPlatformRevenue` |
| `TopSeller` | `name`, `totalRevenue`, `completedOrdersCount` |
| `ProductSales` | `productName`, `totalSold` |
| `ProductModel` | `category` → untuk proporsi kategori |
| `CategoryModel` | `name`, `productCount` |

## Collection yang Digunakan
- **Collections**: `orders`, `users`, `products`, `order_items`, `categories` (Appwrite)

## Perubahan Minimum Agar Menjadi Real Data
1. Ubah `StatelessWidget` → `StatefulWidget` dengan state `AdminAnalytics?`
2. Panggil `AdminAnalyticsService().getAnalytics()` di `initState()`
3. Ganti 4 stat card dengan data dari `AdminAnalytics`:
   - Total Penjualan → `analytics.totalRevenue`
   - Pesanan Selesai → `analytics.completedOrders`
   - Pengguna Baru → Dari data users (analytics tidak punya monthly new users — perlu query tambahan)
   - Rata Transaksi → `analytics.totalRevenue / analytics.completedOrders` (jika > 0)
4. Grafik Pendapatan → **tantangan**: `AdminAnalyticsService` tidak menghitung per-hari/per-bulan. Dua opsi:
   - **Opsi A (low effort)**: Pakai `totalRevenue` bagi rata 7 hari (grafik rata) — tidak akurat
   - **Opsi B (medium)**: Tambah method `getMonthlyRevenue()` di `AdminAnalyticsService` yang group orders per bulan
5. Produk Terlaris → pakai `analytics.topProducts` (dari `AdminAnalyticsService` sudah ada 5 produk)
6. Pertumbuhan Pengguna → query `users` collection, hitung jumlah user per bulan (perlu method baru atau hitung dari `_fetchUsers()`)
7. Proporsi Kategori → pakai `ProductServiceAppwrite.getAllProducts()`, group by `product.category`, hitung persentase
8. Search field → filter data yang ditampilkan
9. Nama admin dari `AuthServiceAppwrite.getCurrentUserData()`

## Estimasi Kompleksitas
- **Sedang** (5-6 jam)
- 4 stat card + top products: mudah (data sudah dari `AdminAnalyticsService`)
- Grafik pendapatan per hari/bulan: **perlu data baru** — service belum menghitung tren time-series
- Pertumbuhan pengguna: perlu query tambahan
- Proporsi kategori: perlu query products + group by

---

# IMPLEMENTATION PLAN

## Step 1: Admin Products — Connect ke Appwrite
**File**: `lib/presentation/admin/products/form_produk_web.dart`
**Perubahan**:
- Ubah `StatelessWidget` → `StatefulWidget`
- Tambah state: `List<ProductModel> products`, `bool isLoading`
- `initState()` → `ProductServiceAppwrite().getAllProducts()`
- Render GridView dari `products.map()` menggunakan `ProductModel`
- Ubah `ProductCard` untuk menerima `ProductModel` (parameter `product`)
- Hitung "Menampilkan X Produk" dari `products.length`
- Loading state (CircularProgressIndicator)
- Empty state
- Nama admin dari `AuthServiceAppwrite.getCurrentUserData()`

**Risiko**: Rendah. Service, model, collection sudah ada. Hanya UI reconnect.

---

## Step 2: Admin Orders — Connect ke Appwrite
**File**: `lib/presentation/admin/orders/form_pesanan_web.dart`
**Perubahan**:
- Ubah `StatelessWidget` → `StatefulWidget`
- Tambah state: `List<OrderModel> orders`, `bool isLoading`, `String? error`
- `initState()` → `OrderServiceAppwrite().getOrders()` + `AdminAnalyticsService().getAnalytics()` (utk stat cards)
- Group orders by status untuk 4 stat card
- Render DataTable dari `orders.map()` menggunakan `OrderModel`
- Format `totalAmount` dengan `formatRupiah()` (reuse dari seller dashboard)
- Format `createdAt` dari ISO string ke "24 Okt 2023, 14:20"
- Pagination: implement `currentPage`, `perPage`, `totalPages`
- Search: connect `TextField.onChanged` ke filter (client-side filter by `orderCode`/`customerName`)
- Nama admin dari `AuthServiceAppwrite.getCurrentUserData()`
- Loading + error + empty state

**Risiko**: Rendah. Service, model, collection sudah ada.

---

## Step 3: Admin Reports — Connect ke Appwrite (Partial)
**File**: `lib/presentation/admin/reports/form_laporan_web.dart`
**Perubahan — Tahap 1 (low effort)**:
- Ubah `StatelessWidget` → `StatefulWidget`
- Panggil `AdminAnalyticsService().getAnalytics()` di `initState()`
- Ganti 4 stat card dengan data real:
  - Total Penjualan → `analytics.totalRevenue`
  - Pesanan Selesai → `analytics.completedOrders`
  - Pengguna Baru → hitung dari result `_fetchUsers()` (tambah method ke service atau query langsung)
  - Rata Transaksi → `totalRevenue ~/ completedOrders`
- Produk Terlaris → `analytics.topProducts` (ganti 3 hardcoded list item)
- Nama admin dari `AuthServiceAppwrite.getCurrentUserData()`

**Risiko**: Rendah. Data sudah tersedia di service.

---

## Step 4: Admin Reports — Grafik & Proporsi
**File**: `lib/presentation/admin/reports/form_laporan_web.dart` + `lib/core/services/admin_analytics_service.dart`
**Perubahan — Tahap 2**:
- Tambah method `getMonthlyRevenue()` di `AdminAnalyticsService`:
  - Query orders, group by bulan dari `createdAt`, sum `totalAmount`
- Tambah method `getNewUserGrowth()` di `AdminAnalyticsService`:
  - Query users, group by bulan dari `$createdAt`
- Di UI: render 7 bar dari 7 hari terakhir (atau 12 bar untuk 12 bulan)
- Proporsi Kategori: query `ProductServiceAppwrite.getAllProducts()`, group by `category`

**Risiko**: Sedang. Perlu tambah method di service. Service perlu di-test agar tidak rusak existing.

---

## Step 5: Cleanup — File Mati
**File**:
- `lib/presentation/admin/dashboard/pages/dashboard_page.dart` (commented out, 179 lines)
- `lib/presentation/admin/dashboard/admin_dashboard_page.dart` (commented out, 16 lines)
- `lib/presentation/admin/dashboard/widgets/statistics_grid.dart` (0 bytes)
- `lib/presentation/admin/dashboard/widgets/dashboard_header.dart` (0 bytes)
- `lib/presentation/admin/dashboard/widgets/dashboard_empty_state.dart` (0 bytes)
- `lib/presentation/admin/users/pages/users_page.dart` (0 bytes)
- `lib/presentation/admin/products/pages/products_page.dart` (0 bytes)
- `lib/presentation/admin/orders/pages/orders_page.dart` (0 bytes)
- `lib/presentation/admin/transactions/pages/transactions_page.dart` (0 bytes)
- `lib/presentation/admin/categories/pages/categories_page.dart` (0 bytes)
- `lib/presentation/admin/promo/pages/promos_page.dart` (0 bytes)
- `lib/presentation/admin/reports/pages/reports_page.dart` (0 bytes)
- `lib/presentation/admin/widgets/admin_layout.dart` (orphan, not imported)
- `lib/presentation/admin/widgets/admin_header.dart` (duplicate of stat_card.dart)

**Perubahan**: Tanya user sebelum hapus. File 0 bytes aman dihapus. File commented out dan orphan perlu konfirmasi.

**Risiko**: Sangat Rendah (file tidak digunakan).

---

# SUMMARY

| Step | File | Perubahan | Risiko | Estimasi |
|------|------|-----------|--------|----------|
| 1 | `form_produk_web.dart` | StatelessWidget → StatefulWidget, connect ProductServiceAppwrite | Rendah | 3-4 jam |
| 2 | `form_pesanan_web.dart` | StatelessWidget → StatefulWidget, connect OrderServiceAppwrite | Rendah | 3-4 jam |
| 3 | `form_laporan_web.dart` | StatelessWidget → StatefulWidget, connect AdminAnalyticsService (4 stat card + top products) | Rendah | 2-3 jam |
| 4 | `form_laporan_web.dart` + `admin_analytics_service.dart` | Tambah method monthly revenue + user growth + kategori proporsi | Sedang | 3-4 jam |
| 5 | 14 file mati | Hapus/arsip (tanya user dulu) | Sangat Rendah | 15 menit |

**Total estimasi**: 12-15 jam (3 fitur, 5 step)
