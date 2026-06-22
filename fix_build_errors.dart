import 'dart:io';

void main() {
  final billingFile = File('lib/screens/billing_screen.dart');
  if (billingFile.existsSync()) {
    String billing = billingFile.readAsStringSync();
    billing = billing.replaceAll('clientObj.balanceDue', 'clientObj.balance_due');
    billingFile.writeAsStringSync(billing);
  }

  final dashFile = File('lib/screens/dashboard_screen.dart');
  if (dashFile.existsSync()) {
    String dash = dashFile.readAsStringSync();
    dash = dash.replaceAll('user.phone ??', 'user.email ??');
    dashFile.writeAsStringSync(dash);
  }
}
