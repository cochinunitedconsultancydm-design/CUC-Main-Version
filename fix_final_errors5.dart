import 'dart:io';

void main() {
  final lmsFile = File('lib/screens/license_management_screen.dart');
  var lmsText = lmsFile.readAsStringSync();
  lmsText = lmsText.replaceAll("status: 'Renewed', ,", "status: 'Renewed',");
  lmsText = lmsText.replaceAll("amplify_core.TemporalDate(", "TemporalDate(");
  lmsText = lmsText.replaceAll(
    "client_id: int.tryParse(license.clientId.toString()) ?? 0,",
    "client_id: license.clientId.toString(),"
  );
  lmsText = lmsText.replaceAll(
    "license_type_id: int.tryParse(license.licenseTypeId.toString()) ?? 0,",
    "license_type_id: license.licenseTypeId.toString(),"
  );
  lmsText = lmsText.replaceAll(
    "client_id: license.clientId,",
    "client_id: license.clientId.toString(),"
  );
  lmsText = lmsText.replaceAll(
    "license_type_id: license.licenseTypeId,",
    "license_type_id: license.licenseTypeId.toString(),"
  );
  lmsText = lmsText.replaceAll(
    "client_license_id: int.tryParse(licenseId.toString()) ?? 0,",
    "client_license_id: licenseId.toString(),"
  );
  // for any other int type errors inside license_management_screen
  lmsFile.writeAsStringSync(lmsText);
  print('Fixed license_management_screen.dart');

  final cbmFile = File('lib/screens/company_bill_management_screen.dart');
  var cbmText = cbmFile.readAsStringSync();
  cbmText = cbmText.replaceAll("bill.paymentDate?.getDateTimeInUtc()", "bill.paymentDate?.getDateTimeInUtc()"); // Wait, String doesn't have getDateTimeInUtc
  cbmText = cbmText.replaceAll("bill.paymentDate?.getDateTimeInUtc()", "DateTime.tryParse(bill.paymentDate ?? '')");
  cbmText = cbmText.replaceAll("bill.date?.getDateTimeInUtc()", "DateTime.tryParse(bill.date ?? '')");
  cbmText = cbmText.replaceAll("TemporalDate(", "amplify_models.TemporalDate("); // Wait, if amplify_models is used, maybe TemporalDate is imported via core? Let's just import amplify_flutter in company_bill_management_screen
  if (!cbmText.contains("package:amplify_flutter/amplify_flutter.dart")) {
    cbmText = cbmText.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:amplify_flutter/amplify_flutter.dart';");
  }
  cbmText = cbmText.replaceAll("amplify_models.TemporalDate", "TemporalDate");
  cbmFile.writeAsStringSync(cbmText);
  print('Fixed company_bill_management_screen.dart');

  final ldsFile = File('lib/screens/license_dashboard_screen.dart');
  var ldsText = ldsFile.readAsStringSync();
  // 105:32 - A value of type 'String?' can't be assigned to a variable of type 'DateTime?'
  // 211:24 - The argument type 'String?' can't be assigned to the parameter type 'DateTime?'
  ldsText = ldsText.replaceAll("DateTime? _serviceDate = l['service_date'];", "DateTime? _serviceDate = DateTime.tryParse(l['service_date']?.toString() ?? '');");
  ldsText = ldsText.replaceAll("DateTime? _expiryDate = l['expiry_date'];", "DateTime? _expiryDate = DateTime.tryParse(l['expiry_date']?.toString() ?? '');");
  ldsText = ldsText.replaceAll("DateTime? paymentDate = b['payment_date'];", "DateTime? paymentDate = DateTime.tryParse(b['payment_date']?.toString() ?? '');");
  ldsText = ldsText.replaceAll("TemporalDate(_serviceDate)", "_serviceDate != null ? TemporalDate(_serviceDate) : null");
  ldsText = ldsText.replaceAll("TemporalDate(_expiryDate)", "_expiryDate != null ? TemporalDate(_expiryDate) : null");
  ldsText = ldsText.replaceAll("TemporalDate(paymentDate)", "paymentDate != null ? TemporalDate(paymentDate) : null");
  if (!ldsText.contains("package:amplify_flutter/amplify_flutter.dart")) {
    ldsText = ldsText.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:amplify_flutter/amplify_flutter.dart';");
  }
  ldsFile.writeAsStringSync(ldsText);
  print('Fixed license_dashboard_screen.dart');
}
