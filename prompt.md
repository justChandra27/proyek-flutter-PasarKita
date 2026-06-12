MODE: PLAN — SELESAI

==================================================
VISUAL AUDIT — HOME CUSTOMER
==================================================

## 1. Banner (Hanya Mobile)
| Aspek | Saat Ini |
|---|---|
| Container | `height: 190`, `width: double.infinity`, bg `#0F56B3`, radius `24`, padding `20` |
| Layout | Row: left Column (text) + right CircleAvatar (icon) |
| Teks | "Premium\nFashion" (white, 42px, bold) + "Discover your style" (white70, 16px) |
| Ikon | CircleAvatar(radius:34, bg white24, icon shopping_bag) — statis, tidak ada gambar nyata |
| Web | **TIDAK ADA BANNER SAMA SEKALI** |

## 2. Kategori
| Aspek | Web | Mobile |
|---|---|---|
| Container | horizontal ListView | horizontal ListView |
| Tinggi | tidak di-set | `height: 42` |
| Chip aktif | bg `#DBEAFE`, text `#2563EB`, border `#CBD5E1`, radius 30 | bg `#2563EB`, text white, border `black12`, radius 25, bold |
| Chip non-aktif | bg white, text `black87` | bg white, text `black87` |
| Padding chip | horizontal 18, vertical 10 | horizontal 20 |
| Filter stok | `GestureDetector` biru, tap cycle | `GestureDetector` biru, tap → BottomSheet |
| Visual | Text-only, tidak ada ikon/gambar kategori, tidak ada animasi |

## 3. ProductCard (Saat Ini)
| Aspek | Web | Mobile |
|---|---|---|
| Border radius | 16 (default) | 20 |
| Border | none | `Colors.black12` 1px |
| Shadow/Elevation | **TIDAK ADA** | **TIDAK ADA** |
| Badge | "Stok Habis" red, radius 8 | "Stok Habis" red, radius 6 |
| Nama produk | bold, fontSize 24 (default) | bold, fontSize 18 |
| Harga | `#2563EB`, bold | `#2563EB`, bold, 16px |
| Sold count | **TIDAK DITAMPILKAN** (soldCount ada di model) | **TIDAK DITAMPILKAN** |
| Wishlist | **TIDAK ADA** | **TIDAK ADA** |
| Diskon | **TIDAK ADA** | **TIDAK ADA** |
| Grid | 4 kolom tanpa responsive breakpoint | 2 kolom, aspectRatio 0.62 |

## 4. Loading State
- Web: `CircularProgressIndicator()` biasa, tanpa skeleton
- Mobile: `CircularProgressIndicator()` di SizedBox(height:200), tanpa skeleton
- Load more: spinner kecil (24x24, strokeWidth:2)

## 5. Empty State
- Web: teks "Tidak ada produk yang ditemukan" (plain, default style)
- Mobile: teks sama di SizedBox(height:200)
- Tidak ada ilustrasi, tidak ada CTA, tidak ada saran pencarian

## 6. Error State
- Web: teks "Gagal memuat produk" (red style)
- Mobile: teks sama di SizedBox(height:200)
- Tidak ada tombol retry, tidak ada ilustrasi

## 7. Produk Populer (soldCount)
- `ProductModel.soldCount` tersedia (diisi dari Appwrite)
- **Tidak pernah digunakan** di dashboard — hanya dipakai di halaman detail produk
- Tidak ada section "Produk Populer" sama sekali

## 8. Produk Terbaru
- Ada header "Produk Terbaru" (plain text)
- Web: 4 kolom GridView
- Mobile: 2 kolom GridView
- Tidak ada subtitle/produk count, grid view icon dekoratif saja

==================================================
FILE TERDAMPAK
==================================================

