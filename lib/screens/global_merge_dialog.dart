import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../models/client.dart';
import '../services/backup_aware_api.dart';

class GlobalMergeDialog extends StatefulWidget {
  final List<Client> allClients;
  final VoidCallback onMerged;

  const GlobalMergeDialog({
    super.key,
    required this.allClients,
    required this.onMerged,
  });

  @override
  State<GlobalMergeDialog> createState() => _GlobalMergeDialogState();
}

class DuplicateGroup {
  final Client primary;
  final List<Client> duplicates;
  final String matchReason;

  DuplicateGroup({required this.primary, required this.duplicates, required this.matchReason});
}

class _GlobalMergeDialogState extends State<GlobalMergeDialog> {
  List<DuplicateGroup> _groups = [];
  final Set<int> _selectedGroupIndices = {};
  bool _isScanning = true;
  bool _isMerging = false;
  int _mergedCount = 0;

  @override
  void initState() {
    super.initState();
    _scanForDuplicates();
  }

  void _scanForDuplicates() {
    final Map<String, List<Client>> phoneMap = {};
    final Map<String, List<Client>> regMap = {};
    final Map<String, List<Client>> nameMap = {};

    for (var c in widget.allClients) {
      final phone = (c.phone ?? '').toLowerCase().trim();
      final reg = (c.registrationNumber ?? '').toLowerCase().trim();
      final name = (c.name ?? '').toLowerCase().trim();

      if (phone.isNotEmpty && phone.length > 5) {
        phoneMap.putIfAbsent(phone, () => []).add(c);
      }
      if (reg.isNotEmpty && reg.length > 2) {
        regMap.putIfAbsent(reg, () => []).add(c);
      }
      if (name.isNotEmpty && name.length > 3) {
        nameMap.putIfAbsent(name, () => []).add(c);
      }
    }

    final Set<String> processedClientIds = {};
    final List<DuplicateGroup> foundGroups = [];

    void checkMap(Map<String, List<Client>> map, String reasonPrefix) {
      for (var entry in map.entries) {
        final groupClients = entry.value.where((c) => !processedClientIds.contains(c.id.toString())).toList();
        if (groupClients.length > 1) {
          // Sort so the oldest (assumed first created) is primary, or just pick the first
          final primary = groupClients.first;
          final duplicates = groupClients.sublist(1);
          
          for (var c in groupClients) {
            processedClientIds.add(c.id.toString());
          }

          foundGroups.add(DuplicateGroup(
            primary: primary,
            duplicates: duplicates,
            matchReason: 'Matched by $reasonPrefix: ${entry.key}',
          ));
        }
      }
    }

    checkMap(phoneMap, 'Phone Number');
    checkMap(regMap, 'Registration Number');
    checkMap(nameMap, 'Exact Name');

    setState(() {
      _groups = foundGroups;
      _selectedGroupIndices.clear();
      _selectedGroupIndices.addAll(List.generate(foundGroups.length, (i) => i));
      _isScanning = false;
    });
  }

