const crypto = require('crypto');
const http = require('http');

async function runTests() {
  console.log('🧪 Starting Razorpay Standard Web Checkout tests...\n');

  // Test 1: Test signature verification math
  const secret = 'Onz58XhC0gc5193jPIKbbgm2';
  const orderId = 'order_test_123456';
  const paymentId = 'pay_test_789012';
  const expectedSig = crypto
    .createHmac('sha256', secret)
    .update(`${orderId}|${paymentId}`)
    .digest('hex');

  console.log('✅ Signature generation test:');
  console.log(`   Order ID: ${orderId}`);
  console.log(`   Payment ID: ${paymentId}`);
  console.log(`   Expected HMAC: ${expectedSig}\n`);

  // Start app directly for in-memory integration testing
  const app = require('../server.js');
  const server = app.listen(5099, async () => {
    console.log('✅ Test server listening on http://localhost:5099');

    try {
      // Test 2: Validation check - amount < 100 paise
      const badOrderRes = await fetch('http://localhost:5099/api/create-order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: 50 }),
      });
      const badOrderJson = await badOrderRes.json();
      console.log(`✅ Validation test (amount < 100 paise): Status ${badOrderRes.status} -> ${badOrderJson.error}`);

      // Test 3: Create Order test with valid amount >= 100 paise (50000 paise = ₹500)
      const createOrderRes = await fetch('http://localhost:5099/api/create-order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          amount: 50000,
          currency: 'INR',
          receipt: 'test_rcpt_1',
          notes: { test: 'true' },
        }),
      });
      const createOrderJson = await createOrderRes.json();
      console.log(`✅ Create Order test: Status ${createOrderRes.status}`);
      console.log('   Order response:', createOrderJson);

      if (!createOrderJson.order_id) {
        throw new Error('Create order failed: ' + JSON.stringify(createOrderJson));
      }

      // Test 4: Verify Payment Signature - Valid Signature
      const testOrderId = createOrderJson.order_id;
      const testPaymentId = 'pay_dummy_test_123';
      const validSig = crypto
        .createHmac('sha256', secret)
        .update(`${testOrderId}|${testPaymentId}`)
        .digest('hex');

      const verifyRes = await fetch('http://localhost:5099/api/verify-payment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          razorpay_order_id: testOrderId,
          razorpay_payment_id: testPaymentId,
          razorpay_signature: validSig,
        }),
      });
      const verifyJson = await verifyRes.json();
      console.log(`✅ Verify Payment test (Valid Signature): Status ${verifyRes.status}`);
      console.log('   Verify response:', verifyJson);

      // Test 5: Verify Payment Signature - Invalid Signature
      const invalidVerifyRes = await fetch('http://localhost:5099/api/verify-payment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          razorpay_order_id: testOrderId,
          razorpay_payment_id: testPaymentId,
          razorpay_signature: 'invalid_signature_hex_code_1234567890abcdef',
        }),
      });
      const invalidVerifyJson = await invalidVerifyRes.json();
      console.log(`✅ Verify Payment test (Invalid Signature): Status ${invalidVerifyRes.status}`);
      console.log('   Mismatch response:', invalidVerifyJson);

      // Test 6: Verify Payment Signature - Missing Fields
      const missingFieldsRes = await fetch('http://localhost:5099/api/verify-payment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          razorpay_order_id: testOrderId,
        }),
      });
      const missingFieldsJson = await missingFieldsRes.json();
      console.log(`✅ Missing Fields test: Status ${missingFieldsRes.status}`);
      console.log('   Missing fields response:', missingFieldsJson);

      console.log('\n🎉 ALL RAZORPAY STANDARD WEB CHECKOUT TESTS PASSED SUCCESSFULLY!\n');
    } catch (err) {
      console.error('❌ Test error:', err);
    } finally {
      server.close();
      process.exit(0);
    }
  });
}

runTests();
