import 'dart:convert';

class Billing {
  final dynamic id;
  final String? clientName;
  final String? invoiceNo;
  final String? date;
  final String? amount;
  final String? type;
  final String? category;
  final String? authorities;
  final String? status;
  final String? createdAt;
  final Map<String, dynamic>? data;

  Billing({
    this.id,
    this.clientName,
    this.invoiceNo,
    this.date,
    this.amount,
    this.type,
    this.category,
    this.authorities,
    this.status,
    this.createdAt,
    this.data,
  });

  factory Billing.fromMap(Map<String, dynamic> map) {
    dynamic parsedData;
    if (map['data'] is Map) {
      parsedData = Map<String, dynamic>.from(map['data']);
    } else if (map['data'] is String) {
      try {
        parsedData = jsonDecode(map['data']);
      } catch (_) {}
    }

    return Billing(
      id: map['id'],
      clientName: map['client_name']?.toString(),
      invoiceNo: map['invoice_no']?.toString(),
      date: map['date']?.toString(),
      amount: map['amount']?.toString(),
      type: map['type']?.toString(),
      category: map['category']?.toString(),
      authorities: map['authorities']?.toString(),
      status: map['status']?.toString(),
      createdAt: map['createdAt']?.toString() ?? map['created_at']?.toString(),
      data: parsedData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'client_name': clientName,
      'invoice_no': invoiceNo,
      'date': date,
      'amount': amount,
      'type': type,
      'category': category,
      'authorities': authorities,
      'status': status,
      'createdAt': createdAt,
      'data': data,
    };
  }

  // Helper for line items
  List<Map<String, dynamic>> get items => 
    (data?['items'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
  
  String get outstandingAmount => data?['outstanding_amount']?.toString() ?? '';
  String get amountInWords => data?['amount_in_words']?.toString() ?? '';
  String get grandTotal => data?['grand_total']?.toString() ?? '';
}
