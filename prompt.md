MODE: IMPLEMENT

Proyek: PasarKita Flutter

Bug:
Seller profile badge tetap menampilkan "Profile Belum Lengkap"
setelah profile berhasil disimpan.

Root cause:
form_profil_seller_web.dart::_saveProfile()
berhasil update Appwrite Database
tetapi _userModel tidak di-refresh.

Implementasi:

1. File:
   lib/presentation/seller/profile/form_profil_seller_web.dart

2. Audit _saveProfile()

3. Setelah updateDocument() berhasil:

   refresh _userModel dengan data terbaru.

4. Pilih salah satu pendekatan terbaik:

   Option A:

   * panggil kembali _loadUser()

   atau

   Option B:

   * update _userModel langsung dari controller values

5. Pastikan setelah klik Simpan:

   * badge berubah realtime
   * tidak perlu refresh browser
   * tidak perlu logout/login

6. Jangan mengubah logika isSellerProfileComplete()

7. Jangan mengubah struktur database.

8. Jalankan flutter analyze.

# STALE USERMODEL FIX REPORT

## File Modified

`lib/presentation/seller/profile/form_profil_seller_web.dart`

## Changes

**Before** (lines 101-108):
```dart
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _saving = false;
      });
```

**After** (lines 101-107):
```dart
      if (!mounted) return;
      await _loadUser();
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _saving = false;
      });
```

Added `await _loadUser();` between the DB update and the `setState` call. This refreshes `_userModel` from the database after a successful save, so the badge reads fresh data.

## Result

| Before | After |
|---|---|
| `_userModel` stale after save — badge shows old data | `_userModel` refreshed from DB — badge shows new data |
| Need browser refresh to see correct badge | Badge updates immediately after save |
| Temporary prints removed (clean) | No prints in production code |

## flutter analyze

**0 errors** — all 27 issues are pre-existing info/warnings.

## Final Verdict

Fix implemented. After clicking Simpan, `_loadUser()` re-fetches the user document from Appwrite, rebuilding `_userModel` with the latest `phone`, `storeName`, `storeAddress` values. The badge now reflects the correct completeness status in real time.
