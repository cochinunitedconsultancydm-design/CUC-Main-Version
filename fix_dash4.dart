import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard_screen.dart');
  var content = file.readAsStringSync();

  // 1. var dealsWhere -> amplify_core.QueryPredicate dealsWhere
  content = content.replaceFirst(
    "var dealsWhere = amplify_models.Deals.STAGE.ne('Completed');",
    "amplify_core.QueryPredicate dealsWhere = amplify_models.Deals.STAGE.ne('Completed');"
  );
  content = content.replaceFirst(
    "var tasksWhere = amplify_models.Tasks.STATUS.ne('Completed');",
    "amplify_core.QueryPredicate tasksWhere = amplify_models.Tasks.STATUS.ne('Completed');"
  );

  // 2. _client in _recordPayment
  content = content.replaceFirst(
'''        await _client.from('billings').update({
          'status': isPaid ? 'Received' : 'Pending',
          'data': d,
        }).eq('id', b.id!);''',
'''        final reqBill = amplify_models.Billings(id: b.id.toString(), status: isPaid ? 'Received' : 'Pending', data: amplify_core.AWSJson.fromMap(d).toString());
        await amplify_core.Amplify.API.mutate(request: ModelMutations.update(reqBill)).response;'''
  );

  content = content.replaceFirst(
'''        if (b.clientName != null && b.clientName!.isNotEmpty) {
           await _client.from('clients').update({
             'balance_due': d['balance_due'],
           }).eq('name', b.clientName!);
        }''',
'''        if (b.clientName != null && b.clientName!.isNotEmpty) {
           final q = ModelQueries.list(amplify_models.Clients.classType, where: amplify_models.Clients.NAME.eq(b.clientName!));
           final r = await amplify_core.Amplify.API.query(request: q).response;
           if (r.data?.items.isNotEmpty == true) {
             final clientToUpdate = r.data!.items.first!.copyWith(balance_due: d['balance_due'].toString());
             await amplify_core.Amplify.API.mutate(request: ModelMutations.update(clientToUpdate)).response;
           }
        }'''
  );

  // 3. _client in _duplicateBilling
  content = content.replaceFirst(
'''        final res = await _client
            .from('billings')
            .select('invoice_no')
            .eq('authorities', prefix)
            .order('id', ascending: false)
            .limit(1)
            .maybeSingle();''',
'''        final q = ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.AUTHORITIES.eq(prefix));
        final rObj = await amplify_core.Amplify.API.query(request: q).response;
        final billList = rObj.data?.items.whereType<amplify_models.Billings>().toList() ?? [];
        billList.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        final res = billList.isNotEmpty ? {'invoice_no': billList.first.invoice_no} : null;'''
  );

  // 4. Also fix any amplify_core.ModelQueries and amplify_core.ModelMutations to just ModelQueries and ModelMutations
  content = content.replaceAll('amplify_core.ModelQueries', 'ModelQueries');
  content = content.replaceAll('amplify_core.ModelMutations', 'ModelMutations');

  file.writeAsStringSync(content);
  
  final file2 = File('lib/screens/manager_dashboard_screen.dart');
  var content2 = file2.readAsStringSync();
  content2 = content2.replaceAll('amplify_core.ModelQueries', 'ModelQueries');
  content2 = content2.replaceAll('amplify_core.ModelMutations', 'ModelMutations');
  file2.writeAsStringSync(content2);
}
