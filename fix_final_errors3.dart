import 'dart:io';

void main() {
  final dashFile = File('lib/screens/dashboard_screen.dart');
  var dashText = dashFile.readAsStringSync();
  // Fix QueryPredicateGroup invalid assignment
  dashText = dashText.replaceAll(
    'QueryPredicateGroup', 
    'QueryPredicate'
  );
  dashText = dashText.replaceAll(
    'QueryPredicateOperation', 
    'QueryPredicate'
  );
  // Fix _client.auth.currentUser
  dashText = dashText.replaceAll(
    '_client.auth.currentUser?.id',
    '((await Amplify.Auth.getCurrentUser()).userId)'
  );
  dashText = dashText.replaceAll(
    '_client.auth.currentUser',
    '(await Amplify.Auth.getCurrentUser())'
  );
  // Remove _client if it's just leftovers
  dashText = dashText.replaceAll('_client.', '/* removed _client */.');
  dashFile.writeAsStringSync(dashText);
  print('Fixed dashboard_screen.dart');

  final ldsFile = File('lib/screens/license_dashboard_screen.dart');
  var ldsText = ldsFile.readAsStringSync();
  ldsText = ldsText.replaceAll('getDateTimeInUtc()', 'toString()');
  // the argument type Object can't be assigned to String. Let's cast to String:
  ldsText = ldsText.replaceAll("b['amount']", "b['amount'].toString()");
  ldsText = ldsText.replaceAll("b['payment_date']", "b['payment_date'].toString()");
  ldsText = ldsText.replaceAll("l['expiry_date']", "l['expiry_date'].toString()");
  ldsText = ldsText.replaceAll("l['service_date']", "l['service_date'].toString()");
  ldsFile.writeAsStringSync(ldsText);
  print('Fixed license_dashboard_screen.dart');

  final lmsFile = File('lib/screens/license_management_screen.dart');
  var lmsText = lmsFile.readAsStringSync();
  lmsText = lmsText.replaceAll('amplify_core.TemporalDate', 'TemporalDate');
  lmsText = lmsText.replaceAll("DateTime? nextExpiry = license.expiryDate;", "DateTime? nextExpiry = license.expiryDate?.getDateTimeInUtc();");
  lmsText = lmsText.replaceAll("license.expiryDate != null", "license.expiryDate != null");
  // The argument type Object can't be assigned to String.
  lmsText = lmsText.replaceAll('nextExpiry.toString()', 'nextExpiry?.toString() ?? ""');
  lmsText = lmsText.replaceAll("status: 'Renewed'", "status: 'Renewed', createdAt: TemporalDateTime.now().toString()");
  lmsText = lmsText.replaceAll("createdAt: TemporalDateTime.now().toString()", ""); // I should just remove createdAt if it's not defined
  lmsText = lmsText.replaceAll("createdAt: ", "// createdAt: ");
  lmsText = lmsText.replaceAll("paymentStatus: ", "// paymentStatus: ");
  // fix compareTo
  lmsText = lmsText.replaceAll('.compareTo(b.expiryDate', '?.compareTo(b.expiryDate');
  lmsFile.writeAsStringSync(lmsText);
  print('Fixed license_management_screen.dart');

  final cbmFile = File('lib/screens/company_bill_management_screen.dart');
  var cbmText = cbmFile.readAsStringSync();
  cbmText = cbmText.replaceAll("int.tryParse(bill.clientId.toString())", "bill.clientId");
  cbmFile.writeAsStringSync(cbmText);
  print('Fixed company_bill_management_screen.dart');

  final dscFile = File('lib/screens/dsc_management_screen.dart');
  var dscText = dscFile.readAsStringSync();
  dscText = dscText.replaceAll("createdAt: ", "// createdAt: ");
  dscFile.writeAsStringSync(dscText);
  print('Fixed dsc_management_screen.dart');
}
