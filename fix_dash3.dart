import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard_screen.dart');
  var content = file.readAsStringSync();

  // Add import
  if (!content.contains("import 'package:amplify_core/amplify_core.dart' as amplify_core;")) {
    content = content.replaceFirst("import 'package:amplify_flutter/amplify_flutter.dart';", "import 'package:amplify_flutter/amplify_flutter.dart';\nimport 'package:amplify_core/amplify_core.dart' as amplify_core;");
  }

  // 1. Line 420: amplify_core.QueryPredicateOperation
  content = content.replaceAll(
      '(dealsWhere as amplify_core.QueryPredicateOperation).and(amplify_models.Deals.RESPONSIBLE_ID.eq(userId))',
      '(dealsWhere as amplify_core.QueryPredicateOperation).and(amplify_models.Deals.RESPONSIBLE_ID.eq(userId))'); // Wait, earlier it was amplify_core...
  
  // Actually, I just need to add the import, because the original file already had `amplify_core.QueryPredicateOperation`.
  
  // 2. Line 1419:
  content = content.replaceAll(
'''        await _client.from('billings').update({
          'status': isPaid ? 'Received' : 'Pending',
          'data': d,
        }).eq('id', b.id!);''',
'''        final reqBill = amplify_models.Billings(id: b.id.toString(), status: isPaid ? 'Received' : 'Pending', data: amplify_core.AWSJson.fromMap(d).toString());
        await amplify_core.Amplify.API.mutate(request: amplify_core.ModelMutations.update(reqBill)).response;'''
  );

  // 3. Line 1424:
  content = content.replaceAll(
'''        if (b.clientName != null && b.clientName!.isNotEmpty) {
           await _client.from('clients').update({
             'balance_due': d['balance_due'],
           }).eq('name', b.clientName!);
        }''',
'''        if (b.clientName != null && b.clientName!.isNotEmpty) {
           final q = amplify_core.ModelQueries.list(amplify_models.Clients.classType, where: amplify_models.Clients.NAME.eq(b.clientName!));
           final r = await amplify_core.Amplify.API.query(request: q).response;
           if (r.data?.items.isNotEmpty == true) {
             final clientToUpdate = amplify_models.Clients(id: r.data!.items.first!.id, balance_due: d['balance_due'].toString());
             await amplify_core.Amplify.API.mutate(request: amplify_core.ModelMutations.update(clientToUpdate)).response;
           }
        }'''
  );

  // 4. Line 1454: delete
  content = content.replaceAll(
'''        await _client.from('billings').delete().eq('id', b.id!);''',
'''        await amplify_core.Amplify.API.mutate(request: amplify_core.ModelMutations.deleteById(amplify_models.Billings.classType, amplify_models.BillingsModelIdentifier(id: b.id.toString()))).response;'''
  );

  // 5. Line 1470: duplicate
  content = content.replaceAll(
'''        final res = await _client
            .from('billings')
            .select('invoice_no')
            .eq('authorities', prefix)
            .order('id', ascending: false)
            .limit(1)
            .maybeSingle();''',
'''        final q = amplify_core.ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.AUTHORITIES.eq(prefix));
        final rObj = await amplify_core.Amplify.API.query(request: q).response;
        final billList = rObj.data?.items.whereType<amplify_models.Billings>().toList() ?? [];
        billList.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        final res = billList.isNotEmpty ? {'invoice_no': billList.first.invoice_no} : null;'''
  );

  // 6. Line 1846: _buildSettingsPage
  content = content.replaceAll(
'''      final res = await _client.from('users').select().eq('id', userId!).maybeSingle();''',
'''      final rObj = await amplify_core.Amplify.API.query(request: amplify_core.ModelQueries.get(amplify_models.Users.classType, amplify_models.UsersModelIdentifier(id: userId.toString()))).response;
      final res = rObj.data != null ? {'name': rObj.data!.name, 'email': rObj.data!.email, 'phone': rObj.data!.phone} : null;'''
  );

  // 7. Line 1957
  content = content.replaceAll(
'''                    final userData = await _client.from('users').select('password').eq('id', myId!).maybeSingle();''',
'''                    final uReq = await amplify_core.Amplify.API.query(request: amplify_core.ModelQueries.get(amplify_models.Users.classType, amplify_models.UsersModelIdentifier(id: myId.toString()))).response;
                    final userData = uReq.data != null ? {'password': uReq.data!.password} : null;'''
  );

  // 8. Line 1965
  content = content.replaceAll(
'''                    await _client.from('users').update({'password': newController.text}).eq('id', myId);''',
'''                    await amplify_core.Amplify.API.mutate(request: amplify_core.ModelMutations.update(amplify_models.Users(id: myId.toString(), password: newController.text))).response;'''
  );

  file.writeAsStringSync(content);
}
