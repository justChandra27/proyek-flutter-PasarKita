import nodemailer from 'nodemailer';

export default async ({ req, res, log, error }) => {
  try {
    log('========================');
    log('FUNCTION START');
    log('========================');

    const smtpHost = process.env.SMTP_HOST;
    const smtpPort = Number(process.env.SMTP_PORT);
    const smtpUser = process.env.SMTP_USER;
    const smtpPass = process.env.SMTP_PASS;
    const smtpFrom = process.env.SMTP_FROM;

    log(`SMTP_HOST=${smtpHost}`);
    log(`SMTP_PORT=${smtpPort}`);
    log(`SMTP_USER=${smtpUser}`);
    log(`SMTP_FROM=${smtpFrom}`);

    const missing = [];

    if (!smtpHost) missing.push('SMTP_HOST');
    if (!smtpPort) missing.push('SMTP_PORT');
    if (!smtpUser) missing.push('SMTP_USER');
    if (!smtpPass) missing.push('SMTP_PASS');
    if (!smtpFrom) missing.push('SMTP_FROM');

    if (missing.length > 0) {
      throw new Error(
        `Missing environment variables: ${missing.join(', ')}`
      );
    }

    log('Creating transporter');

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

    log('Transporter created');

    // =====================
    // VERIFY
    // =====================

    log('VERIFY START');

    await transporter.verify();

    log('VERIFY SUCCESS');

    // =====================
    // SEND TEST EMAIL
    // =====================

    const mailOptions = {
      from: smtpFrom,
      to: smtpFrom,
      subject: 'PasarKita SMTP Test',
      html: `
        <h2>SMTP Test Success</h2>
        <p>Email berhasil dikirim dari Appwrite Function</p>
        <p>${new Date().toISOString()}</p>
      `,
    };

    log('MAIL OBJECT CREATED');
    log(`TO=${smtpFrom}`);

    log('SENDMAIL START');

    const result = await transporter.sendMail(mailOptions);

    log('SENDMAIL SUCCESS');
    log(`MESSAGE_ID=${result.messageId}`);

    return res.json({
      success: true,
      verify: true,
      sendMail: true,
      messageId: result.messageId,
    });

  } catch (err) {
    error('========================');
    error('FUNCTION ERROR');
    error(`MESSAGE=${err.message}`);

    if (err.code) {
      error(`CODE=${err.code}`);
    }

    if (err.command) {
      error(`COMMAND=${err.command}`);
    }

    if (err.response) {
      error(`RESPONSE=${err.response}`);
    }

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