  Future<void> _mergeAll() async {
    final selectedGroups = _groups.asMap().entries.where((e) => _selectedGroupIndices.contains(e.key)).map((e) => e.value).toList();
    if (selectedGroups.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Global Merge'),
        content: Text('Are you sure you want to merge the ${selectedGroups.length} selected group(s)? This will permanently delete ${ selectedGroups.fold<int>(0, (p, g) => p + g.duplicates.length) } duplicate clients and transfer their records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Merge All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isMerging = true;
      _mergedCount = 0;
    });

    try {
      for (var group in selectedGroups) {
        final pName = group.primary.name ?? '';
        final pIdStr = group.primary.id?.toString() ?? '';
        final pIdInt = int.tryParse(pIdStr) ?? 0;

        for (var dupClient in group.duplicates) {
          final dupName = dupClient.name ?? '';
          final dupIdInt = int.tryParse(dupClient.id?.toString() ?? '') ?? 0;

          // 1. ClientDocuments
          var reqDocs = ModelQueries.list(amplify_models.ClientDocuments.classType, where: amplify_models.ClientDocuments.CLIENT_NAME.eq(dupName), limit: 10000);
          var resDocs = await Amplify.API.query(request: reqDocs).response;
          for (var doc in resDocs.data?.items.whereType<amplify_models.ClientDocuments>() ?? []) {
            await BackupAwareApi().update(doc.copyWith(client_name: pName, client_id: pIdStr));
          }

          // 2. Tasks
          var reqTasks = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.CLIENT_NAME.eq(dupName), limit: 10000);
          var resTasks = await Amplify.API.query(request: reqTasks).response;
          for (var t in resTasks.data?.items.whereType<amplify_models.Tasks>() ?? []) {
            await BackupAwareApi().update(t.copyWith(client_name: pName));
          }

          // 3. Properties
          var reqProps = ModelQueries.list(amplify_models.Properties.classType, where: amplify_models.Properties.CLIENT_NAME.eq(dupName), limit: 10000);
          var resProps = await Amplify.API.query(request: reqProps).response;
          for (var p in resProps.data?.items.whereType<amplify_models.Properties>() ?? []) {
            await BackupAwareApi().update(p.copyWith(client_name: pName));
          }

          // 4. ClientLicenses
          var reqLic = ModelQueries.list(amplify_models.ClientLicenses.classType, where: amplify_models.ClientLicenses.CLIENT_ID.eq(dupIdInt), limit: 10000);
          var resLic = await Amplify.API.query(request: reqLic).response;
          for (var l in resLic.data?.items.whereType<amplify_models.ClientLicenses>() ?? []) {
            await BackupAwareApi().update(l.copyWith(client_id: pIdInt, manual_client_name: pName));
          }

          // 5. Deals
          var reqDeals = ModelQueries.list(amplify_models.Deals.classType, where: amplify_models.Deals.CLIENT_NAME.eq(dupName), limit: 10000);
          var resDeals = await Amplify.API.query(request: reqDeals).response;
          for (var d in resDeals.data?.items.whereType<amplify_models.Deals>() ?? []) {
            await BackupAwareApi().update(d.copyWith(client_name: pName, client_id: pIdInt));
          }

          // 6. Billings
          var reqBills = ModelQueries.list(amplify_models.Billings.classType, where: amplify_models.Billings.CLIENT_NAME.eq(dupName), limit: 10000);
          var resBills = await Amplify.API.query(request: reqBills).response;
          for (var b in resBills.data?.items.whereType<amplify_models.Billings>() ?? []) {
            await BackupAwareApi().update(b.copyWith(client_name: pName));
          }

          // 7. DscRecords
          var reqDsc = ModelQueries.list(amplify_models.DscRecords.classType, where: amplify_models.DscRecords.CLIENT_NAME.eq(dupName), limit: 10000);
          var resDsc = await Amplify.API.query(request: reqDsc).response;
          for (var d in resDsc.data?.items.whereType<amplify_models.DscRecords>() ?? []) {
            await BackupAwareApi().update(d.copyWith(client_name: pName));
          }

          // Delete duplicate client
          await BackupAwareApi().deleteById(amplify_models.Clients.classType, amplify_models.ClientsModelIdentifier(id: dupClient.id.toString()));
          
          if (mounted) {
            setState(() { _mergedCount++; });
          }
        }
      }

      if (mounted) {
        widget.onMerged();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully merged $_mergedCount duplicate clients globally!'), backgroundColor: Colors.green));
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
        width: 800,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Global Duplicate Scanner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            if (_isScanning)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_groups.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text('No duplicates found!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Found ${_groups.length} group(s) of duplicates. The primary client (bold) will keep its profile, and all records from the duplicates will be transferred to it.',
                        style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _groups.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(group.matchReason, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                              Checkbox(
                                value: _selectedGroupIndices.contains(index),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedGroupIndices.add(index);
                                    } else {
                                      _selectedGroupIndices.remove(index);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Primary Client (Kept):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('${group.primary.name} (Phone: ${group.primary.phone ?? "N/A"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          const Text('Duplicates (Merged & Deleted):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ...group.duplicates.map((d) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.merge_type, size: 14, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('${d.name} (Phone: ${d.phone ?? "N/A"})', style: const TextStyle(color: Colors.redAccent, decoration: TextDecoration.lineThrough)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isMerging ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isMerging || _selectedGroupIndices.isEmpty ? null : _mergeAll,
                    icon: _isMerging 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.auto_fix_high),
                    label: Text(_isMerging ? 'Merging $_mergedCount...' : 'Merge ${_selectedGroupIndices.length} Selected Groups'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
