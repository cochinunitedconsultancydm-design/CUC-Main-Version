import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RazorpayOrder {
  final String orderId;
  final int amount;
  final String currency;
  final String keyId;

  RazorpayOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    return RazorpayOrder(
      orderId: json['order_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      keyId: json['key_id']?.toString() ?? '',
    );
  }
}

class RazorpayPaymentLink {
  final String id;
  final String shortUrl;
  final String status;
  final double amount;
  final String currency;

  RazorpayPaymentLink({
    required this.id,
    required this.shortUrl,
    required this.status,
    required this.amount,
    required this.currency,
  });

  factory RazorpayPaymentLink.fromJson(Map<String, dynamic> json) {
    return RazorpayPaymentLink(
      id: json['id']?.toString() ?? '',
      shortUrl: json['short_url']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: ((json['amount'] as num?)?.toDouble() ?? 0.0) / 100.0,
      currency: json['currency']?.toString() ?? 'INR',
    );
  }
}

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();

  static const String keyId = 'rzp_test_U4jLB7rZ20MRyi';
  static const String keySecret = 'Onz58XhC0gc5193jPIKbbgm2';
  static const String _baseUrl = 'https://api.razorpay.com/v1';

  String get _basicAuthHeader {
    final credentials = '$keyId:$keySecret';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  /// Create a standard Razorpay Payment Link
  Future<RazorpayPaymentLink> createPaymentLink({
    required double amount,
    required String invoiceNo,
    required String clientName,
    String? clientPhone,
    String? clientEmail,
    String? billingId,
    String? description,
  }) async {
    final url = Uri.parse('$_baseUrl/payment_links');

    // Amount in paise (minimum 100 paise = 1 INR)
    final int amountInPaise = (amount * 100).round();
    if (amountInPaise < 100) {
      throw Exception('Payment amount must be at least ₹1.00');
    }

    final Map<String, dynamic> customerData = {
      'name': clientName.isNotEmpty ? clientName : 'Valued Client',
    };

    if (clientPhone != null && clientPhone.trim().isNotEmpty) {
      var digits = clientPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.startsWith('0091') && digits.length == 14) {
        digits = digits.substring(4);
      } else if (digits.startsWith('91') && digits.length == 12) {
        digits = digits.substring(2);
      } else if (digits.startsWith('0') && digits.length == 11) {
        digits = digits.substring(1);
      }
      if (digits.length == 10) {
        customerData['contact'] = '+91$digits';
      } else if (digits.isNotEmpty) {
        customerData['contact'] = digits.startsWith('+') ? digits : '+$digits';
      }
    }

    if (clientEmail != null && clientEmail.trim().isNotEmpty) {
      customerData['email'] = clientEmail.trim();
    }

    final notes = <String, String>{
      'invoice_no': invoiceNo,
      'company': 'Cochin United Consultancy',
    };
    if (billingId != null && billingId.isNotEmpty) {
      notes['billing_id'] = billingId;
    }

    final body = {
      'amount': amountInPaise,
      'currency': 'INR',
      'accept_partial': false,
      'description': description ?? 'Payment for Invoice #$invoiceNo - $clientName',
      'customer': customerData,
      'notify': {
        'sms': false,
        'email': false,
        'whatsapp': false,
      },
      'reminder_enable': true,
      'notes': notes,
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': _basicAuthHeader,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return RazorpayPaymentLink.fromJson(json);
    } else {
      debugPrint('Razorpay error: ${response.statusCode} - ${response.body}');
      String errorMsg = 'Failed to create Razorpay payment link (${response.statusCode})';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson['error'] != null && errJson['error']['description'] != null) {
          errorMsg = errJson['error']['description'];
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  static const String _backendBaseUrl = 'http://localhost:5000/api';

  /// Create a Razorpay Order via backend (POST /api/create-order)
  Future<RazorpayOrder> createOrder({
    required double amount,
    required String invoiceNo,
    required String clientName,
    String? clientPhone,
    String? clientEmail,
    String? billingId,
  }) async {
    final int amountInPaise = (amount * 100).round();
    final url = Uri.parse('$_backendBaseUrl/create-order');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountInPaise,
        'currency': 'INR',
        'receipt': 'rcpt_$invoiceNo',
        'notes': {
          'invoice_no': invoiceNo,
          'client_name': clientName,
          'client_phone': clientPhone ?? '',
          'billing_id': billingId ?? '',
        },
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return RazorpayOrder.fromJson(data);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Failed to create order on server');
    }
  }

  /// Verify Payment Signature via backend (POST /api/verify-payment)
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final url = Uri.parse('$_backendBaseUrl/verify-payment');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    }
    return false;
  }
}
