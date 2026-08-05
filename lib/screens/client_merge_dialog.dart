import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../models/client.dart';
import '../services/backup_aware_api.dart';

class ClientMergeDialog extends StatefulWidget {
  final Client primaryClient;
  final List<Client> allClients;
  final VoidCallback onMerged;

  const ClientMergeDialog({
    super.key,
    required this.primaryClient,
    required this.allClients,
    required this.onMerged,
  });

  @override
  State<ClientMergeDialog> createState() => _ClientMergeDialogState();
}

class _ClientMergeDialogState extends State<ClientMergeDialog> {
  final _searchController = TextEditingController();
  List<Client> _filteredClients = [];
  final Set<String> _selectedIds = {};
  bool _isMerging = false;

  @override
  void initState() {
    super.initState();
    final pName = (widget.primaryClient.name ?? '').toLowerCase().trim();
    final pPhone = (widget.primaryClient.phone ?? '').toLowerCase().trim();
    final pReg = (widget.primaryClient.registrationNumber ?? '').toLowerCase().trim();

    _filteredClients = widget.allClients.where((c) {
      if (c.id == widget.primaryClient.id) return false;
      final cName = (c.name ?? '').toLowerCase().trim();
      final cPhone = (c.phone ?? '').toLowerCase().trim();
      final cReg = (c.registrationNumber ?? '').toLowerCase().trim();

      if (pPhone.isNotEmpty && pPhone == cPhone) return true;
      if (pReg.isNotEmpty && pReg == cReg) return true;
      if (pName.length > 3 && cName.length > 3) {
        if (cName.contains(pName) || pName.contains(cName)) return true;
      }
      return false;
    }).toList();
  }

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filteredClients = widget.allClients.where((c) {
        if (c.id == widget.primaryClient.id) return false;
        final name = (c.name ?? '').toLowerCase();
        final fileNo = (c.fileNo ?? '').toLowerCase();
        final regNo = (c.registrationNumber ?? '').toLowerCase();
        final phone = (c.phone ?? '').toLowerCase();
        return name.contains(q) || fileNo.contains(q) || regNo.contains(q) || phone.contains(q);
      }).toList();
    });
  }

  Future<void> _mergeSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Merge'),
        content: Text('Are you sure you want to merge ${_selectedIds.length} client(s) into ${widget.primaryClient.name}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Merge'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isMerging = true);

    try {
      final pName = widget.primaryClient.name ?? '';
      final pIdStr = widget.primaryClient.id?.toString() ?? '';
      final pIdInt = int.tryParse(pIdStr) ?? 0;

      for (var dupId in _selectedIds) {
        final dupClient = widget.allClients.firstWhere((c) => c.id.toString() == dupId);
        final dupName = dupClient.name ?? '';
        final dupIdInt = int.tryParse(dupClient.id?.toString() ?? '') ?? 0;

        // 1. ClientDocuments
        var reqDocs = ModelQueries.list(amplify_models.ClientDocuments.classType, where: amplify_models.ClientDocuments.CLIENT_NAME.eq(dupName));
        var resDocs = await Amplify.API.query(request: reqDocs).response;
        for (var doc in resDocs.data?.items.whereType<amplify_models.ClientDocuments>() ?? []) {
          await BackupAwareApi().update(doc.copyWith(client_name: pName, client_id: pIdStr));
        }

        // 2. Tasks
        var reqTasks = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.CLIENT_NAME.eq(dupName));
        var resTasks = await Amplify.API.query(request: reqTasks).response;
        for (var t in resTasks.data?.items.whereType<amplify_models.Tasks>() ?? []) {
          await BackupAwareApi().update(t.copyWith(client_name: pName));
        }

        // 3. Properties
        var reqProps = ModelQueries.list(amplify_models.Properties.classType, where: amplify_models.Properties.CLIENT_NAME.eq(dupName));
        var resProps = await Amplify.API.query(request: reqProps).response;
        for (var p in resProps.data?.items.whereType<amplify_models.Properties>() ?? []) {
          await BackupAwareApi().update(p.copyWith(client_name: pName));
        }

        // 4. ClientLicenses
        var reqLic = ModelQueries.list(amplify_models.ClientLicenses.classType, where: amplify_models.ClientLicenses.CLIENT_ID.eq(dupIdInt));
        var resLic = await Amplify.API.query(request: reqLic).response;
        for (var l in resLic.data?.items.whereType<amplify_models.ClientLicenses>() ?? []) {
          await BackupAwareApi().update(l.copyWith(client_id: pIdInt, manual_client_name: pName));
        }

        // 5. Deals
        var reqDeals = ModelQueries.list(amplify_models.Deals.classType, where: amplify_models.Deals.CLIENT_NAME.eq(dupName));
        var resDeals = await Amplify.API.query(request: reqDeals).response;
        for (var d in resDeals.data?.items.whereType<amplify_models.Deals>() ?? []) {
          await BackupAwareApi().update(d.copyWith(client_name: pName, client_id: pIdInt));
        }

        // 6. Billings
        var reqBills = ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.CLIENT_NAME.eq(dupName));
        var resBills = await Amplify.API.query(request: reqBills).response;
        for (var b in resBills.data?.items.whereType<amplify_models.Billings>() ?? []) {
          await BackupAwareApi().update(b.copyWith(client_name: pName));
        }

        // 7. DscRecords
        var reqDsc = ModelQueries.list(amplify_models.DscRecords.classType, where: amplify_models.DscRecords.CLIENT_NAME.eq(dupName));
        var resDsc = await Amplify.API.query(request: reqDsc).response;
        for (var d in resDsc.data?.items.whereType<amplify_models.DscRecords>() ?? []) {
          await BackupAwareApi().update(d.copyWith(client_name: pName));
        }

        // Delete duplicate client
        await BackupAwareApi().deleteById(amplify_models.Clients.classType, amplify_models.ClientsModelIdentifier(id: dupClient.id.toString()));
      }

      if (mounted) {
        widget.onMerged();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully merged clients!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Merge failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isMerging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Merge Clients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Primary Client: ${widget.primaryClient.name}\nSelect duplicates below to merge them into this client. All records will be transferred.',
                      style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search for duplicates...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredClients.isEmpty
                  ? const Center(child: Text('No clients found.'))
                  : ListView.builder(
                      itemCount: _filteredClients.length,
                      itemBuilder: (context, index) {
                        final c = _filteredClients[index];
                        final isSelected = _selectedIds.contains(c.id.toString());
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedIds.add(c.id.toString());
                              } else {
                                _selectedIds.remove(c.id.toString());
                              }
                            });
                          },
                          title: Text(c.name ?? 'Unknown'),
                          subtitle: Text('File: ${c.fileNo ?? "N/A"} • Phone: ${c.phone ?? "N/A"}'),
                          secondary: const Icon(Icons.person_outline),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isMerging || _selectedIds.isEmpty ? null : _mergeSelected,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isMerging 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Merge ${_selectedIds.length} Client(s)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
