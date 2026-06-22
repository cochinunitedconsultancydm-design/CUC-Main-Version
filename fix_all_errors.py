import re
import os

def fix_file(path, replacements):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    for target, replacement in replacements:
        if target in content:
            content = content.replace(target, replacement)
        else:
            print(f"Warning: could not find {target[:50]}... in {path}")
            
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# Fix dashboard_screen.dart
fix_file('lib/screens/dashboard_screen.dart', [
    (
'''        await _client.from('billings').update({
          'status': isPaid ? 'Received' : 'Pending',
          'data': d,
        }).eq('id', b.id!);''',
'''        final reqBill = amplify_models.Billings(id: b.id.toString(), status: isPaid ? 'Received' : 'Pending', data: amplify_core.AWSJson.fromMap(d).toString());
        await amplify_core.Amplify.API.mutate(request: amplify_core.ModelMutations.update(reqBill)).response;'''
    ),
    (
'''           await _client.from('clients').update({
             'balance_due': d['balance_due'],
           }).eq('name', b.clientName!);''',
'''           final q = amplify_core.ModelQueries.list(amplify_models.Clients.classType, where: amplify_models.Clients.NAME.eq(b.clientName!));
           final r = await amplify_core.Amplify.API.query(request: q).response;
           if (r.data?.items.isNotEmpty == true) {
             final clientToUpdate = r.data!.items.first!.copyWith(balance_due: d['balance_due'].toString());
             await amplify_core.Amplify.API.mutate(request: amplify_core.ModelMutations.update(clientToUpdate)).response;
           }'''
    ),
    (
'''        await _client.from('billings').delete().eq('id', b.id!);''',
'''        await amplify_core.Amplify.API.mutate(request: amplify_core.ModelMutations.deleteById(amplify_models.Billings.classType, amplify_models.BillingsModelIdentifier(id: b.id.toString()))).response;'''
    ),
    (
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
    ),
    (
'''      final res = await _client.from('users').select().eq('id', userId!).maybeSingle();''',
'''      final rObj = await amplify_core.Amplify.API.query(request: amplify_core.ModelQueries.get(amplify_models.Users.classType, amplify_models.UsersModelIdentifier(id: userId.toString()))).response;
      final res = rObj.data != null ? {'name': rObj.data!.name, 'email': rObj.data!.email, 'phone': rObj.data!.phone} : null;'''
    ),
    (
'''                    final userData = await _client.from('users').select('password').eq('id', myId!).maybeSingle();''',
'''                    final uReq = await amplify_core.Amplify.API.query(request: amplify_core.ModelQueries.get(amplify_models.Users.classType, amplify_models.UsersModelIdentifier(id: myId.toString()))).response;
                    final userData = uReq.data != null ? {'password': uReq.data!.password} : null;'''
    ),
    (
'''                    await _client.from('users').update({'password': newController.text}).eq('id', myId);''',
'''                    await amplify_core.Amplify.API.mutate(request: amplify_core.ModelMutations.update(amplify_models.Users(id: myId.toString(), password: newController.text))).response;'''
    )
])

# Fix admin_dashboard_screen.dart (invoiceNo -> invoice_no, clientName -> client_name)
fix_file('lib/screens/admin_dashboard_screen.dart', [
    ('b.invoiceNo', 'b.invoice_no'),
    ('b.clientName', 'b.client_name'),
    ('b.userId', 'b.user_id'),
    ('Future<GraphQLResponse<PaginatedResult<Clients>>>', 'amplify_core.GraphQLResponse<amplify_core.PaginatedResult<amplify_models.Clients>>'),
    ('Future<GraphQLResponse<PaginatedResult<Billings>>>', 'amplify_core.GraphQLResponse<amplify_core.PaginatedResult<amplify_models.Billings>>'),
    ('Future<GraphQLResponse<PaginatedResult<Deals>>>', 'amplify_core.GraphQLResponse<amplify_core.PaginatedResult<amplify_models.Deals>>'),
    ('Future<GraphQLResponse<PaginatedResult<Tasks>>>', 'amplify_core.GraphQLResponse<amplify_core.PaginatedResult<amplify_models.Tasks>>'),
    ('Future<GraphQLResponse<PaginatedResult<ActivityLogs>>>', 'amplify_core.GraphQLResponse<amplify_core.PaginatedResult<amplify_models.ActivityLogs>>'),
    ('Future<GraphQLResponse<PaginatedResult<DscRecords>>>', 'amplify_core.GraphQLResponse<amplify_core.PaginatedResult<amplify_models.DscRecords>>'),
    ('Future<GraphQLResponse<PaginatedResult<UserSessions>>>', 'amplify_core.GraphQLResponse<amplify_core.PaginatedResult<amplify_models.UserSessions>>')
])

# Fix manager_dashboard_screen.dart (amplify_core. prefix on ModelQueries)
fix_file('lib/screens/manager_dashboard_screen.dart', [
    ('amplify_core.ModelQueries', 'ModelQueries')
])

# Fix billing_screen.dart
fix_file('lib/screens/billing_screen.dart', [
    ('c.balanceDue', 'c.balance_due')
])

# Fix accountant_dashboard_screen.dart
fix_file('lib/screens/accountant_dashboard_screen.dart', [
    ('b.invoiceNo', 'b.invoice_no'),
    ('b.clientName', 'b.client_name')
])

# Fix uploaded_files_screen.dart (105: Not a constant expression)
fix_file('lib/screens/uploaded_files_screen.dart', [
    ('const BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle)', 'BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle)')
])

# Fix client_files_dialog.dart (126: AWSFile.fromFile)
fix_file('lib/screens/client_files_dialog.dart', [
    ('AWSFile.fromFile(file)', 'AWSFile.fromPath(file.path)'),
    ('final itemName = file.path.split(\'/\').last;', 'final itemName = f.path.split(\'/\').last;'),
    ('${(file.size ?? 0) ~/ 1024} KB', '${(f.size ?? 0) ~/ 1024} KB'),
    ('itemBuilder: (context, index) {', 'itemBuilder: (context, index) {\n        final f = files[index];')
])

# Fix chat_screen.dart
fix_file('lib/screens/chat_screen.dart', [
    ('onData:', 'onEvent:')
])

print("Finished fixing errors.")
