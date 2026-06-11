# Gap Analysis: Seller Orders Web vs Mobile

## Tabel Perbandingan

| # | Fitur | Web | Mobile | Gap |
|---|-------|:---:|:------:|:---:|
| 1 | **Search** | ✅ `_searchController`, filter by orderCode & customerName | ❌ Tidak ada | Mobile tidak punya search |
| 2 | **Tab Status** | ✅ 5 tab (Semua/Pending/Shipped/Completed/Cancelled) dengan state | ⚠️ 4 tab hardcoded semua `false`, tidak ada `setState` | Tab mobile statis, tidak menyaring data |
| 3 | **Sorting** | ✅ PopupMenu: Terbaru/Terlama/Total Tertinggi/Terendah | ❌ Tidak ada | Mobile tidak punya sorting |
| 4 | **Advanced Filter** | ✅ Dialog: multi-status, date range, min-max total | ❌ Tidak ada | Mobile tidak punya filter |
| 5 | **Detail Pesanan** | ✅ `_showDetailDialog` (order info + items) | ❌ Tidak ada | Mobile tidak punya detail view |
| 6 | **Update Status** | ✅ `_StatusButton` + PopupMenu + `_updateOrderStatus` + `_loadOrders` refresh | ✅ `_StatusActions` + `ElevatedButton` + `updateOrderStatus` + SnackBar | ✅ Setara |
| 7 | **Hubungi Pembeli** | ✅ `_showContactDialog` (WhatsApp/Telepon) | ❌ Tidak ada | Mobile tidak punya contact |
| 8 | **Export CSV** | ✅ `_exportCsv()` via `dart:html` | ❌ Tidak ada | Mobile tidak punya export (wajar — file-based, not CSV for mobile) |
| 9 | **Pagination** | ✅ `_pagedOrders`, dynamic footer, page buttons | ❌ Tidak ada | Mobile render semua order dalam satu ListView |

## Fitur yang Belum Ada di Mobile (6 fitur)

| Fitur | Kompleksitas | Risiko | Prioritas |
|-------|:-----------:|:------:|:--------:|
| Search | Rendah | Rendah | **P1** |
| Tab Status (fungsional) | Rendah | Rendah | **P1** |
| Sorting | Rendah | Rendah | **P2** |
| Detail Pesanan | Rendah | Rendah | **P2** |
| Hubungi Pembeli | Rendah | Rendah | **P2** |
| Advanced Filter | Sedang | Rendah | **P3** |
| Pagination | Sedang | Rendah | **P3** |
| Export CSV | — | — | Tidak relevan (CSV khas web) |

## Estimasi Effort

| Fitur | Jam | Keterangan |
|-------|:---:|------------|
| Search + Tab + Sort | 1–2 | State + getter sederhana, reuse pola web |
| Detail Pesanan + Hubungi | 1–2 | Dialog sederhana |
| Advanced Filter | 2–3 | Dialog multi-field, date picker |
| Pagination | 2–3 | State page, getter, footer widget |

**Total: ~6–10 jam**

## Rekomendasi Urutan Pengerjaan

1. **Search + Tab Status + Sorting** — state minimal, dampak besar
2. **Detail Pesanan + Hubungi Pembeli** — reuse `_OrderCard` yang sudah ada
3. **Advanced Filter** — reuse pola web, butuh dialog
4. **Pagination** — butuh restrukturisasi dari `FutureBuilder` ke stateful list

## Catatan

- **Update Status** sudah setara di mobile (`_StatusActions`) — tidak perlu diubah.
- **Export CSV** tidak relevan untuk mobile — skip.
- Semua fitur bisa pakai service/models yang sudah ada — tidak perlu backend change.
- Mobile pakai `FutureBuilder` (tidak seperti web yang pakai `setState` manual) — perlu perhatikan transisi saat tambah pagination.
