# Withdrawal Notification Implementation Report

## Existing Notification Pattern

`NotificationServiceAppwrite.createNotification()` requires: `userId`, `title`, `message`, `type`, `orderId`. Used by `OrderServiceAppwrite.updateOrderStatus()` with `type: 'status_update'` and a real `orderId`. Withdrawal has no order — passes `orderId: ''` (valid since `NotificationModel.orderId` defaults to `''`).

New type value: `'withdrawal'` (safe — `NotificationModel.type` is a free String).

## Files Modified

| File | Change |
|---|---|
| `lib/core/services/withdrawal_service_appwrite.dart` | Added `import 'notification_service_appwrite.dart'`; added `_formatAmount()` helper; added `createNotification()` call in `approveWithdrawal()` and `rejectWithdrawal()`; extracted `sellerId`/`amount` in `rejectWithdrawal()` |

## Approval Notification

Added inside `approveWithdrawal()` after the document update + balance deduction (inside the `try` block, before `finally`):

```dart
await NotificationServiceAppwrite().createNotification(
  userId: sellerId,
  title: 'Penarikan Disetujui',
  message: 'Penarikan saldo sebesar Rp X telah disetujui dan sedang diproses.',
  type: 'withdrawal',
  orderId: '',
);
```

- Uses `sellerId` (line 93) and `freshAmount` (line 113) already extracted from the withdrawal doc
- Sent only after successful approval + balance deduction
- No flow changes to approval logic

## Rejection Notification

Added inside `rejectWithdrawal()` after the document update:

```dart
await NotificationServiceAppwrite().createNotification(
  userId: sellerId,
  title: 'Penarikan Ditolak',
  message: 'Penarikan saldo sebesar Rp X ditolak.\nAlasan: $note',
  type: 'withdrawal',
  orderId: '',
);
```

- `sellerId` and `amount` extracted from withdrawal doc (new lines added)
- `note` is the rejection reason already passed to the method
- Sent only after successful document update
- No flow changes to rejection logic

## Risks

- `NotificationServiceAppwrite.createNotification()` is called inside the lock-protected section of `approveWithdrawal()`. If the notification service is down, the lock remains held for the full TTL (10s). Acceptable since the notification is sent after all critical DB updates are complete.
- `orderId: ''` is passed for withdrawal notifications — this is consistent with the model default and doesn't break any existing query.

## Manual Testing Checklist

- [ ] Admin approves withdrawal → seller receives notification "Penarikan Disetujui" with amount
- [ ] Admin rejects withdrawal with reason → seller receives notification "Penarikan Ditolak" with amount + reason
- [ ] Notification appears in seller's notification list (`type: 'withdrawal'`)
- [ ] `flutter analyze` — 0 errors, 0 new issues
