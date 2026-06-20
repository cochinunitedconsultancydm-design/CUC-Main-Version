import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/client_license.dart';
import '../models/client.dart';
import '../widgets/add_license_dialog.dart';
import 'license_management_screen.dart';
import 'client_files_dialog.dart';
import '../services/excel_service.dart';

class LicenseDashboardScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const LicenseDashboardScreen({super.key, this.onBack});

  @override
  State<LicenseDashboardScreen> createState() => _LicenseDashboardScreenState();
}

class _LicenseDashboardScreenState extends State<LicenseDashboardScreen> {
  final _client = Supabase.instance.client;
  final _excel = ExcelService();
  
  static const Map<int, String> _fallbackLicenseTypes = {
    2: 'Rent',
    4: 'FSSAI',
    5: 'Labour Registration',
    6: 'Insurance',
    7: 'Corporation License',
    8: 'PCC',
    9: 'Driving License',
    10: 'Passport',
    11: 'Health Card of Employees',
    12: 'DSC',
  };
  
  bool _isLoading = true;
  
  int _totalLicenses = 0;
  int _activeLicenses = 0;
  int _expiredLicenses = 0;
  int _expiringSoon = 0;
  double _pendingAmount = 0;
  Map<String, List<Map<String, dynamic>>> _licensesByType = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));
      
      // Fetch all license types first
      final typesRes = await _client.from('license_types').select('id, name');
      final List<Map<String, dynamic>> fetchedTypes = List<Map<String, dynamic>>.from(typesRes);

      // Fetch all licenses with their clients and types
      final licensesRes = await _client.from('client_licenses').select('''
        id, status, expiry_date, file_no, manual_client_name, license_type_id,
        clients(name),
        license_types(name)
      ''');
      
      final List<dynamic> licenses = licensesRes;
      
      int total = 0;
      int active = 0;
      int expired = 0;
      int expiringSoon = 0;
      
      Map<String, List<Map<String, dynamic>>> licensesByType = {};
      
      for (var l in licenses) {
        final map = l as Map<String, dynamic>;
        
        final String clientName = map['clients'] != null ? (map['clients'] is List ? map['clients'][0]['name'] : map['clients']['name']) : map['manual_client_name'] ?? 'Unknown';
        
        String? typeName;
        if (map['license_types'] != null) {
          typeName = (map['license_types'] is List && map['license_types'].isNotEmpty) ? map['license_types'][0]['name'] : (map['license_types'] is Map ? map['license_types']['name'] : null);
        }
        
        if (typeName == null && map['license_type_id'] != null) {
          final int tId = map['license_type_id'] as int;
          final match = fetchedTypes.where((t) => t['id'] == tId).firstOrNull;
          if (match != null) {
            typeName = match['name'];
          } else {
            typeName = _fallbackLicenseTypes[tId];
          }
        }
        
        typeName ??= 'License';
        final String fileNo = map['file_no'] ?? '-';
        
        DateTime? expiryDate;
        if (map['expiry_date'] != null) {
          expiryDate = DateTime.tryParse(map['expiry_date']);
        }
        
        final status = map['status']?.toString().toLowerCase() ?? '';
        
        bool isExpired = false;
        bool isExpiringSoon = false;
        bool isActive = false;
        
        if (expiryDate != null) {
          if (expiryDate.isBefore(now)) {
            isExpired = true;
          } else if (expiryDate.isBefore(thirtyDaysFromNow)) {
            isExpiringSoon = true;
            isActive = true;
          } else {
            isActive = true;
          }
        }
        
        if (status == 'expired') isExpired = true;
        if (status == 'active' && !isExpired && !isExpiringSoon) isActive = true;
        
        total++;
        if (isExpired) expired++;
        if (isActive) active++;
        if (isExpiringSoon) expiringSoon++;
        
        final displayData = {
          'id': map['id'],
          'clientId': map['client_id'],
          'clientName': clientName,
          'typeName': typeName,
          'fileNo': fileNo,
          'expiryDate': expiryDate,
          'isExpired': isExpired,
          'isExpiringSoon': isExpiringSoon,
        };
        
        licensesByType.putIfAbsent(typeName, () => []).add(displayData);
      }
      
      // Fetch Pending Amount
      final billingRes = await _client.from('license_billing').select('amount').eq('payment_status', 'Pending');
      double pending = 0;
      for (var b in billingRes) {
        pending += (b['amount'] as num?)?.toDouble() ?? 0.0;
      }
      
      // Sort lists within each type
      for (var key in licensesByType.keys) {
        licensesByType[key]!.sort((a, b) {
          final aDate = a['expiryDate'] as DateTime? ?? DateTime(2100);
          final bDate = b['expiryDate'] as DateTime? ?? DateTime(2100);
          return aDate.compareTo(bDate);
        });
      }
      
      if (mounted) {
        setState(() {
          _totalLicenses = total;
          _activeLicenses = active;
          _expiredLicenses = expired;
          _expiringSoon = expiringSoon;
          _pendingAmount = pending;
          
          _licensesByType = licensesByType;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching license dashboard data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportData() async {
    // Basic export functionality placeholder or call the existing export
    try {
      final res = await _client.from('client_licenses').select('*, clients(name), license_types(name)');
      final licenses = res.map((row) {
        final map = Map<String, dynamic>.from(row as Map<String, dynamic>);
        if (map['clients'] != null) {
          final c = map['clients'];
          map['client_name'] = (c is List && c.isNotEmpty) ? c[0]['name'] : (c is Map ? c['name'] : null);
        }
        if (map['license_types'] != null) {
          final lt = map['license_types'];
          map['license_type_name'] = (lt is List && lt.isNotEmpty) ? lt[0]['name'] : (lt is Map ? lt['name'] : null);
        }
        return ClientLicense.fromMap(map);
      }).toList();
      final path = await _excel.exportLicenses(licenses);
      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to $path'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1), // Indigo color similar to the screenshot icon
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'License & Agreement Dashboard',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          _buildActionButton(
            label: 'Export All',
            icon: Icons.download,
            backgroundColor: const Color(0xFF10B981), // Emerald
            onPressed: _exportData,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            label: 'Add License',
            icon: Icons.add_circle_outline,
            backgroundColor: const Color(0xFFF59E0B), // Amber
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const AddLicenseDialog(),
              );
              if (result == true) {
                _fetchDashboardData();
              }
            },
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            label: 'Manage Licenses',
            icon: Icons.settings,
            backgroundColor: const Color(0xFF6366F1), // Indigo
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.black87),
                  ),
                  body: const SafeArea(child: LicenseManagementScreen()),
                )),
              ).then((_) => _fetchDashboardData());
            },
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            label: 'Logout',
            backgroundColor: const Color(0xFF1F2937), // Dark Gray
            onPressed: () {
              // Usually handled by the main dashboard, but added here for UI completeness
            },
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(),
                const SizedBox(height: 32),
                ...(_licensesByType.keys.toList()..sort()).map((typeName) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildSection(
                      title: typeName,
                      icon: Icons.folder_open_rounded,
                      iconColor: AppTheme.primaryColor,
                      items: _licensesByType[typeName]!,
                      emptyMessage: 'No licenses in this category',
                    ),
                  );
                }),
              ],
            ),
          ),
    );
  }

  Widget _buildActionButton({
    required String label, 
    IconData? icon, 
    required Color backgroundColor, 
    required VoidCallback onPressed
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - (16 * 4)) / 5;
        
        if (constraints.maxWidth < 900) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildCard('Total Licenses', _totalLicenses.toString(), Icons.description_outlined, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), 160, 'All'),
              _buildCard('Active', _activeLicenses.toString(), Icons.shield_outlined, const Color(0xFFF0FDF4), const Color(0xFF22C55E), 160, 'Active'),
              _buildCard('Expired', _expiredLicenses.toString(), Icons.cancel_outlined, const Color(0xFFFEF2F2), const Color(0xFFEF4444), 160, 'Expired'),
              _buildCard('Expiring Soon', _expiringSoon.toString(), Icons.warning_amber_rounded, const Color(0xFFFFFBEB), const Color(0xFFF59E0B), 160, 'Expiring Soon'),
              _buildCard('Pending ₹', '₹${NumberFormat("#,##,###").format(_pendingAmount)}', Icons.attach_money, const Color(0xFFFAF5FF), const Color(0xFFA855F7), 160, null),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCard('Total Licenses', _totalLicenses.toString(), Icons.description_outlined, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), cardWidth, 'All'),
            _buildCard('Active', _activeLicenses.toString(), Icons.shield_outlined, const Color(0xFFF0FDF4), const Color(0xFF22C55E), cardWidth, 'Active'),
            _buildCard('Expired', _expiredLicenses.toString(), Icons.cancel_outlined, const Color(0xFFFEF2F2), const Color(0xFFEF4444), cardWidth, 'Expired'),
            _buildCard('Expiring Soon', _expiringSoon.toString(), Icons.warning_amber_rounded, const Color(0xFFFFFBEB), const Color(0xFFF59E0B), cardWidth, 'Expiring Soon'),
            _buildCard('Pending ₹', '₹${NumberFormat("#,##,###").format(_pendingAmount)}', Icons.attach_money, const Color(0xFFFAF5FF), const Color(0xFFA855F7), cardWidth, null),
          ],
        );
      }
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color bgColor, Color iconColor, double width, String? filterValue) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: filterValue != null ? () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            appBar: AppBar(
              title: Text('$filterValue Licenses', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            body: LicenseManagementScreen(initialFilter: filterValue),
          )));
        } : () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, dynamic>> items,
    required String emptyMessage,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  Color statusColor = Colors.green;
                  if (item['isExpired'] == true) statusColor = Colors.red;
                  else if (item['isExpiringSoon'] == true) statusColor = Colors.orange;
                  
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                    child: ListTile(
                      onTap: () {
                        if (item['clientId'] != null) {
                          showDialog(
                            context: context,
                            builder: (context) => ClientFilesDialog(
                              client: Client(id: item['clientId'], name: item['clientName'], fileNo: item['fileNo']),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client information not available for this license')));
                        }
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      title: Text(item['clientName'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('File: ${item['fileNo']}', style: const TextStyle(fontSize: 12)),
                      trailing: Text(
                        item['expiryDate'] != null ? DateFormat('dd MMM yyyy').format(item['expiryDate']) : 'N/A',
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
