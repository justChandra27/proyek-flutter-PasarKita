Implementasikan Tahap 6 — Admin Dashboard Global Analytics.

Tujuan:

Memberikan dashboard statistik keseluruhan marketplace untuk admin.

Lakukan audit terlebih dahulu sebelum mengubah kode.

==================================================
BAGIAN A — Ringkasan Marketplace
================================

Tampilkan card statistik:

1. Total Customer
2. Total Seller
3. Total Produk
4. Total Order
5. Order Completed
6. Total Revenue Marketplace

Definisi:

Total Revenue Marketplace =
SUM seluruh order dengan status completed.

==================================================
BAGIAN B — Statistik Status Order
=================================

Hitung jumlah order:

pending
processing
shipped
completed
cancelled

Tampilkan dalam section dashboard admin.

==================================================
BAGIAN C — Top Seller
=====================

Tampilkan 5 seller terbaik berdasarkan:

total revenue DESC

Tampilkan:

* nama seller
* total pendapatan
* jumlah order completed

==================================================
BAGIAN D — Produk Terlaris Marketplace
======================================

Tampilkan 5 produk terlaris.

Urutkan berdasarkan:

quantity terjual DESC

Tampilkan:

* nama produk
* jumlah terjual

==================================================
BAGIAN E — Service Layer
========================

Buat service terpisah:

AdminAnalyticsService

Pisahkan seluruh query analytics dari UI.

Jangan menaruh query Appwrite di widget.

==================================================
BAGIAN F — Empty State
======================

Jika belum ada data marketplace:

Tampilkan:

"Belum ada aktivitas marketplace."

==================================================
OUTPUT YANG DIINGINKAN
======================

1. File yang diubah.
2. Struktur AdminAnalyticsService.
3. Query yang digunakan.
4. Cuplikan kode utama.
5. Hasil flutter analyze.
6. Risiko performa yang masih tersisa.

Fokus hanya pada admin dashboard.

Jangan mengubah checkout, cart, customer workflow, seller workflow, authentication, maupun Appwrite configuration.
