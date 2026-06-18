MODE: IMPLEMENT

Proyek: PasarKita Flutter + Appwrite

Jangan mengubah file selain:

* functions/email_receipt/index.js
* functions/email_receipt/package.json

Tujuan:

Audit dan perbaiki dependency Nodemailer agar dapat dimuat oleh Appwrite Function Node.js 22.

Perubahan:

1. Ubah package.json:

{
"name": "pasarkita-email-receipt",
"version": "1.0.0",
"type": "module",
"main": "index.js",
"dependencies": {
"nodemailer": "^6.9.14"
}
}

2. Ganti index.js menjadi test dependency sederhana:

import nodemailer from 'nodemailer';

export default async ({ res, log }) => {
log('Nodemailer loaded');

return res.json({
success: true,
version: nodemailer.version || 'loaded'
});
};

3. Jangan tambahkan SMTP.
4. Jangan tambahkan transporter.
5. Jangan tambahkan sendMail.
6. Jangan membaca environment variable.

Output ke prompt.md:

* File yang diubah
* Perubahan dependency
* Cara deploy ulang
* Cara test execute
* Cara memastikan nodemailer berhasil dimuat

==================================================
OUTPUT — HASIL IMPLEMENTASI
==================================================

1. File yang diubah
   - functions/email_receipt/index.js
   - functions/email_receipt/package.json

2. Perubahan dependency
   package.json: nodemailer "^9.0.0" -> "^6.9.14"
   Alasan: versi 6.x adalah seri LTS stabil yang sudah teruji kompatibel
   dengan berbagai runtime Node.js (6.x s.d. 22.x).

3. Cara deploy ulang
   Upload folder functions/email_receipt via Appwrite Console:
   - Functions → pilih function → Deploy
   - Upload file index.js + package.json
   - Set entrypoint: index.js
   - Build & activate

4. Cara test execute
   Appwrite Console → Functions → pilih function → Execute Now
   Body bebas (tidak dibaca)
   Cek Execution Logs untuk hasilnya.

5. Cara memastikan nodemailer berhasil dimuat
   - Cek Execution Logs: harus muncul log "Nodemailer loaded"
   - Cek response JSON: {"success":true,"version":"6.x.x"}
   - Jika response 503/500 dan tidak ada log "Nodemailer loaded":
     berarti nodemailer 6.9.14 gagal dimuat oleh Runtime Node.js 22
     → eksperimen dengan versi lebih lama (6.9.0, 6.8.0, dll)
     → atau coba tanpa "type": "module" (pakai require)
