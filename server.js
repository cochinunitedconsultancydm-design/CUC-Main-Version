const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const path = require('path');
const Razorpay = require('razorpay');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS and JSON parsing
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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
async function autoUpdateBillOnPayment({ orderId, paymentId, invoiceNo, billingId, amount }) {
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
        billData.payment_received = true;
        billData.payment_date = new Date().toISOString();
        billData.razorpay_payment_id = paymentId;
        billData.marked_paid_by = 'Razorpay Web Checkout';
        billData.balance_due = '0/-';
        if (amount) billData.advance_received = String(amount);

        await fetch(`${supabaseUrl}/rest/v1/billings?${filter}`, {
          method: 'PATCH',
          headers: {
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`,
            'Content-Type': 'application/json',
            'Prefer': 'return=representation'
          },
          body: JSON.stringify({
            status: 'Received',
            data: billData
          })
        });
        console.log(`[Auto-Sync] Supabase billing ${invoiceNo || billingId} updated to Received.`);
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

  if (event === 'payment.captured' || event === 'payment_link.paid' || event === 'order.paid') {
    const payment = req.body.payload?.payment?.entity;
    const paymentLink = req.body.payload?.payment_link?.entity;
    const notes = payment?.notes || paymentLink?.notes || {};

    const invoiceNo = notes.invoice_no;
    const billingId = notes.billing_id;
    const paymentId = payment?.id || paymentLink?.id;
    const orderId = payment?.order_id || req.body.payload?.order?.entity?.id;
    const amount = (payment?.amount || paymentLink?.amount || 0) / 100;

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

// Start the backend server
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`🚀 Razorpay Standard Checkout Server running on http://localhost:${PORT}`);
    console.log(`📡 Endpoints available:`);
    console.log(`   POST http://localhost:${PORT}/api/create-order`);
    console.log(`   POST http://localhost:${PORT}/api/verify-payment`);
    console.log(`   GET  http://localhost:${PORT}/api/config`);
  });
}

module.exports = app;