| # | File | Perubahan |
|---|---|---|
| 1 | `lib/presentation/customer/dashboard/dashboard_customer_web.dart` | Banner baru, skeleton, empty/error state, popular products, ProductCard redesign params |
| 2 | `lib/presentation/customer/dashboard/dashboard_customer_mobile.dart` | Banner redesign, skeleton, empty/error state, popular products, ProductCard redesign params |
| 3 | `lib/presentation/customer/widgets/product_card.dart` | Tambah shadow, sold count, wishlist, diskon, parameter baru |
| 4 | `lib/presentation/customer/widgets/category_chip.dart` | Optional: tambah parameter icon/widget dukung ikon kategori |
| 5 | `lib/providers/product_filter_provider.dart` | Tambah `popularProducts` getter, `loadPopular()` method |
| 6 | `lib/core/services/product_service_appwrite.dart` | Optional: method `getPopularProducts()` |
| 7 | `lib/core/widgets/loading_widget.dart` | **Isi file** — shimmer/skeleton widget |
| 8 | `lib/core/widgets/empty_state_widget.dart` | **File baru** — empty state reusable |
| 9 | `lib/core/widgets/error_state_widget.dart` | **File baru** — error state reusable |
| 10 | `lib/presentation/customer/widgets/promo_banner_carousel.dart` | **File baru** — carousel banner |
| 11 | `lib/presentation/customer/widgets/popular_products_row.dart` | **File baru** — horizontal popular products |
| 12 | `lib/core/constants/app_colors.dart` | **Isi file** — palette terpusat |

==================================================
WIDGET YANG BISA DIREUSE
==================================================

| Widget | File | Untuk |
|---|---|---|
| `ProductCard` | `widgets/product_card.dart` | Base card — tambah shadow, sold count, wishlist via parameter |
| `CategoryChip` | `widgets/category_chip.dart` | Kategori — bisa ditambah icon parameter |
| `StarRatingRow` | `widgets/star_rating_row.dart` | Rating — reuse tanpa perubahan |
| `formatRupiah()` | `core/utils/format_rupiah.dart` | Format harga — reuse |
| `ProductReviewList` | `widgets/product_review_list.dart` | Nanti untuk detail produk, tidak relevan untuk dashboard |
| `ProductModel.soldCount` | `data/models/product_model.dart` | Field sudah ada, tinggal dipakai |

==================================================
WIDGET BARU YANG DIPERLUKAN
==================================================

| # | Widget | Priority | Keterangan |
|---|---|---|---|
| 1 | `PromoBannerCarousel` | **HIGH** | Slider banner dengan auto-scroll, dot indicator, multiple slides. Web & mobile. |
| 2 | `ShimmerProductCard` | **HIGH** | Skeleton loader berbentuk card (image placeholder + text lines) |
| 3 | `PopularProductsRow` | **HIGH** | Horizontal scroll row produk berdasarkan soldCount, header "Produk Populer" |
| 4 | `EmptyStateWidget` | **MEDIUM** | Ilustrasi + pesan + optional CTA "Coba kata kunci lain" |
| 5 | `ErrorStateWidget` | **MEDIUM** | Ilustrasi + pesan + tombol "Coba Lagi" (VoidCallback retry) |

**Opsional (tahap berikutnya):**
| 6 | `WishlistButton` | LOW | Heart icon overlay di gambar produk |
| 7 | `DiscountBadge` | LOW | Pill diskon merah (misal -20%) |
| 8 | `SoldCountText` | LOW | Teks "Terjual 123" kecil |
| 9 | `SearchTextField` | LOW | Search field dengan clear button |
| 10 | `StockFilterBottomSheet` | LOW | Bottom sheet filter stok (shared web/mobile) |

==================================================
RENCANA IMPLEMENTASI — 5 TAHAP
==================================================

