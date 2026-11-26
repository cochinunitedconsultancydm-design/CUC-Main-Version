import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  static const String keyId = 'rzp_test_U4g76ID5dKIyBc';
  static const String keySecret = '7rn9h8sDCaFoSHNLOFf8h4uA';
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
      var phoneDigits = clientPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (phoneDigits.length == 10) {
        phoneDigits = '+91$phoneDigits';
      } else if (!phoneDigits.startsWith('+')) {
        phoneDigits = '+$phoneDigits';
      }
      customerData['contact'] = phoneDigits;
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
}
