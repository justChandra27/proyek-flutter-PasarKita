# Withdrawal Rejection Reason Fix Report

## Files Modified

| File | Change |
|---|---|
| `lib/presentation/seller/withdrawal/withdrawal_page.dart` (line 313) | Appended `adminNote` to `ListTile` subtitle when `status == 'rejected'` and `adminNote.isNotEmpty` |

## Before

```
subtitle: Text(
  '${item.bankName} - ${item.bankAccount}\n${_statusLabel(item.status)}',
),
```

Seller saw:
```
BCA - 123456
Ditolak
```

## After

```
subtitle: Text(
  '${item.bankName} - ${item.bankAccount}\n${_statusLabel(item.status)}'
  '${item.status == 'rejected' && item.adminNote.isNotEmpty ? '\nAlasan Penolakan: ${item.adminNote}' : ''}',
),
```

Seller now sees (when rejected with reason):
```
BCA - 123456
Ditolak
Alasan Penolakan: Saldo tidak mencukupi minimum penarikan
```

Approved/pending items are unchanged. Items with empty `adminNote` are unchanged.

## Manual Testing Checklist

- [ ] Withdrawal with `status: 'rejected'` and non-empty `adminNote` → shows "Alasan Penolakan: ..." in subtitle
- [ ] Withdrawal with `status: 'rejected'` and empty `adminNote` → no extra line (same as before)
- [ ] Withdrawal with `status: 'approved'` → no extra line (same as before)
- [ ] Withdrawal with `status: 'pending'` → no extra line (same as before)
- [ ] `flutter analyze` — 0 errors, 0 new issues
