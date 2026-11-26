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
      return res.status(200).json({
        status: 'success',
        message: 'Payment verified successfully',
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
