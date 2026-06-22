import 'dart:io';

void main() {
  final lmsFile = File('lib/screens/license_management_screen.dart');
  var lmsText = lmsFile.readAsStringSync();
  lmsText = lmsText.replaceAll(
    "service_date: amplify_core.TemporalDate(DateTime.now()),",
    "service_date: DateTime.now().toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "service_date: TemporalDate(DateTime.now()),",
    "service_date: DateTime.now().toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "expiry_date: amplify_core.TemporalDate(nextExpiry),",
    "expiry_date: nextExpiry?.toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "expiry_date: TemporalDate(nextExpiry),",
    "expiry_date: nextExpiry?.toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "service_date: serviceDate != null ? amplify_core.TemporalDate(serviceDate!) : null,",
    "service_date: serviceDate?.toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "service_date: serviceDate != null ? TemporalDate(serviceDate!) : null,",
    "service_date: serviceDate?.toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "expiry_date: expiryDate != null ? amplify_core.TemporalDate(expiryDate!) : null,",
    "expiry_date: expiryDate?.toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "expiry_date: expiryDate != null ? TemporalDate(expiryDate!) : null,",
    "expiry_date: expiryDate?.toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "payment_date: amplify_core.TemporalDate(date),",
    "payment_date: date.toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(
    "payment_date: TemporalDate(date),",
    "payment_date: date.toIso8601String(),"
  );
  lmsText = lmsText.replaceAll(".compareTo(b.expiryDate", "?.compareTo(b.expiryDate");
  lmsText = lmsText.replaceAll(
    "license_type_id: license.licenseTypeId.toString(),",
    "license_type_id: int.tryParse(license.licenseTypeId.toString()),"
  );
  lmsText = lmsText.replaceAll(
    "client_id: license.clientId.toString(),",
    "client_id: int.tryParse(license.clientId.toString()),"
  );
  lmsText = lmsText.replaceAll(
    "client_id: int.tryParse(int.tryParse(license.clientId.toString()).toString()),",
    "client_id: int.tryParse(license.clientId.toString()),"
  );
  lmsFile.writeAsStringSync(lmsText);
  print('Fixed license_management_screen.dart strings');

  final cbmFile = File('lib/screens/company_bill_management_screen.dart');
  var cbmText = cbmFile.readAsStringSync();
  cbmText = cbmText.replaceAll(
    "date: amplify_models.TemporalDate(billDate!),",
    "date: billDate?.toIso8601String(),"
  );
  cbmText = cbmText.replaceAll(
    "date: TemporalDate(billDate!),",
    "date: billDate?.toIso8601String(),"
  );
  cbmText = cbmText.replaceAll(
    "payment_date: amplify_models.TemporalDate(paymentDate),",
    "payment_date: paymentDate.toIso8601String(),"
  );
  cbmText = cbmText.replaceAll(
    "payment_date: TemporalDate(paymentDate),",
    "payment_date: paymentDate.toIso8601String(),"
  );
  cbmFile.writeAsStringSync(cbmText);
  print('Fixed company_bill_management_screen.dart strings');
  
  final ldFile = File('lib/screens/license_dashboard_screen.dart');
  var ldText = ldFile.readAsStringSync();
  ldText = ldText.replaceAll("TemporalDate(_serviceDate)", "_serviceDate?.toIso8601String()");
  ldText = ldText.replaceAll("TemporalDate(_expiryDate)", "_expiryDate?.toIso8601String()");
  ldText = ldText.replaceAll("TemporalDate(paymentDate)", "paymentDate?.toIso8601String()");
  ldFile.writeAsStringSync(ldText);
  print('Fixed license_dashboard_screen.dart strings');
  
  final cfFile = File('lib/screens/client_files_dialog.dart');
  var cfText = cfFile.readAsStringSync();
  cfText = cfText.replaceAll("AWSFile.fromPath(file.path)", "AWSFile.fromPath(file.path!)");
  cfFile.writeAsStringSync(cfText);
}
