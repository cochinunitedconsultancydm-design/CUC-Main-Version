/**
 * Helper bridge for Razorpay Standard Web Checkout
 */
window.openRazorpayCheckout = function(options, onSuccess, onFailure, onDismiss) {
  if (typeof Razorpay === 'undefined') {
    console.error('Razorpay SDK is not loaded in window.');
    if (onFailure) onFailure('Razorpay SDK is not loaded. Please check your network connection.');
    return;
  }

  const rzpOptions = Object.assign({}, options, {
    handler: function(response) {
      console.log('Razorpay payment successful:', response);
      if (onSuccess) {
        onSuccess(
          response.razorpay_payment_id,
          response.razorpay_order_id,
          response.razorpay_signature
        );
      }
    },
    modal: {
      ondismiss: function() {
        console.warn('Razorpay checkout modal dismissed by user.');
        if (onDismiss) onDismiss();
      }
    }
  });

  const rzp = new Razorpay(rzpOptions);

  rzp.on('payment.failed', function(resp) {
    console.error('Razorpay payment failed:', resp.error);
    if (onFailure) {
      onFailure(resp.error ? resp.error.description || resp.error.reason : 'Payment failed');
    }
  });

  rzp.open();
};
