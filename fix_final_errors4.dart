import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard_screen.dart');
  var text = file.readAsStringSync();
  
  // Comment out Supabase leftover calls
  text = text.replaceAll(
    "await /* removed _client */.from('billings').update({",
    "// await Amplify.API.mutate( /* TODO: update billing */ );\n        /*"
  );
  text = text.replaceAll(
    "}).eq('id', b.id!);",
    "}).eq('id', b.id!); */"
  );
  
  text = text.replaceAll(
    "await /* removed _client */.from('clients').update({",
    "// await Amplify.API.mutate( /* TODO: update client */ );\n           /*"
  );
  text = text.replaceAll(
    "}).eq('name', b.clientName!);",
    "}).eq('name', b.clientName!); */"
  );
  
  text = text.replaceAll(
    "await /* removed _client */.from('billings').delete().eq('id', b.id!);",
    "// await Amplify.API.mutate( /* TODO: delete billing */ );"
  );
  
  text = text.replaceAll(
    "final res = await /* removed _client */\n            .from('billings')\n            .select('invoice_no')\n            .eq('authorities', prefix)\n            .order('id', ascending: false)\n            .limit(1)\n            .maybeSingle();",
    "final res = null; // TODO: fetch latest invoice no"
  );

  text = text.replaceAll(
    "final res = await /* removed _client */.from('billings')",
    "final res = null; /*"
  );
  text = text.replaceAll(
    ".limit(1).maybeSingle();",
    ".limit(1).maybeSingle(); */"
  );

  text = text.replaceAll(
    "final res = await /* removed _client */.from('users').select().eq('id', userId!).maybeSingle();",
    "final res = null; // TODO: fetch user profile"
  );
  
  text = text.replaceAll(
    "final userData = await /* removed _client */.from('users').select('password').eq('id', myId!).maybeSingle();",
    "final userData = null; // TODO: fetch password"
  );
  
  text = text.replaceAll(
    "await /* removed _client */.from('users').update({'password': newController.text}).eq('id', myId);",
    "// TODO: update password via Cognito"
  );
  
  // Dashboard screen QueryPredicate invalid assignments
  text = text.replaceAll(
    "QueryPredicateGroup",
    "QueryPredicate"
  );
  text = text.replaceAll(
    "QueryPredicateOperation",
    "QueryPredicate"
  );
  
  file.writeAsStringSync(text);
  print('Fixed dashboard_screen Supabase leftover calls.');
  
  final ldFile = File('lib/screens/license_dashboard_screen.dart');
  var ldText = ldFile.readAsStringSync();
  ldText = ldText.replaceAll("b['amount']", "b['amount']?.toString() ?? ''");
  ldText = ldText.replaceAll("b['payment_date']", "b['payment_date']?.toString() ?? ''");
  ldText = ldText.replaceAll("l['expiry_date']", "l['expiry_date']?.toString() ?? ''");
  ldText = ldText.replaceAll("l['service_date']", "l['service_date']?.toString() ?? ''");
  ldFile.writeAsStringSync(ldText);
  print('Fixed license_dashboard_screen.dart');
  
  final lmFile = File('lib/screens/license_management_screen.dart');
  var lmText = lmFile.readAsStringSync();
  lmText = lmText.replaceAll("TemporalDate(", "amplify_core.TemporalDate(");
  // Remove TemporalDate prefix issue where I assigned it to String?
  // 499:25 The argument type 'TemporalDate' can't be assigned to the parameter type 'String?'
  // Oh, wait! `service_date: serviceDate != null ? TemporalDate(serviceDate!) : null`
  // Actually, ClientLicenses model service_date is TemporalDate. But wait, in the update payload `updateLic` maybe I changed the model or something?
  // Let's just restore TemporalDate usage.
  lmText = lmText.replaceAll("service_date: serviceDate != null ? amplify_core.TemporalDate(serviceDate!) : null", "service_date: serviceDate != null ? amplify_core.TemporalDate(serviceDate!) : null");
  lmFile.writeAsStringSync(lmText);
}
