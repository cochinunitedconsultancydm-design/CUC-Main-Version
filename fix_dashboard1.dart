import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  // 1. Line 1419: billing update
  content = content.replaceAll(
'''        await _client.from('billings').update({
          'status': isPaid ? 'Received' : 'Pending',
          'data': d,
        }).eq('id', b.id!);''',
'''        final reqBill = amplify_models.Billings(id: b.id.toString(), status: isPaid ? 'Received' : 'Pending', data: amplify_core.AWSJson.fromMap(d).toString());
        await Amplify.API.mutate(request: ModelMutations.update(reqBill)).response;'''
  );

  // 2. Line 1425: clients update
  content = content.replaceAll(
'''           await _client.from('clients').update({
             'balance_due': d['balance_due'],
           }).eq('name', b.clientName!);''',
'''           final q = ModelQueries.list(amplify_models.Clients.classType, where: amplify_models.Clients.NAME.eq(b.clientName!));
           final r = await Amplify.API.query(request: q).response;
           if (r.data?.items.isNotEmpty == true) {
             final clientToUpdate = amplify_models.Clients(id: r.data!.items.first!.id, balance_due: d['balance_due']);
             await Amplify.API.mutate(request: ModelMutations.update(clientToUpdate)).response;
           }'''
  );

  // 3. Line 1454: billing delete
  content = content.replaceAll(
'''        await _client.from('billings').delete().eq('id', b.id!);''',
'''        await Amplify.API.mutate(request: ModelMutations.deleteById(amplify_models.Billings.classType, amplify_models.BillingsModelIdentifier(id: b.id.toString()))).response;'''
  );

  // 4. Line 1470: billing select
  content = content.replaceAll(
'''        final res = await _client
            .from('billings')
            .select('invoice_no')
            .eq('authorities', prefix)
            .order('id', ascending: false)
            .limit(1)
            .maybeSingle();''',
'''        final q = ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.AUTHORITIES.eq(prefix));
        final r = await Amplify.API.query(request: q).response;
        final list = r.data?.items.whereType<amplify_models.Billings>().toList() ?? [];
        list.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        final res = list.isNotEmpty ? {'invoice_no': list.first.invoice_no} : null;'''
  );

  // 5. Line 1846: user select
  content = content.replaceAll(
'''      final res = await _client.from('users').select().eq('id', userId!).maybeSingle();''',
'''      final r = await Amplify.API.query(request: ModelQueries.get(amplify_models.Users.classType, amplify_models.UsersModelIdentifier(id: userId.toString()))).response;
      final res = r.data != null ? {'name': r.data!.name, 'email': r.data!.email, 'phone': r.data!.phone} : null;'''
  );

  // 6. Line 1957: password verify
  content = content.replaceAll(
'''                    final userData = await _client.from('users').select('password').eq('id', myId!).maybeSingle();''',
'''                    final uReq = await Amplify.API.query(request: ModelQueries.get(amplify_models.Users.classType, amplify_models.UsersModelIdentifier(id: myId.toString()))).response;
                    final userData = uReq.data != null ? {'password': uReq.data!.password} : null;'''
  );

  // 7. Line 1965: password update
  content = content.replaceAll(
'''                    await _client.from('users').update({'password': newController.text}).eq('id', myId);''',
'''                    await Amplify.API.mutate(request: ModelMutations.update(amplify_models.Users(id: myId.toString(), password: newController.text))).response;'''
  );

  file.writeAsStringSync(content);
  print('Fixed dashboard supabase usage!');
}