## TAHAP 1: Infrastructure & Skeleton
**Goal:** Base infrastructure untuk redesign tanpa mengubah visual existing.
- [ ] Isi `app_colors.dart` dengan warna palette yang dipakai (primary #2563EB, bg #F8FAFC, dll.)
- [ ] Buat `ShimmerProductCard` — skeleton card dengan ukuran identik ProductCard
- [ ] Buat `EmptyStateWidget` dan `ErrorStateWidget`
- [ ] Ganti loading/empty/error state di kedua dashboard
- **File:** `app_colors.dart`, `loading_widget.dart`, `empty_state_widget.dart`, `error_state_widget.dart`, `dashboard_customer_web.dart`, `dashboard_customer_mobile.dart`

## TAHAP 2: Promo Banner + Kategori
**Goal:** Banner carousel dan kategori redesain.
- [ ] Buat `PromoBannerCarousel` — pageview + dot indicator + auto-scroll timer
- [ ] Web dashboard: tambah banner section (currently missing!)
- [ ] Mobile dashboard: ganti _promoBanner statis dengan carousel
- [ ] Optional: tambah parameter `icon`/`leading` di CategoryChip
- **File:** `promo_banner_carousel.dart`, `dashboard_customer_web.dart`, `dashboard_customer_mobile.dart`, `category_chip.dart`

## TAHAP 3: ProductCard Redesign
**Goal:** Modernisasi card tanpa breaking parameter existing.
- [ ] Tambah `boxShadow`/`elevation` parameter di ProductCard (default null = no shadow)
- [ ] Tambah `showSoldCount` + `soldCount` parameter
- [ ] Tambah `wishlistBuilder` — optional widget overlay (misal heart icon)
- [ ] Tambah `discountBadgeBuilder` — optional widget overlay diskon
- [ ] Web: shadow aktif, mobile: shadow aktif
- **File:** `product_card.dart`, kedua dashboard (parameter baru)

## TAHAP 4: Produk Populer
**Goal:** Section "Produk Populer" berdasarkan soldCount.
- [ ] Tambah `popularProducts` getter di `ProductFilterProvider` (sort by soldCount descending, limit 10)
- [ ] Buat `PopularProductsRow` — horizontal ListView item kecil (mirip ProductCard tapi compact)
- [ ] Integrasi ke kedua dashboard (antara banner dan kategori, atau setelah kategori)
- **File:** `product_filter_provider.dart`, `popular_products_row.dart`, kedua dashboard

## TAHAP 5: Polish & Responsive
**Goal:** Final touches.
- [ ] Responsive grid web: wrap grid dalam `LayoutBuilder`, ubah crossAxisCount berdasarkan width
- [ ] Animated kategori: animate scroll ke kategori yang dipilih
- [ ] Optional: wishlist, diskon badge, sold count
- [ ] Deploy shimmer saat load more
- **File:** kedua dashboard, `product_card.dart`

==================================================
RISIKO
==================================================

| Risiko | Dampak | Mitigasi |
|---|---|---|
| **ProductCard shadow berubah layout** | Tinggi card bertambah → grid tidak rapi | Pakai `Container` dengan `BoxDecoration(boxShadow: ...)`, jangan `ClipRRect` yang memotong shadow. Test aspectRatio grid. |
| **Banner carousel height tidak konsisten** | Web vs mobile beda ukuran | Parameter `bannerHeight` di `PromoBannerCarousel`, default 190 (mobile) / 220 (web) |
| **Shimmer ukuran tidak cocok** | Skeleton tidak align dengan card real | `ShimmerProductCard` harus punya parameter `borderRadius`, `aspectRatio` yang sinkron dengan ProductCard |
| **soldCount = 0 untuk semua produk** | PopularProductsRow kosong | Fallback: tampilkan produk terbaru jika soldCount semua 0. Buat `ProductFilterProvider.priorityProducts` getter. |
| **Provider bertambah berat** | Load semua review stats + popular products → lambat | Batasi popular products query dengan `limit: 10`. Gunakan `loadPopular()` terpisah dari `loadProducts()`. |
| **Web responsive grid** | Layout breakpoint tidak akurat | Pakai `LayoutBuilder` + `breakpoints` (480: 2 cols, 768: 3 cols, 1024: 4 cols, 1440: 5 cols) |
| **const constructor hilang** | Performance | Pastikan semua widget baru punya `const constructor` |
| **Test tidak ada** | Regression tidak terdeteksi | Verifikasi manual: scroll, filter, add to cart, detail, banner auto-scroll |

==================================================
PRIORITAS IMPLEMENTASI
==================================================

Rekomendasi urutan pengerjaan (impact ÷ effort):

1. **Tahap 1** (Infrastructure) — effort rendah, impact tinggi (skeleton + empty/error state)
2. **Tahap 2** (Banner + Kategori) — effort sedang, impact tinggi (visual paling terlihat)
3. **Tahap 3** (ProductCard) — effort rendah, impact tinggi (shadow + sold count)
4. **Tahap 4** (Populer) — effort sedang, impact sedang (section baru)
5. **Tahap 5** (Polish) — effort rendah, impact rendah (responsive, animasi)

**Rekomendasi:** Kerjakan berurutan (Tahap 1 → 2 → 3 → 4 → 5). Setiap tahap independent dan bisa di-commit sendiri-sendiri.
