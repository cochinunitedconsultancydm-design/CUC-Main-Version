class LicenseBilling {
  final int id;
  final int clientLicenseId;
  final double amount;
  final String? invoiceNo;
  final String status;
  final DateTime? paymentDate;

  LicenseBilling({
    required this.id,
    required this.clientLicenseId,
    required this.amount,
    this.invoiceNo,
    required this.status,
    this.paymentDate,
  });

  factory LicenseBilling.fromMap(Map<String, dynamic> map) {
    return LicenseBilling(
      id: map['id'],
      clientLicenseId: map['client_license_id'],
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      invoiceNo: map['invoice_no'],
      status: map['payment_status'] ?? 'Pending',
      paymentDate: map['payment_date'] != null
          ? DateTime.tryParse(map['payment_date'].toString())
          : null,
    );
  }
}
