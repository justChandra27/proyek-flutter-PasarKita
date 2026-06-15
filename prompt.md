# Seller Orders Filter Fix Report

## Root Cause

### Bug 1 (CRITICAL): Search `return true` bypasses advanced filters

Pada `_filteredOrders` getter di kedua file (web + mobile), blok search menggunakan `return true` saat match, yang menyebabkan semua filter setelahnya (status/date/price) tidak pernah dieksekusi:

```dart
// BEFORE — BUG: return true langsung skip filter-status, date, price
if (_searchQuery.isNotEmpty) {
  final q = _searchQuery.toLowerCase();
  if (order.orderCode.toLowerCase().contains(q)) return true;
  if (order.customerName.toLowerCase().contains(q)) return true;
  final items = entry['items'] as List<OrderItemModel>;
  if (items.any((i) => i.productName.toLowerCase().contains(q))) return true;
  return false;  // hanya tercapai jika search TIDAK match
}
```

### Bug 2 (HIGH): `_activeTab` dan `_filterStatuses` konflik

Tab filter (line 145) dan advanced status filter (line 158) berjalan sequential (AND). Jika tab = `'pending'` dan advanced filter = `{'shipped'}`, tab mengecualikan semua non-pending, lalu advanced mengecualikan pending (karena `'pending'` tidak ada di `{'shipped'}`). Hasil: 0 pesanan.

---

## Files Modified

| File | Lines Changed | Bug Fixed |
|------|--------------|-----------|
| `lib/presentation/seller/orders/form_pesanan_seller_web.dart` | 141-198 | Bug 1 + Bug 2 |
| `lib/presentation/seller/orders/form_pesanan_seller_mobile.dart` | 64-101 | Bug 1 |

---

## Logic Before / After

### Bug 1 — Web & Mobile

| Aspek | Before | After |
|-------|--------|-------|
| Search return | `return true` saat match → skip filter lain | `matchesSearch` boolean → `return false` jika tidak match (AND) |
| Aliran filter | Search tabung dulu -> skip -> filter lain tidak jalan | Search adalah salah satu AND condition |
| Contoh: search "abc" + status filter "shipped" + price > 100000 | Hanya filter search berfungsi | Semua filter diterapkan dengan AND |

### Bug 2 — Web only

| Aspek | Before | After |
|-------|--------|-------|
| Prioritas | Tab dulu → advanced belakang → konflik | Jika `_filterStatuses` tidak kosong, **tab diabaikan** (override) |
| Tab + advanced filter beda status | Hasil 0 (conflict) | Advanced filter menang, tab ignored |
| Tab + advanced filter kosong | Tab berfungsi normal | Tab berfungsi normal (sama) |

### Logic After — Web

```dart
List<Map<String, dynamic>> get _filteredOrders {
  var result = _allOrders.where((entry) {
    final order = entry['order'] as OrderModel;
    final items = entry['items'] as List<OrderItemModel>;

    // STATUS: advanced filter override tab jika ada
    if (_filterStatuses.isNotEmpty) {
      if (!_filterStatuses.contains(order.status.toLowerCase())) return false;
    } else {
      if (_activeTab != 'semua') {
        if (order.status.toLowerCase() != _activeTab) return false;
      }
    }

    // SEARCH: AND dengan filter lainnya (tidak short-circuit)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          order.orderCode.toLowerCase().contains(q) ||
          order.customerName.toLowerCase().contains(q) ||
          items.any((i) => i.productName.toLowerCase().contains(q));
      if (!matchesSearch) return false;
    }

    // DATE FILTER (AND)
    if (_filterStartDate != null || _filterEndDate != null) { ... }

    // PRICE FILTER (AND)
    if (_filterMinTotal != null || _filterMaxTotal != null) { ... }

    return true;  // ALL filters passed
  }).toList();
  // ... sorting ...
}
```

---

## Mobile Impact

Mobile memiliki **Bug 1 yang SAMA** (search `return true`). Tidak memiliki Bug 2 karena tidak ada advanced filter dialog.

Fix diterapkan di `form_pesanan_seller_mobile.dart` dengan pola identik — search menggunakan `matchesSearch` boolean + `return false` untuk AND composition.

---

## Risks

| Risk | Assessment |
|------|------------|
| Regresi search | ✅ Rendah — logika search match identik, hanya cara return diubah |
| Regresi tab filter | ✅ Rendah — tab behavior sama saat advanced filter kosong |
| Regresi advanced filter | ✅ Rendah — filter status/date/price hanya di-skip jika search `return true` (yang sekarang tidak terjadi) |
| `flutter analyze` | ✅ Pass — 0 errors |

---

## Manual Testing Checklist

### Skenario Web

- [ ] **Search saja:** Ketik nama produk/pembeli/kode → hasil hanya yang cocok
- [ ] **Tab saja:** Klik tab "Perlu Diproses" → hanya pending muncul
- [ ] **Tab + search:** Tab "Pending" + search nama → hanya pending yang cocok search
- [ ] **Advanced status saja:** Buka filter, centang "Shipped" + "Completed" → hanya shipped+completed
- [ ] **Advanced status + tab:** Centang "Shipped" di advanced filter + tab "Pending" → advanced filter menang (shipped muncul, bukan pending)
- [ ] **Search + advanced status:** Search "abc" + centang "Shipped" → hanya shipped yang cocok "abc"
- [ ] **Search + status + date:** Search + shipped + date range → AND semua
- [ ] **Search + status + date + price:** Search + shipped + date + price range → AND semua
- [ ] **Reset filter:** Klik "Reset" di dialog filter → semua filter hilang, semua pesanan muncul
- [ ] **Ekspor rekap:** Data yang diekspor sesuai filter aktif

### Skenario Mobile

- [ ] **Search saja:** Ketik di search → hasil hanya yang cocok
- [ ] **Tab saja:** Tab berfungsi
- [ ] **Search + tab:** Kombinasi AND
