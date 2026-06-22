import 'dart:io';

void main() {
  final file = File('lib/screens/manager_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  // 1. Line 1433: sort
  content = content.replaceAll(
'''        list.sort((a, b) => (a.name).compareTo(b.name));''',
'''        list.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));'''
  );

  // 2. Line 1681: history
  content = content.replaceAll(
'''            future: _client
              .from('activity_logs')
              .select('action, details, created_at')
              .ilike('details', '%${item['title']}%')
              .order('created_at', ascending: false)
              .limit(50),''',
'''            future: _fetchClientHistory(item['title'] ?? ''),'''
  );

  // Inject the _fetchClientHistory method
  if (!content.contains('_fetchClientHistory')) {
    content = content.replaceAll(
'''  void _showClientHistory(BuildContext context, Map<String, dynamic> item) {''',
'''  Future<List<Map<String, dynamic>>> _fetchClientHistory(String title) async {
    final req = amplify_core.ModelQueries.list(
      amplify_models.ActivityLogs.classType,
      where: amplify_models.ActivityLogs.DETAILS.contains(title),
    );
    final res = await amplify_core.Amplify.API.query(request: req).response;
    final logs = res.data?.items.whereType<amplify_models.ActivityLogs>().toList() ?? [];
    logs.sort((a, b) => (b.createdAt?.getDateTimeInUtc() ?? DateTime.now()).compareTo(a.createdAt?.getDateTimeInUtc() ?? DateTime.now()));
    return logs.map((l) => l.toJson()).toList();
  }

  void _showClientHistory(BuildContext context, Map<String, dynamic> item) {'''
    );
  }

  // 3. Line 1857: balance_due
  content = content.replaceAll(
'''             final updatedClient = client.copyWith(balanceDue: double.tryParse(d['balance_due'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0);''',
'''             final updatedClient = client.copyWith(balance_due: d['balance_due'].toString());'''
  );

  // 4. Line 1907: _duplicateBilling
  content = content.replaceAll(
'''        final res = null; /* await _client */
            .from('billings')
            .select('invoice_no')
            .eq('authorities', prefix)
            .order('id', ascending: false)
            .limit(1)
            .maybeSingle();''',
'''        final q = amplify_core.ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.AUTHORITIES.eq(prefix));
        final r = await amplify_core.Amplify.API.query(request: q).response;
        final billList = r.data?.items.whereType<amplify_models.Billings>().toList() ?? [];
        billList.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        final res = billList.isNotEmpty ? {'invoice_no': billList.first.invoice_no} : null;'''
  );

  file.writeAsStringSync(content);
  print('Fixed manager dashboard supabase usage!');
}
