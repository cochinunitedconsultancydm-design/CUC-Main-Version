import 'dart:io';

void main() {
  final file = File('lib/screens/license_management_screen.dart');
  var content = file.readAsStringSync();
  
  // Fix ClientLicense constructor parsing (lines 268-281)
  content = content.replaceAll(
    "return ClientLicense(\\n             id: int.tryParse(row.id), // Dynamic -> int for legacy compatibility\\n             clientId: int.tryParse(row.client_id ?? ''),\\n             clientName: client.name,\\n             licenseTypeId: int.tryParse(row.license_type_id ?? ''),\\n             licenseTypeName: type['name'],\\n             serviceDate: row.service_date?.getDateTimeInUtc(),\\n             expiryDate: row.expiry_date?.getDateTimeInUtc(),\\n             fileNo: row.file_no,\\n             notes: row.notes,\\n             status: row.status,\\n             manualClientName: row.manual_client_name,\\n             createdAt: row.createdAt?.getDateTimeInUtc(),\\n           );",
    "return ClientLicense(\\n             id: int.tryParse(row.id), // Dynamic -> int for legacy compatibility\\n             clientId: int.tryParse(row.client_id ?? ''),\\n             clientName: client.name,\\n             licenseTypeId: int.tryParse(row.license_type_id ?? ''),\\n             licenseTypeName: type['name'],\\n             serviceDate: row.service_date != null ? DateTime.tryParse(row.service_date!) : null,\\n             expiryDate: row.expiry_date != null ? DateTime.tryParse(row.expiry_date!) : null,\\n             fileNo: row.file_no,\\n             notes: row.notes,\\n             status: row.status,\\n             manualClientName: row.manual_client_name,\\n           );"
  );

  // Fallback for different line endings
  content = content.replaceAll(
    "return ClientLicense(\\r\\n             id: int.tryParse(row.id), // Dynamic -> int for legacy compatibility\\r\\n             clientId: int.tryParse(row.client_id ?? ''),\\r\\n             clientName: client.name,\\r\\n             licenseTypeId: int.tryParse(row.license_type_id ?? ''),\\r\\n             licenseTypeName: type['name'],\\r\\n             serviceDate: row.service_date?.getDateTimeInUtc(),\\r\\n             expiryDate: row.expiry_date?.getDateTimeInUtc(),\\r\\n             fileNo: row.file_no,\\r\\n             notes: row.notes,\\r\\n             status: row.status,\\r\\n             manualClientName: row.manual_client_name,\\r\\n             createdAt: row.createdAt?.getDateTimeInUtc(),\\r\\n           );",
    "return ClientLicense(\\n             id: int.tryParse(row.id), // Dynamic -> int for legacy compatibility\\n             clientId: int.tryParse(row.client_id ?? ''),\\n             clientName: client.name,\\n             licenseTypeId: int.tryParse(row.license_type_id ?? ''),\\n             licenseTypeName: type['name'],\\n             serviceDate: row.service_date != null ? DateTime.tryParse(row.service_date!) : null,\\n             expiryDate: row.expiry_date != null ? DateTime.tryParse(row.expiry_date!) : null,\\n             fileNo: row.file_no,\\n             notes: row.notes,\\n             status: row.status,\\n             manualClientName: row.manual_client_name,\\n           );"
  );

  // Fix LicenseBilling constructor parsing (lines 298-306)
  content = content.replaceAll(
    "LicenseBilling(\\n           id: int.tryParse(row.id),\\n           clientLicenseId: int.tryParse(row.client_license_id ?? ''),\\n           amount: row.amount ?? 0.0,\\n           invoiceNo: row.invoice_no,\\n           paymentStatus: row.payment_status ?? 'Pending',\\n           paymentDate: row.payment_date?.getDateTimeInUtc(),\\n           createdAt: row.createdAt?.getDateTimeInUtc(),\\n         )",
    "LicenseBilling(\\n           id: int.tryParse(row.id) ?? 0,\\n           clientLicenseId: int.tryParse(row.client_license_id ?? '') ?? 0,\\n           amount: row.amount ?? 0.0,\\n           invoiceNo: row.invoice_no,\\n           status: row.payment_status ?? 'Pending',\\n           paymentDate: row.payment_date != null ? DateTime.tryParse(row.payment_date!) : null,\\n         )"
  );
  
  content = content.replaceAll(
    "LicenseBilling(\\r\\n           id: int.tryParse(row.id),\\r\\n           clientLicenseId: int.tryParse(row.client_license_id ?? ''),\\r\\n           amount: row.amount ?? 0.0,\\r\\n           invoiceNo: row.invoice_no,\\r\\n           paymentStatus: row.payment_status ?? 'Pending',\\r\\n           paymentDate: row.payment_date?.getDateTimeInUtc(),\\r\\n           createdAt: row.createdAt?.getDateTimeInUtc(),\\r\\n         )",
    "LicenseBilling(\\n           id: int.tryParse(row.id) ?? 0,\\n           clientLicenseId: int.tryParse(row.client_license_id ?? '') ?? 0,\\n           amount: row.amount ?? 0.0,\\n           invoiceNo: row.invoice_no,\\n           status: row.payment_status ?? 'Pending',\\n           paymentDate: row.payment_date != null ? DateTime.tryParse(row.payment_date!) : null,\\n         )"
  );

  file.writeAsStringSync(content);
  print('Fixed ClientLicense and LicenseBilling maps');
}
