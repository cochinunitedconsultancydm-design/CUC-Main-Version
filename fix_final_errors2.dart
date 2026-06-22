import 'dart:io';

void main() {
  final f1 = File('lib/screens/license_management_screen.dart');
  var text1 = f1.readAsStringSync();
  
  // Replace TemporalDate calls
  text1 = text1.replaceAll('amplify_models.TemporalDate', 'amplify_core.TemporalDate');
  text1 = text1.replaceAll('TemporalDate(', 'amplify_core.TemporalDate(');
  text1 = text1.replaceAll('amplify_core.amplify_core.TemporalDate', 'amplify_core.TemporalDate');
  
  // Replace getDateTimeInUtc for Strings
  text1 = text1.replaceAll('getDateTimeInUtc()', 'toString()');
  
  // Fix type assignments for license_type_id and client_id
  text1 = text1.replaceAll('license_type_id: selectedTypeId?.toString()', 'license_type_id: selectedTypeId');
  text1 = text1.replaceAll('client_id: license.clientId.toString()', 'client_id: int.tryParse(license.clientId.toString()) ?? 0');
  text1 = text1.replaceAll('license_type_id: license.licenseTypeId.toString()', 'license_type_id: int.tryParse(license.licenseTypeId.toString()) ?? 0');
  
  // Check if status is required on update
  text1 = text1.replaceAll(
    "final updateLic = amplify_models.ClientLicenses(",
    "final updateLic = amplify_models.ClientLicenses(\nstatus: license.status ?? 'Active',"
  );
  
  f1.writeAsStringSync(text1);
  print('Fixed license_management_screen.dart');
}
