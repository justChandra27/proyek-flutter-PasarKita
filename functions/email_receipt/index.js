import nodemailer from 'nodemailer';

export default async ({ req, res, log, error }) => {
  try {
    log('========================');
    log('EMAIL RECEIPT FUNCTION START');
    log('========================');

    const smtpHost = process.env.SMTP_HOST;
    const smtpPort = Number(process.env.SMTP_PORT);
    const smtpUser = process.env.SMTP_USER;
    const smtpPass = process.env.SMTP_PASS;
    const smtpFrom = process.env.SMTP_FROM;

    const missing = [];
    if (!smtpHost) missing.push('SMTP_HOST');
    if (!smtpPort) missing.push('SMTP_PORT');
    if (!smtpUser) missing.push('SMTP_USER');
    if (!smtpPass) missing.push('SMTP_PASS');
    if (!smtpFrom) missing.push('SMTP_FROM');

    if (missing.length > 0) {
      throw new Error(`Missing environment variables: ${missing.join(', ')}`);
    }

    const transporter = nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpPort === 465,
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
      connectionTimeout: 15000,
      greetingTimeout: 15000,
      socketTimeout: 15000,
    });

    await transporter.verify();
    log('SMTP VERIFY SUCCESS');

    // Parse payload
    let payload = {};
    if (req.body) {
      if (typeof req.body === 'string') {
        payload = JSON.parse(req.body);
      } else {
        payload = req.body;
      }
    }

    const {
      to = smtpFrom,
      customerName = 'Customer',
      orderId = '',
      orderCode = '',
      items = [],
      subtotal = 0,
      shippingCost = 0,
      total = 0,
      orderDate = '',
    } = payload;

    log(`Sending to: ${to}`);
    log(`Order: ${orderCode}`);

    // Build items table HTML
    let itemsHtml = '';
    if (items.length > 0) {
      itemsHtml = items.map((item, i) => {
        const name = item.productName || item.name || `Item ${i + 1}`;
        const qty = item.quantity || 1;
        const price = item.price || 0;
        const fmtPrice = new Intl.NumberFormat('id-ID').format(price);
        const fmtSubtotal = new Intl.NumberFormat('id-ID').format(price * qty);
        return `
          <tr>
            <td style="padding:8px;border-bottom:1px solid #eee;">${name}</td>
            <td style="padding:8px;border-bottom:1px solid #eee;text-align:center;">${qty}</td>
            <td style="padding:8px;border-bottom:1px solid #eee;text-align:right;">Rp ${fmtPrice}</td>
            <td style="padding:8px;border-bottom:1px solid #eee;text-align:right;">Rp ${fmtSubtotal}</td>
          </tr>
        `;
      }).join('');
    }

    const serviceFee = total - subtotal - shippingCost;
    const fmtTotal = new Intl.NumberFormat('id-ID').format(total);
    const fmtSubtotalVal = new Intl.NumberFormat('id-ID').format(subtotal);

    const fmtServiceFee = new Intl.NumberFormat('id-ID').format(serviceFee);
    const dateStr = orderDate ? new Date(orderDate).toLocaleDateString('id-ID', { year: 'numeric', month: 'long', day: 'numeric' }) : new Date().toLocaleDateString('id-ID');

    const html = `
      <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;">
        <div style="background:#2563EB;padding:24px;text-align:center;border-radius:12px 12px 0 0;">
          <h1 style="color:#fff;margin:0;font-size:24px;">PasarKita</h1>
          <p style="color:#DBEAFE;margin:8px 0 0;">Invoice Pembelian</p>
        </div>

        <div style="padding:24px;border:1px solid #e0e0e0;border-top:none;border-radius:0 0 12px 12px;">
          <p style="font-size:14px;color:#666;">Halo <strong>${customerName}</strong>,</p>
          <p style="font-size:14px;color:#666;">Terima kasih telah berbelanja di PasarKita. Berikut detail pesanan Anda:</p>

          <table style="width:100%;margin:16px 0;font-size:13px;">
            <tr>
              <td style="color:#666;width:100px;">Kode Pesanan</td>
              <td><strong>${orderCode}</strong></td>
            </tr>
            <tr>
              <td style="color:#666;">Tanggal</td>
              <td><strong>${dateStr}</strong></td>
            </tr>
          </table>

          <h3 style="font-size:16px;margin:16px 0 8px;color:#333;">Detail Produk</h3>
          <table style="width:100%;border-collapse:collapse;font-size:13px;">
            <thead>
              <tr style="background:#F8FAFC;">
                <th style="padding:8px;text-align:left;border-bottom:2px solid #2563EB;">Produk</th>
                <th style="padding:8px;text-align:center;border-bottom:2px solid #2563EB;">Qty</th>
                <th style="padding:8px;text-align:right;border-bottom:2px solid #2563EB;">Harga</th>
                <th style="padding:8px;text-align:right;border-bottom:2px solid #2563EB;">Subtotal</th>
              </tr>
            </thead>
            <tbody>
              ${itemsHtml}
            </tbody>
          </table>

          <table style="width:100%;margin:16px 0;font-size:14px;">
            <tr>
              <td style="color:#666;padding:4px 0;">Subtotal Produk</td>
              <td style="text-align:right;padding:4px 0;">Rp ${fmtSubtotalVal}</td>
            </tr>
            <tr>
              <td style="color:#666;padding:4px 0;">Biaya Layanan</td>
              <td style="text-align:right;padding:4px 0;">Rp ${fmtServiceFee}</td>
            </tr>
            <tr>
              <td style="padding:8px 0;border-top:2px solid #2563EB;"><strong>Total Pembayaran</strong></td>
              <td style="text-align:right;padding:8px 0;border-top:2px solid #2563EB;"><strong style="font-size:18px;color:#2563EB;">Rp ${fmtTotal}</strong></td>
            </tr>
          </table>

          <div style="background:#EFF6FF;padding:16px;border-radius:8px;margin:16px 0;font-size:13px;">
            <p style="margin:0 0 8px;color:#2563EB;font-weight:bold;">Langkah Selanjutnya:</p>
            <p style="margin:0 0 4px;color:#333;">1. Upload bukti pembayaran melalui halaman pesanan.</p>
            <p style="margin:0 0 4px;color:#333;">2. Admin PasarKita akan melakukan verifikasi pembayaran.</p>
            <p style="margin:0 0 4px;color:#333;">3. Jika pembayaran valid, seller akan memproses dan mengirim pesanan Anda.</p>
            <p style="margin:0;color:#333;">4. Jika pembayaran tidak valid, pesanan akan ditolak dan Anda akan menerima notifikasi pada akun PasarKita.</p>
          </div>

          <p style="font-size:12px;color:#999;margin-top:24px;text-align:center;">
            &copy; ${new Date().getFullYear()} PasarKita. All rights reserved.
          </p>
        </div>
      </div>
    `;

    const mailOptions = {
      from: smtpFrom,
      to: to,
      subject: `Invoice Pesanan ${orderCode} - PasarKita`,
      html: html,
    };

    log('SENDING EMAIL...');
    const result = await transporter.sendMail(mailOptions);
    log('EMAIL SENT SUCCESSFULLY');
    log(`MESSAGE_ID=${result.messageId}`);

    return res.json({
      success: true,
      messageId: result.messageId,
      to: to,
      orderCode: orderCode,
    });

  } catch (err) {
    error('========================');
    error('EMAIL RECEIPT FUNCTION ERROR');
    error(`MESSAGE=${err.message}`);
    if (err.code) error(`CODE=${err.code}`);
    if (err.command) error(`COMMAND=${err.command}`);
    if (err.response) error(`RESPONSE=${err.response}`);
    error(err.stack);
    error('========================');

    return res.json({
      success: false,
      error: err.message,
      code: err.code || null,
      command: err.command || null,
      response: err.response || null,
    }, 500);
  }
};
