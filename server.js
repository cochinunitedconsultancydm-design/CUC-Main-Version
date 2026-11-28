const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const path = require('path');
const Razorpay = require('razorpay');
const nodemailer = require('nodemailer');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS and JSON parsing (with rawBody capture for HMAC signature verification)
app.use(cors());
app.use(express.json({
  limit: '10mb',
  verify: (req, res, buf) => {
    req.rawBody = buf;
  }
}));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Setup Nodemailer Gmail SMTP Transporter
function getEmailTransporter() {
  const user = process.env.SMTP_USER || 'cochinunitedconsultancydm@gmail.com';
  const pass = (process.env.SMTP_PASS || 'wswpwxsrskromlkp').replace(/\s+/g, '');
  return nodemailer.createTransport({
    service: 'gmail',
    auth: { user, pass }
  });
}

/**
 * Send official Payment Receipt Email to client with PDF attachment and admin copy
 */
async function sendReceiptEmail({ to, clientName, invoiceNo, amount, paymentMode, paymentId, receiptPdfUrl, pdfBytesBase64 }) {
  try {
    const transporter = getEmailTransporter();
    const adminEmail = 'cochinunitedconsultancydm@gmail.com';
    const recipient = (to && to.includes('@')) ? to.trim() : adminEmail;
    const isClientCopy = recipient !== adminEmail;

    const formattedAmount = String(amount || '0').replace('/-', '');
    const cleanInvoiceNo = (invoiceNo || 'INV').replace(/[^a-zA-Z0-9_-]/g, '_');

    const attachments = [];
    if (pdfBytesBase64) {
      attachments.push({
        filename: `Payment_Receipt_RCPT_${cleanInvoiceNo}.pdf`,
        content: Buffer.from(pdfBytesBase64, 'base64'),
        contentType: 'application/pdf'
      });
    }

    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; background: #ffffff;">
        <div style="background: #0f172a; padding: 24px; text-align: center; color: #ffffff;">
          <h2 style="margin: 0; font-size: 20px; font-weight: bold; letter-spacing: 0.5px;">COCHIN UNITED CONSULTANCY</h2>
          <p style="margin: 4px 0 0 0; font-size: 13px; color: #94a3b8;">Official Payment Receipt</p>
        </div>
        <div style="padding: 24px;">
          <p style="font-size: 15px; color: #334155; margin-top: 0;">
            Dear <strong>${clientName || 'Valued Client'}</strong>,
          </p>
          <p style="font-size: 14px; color: #475569; line-height: 1.6;">
            Thank you for your payment. We confirm that your payment has been successfully received and recorded in our systems.
          </p>
          
          <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; margin: 20px 0;">
            <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
              <tr>
                <td style="padding: 6px 0; color: #64748b;">Receipt Number:</td>
                <td style="padding: 6px 0; text-align: right; font-weight: bold; color: #0f172a;">RCPT-${invoiceNo || 'N/A'}</td>
              </tr>
              <tr>
                <td style="padding: 6px 0; color: #64748b;">Invoice Reference:</td>
                <td style="padding: 6px 0; text-align: right; font-weight: bold; color: #0f172a;">${invoiceNo || 'N/A'}</td>
              </tr>
              <tr>
                <td style="padding: 6px 0; color: #64748b;">Payment Date:</td>
                <td style="padding: 6px 0; text-align: right; font-weight: bold; color: #0f172a;">${new Date().toLocaleDateString('en-IN', { year: 'numeric', month: 'short', day: 'numeric' })}</td>
              </tr>
              <tr>
                <td style="padding: 6px 0; color: #64748b;">Payment Mode:</td>
                <td style="padding: 6px 0; text-align: right; font-weight: bold; color: #0f172a;">${paymentMode || 'Razorpay Online'}</td>
              </tr>
              ${paymentId ? `
              <tr>
                <td style="padding: 6px 0; color: #64748b;">Transaction ID:</td>
                <td style="padding: 6px 0; text-align: right; font-weight: bold; color: #0f172a;">${paymentId}</td>
              </tr>
              ` : ''}
              <tr style="border-top: 1px dashed #cbd5e1;">
                <td style="padding: 10px 0 4px 0; color: #0f172a; font-weight: bold; font-size: 15px;">Amount Paid:</td>
                <td style="padding: 10px 0 4px 0; text-align: right; font-weight: bold; font-size: 17px; color: #16a34a;">₹${formattedAmount}</td>
              </tr>
              <tr>
                <td style="padding: 4px 0; color: #64748b;">Balance Due:</td>
                <td style="padding: 4px 0; text-align: right; font-weight: bold; color: #16a34a;">₹0.00 (PAID IN FULL)</td>
              </tr>
            </table>
          </div>

          ${receiptPdfUrl ? `
          <div style="text-align: center; margin: 24px 0;">
            <a href="${receiptPdfUrl}" target="_blank" style="background: #2563eb; color: #ffffff; text-decoration: none; padding: 12px 24px; border-radius: 6px; font-weight: bold; display: inline-block; font-size: 14px;">
              📄 Download PDF Receipt
            </a>
          </div>
          ` : ''}

          <p style="font-size: 13px; color: #64748b; margin-bottom: 4px;">
            A PDF copy of this receipt is attached to this email for your accounting records.
          </p>
          <p style="font-size: 13px; color: #64748b; margin-top: 0;">
            If you have any questions, please contact us at <a href="mailto:cochinunitedconsultancydm@gmail.com" style="color: #2563eb;">cochinunitedconsultancydm@gmail.com</a> or +91 70124 66754.
          </p>
        </div>
        <div style="background: #f1f5f9; padding: 16px; text-align: center; font-size: 12px; color: #64748b; border-top: 1px solid #e2e8f0;">
          Cochin United Consultancy &bull; High Court Road, Ernakulam, Kerala 682031
        </div>
      </div>
    `;

    const mailOptions = {
      from: `"Cochin United Consultancy" <${adminEmail}>`,
      to: recipient,
      bcc: isClientCopy ? adminEmail : undefined, // Keep official admin copy
      subject: `Payment Receipt: RCPT-${invoiceNo || 'INV'} - Cochin United Consultancy`,
      html: htmlContent,
      attachments
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`[Email] Receipt email dispatched successfully to ${recipient} (Message ID: ${info.messageId})`);
    return { success: true, messageId: info.messageId };
  } catch (err) {
    console.error(`[Email] Failed to send receipt email:`, err);
    return { success: false, error: err.message };
  }
}

// Serve static frontend checkout assets
app.use(express.static(path.join(__dirname, 'public')));

// Initialize Razorpay instance safely using environment variables
function getRazorpayInstance() {
  const keyId = process.env.RAZORPAY_KEY_ID;
  const keySecret = process.env.RAZORPAY_KEY_SECRET;

  if (!keyId || !keySecret) {
    throw new Error('Razorpay API keys are missing in environment variables');
  }

  return new Razorpay({
    key_id: keyId,
    key_secret: keySecret,
  });
}

/**
 * GET /api/config
 * Returns public Key ID (KEY_SECRET is NEVER exposed)
 */
app.get('/api/config', (req, res) => {
  const keyId = process.env.RAZORPAY_KEY_ID;
  if (!keyId) {
    return res.status(500).json({ error: 'RAZORPAY_KEY_ID is not configured' });
  }
  res.json({ key_id: keyId });
});

/**
 * STEP 1: BACKEND - Create Order
 * Endpoint: POST /api/create-order
 * Request: { amount (in paise), currency, receipt, notes }
 * Return: { order_id, amount, currency, key_id }
 * Minimum amount: 100 paise (₹1)
 */
app.post('/api/create-order', async (req, res) => {
  try {
    const { amount, currency = 'INR', receipt, notes } = req.body;

    // Validate amount
    const parsedAmount = parseInt(amount, 10);
    if (isNaN(parsedAmount) || parsedAmount < 100) {
      return res.status(400).json({
        error: 'Invalid amount. Minimum amount must be at least 100 paise (₹1.00)',
      });
    }

    let razorpay;
    try {
      razorpay = getRazorpayInstance();
    } catch (configErr) {
      return res.status(500).json({ error: configErr.message });
    }

    const options = {
      amount: parsedAmount,
      currency: currency.toUpperCase(),
      receipt: receipt || `rcpt_${Date.now()}`,
      notes: notes || { company: 'Cochin United Consultancy' },
    };

    console.log(`[Razorpay] Creating order for ${parsedAmount} ${options.currency}...`);
    const order = await razorpay.orders.create(options);
    console.log(`[Razorpay] Order created successfully: ${order.id}`);

    return res.status(200).json({
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
      key_id: process.env.RAZORPAY_KEY_ID,
    });
  } catch (error) {
    console.error('[Razorpay] Create order error:', error);

    // Handle authentication / permission failures
    if (error.statusCode === 401 || (error.error && error.error.code === 'BAD_REQUEST_ERROR' && error.error.description?.includes('auth'))) {
      return res.status(401).json({
        error: 'Razorpay authentication failed. Please verify your RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET.',
      });
    }

    const statusCode = error.statusCode || 500;
    const errorMessage = error.error?.description || error.message || 'Failed to create Razorpay order';
    return res.status(statusCode).json({ error: errorMessage });
  }
});

/**
 * STEP 3: BACKEND - Verify Signature
 * Endpoint: POST /api/verify-payment
 * Algorithm: HMAC-SHA256(order_id + "|" + payment_id, KEY_SECRET)
 * Compare generated signature with razorpay_signature
 * Return success only if signatures match
 */
app.post('/api/verify-payment', (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    // Validate required fields
    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({
        status: 'failure',
        error: 'Missing required parameters: razorpay_order_id, razorpay_payment_id, and razorpay_signature are all required.',
      });
    }

    const keySecret = process.env.RAZORPAY_KEY_SECRET;
    if (!keySecret) {
      return res.status(500).json({
        status: 'failure',
        error: 'RAZORPAY_KEY_SECRET is not configured on the server.',
      });
    }

    // Generate expected HMAC-SHA256 signature
    const payload = `${razorpay_order_id}|${razorpay_payment_id}`;
    const generatedSignature = crypto
      .createHmac('sha256', keySecret)
      .update(payload)
      .digest('hex');

    // Secure timing-safe string comparison
    const sigBufferA = Buffer.from(generatedSignature, 'utf8');
    const sigBufferB = Buffer.from(razorpay_signature, 'utf8');

    const isMatch = sigBufferA.length === sigBufferB.length && crypto.timingSafeEqual(sigBufferA, sigBufferB);

    if (isMatch) {
      console.log(`[Razorpay] Payment verified successfully: Payment ID: ${razorpay_payment_id}, Order ID: ${razorpay_order_id}`);

      // Automatically update the bill in database and notify local server
      autoUpdateBillOnPayment({
        orderId: razorpay_order_id,
        paymentId: razorpay_payment_id,
        invoiceNo: req.body.invoice_no,
        billingId: req.body.billing_id,
        amount: req.body.amount,
      }).catch((err) => {
        console.error('[Razorpay Auto-Sync] Background update error:', err.message);
      });

      return res.status(200).json({
        status: 'success',
        message: 'Payment verified successfully and bill updated to Paid',
        payment_id: razorpay_payment_id,
        order_id: razorpay_order_id,
      });
    } else {
      console.warn(`[Razorpay] Signature mismatch for Order: ${razorpay_order_id}, Payment: ${razorpay_payment_id}`);
      return res.status(400).json({
        status: 'failure',
        error: 'Invalid payment signature. Verification failed.',
      });
    }
  } catch (error) {
    console.error('[Razorpay] Verification error:', error);
    return res.status(500).json({
      status: 'failure',
      error: error.message || 'Internal server error during signature verification.',
    });
  }
});

/**
 * Automatically update the bill in database and notify local webhook server
 */
async function autoUpdateBillOnPayment({ orderId, paymentId, invoiceNo, billingId, amount, customerEmail, customerName }) {
  console.log(`[Auto-Sync] Processing paid invoice: ${invoiceNo || billingId || orderId}`);
  
  // 1. Notify local Flutter embedded webhook server on port 8088
  try {
    const notifyPayload = {
      event: 'payment.captured',
      payload: {
        payment: {
          entity: {
            id: paymentId,
            order_id: orderId,
            amount: amount ? Math.round(Number(amount) * 100) : 0,
            status: 'captured',
            notes: {
              invoice_no: invoiceNo,
              billing_id: billingId,
            }
          }
        }
      }
    };
    const localRes = await fetch('http://localhost:8088/webhook/razorpay', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(notifyPayload)
    });
    console.log(`[Auto-Sync] Local webhook notified on port 8088: HTTP ${localRes.status}`);
  } catch (err) {
    console.log(`[Auto-Sync] Local webhook port 8088 notice: ${err.message}`);
  }

  // 2. Direct Supabase update
  try {
    const supabaseUrl = process.env.SUPABASE_URL || 'https://bzxtgiqjgfojblezdubd.supabase.co';
    const supabaseKey = process.env.SUPABASE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';

    let filter = '';
    if (billingId) filter = `id=eq.${billingId}`;
    else if (invoiceNo) filter = `invoice_no=eq.${encodeURIComponent(invoiceNo)}`;

    if (filter) {
      const getRes = await fetch(`${supabaseUrl}/rest/v1/billings?${filter}&select=*`, {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`
        }
      });
      const rows = await getRes.json();
      if (Array.isArray(rows) && rows.length > 0) {
        const bill = rows[0];
        let billData = {};
        if (bill.data) {
          try { billData = typeof bill.data === 'string' ? JSON.parse(bill.data) : bill.data; } catch (_) {}
        }

        const totalBillAmount = parseFloat(String(bill.amount || '0').replace(/[^0-9.]/g, '')) || 0;
        const prevReceived = parseFloat(String(billData.advance_received || '0').replace(/[^0-9.]/g, '')) || 0;
        const newTotalReceived = prevReceived + (amount || totalBillAmount);
        const balanceRemaining = Math.max(0, totalBillAmount - newTotalReceived);
        const isFullyPaid = balanceRemaining <= 0 || (totalBillAmount > 0 && newTotalReceived >= totalBillAmount);

        billData.payment_received = isFullyPaid;
        billData.payment_date = new Date().toISOString();
        billData.razorpay_payment_id = paymentId;
        billData.marked_paid_by = 'Razorpay Payment Link';
        billData.balance_due = isFullyPaid ? '0/-' : `${balanceRemaining}/-`;
        billData.advance_received = String(newTotalReceived);

        await fetch(`${supabaseUrl}/rest/v1/billings?${filter}`, {
          method: 'PATCH',
          headers: {
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`,
            'Content-Type': 'application/json',
            'Prefer': 'return=representation'
          },
          body: JSON.stringify({
            status: isFullyPaid ? 'Received' : 'Part Payment',
            data: billData
          })
        });
        console.log(`[Auto-Sync] Supabase billing ${invoiceNo || billingId} updated to ${isFullyPaid ? 'Received' : 'Part Payment'}.`);

        // Automatically log into Supabase company_bills (Company Accounts/Expense Register)
        try {
          const paymentType = isFullyPaid ? 'Full Payment' : 'Part Payment';
          const targetTitle = `${bill.type || 'Invoice'} Payment (${paymentType}) - ${bill.invoice_no || invoiceNo}`;
          await fetch(`${supabaseUrl}/rest/v1/company_bills`, {
            method: 'POST',
            headers: {
              'apikey': supabaseKey,
              'Authorization': `Bearer ${supabaseKey}`,
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal'
            },
            body: JSON.stringify({
              category: 'Client Payment',
              title: targetTitle,
              amount: -Math.abs(amount || totalBillAmount), // In CompanyBills, income is stored as negative
              bill_date: new Date().toISOString(),
              status: 'Paid',
              description: `Payment from ${bill.client_name || 'Client'} via Razorpay Link (${paymentId}). Auto-logged from Billing.`,
              spent_by_name: 'Razorpay Auto-Sync'
            })
          });
          console.log(`[Auto-Sync] Supabase company_bills entry recorded for ${invoiceNo}.`);
        } catch (cbErr) {
          console.log(`[Auto-Sync] Notice logging company_bills in Supabase: ${cbErr.message}`);
        }

        // Dispatch official payment receipt email
        try {
          const clientEmail = billData.client_email || billData.email || '';
          const clientName = bill.client_name || 'Valued Client';
          await sendReceiptEmail({
            to: clientEmail,
            clientName,
            invoiceNo: bill.invoice_no || invoiceNo,
            amount: amount || bill.amount,
            paymentMode: 'Razorpay Online',
            paymentId
          });
        } catch (emailErr) {
          console.error(`[Auto-Sync] Failed to dispatch automated receipt email: ${emailErr.message}`);
        }
      }
    }
  } catch (sbErr) {
    console.error(`[Auto-Sync] Supabase update notice: ${sbErr.message}`);
  }
}

// ---------------------------------------------------------------------------
// 4. Webhook Receiver for Razorpay Events (POST /api/webhook, /webhook/razorpay)
// ---------------------------------------------------------------------------
app.post(['/api/webhook', '/webhook/razorpay', '/api/razorpay-webhook'], async (req, res) => {
  const event = req.body.event;
  console.log(`[Razorpay Webhook] Received event: ${event}`);

  // Validate Razorpay webhook HMAC signature if secret is configured
  const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
  const signature = req.headers['x-razorpay-signature'];
  if (webhookSecret && signature) {
    const rawBody = req.rawBody || JSON.stringify(req.body);
    const expectedSig = crypto.createHmac('sha256', webhookSecret).update(rawBody).digest('hex');
    try {
      const sigBufA = Buffer.from(signature, 'utf8');
      const sigBufB = Buffer.from(expectedSig, 'utf8');
      if (sigBufA.length !== sigBufB.length || !crypto.timingSafeEqual(sigBufA, sigBufB)) {
        console.warn('[Razorpay Webhook] Rejected: Invalid HMAC signature.');
        return res.status(400).json({ error: 'Invalid webhook signature' });
      }
    } catch (err) {
      console.warn('[Razorpay Webhook] Signature verification failed:', err.message);
      return res.status(400).json({ error: 'Signature verification failed' });
    }
  }

  if (event === 'payment.captured' || event === 'payment_link.paid' || event === 'order.paid') {
    const payment = req.body.payload?.payment?.entity;
    const paymentLink = req.body.payload?.payment_link?.entity;
    const notes = payment?.notes || paymentLink?.notes || {};

    const invoiceNo = notes.invoice_no;
    const billingId = notes.billing_id;
    const paymentId = payment?.id || paymentLink?.id;
    const orderId = payment?.order_id || req.body.payload?.order?.entity?.id;
    const amount = (payment?.amount || paymentLink?.amount_paid || paymentLink?.amount || 0) / 100;

    await autoUpdateBillOnPayment({
      orderId,
      paymentId,
      invoiceNo,
      billingId,
      amount
    });
  }

  return res.status(200).json({ status: 'ok' });
});

// ---------------------------------------------------------------------------
// 5. Send Payment Receipt Email Endpoint
// ---------------------------------------------------------------------------
app.post('/api/send-receipt-email', async (req, res) => {
  const { to, clientName, invoiceNo, amount, paymentMode, paymentId, receiptPdfUrl, pdfBytesBase64 } = req.body;
  const result = await sendReceiptEmail({
    to,
    clientName,
    invoiceNo,
    amount,
    paymentMode,
    paymentId,
    receiptPdfUrl,
    pdfBytesBase64
  });

  if (result.success) {
    return res.status(200).json(result);
  } else {
    return res.status(500).json(result);
  }
});

app.get(['/api/health', '/health'], (req, res) => {
  res.status(200).json({ status: 'ok', uptime: process.uptime(), timestamp: new Date().toISOString() });
});

app.get(['/api/webhook', '/webhook/razorpay'], (req, res) => {
  res.status(200).json({
    status: 'active',
    message: 'Razorpay webhook receiver is active. Set this URL as POST in the Razorpay Dashboard.',
    supportedEvents: ['payment_link.paid', 'payment.captured', 'order.paid']
  });
});

// Start the backend server
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`🚀 Razorpay Standard Checkout Server running on http://localhost:${PORT}`);
    console.log(`📡 Endpoints available:`);
    console.log(`   POST http://localhost:${PORT}/api/create-order`);
    console.log(`   POST http://localhost:${PORT}/api/verify-payment`);
    console.log(`   POST http://localhost:${PORT}/api/send-receipt-email`);
    console.log(`   GET  http://localhost:${PORT}/api/config`);
  });
}

module.exports = app;
