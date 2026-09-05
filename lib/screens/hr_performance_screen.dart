import 'dart:io';
import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import '../services/logging_service.dart';
import '../services/security_service.dart';
import '../services/supabase_backup_service.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
import 'metric_details_screen.dart';

class HrPerformanceScreen extends StatefulWidget {
  const HrPerformanceScreen({super.key});

  @override
  State<HrPerformanceScreen> createState() => _HrPerformanceScreenState();
}

class _HrPerformanceScreenState extends State<HrPerformanceScreen> {
  // Tab 1: Staff Directory State
  List<Map<String, dynamic>> _staff = [];
  bool _isLoadingDirectory = true;

  // Tab 2: Time Tracker State
  String _timeTrackerPeriod = 'Today';
  String _timeTrackerSort = 'Name (A-Z)';
  DateTimeRange? _customDateRange;
  
  // Tab 3: HR Dashboard State
  List<amplify_models.StaffAttendance> _attendanceLogs = [];
  bool _isLoadingAttendance = true;
  Map<String, int> _usernameToIdMap = {};
  String _hrDashboardPeriod = 'This Month';
  DateTimeRange? _hrCustomDateRange;
  List<amplify_models.ActivityLogs> _overallLogs = [];
  bool _isLoadingOverallLogs = true;
  List<amplify_models.Billings> _overallBillings = [];
  bool _isLoadingBillings = true;
  
  @override
  void initState() {
    super.initState();
    _fetchStaff();
    _fetchAttendance();
    _loadUserMappings();
    _fetchOverallLogs();
    _fetchBillings();
  }

  double _parseCurrency(String? val) {
    if (val == null || val.isEmpty) return 0;
    return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  String _formatCurrency(double val) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);
    return format.format(val);
  }

  Future<void> _loadUserMappings() async {
    final map = await SupabaseBackupService().getUsernameToIdMap();
    if (mounted) setState(() => _usernameToIdMap = map);
  }

  Future<void> _fetchOverallLogs() async {
    if (!mounted) return;
    setState(() => _isLoadingOverallLogs = true);
    try {
      final req = ModelQueries.list(amplify_models.ActivityLogs.classType, limit: 10000, authorizationMode: APIAuthorizationType.userPools);
      final res = await Amplify.API.query(request: req).response;
      
      final supabaseLogsData = await SupabaseBackupService().getActivityLogs();
      
      if (mounted) {
        setState(() {
          List<amplify_models.ActivityLogs> amplifyLogs = (res.data?.items ?? []).whereType<amplify_models.ActivityLogs>().toList();
          
          List<amplify_models.ActivityLogs> legacyLogs = supabaseLogsData.map((sLog) {
            int? uid = sLog['user_id'];
            if (uid == null && sLog['username'] != null) {
              uid = _usernameToIdMap[sLog['username'].toString().toLowerCase()];
            }
            return amplify_models.ActivityLogs(
              id: sLog['id']?.toString() ?? '',
              user_id: uid,
              action: sLog['action']?.toString(),
              details: sLog['details']?.toString(),
              created_at: sLog['created_at']?.toString() ?? sLog['timestamp']?.toString(), 
              target_type: sLog['target_type']?.toString(),
              target_id: sLog['target_id']?.toString(),
            );
          }).toList();
          
          _overallLogs = [...amplifyLogs];
          final existingIds = amplifyLogs.map((l) => l.id).toSet();
          for (var legLog in legacyLogs) {
            if (!existingIds.contains(legLog.id)) {
              _overallLogs.add(legLog);
            }
          }
          
          _isLoadingOverallLogs = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching overall logs: $e');
      if (mounted) setState(() => _isLoadingOverallLogs = false);
    }
  }

  Future<void> _fetchBillings() async {
    if (!mounted) return;
    setState(() => _isLoadingBillings = true);
    try {
      final req = ModelQueries.list(amplify_models.Billings.classType, limit: 10000, authorizationMode: APIAuthorizationType.userPools);
      final res = await Amplify.API.query(request: req).response;
      
      final supabaseBillingsData = await SupabaseBackupService().getBillings();
      
      if (mounted) {
        setState(() {
          List<amplify_models.Billings> amplifyBillings = (res.data?.items ?? []).whereType<amplify_models.Billings>().toList();
          
          List<amplify_models.Billings> legacyBillings = supabaseBillingsData.map((sLog) {
            return amplify_models.Billings(
              id: sLog['id']?.toString() ?? '',
              client_name: sLog['client_name']?.toString(),
              invoice_no: sLog['invoice_no']?.toString(),
              date: sLog['date']?.toString(),
              amount: sLog['amount']?.toString(),
              type: sLog['type']?.toString(),
              category: sLog['category']?.toString(),
              authorities: sLog['authorities']?.toString(),
              status: sLog['status']?.toString(),
              created_at: sLog['created_at']?.toString(),
              data: sLog['data']?.toString(),
            );
          }).toList();
          
          _overallBillings = [...amplifyBillings];
          final existingIds = amplifyBillings.map((b) => b.id).toSet();
          for (var legBill in legacyBillings) {
            if (!existingIds.contains(legBill.id)) {
              _overallBillings.add(legBill);
            }
          }
          
          _isLoadingBillings = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching billings: $e');
      if (mounted) setState(() => _isLoadingBillings = false);
    }
  }

  (DateTime, DateTime?) _getPeriodBoundaries(String period, DateTimeRange? customDateRange) {
    final today = DateTime.now();
    DateTime startDate;
    DateTime? endDate;
    
    switch (period) {
      case 'This Week':
        startDate = today.subtract(Duration(days: today.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'This Month':
        startDate = DateTime(today.year, today.month, 1);
        break;
      case 'Last Month':
        startDate = DateTime(today.year, today.month - 1, 1);
        endDate = DateTime(today.year, today.month, 0, 23, 59, 59);
        break;
      case 'All Time':
        startDate = DateTime(2000, 1, 1);
        break;
      case 'Custom':
        startDate = customDateRange?.start ?? DateTime(today.year, today.month, today.day);
        if (customDateRange != null) {
          endDate = DateTime(customDateRange.end.year, customDateRange.end.month, customDateRange.end.day, 23, 59, 59);
        }
        break;
      case 'Today':
      default:
        startDate = DateTime(today.year, today.month, today.day);
        break;
    }
    return (startDate, endDate);
  }

  // ==========================================
  // SHARED UTILITIES
  // ==========================================
  Future<void> _fetchAttendance() async {
    if (!mounted) return;
    setState(() => _isLoadingAttendance = true);
    try {
      final req = ModelQueries.list(amplify_models.StaffAttendance.classType, limit: 10000, authorizationMode: APIAuthorizationType.userPools);
      final res = await Amplify.API.query(request: req).response;
      var att = (res.data?.items ?? []).whereType<amplify_models.StaffAttendance>().toList() ?? [];
      if (mounted) {
        setState(() {
          _attendanceLogs = att;
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      if (mounted) setState(() => _isLoadingAttendance = false);
    }
  }

  void _msg(String t, bool ok) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(t), backgroundColor: ok ? Colors.green : Colors.redAccent,
  ));

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.purple;
      case 'hr': return Colors.pink;
      case 'manager': return Colors.indigo;
      case 'accountant': return Colors.teal;
      case 'delivery': return Colors.orange;
      default: return AppTheme.primaryColor;
    }
  }

  // ==========================================
  // TAB 1: STAFF DIRECTORY
  // ==========================================
  Future<void> _fetchStaff() async {
    if (!mounted) return;
    setState(() => _isLoadingDirectory = true);
    try {
      final uReq = ModelQueries.list(amplify_models.Users.classType, limit: 10000, authorizationMode: APIAuthorizationType.userPools);
      final uRes = await Amplify.API.query(request: uReq).response;
      if (uRes.hasErrors) {
        _msg('GraphQL Errors: ${uRes.errors.map((e) => e.message).join(", ")}', false);
      }
      var usersResRaw = (uRes.data?.items ?? []).whereType<amplify_models.Users>().toList() ?? [];
      
      // Fallback for restrictive Amplify auth rules before backend deployment
      if (usersResRaw.length <= 1) {
        try {
          final supabaseUsers = await SupabaseBackupService().getFullUsersData();
          if (supabaseUsers.isNotEmpty) {
            usersResRaw = supabaseUsers.map((su) => amplify_models.Users(
              id: su['id']?.toString() ?? '',
              name: su['name']?.toString(),
              username: su['username']?.toString(),
              email: su['email']?.toString(),
              role: su['role']?.toString(),
              designation: su['designation']?.toString(),
              personal_phone: su['personal_phone']?.toString(),
              aadhar_card: su['aadhar_card']?.toString(),
              driving_license: su['driving_license']?.toString(),
              insurance: su['insurance']?.toString(),
              emergency_contact: su['emergency_contact']?.toString(),
              offer_letter: su['offer_letter']?.toString(),
              dob: su['dob']?.toString(),
              salary: su['salary']?.toString(),
              work_time: su['work_time']?.toString(),
              blood_group: su['blood_group']?.toString(),
              wedding_anniversary: su['wedding_anniversary']?.toString(),
              personal_email: su['personal_email']?.toString(),
              company_email: su['company_email']?.toString(),
              company_phone: su['company_phone']?.toString(),
            )).toList();
          }
        } catch (e) {
          debugPrint('Failed to fetch fallback users from Supabase: $e');
        }
      }
      
      // Deduplicate users by username, prioritizing UUID-based IDs (Cognito)
      final Map<String, amplify_models.Users> uniqueUsers = {};
      for (var u in usersResRaw) {
        final name = (u.name ?? '').toLowerCase().trim();
        if (name.isEmpty) {
          uniqueUsers[u.id] = u; // Keep if no name
          continue;
        }
        var key = (u.username ?? u.email ?? name).toLowerCase().trim();
        if (key.contains('jithasree')) key = 'jitha';
        
        if (uniqueUsers.containsKey(key)) {
          final existing = uniqueUsers[key]!;
          final isNewUuid = u.id.contains('-');
          final isExistingUuid = existing.id.contains('-');
          if (isNewUuid && !isExistingUuid) {
            uniqueUsers[key] = u;
          }
        } else {
          uniqueUsers[key] = u;
        }
      }
      var usersRes = uniqueUsers.values.toList();
      
      usersRes.sort((a, b) {
        int r = (a.role ?? '').compareTo(b.role ?? '');
        if (r != 0) return r;
        return (a.name ?? '').compareTo(b.name ?? '');
      });
      
      final sReq = ModelQueries.list(amplify_models.UserSessions.classType, limit: 10000, authorizationMode: APIAuthorizationType.userPools);
      final sRes = await Amplify.API.query(request: sReq).response;
      var sessionsRes = (sRes.data?.items ?? []).whereType<amplify_models.UserSessions>().toList() ?? [];
      
      sessionsRes.sort((a, b) {
        final dateA = a.login_time != null ? DateTime.tryParse(a.login_time!) ?? DateTime(2000) : DateTime(2000);
        final dateB = b.login_time != null ? DateTime.tryParse(b.login_time!) ?? DateTime(2000) : DateTime(2000);
        return dateB.compareTo(dateA);
      });

      final List<Map<String, dynamic>> combined = [];
      for (var u in usersRes) {
        final userSessions = sessionsRes.where((s) => s.user_id?.toString() == u.id.toString()).toList();
        final session = userSessions.isNotEmpty ? userSessions.first : null;
        
        combined.add({
          'id': u.id,
          'name': u.name,
          'username': u.username,
          'email': u.email,
          'role': u.role,
          'last_login': session?.login_time,
          'is_active': session?.is_active ?? false,
          'designation': u.designation,
          'personal_phone': u.personal_phone,
          'aadhar_card': u.aadhar_card,
          'driving_license': u.driving_license,
          'insurance': u.insurance,
          'emergency_contact': u.emergency_contact,
          'offer_letter': u.offer_letter,
          'dob': u.dob,
          'salary': u.salary,
          'work_time': u.work_time,
          'blood_group': u.blood_group,
          'wedding_anniversary': u.wedding_anniversary,
          'personal_email': u.personal_email,
          'company_email': u.company_email,
          'company_phone': u.company_phone,
        });
      }

      if (!mounted) return;
      setState(() {
        _staff = combined;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _staff = [
          {
            'id': 'local-test-1',
            'name': 'John Doe (Test)',
            'username': 'johndoe',
            'email': 'john@test.com',
            'role': 'manager',
            'is_active': true,
            'designation': 'Senior Manager',
            'personal_phone': '+1234567890',
            'salary': '85000',
          },
          {
            'id': 'local-test-2',
            'name': 'Jane Smith (Test)',
            'username': 'janesmith',
            'email': 'jane@test.com',
            'role': 'staff',
            'is_active': false,
            'designation': 'Support Staff',
            'company_phone': 'Ext 102',
            'blood_group': 'O+',
            'wedding_anniversary': '2015-05-20',
          }
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoadingDirectory = false);
    }
  }

  void _showDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        final role = user['role']?.toString() ?? 'staff';
        final color = _getRoleColor(role);
        
        Widget detailRow(IconData icon, String label, String? value, {bool isLink = false}) {
          final bool isEmpty = value == null || value.toString().trim().isEmpty;
          final String displayValue = isEmpty ? 'Not Provided' : value.toString();
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      (isLink && !isEmpty)
                        ? InkWell(
                            onTap: () async {
                              try {
                                final result = await Amplify.Storage.getUrl(path: StoragePath.fromString(value)).result;
                                final Uri url = Uri.parse(result.url.toString());
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              } catch (e) {
                                debugPrint('Error launching url: $e');
                              }
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.remove_red_eye, color: AppTheme.primaryColor, size: 16),
                                SizedBox(width: 6),
                                Text('View Document', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                              ],
                            ),
                          )
                        : Text(
                            isLink && isEmpty ? 'No document uploaded' : displayValue, 
                            style: TextStyle(
                              fontSize: 15, 
                              color: isEmpty ? Colors.grey.shade400 : Colors.black87, 
                              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                              fontWeight: FontWeight.w500
                            )
                          ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: 600,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: color.withAlpha(40),
                        child: Text(user['name']?[0] ?? '?', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name'] ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                              child: Text(role.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.black54),
                        style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(8)),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        const SizedBox(height: 16),
                        detailRow(Icons.cake, 'Date of Birth', user['dob']),
                        detailRow(Icons.favorite, 'Wedding Anniversary', user['wedding_anniversary']),
                        detailRow(Icons.bloodtype, 'Blood Group', user['blood_group']),
                        detailRow(Icons.phone_android, 'Personal Phone', user['personal_phone']),
                        detailRow(Icons.mail_outline, 'Personal Email', user['personal_email']),
                        detailRow(Icons.contact_emergency, 'Emergency Contact', user['emergency_contact']),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                        
                        const Text('Employment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        const SizedBox(height: 16),
                        detailRow(Icons.alternate_email, 'Username', user['username']),
                        detailRow(Icons.business, 'Company Email', user['email']),
                        detailRow(Icons.alternate_email, 'Secondary Company Email', user['company_email']),
                        detailRow(Icons.phone, 'Company Phone', user['company_phone']),
                        detailRow(Icons.work_outline, 'Designation', user['designation']),
                        detailRow(Icons.monetization_on, 'Salary', user['salary']),
                        detailRow(Icons.access_time, 'Work Time', user['work_time']),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                        
                        const Text('Documents & IDs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        const SizedBox(height: 16),
                        detailRow(Icons.credit_card, 'Aadhar Card', user['aadhar_card'], isLink: true),
                        detailRow(Icons.card_membership, 'Driving License', user['driving_license'], isLink: true),
                        detailRow(Icons.security, 'Insurance Upload', user['insurance'], isLink: true),
                        detailRow(Icons.document_scanner, 'Offer Letter', user['offer_letter'], isLink: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showForm([Map<String, dynamic>? user]) {
    final name = TextEditingController(text: user?['name']);
    final username = TextEditingController(text: user?['username']);
    final email = TextEditingController(text: user?['email']);
    final password = TextEditingController();
    
    final designation = TextEditingController(text: user?['designation']);
    final personalPhone = TextEditingController(text: user?['personal_phone']);
    final aadharCard = TextEditingController(text: user?['aadhar_card']);
    final drivingLicense = TextEditingController(text: user?['driving_license']);
    final insurance = TextEditingController(text: user?['insurance']);
    final emergencyContact = TextEditingController(text: user?['emergency_contact']);
    final offerLetter = TextEditingController(text: user?['offer_letter']);
    final dob = TextEditingController(text: user?['dob']);
    final weddingAnniversary = TextEditingController(text: user?['wedding_anniversary']);
    final salary = TextEditingController(text: user?['salary']);
    final workTime = TextEditingController(text: user?['work_time']);
    final bloodGroup = TextEditingController(text: user?['blood_group']);
    final personalEmail = TextEditingController(text: user?['personal_email']);
    final companyEmail = TextEditingController(text: user?['company_email']);
    final companyPhone = TextEditingController(text: user?['company_phone']);
    
    String role = user?['role'] ?? 'staff';

    InputDecoration inputDec(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    }

    Widget roleChip(String label, String value, bool isSelected, Color color, Function(String) onSelect) {
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(value),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(20) : Colors.white,
              border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    Widget sectionHeader(String title, IconData icon) {
      return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withAlpha(20), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
          ],
        ),
      );
    }

    Widget uploadField(String label, IconData icon, TextEditingController controller) {
      bool isUploading = false;
      bool isFetchingUrl = false;
      return StatefulBuilder(
        builder: (context, setUploadState) {
          return TextFormField(
            controller: controller,
            readOnly: true,
            decoration: inputDec(label, icon).copyWith(
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.text.isNotEmpty)
                    isFetchingUrl 
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                      : IconButton(
                          icon: const Icon(Icons.remove_red_eye, color: AppTheme.primaryColor),
                          tooltip: 'View Document',
                          onPressed: () async {
                            try {
                              setUploadState(() => isFetchingUrl = true);
                              final result = await Amplify.Storage.getUrl(
                                path: StoragePath.fromString(controller.text),
                              ).result;
                              final Uri url = Uri.parse(result.url.toString());
                              if (!await launchUrl(url)) {
                                _msg('Could not open document', false);
                              }
                            } catch (e) {
                              _msg('Failed to view document: $e', false);
                            } finally {
                              if (mounted) setUploadState(() => isFetchingUrl = false);
                            }
                          },
                        ),
                  isUploading 
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                    : IconButton(
                        icon: const Icon(Icons.upload_file, color: AppTheme.primaryColor),
                        tooltip: 'Upload New',
                        onPressed: () async {
                          try {
                            final result = await FilePicker.pickFiles(type: FileType.any);
                            if (result != null && result.files.single.path != null) {
                              setUploadState(() => isUploading = true);
                              final fileName = result.files.single.name;
                              final userId = user?['id'] ?? 'new_user_${DateTime.now().millisecondsSinceEpoch}';
                              final path = 'public/staff/$userId/docs/$fileName';
                              
                              await Amplify.Storage.uploadFile(
                                localFile: AWSFile.fromPath(result.files.single.path!),
                                path: StoragePath.fromString(path),
                              ).result;
        try {
          final bytes = await File(result.files.single.path!).readAsBytes();
          SupabaseBackupService().backupFileInBackground(path, bytes);
        } catch (_) {}
                              
                              setUploadState(() { controller.text = path; });
                            }
                          } catch (e) {
                            _msg('Upload failed: $e', false);
                          } finally {
                            if (mounted) setUploadState(() => isUploading = false);
                          }
                        },
                      ),
                  const SizedBox(width: 4),
                ],
              )
            ),
          );
        }
      );
    }

    Widget buildRow(List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: children.map((e) {
            bool isLast = children.last == e;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 16),
                child: e,
              ),
            );
          }).toList(),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 850),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Region
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user == null ? 'Add Staff Member' : 'Edit Staff Profile', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user == null ? 'Enter details to register a new member.' : 'Update the details for this staff member.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 24,
                        style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                      ),
                    ],
                  ),
                ),
                
                // Form Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        sectionHeader('Personal Information', Icons.person),
                        buildRow([
                          TextField(controller: name, decoration: inputDec('Full Name', Icons.person_outline_rounded), maxLength: 100),
                          TextField(controller: dob, decoration: inputDec('Date of Birth', Icons.cake), maxLength: 50),
                        ]),
                        buildRow([
                          TextField(controller: weddingAnniversary, decoration: inputDec('Wedding Anniversary', Icons.favorite), maxLength: 50),
                          TextField(controller: bloodGroup, decoration: inputDec('Blood Group', Icons.bloodtype), maxLength: 20),
                        ]),
                        buildRow([
                          TextField(controller: personalPhone, decoration: inputDec('Personal Phone', Icons.phone_android), maxLength: 50),
                          TextField(controller: personalEmail, decoration: inputDec('Personal Email', Icons.mail_outline), maxLength: 100),
                        ]),
                        buildRow([
                          TextField(controller: emergencyContact, decoration: inputDec('Emergency Contact', Icons.contact_emergency), maxLength: 100),
                          const SizedBox(),
                        ]),

                        sectionHeader('Employment Details', Icons.work),
                        buildRow([
                          TextField(controller: designation, decoration: inputDec('Designation', Icons.work_outline), maxLength: 100),
                          TextField(controller: email, decoration: inputDec('Login / Company Email', Icons.business), keyboardType: TextInputType.emailAddress, maxLength: 100),
                        ]),
                        buildRow([
                          TextField(controller: companyEmail, decoration: inputDec('Secondary Company Email', Icons.alternate_email), maxLength: 100),
                          TextField(controller: companyPhone, decoration: inputDec('Company Phone', Icons.phone), maxLength: 50),
                        ]),
                        buildRow([
                          TextField(controller: salary, decoration: inputDec('Salary', Icons.monetization_on), maxLength: 100),
                          TextField(controller: workTime, decoration: inputDec('Work Time', Icons.access_time), maxLength: 100),
                        ]),
                        
                        sectionHeader('Documents & IDs', Icons.folder_shared),
                        buildRow([
                          uploadField('Aadhar Card', Icons.credit_card, aadharCard),
                          uploadField('Driving License', Icons.card_membership, drivingLicense),
                        ]),
                        buildRow([
                          uploadField('Insurance Upload', Icons.security, insurance),
                          uploadField('Offer Letter', Icons.document_scanner, offerLetter),
                        ]),

                        sectionHeader('Authentication & Access', Icons.security),
                        buildRow([
                          TextField(controller: username, decoration: inputDec('Username', Icons.alternate_email_rounded), maxLength: 50),
                          if (user == null)
                            TextField(controller: password, decoration: inputDec('Initial Password', Icons.lock_outline_rounded), obscureText: true, maxLength: 128)
                          else
                            const SizedBox(),
                        ]),
                        
                        const Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          child: Text('Access Level (Role)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ),
                        Row(
                          children: [
                            roleChip('Admin', 'admin', role == 'admin', Colors.purple, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            roleChip('Manager', 'manager', role == 'manager', Colors.indigo, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            roleChip('Accountant', 'accountant', role == 'accountant', Colors.teal, (v) => setModalState(() => role = v)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            roleChip('HR', 'hr', role == 'hr', Colors.pink, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            roleChip('Staff', 'staff', role == 'staff', AppTheme.primaryColor, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            roleChip('Delivery', 'delivery', role == 'delivery', Colors.orange, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          foregroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (name.text.isEmpty || username.text.isEmpty || email.text.isEmpty || (user == null && password.text.isEmpty)) {
                            _msg('Please fill required fields (Name, Username, Email, Password)', false);
                            return;
                          }
                          try {
                            if (user == null) {
                              try {
                                final normalizedUser = username.text.toLowerCase().trim();
                                final userPart = normalizedUser.contains('@') ? normalizedUser.split('@')[0] : normalizedUser;
                                final loginEmail = normalizedUser.contains('@') ? normalizedUser : '$userPart@cuc.local';

                                await Amplify.Auth.signUp(
                                  username: loginEmail,
                                  password: password.text,
                                  options: SignUpOptions(
                                    userAttributes: {
                                      CognitoUserAttributeKey.email: loginEmail,
                                      CognitoUserAttributeKey.name: name.text.trim(),
                                    },
                                  ),
                                );
                                debugPrint('Created Cognito user for $loginEmail');
                              } catch (e) {
                                debugPrint('Cognito signup failed: $e');
                                if (!e.toString().contains('UsernameExistsException')) {
                                  _msg('Failed to create Cognito login: $e', false);
                                  return;
                                }
                              }

                              // SECURITY: Hash password before storing
                              final hashedPassword = SecurityService().hashPassword(password.text);
                              final newUser = amplify_models.Users(
                                name: SecurityService().sanitize(name.text, maxLength: 100),
                                username: SecurityService().sanitize(username.text, maxLength: 50),
                                email: SecurityService().sanitize(email.text, maxLength: 100),
                                password: hashedPassword,
                                role: role,
                                designation: designation.text.isNotEmpty ? designation.text : null,
                                personal_phone: personalPhone.text.isNotEmpty ? personalPhone.text : null,
                                aadhar_card: aadharCard.text.isNotEmpty ? aadharCard.text : null,
                                driving_license: drivingLicense.text.isNotEmpty ? drivingLicense.text : null,
                                insurance: insurance.text.isNotEmpty ? insurance.text : null,
                                emergency_contact: emergencyContact.text.isNotEmpty ? emergencyContact.text : null,
                                offer_letter: offerLetter.text.isNotEmpty ? offerLetter.text : null,
                                dob: dob.text.isNotEmpty ? dob.text : null,
                                salary: salary.text.isNotEmpty ? salary.text : null,
                                work_time: workTime.text.isNotEmpty ? workTime.text : null,
                                blood_group: bloodGroup.text.isNotEmpty ? bloodGroup.text : null,
                                wedding_anniversary: weddingAnniversary.text.isNotEmpty ? weddingAnniversary.text : null,
                                personal_email: personalEmail.text.isNotEmpty ? personalEmail.text : null,
                                company_email: companyEmail.text.isNotEmpty ? companyEmail.text : null,
                                company_phone: companyPhone.text.isNotEmpty ? companyPhone.text : null,
                              );
                              await BackupAwareApi().create(newUser);
                              await LoggingService().logAction(action: 'CREATE_STAFF', targetType: 'Staff', targetId: username.text, details: 'Added new staff member: ${name.text}');
                            } else {
                              final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.ID.eq(user['id'].toString()), limit: 10000, authorizationMode: APIAuthorizationType.userPools);
                              final res = await Amplify.API.query(request: req).response;
                              if (res.data?.items.isNotEmpty == true) {
                                final existing = res.data!.items.first!;
                                final updated = existing.copyWith(
                                  name: name.text,
                                  username: username.text,
                                  email: email.text,
                                  role: role,
                                  designation: designation.text,
                                  personal_phone: personalPhone.text,
                                  aadhar_card: aadharCard.text,
                                  driving_license: drivingLicense.text,
                                  insurance: insurance.text,
                                  emergency_contact: emergencyContact.text,
                                  offer_letter: offerLetter.text,
                                  dob: dob.text,
                                  salary: salary.text,
                                  work_time: workTime.text,
                                  blood_group: bloodGroup.text,
                                  wedding_anniversary: weddingAnniversary.text,
                                  personal_email: personalEmail.text,
                                  company_email: companyEmail.text,
                                  company_phone: companyPhone.text,
                                );
                                final updateRes = await BackupAwareApi().update(updated);
                                if (updateRes.hasErrors) {
                                  throw Exception(updateRes.errors.map((e) => e.message).join(', '));
                                }
                                await LoggingService().logAction(action: 'UPDATE_STAFF', targetType: 'Staff', targetId: username.text, details: 'Updated staff member: ${name.text}');
                              }
                            }
                            if (mounted) Navigator.pop(context);
                            await Future.delayed(const Duration(milliseconds: 1200));
                            _fetchStaff();
                            _msg('Saved successfully', true);
                          } catch (e) {
                            _msg('Error: $e', false);
                          }
                        },
                        icon: Icon(user == null ? Icons.add_circle_outline : Icons.save_rounded, size: 20),
                        label: Text(user == null ? 'Create Member' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword(Map<String, dynamic> user) {
    final passController = TextEditingController();
    bool isSaving = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Reset Password for ${user['name']}'),
          content: TextField(
            controller: passController,
            decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
            obscureText: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (passController.text.trim().isEmpty) return;
                if (passController.text.length < 6) {
                  _msg('Password must be at least 6 characters', false);
                  return;
                }
                setModalState(() => isSaving = true);
                try {
                  // SECURITY: Hash password before storing
                  final hashedPassword = SecurityService().hashPassword(passController.text);
                  final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.ID.eq(user['id'].toString()), limit: 10000, authorizationMode: APIAuthorizationType.userPools);
                  final res = await Amplify.API.query(request: req).response;
                  if (res.data?.items.isNotEmpty == true) {
                    final existing = res.data!.items.first!;
                    final updated = existing.copyWith(password: hashedPassword);
                    await BackupAwareApi().update(updated);
                  }
                  await LoggingService().logAction(action: 'RESET_PASSWORD', targetType: 'Staff', targetId: user['username'], details: 'Reset password for ${user['name']}');
                  if (mounted) Navigator.pop(context);
                  _msg('Password reset successfully for ${user['name']}', true);
                } catch (e) {
                  _msg('Error: $e', false);
                } finally {
                  if (mounted) setModalState(() => isSaving = false);
                }
              },
              child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(dynamic id) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Remove this staff member?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
      ],
    ));
    if (ok == true) {
      try {
        final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.ID.eq(id.toString()), limit: 10000, authorizationMode: APIAuthorizationType.userPools);
        final res = await Amplify.API.query(request: req).response;
        if (res.data?.items.isNotEmpty == true) {
          await BackupAwareApi().delete(res.data!.items.first!);
        }
        await LoggingService().logAction(action: 'DELETE_STAFF', targetType: 'Staff', targetId: id.toString(), details: 'Deleted staff member');
        _fetchStaff();
        _msg('Removed', true);
      } catch (e) { _msg('Error: $e', false); }
    }
  }

  String _getLastLoginText(dynamic lastLogin) {
    if (lastLogin == null) return 'Never logged in';
    final date = DateTime.parse(lastLogin.toString()).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 5) return 'Active now';
    if (diff.inHours < 24) return 'Active ${DateFormat('HH:mm').format(date)}';
    return 'Last seen ${DateFormat('dd MMM').format(date)}';
  }

  Widget _actionBtn(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color),
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: color.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildDirectoryTab(bool isWide) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Directory Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Add Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _isLoadingDirectory ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _staff.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = _staff[index];
                final role = s['role']?.toString() ?? 'staff';
                final color = _getRoleColor(role);
                final isActive = s['is_active'] == true;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showDetails(s),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 16),
                        child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: color.withAlpha(25),
                              child: Text(s['name']?[0] ?? '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    s['name'] ?? 'No Name',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(role.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('@${s['username']} • ${s['email'] ?? 'No Email'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        if (isWide)
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_filled_rounded, size: 14, color: isActive ? Colors.green : Colors.grey.shade400),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getLastLoginText(s['last_login']),
                                      style: TextStyle(fontSize: 13, color: isActive ? Colors.green : Colors.grey.shade600, fontWeight: isActive ? FontWeight.bold : FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _actionBtn(Icons.lock_reset_rounded, Colors.orange, 'Reset Password', () => _resetPassword(s)),
                            const SizedBox(width: 8),
                            _actionBtn(Icons.edit_rounded, Colors.blueGrey, 'Edit', () => _showForm(s)),
                            const SizedBox(width: 8),
                            _actionBtn(Icons.delete_outline_rounded, Colors.redAccent, 'Delete', () => _delete(s['id'])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                  ),
                ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05, end: 0);
              },
            ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: TIME TRACKER
  // ==========================================
  Future<DateTimeRange?> _showCompactDateRangePicker() async {
    DateTime start = _customDateRange?.start ?? DateTime.now();
    DateTime end = _customDateRange?.end ?? DateTime.now();

    return await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Select Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(start), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: start, 
                          firstDate: DateTime(2020), 
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor)),
                            child: child!,
                          ),
                        );
                        if (d != null) {
                          setDialogState(() {
                            start = d;
                            if (end.isBefore(start)) end = start;
                          });
                        }
                      },
                    ),
                    const Divider(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(end), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: end, 
                          firstDate: start, 
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor)),
                            child: child!,
                          ),
                        );
                        if (d != null) setDialogState(() => end = d);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, DateTimeRange(start: start, end: end)), 
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                  child: const Text('Apply'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<List<Map<String, dynamic>>> _fetchStaffTimeStats() async {
    final uReq = ModelQueries.list(amplify_models.Users.classType, limit: 10000, authorizationMode: APIAuthorizationType.userPools);
    final uRes = await Amplify.API.query(request: uReq).response;
    var usersResRaw = (uRes.data?.items ?? []).whereType<amplify_models.Users>().toList() ?? [];
    
    // Fallback for restrictive Amplify auth rules before backend deployment
    if (usersResRaw.length <= 1) {
      try {
        final supabaseUsers = await SupabaseBackupService().getFullUsersData();
        if (supabaseUsers.isNotEmpty) {
          usersResRaw = supabaseUsers.map((su) => amplify_models.Users(
            id: su['id']?.toString() ?? '',
            name: su['name']?.toString(),
            username: su['username']?.toString(),
            email: su['email']?.toString(),
            role: su['role']?.toString(),
          )).toList();
        }
      } catch (e) {
        debugPrint('Failed to fetch fallback users from Supabase: $e');
      }
    }
    
    final Map<String, amplify_models.Users> uniqueUsers = {};
    for (var u in usersResRaw) {
      final name = (u.name ?? '').toLowerCase().trim();
      if (name.isEmpty) {
        uniqueUsers[u.id] = u;
        continue;
      }
      var firstName = name.split(' ')[0];
      if (firstName == 'jithasree') firstName = 'jitha';
      if (uniqueUsers.containsKey(firstName)) {
        final existing = uniqueUsers[firstName]!;
        if (u.id.contains('-') && !existing.id.contains('-')) {
          uniqueUsers[firstName] = u;
        }
      } else {
        uniqueUsers[firstName] = u;
      }
    }
    
    var usersRes = uniqueUsers.values.where((u) => u.role != 'admin' && u.role != 'client').toList();
    usersRes.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    
    final today = DateTime.now();
    DateTime startDate;
    DateTime? endDate;
    
    switch (_timeTrackerPeriod) {
      case 'This Week':
        startDate = today.subtract(Duration(days: today.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'This Month':
        startDate = DateTime(today.year, today.month, 1);
        break;
      case 'Last Month':
        startDate = DateTime(today.year, today.month - 1, 1);
        endDate = DateTime(today.year, today.month, 0, 23, 59, 59);
        break;
      case 'All Time':
        startDate = DateTime(2000, 1, 1);
        break;
      case 'Custom':
        startDate = _customDateRange?.start ?? DateTime(today.year, today.month, today.day);
        if (_customDateRange != null) {
          endDate = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
        }
        break;
      case 'Today':
      default:
        startDate = DateTime(today.year, today.month, today.day);
        break;
    }
    
    final sReq = ModelQueries.list(amplify_models.UserSessions.classType, limit: 10000, authorizationMode: APIAuthorizationType.userPools);
    final sRes = await Amplify.API.query(request: sReq).response;
    var allSessions = (sRes.data?.items ?? []).whereType<amplify_models.UserSessions>().toList() ?? [];
    
    var sessionsRes = allSessions.where((s) {
      if (s.login_time == null) return false;
      final t = DateTime.tryParse(s.login_time!);
      if (t == null) return false;
      if (t.isBefore(startDate)) return false;
      if (endDate != null && t.isAfter(endDate)) return false;
      return true;
    }).toList();
    
    sessionsRes.sort((a, b) {
      final dateA = a.login_time != null ? DateTime.tryParse(a.login_time!) ?? DateTime(2000) : DateTime(2000);
      final dateB = b.login_time != null ? DateTime.tryParse(b.login_time!) ?? DateTime(2000) : DateTime(2000);
      return dateB.compareTo(dateA); // descending
    });
        
    final List<Map<String, dynamic>> combined = [];
    for (var u in usersRes) {
      int totalActive = 0;
      int totalIdle = 0;
      bool isCurrentlyActive = false;
      String currentStatus = 'Offline';
      String? lastLogin;
      String? lastLogout;

      final userSessions = sessionsRes.where((s) => s.user_id?.toString() == u.id.toString()).toList();
      
      if (userSessions.isNotEmpty) {
        lastLogin = userSessions.first.login_time;
        lastLogout = userSessions.first.logout_time;
        isCurrentlyActive = userSessions.first.is_active ?? false;
        currentStatus = isCurrentlyActive ? (userSessions.first.status ?? 'Active') : 'Offline';
        
        for (var s in userSessions) {
          totalActive += s.active_seconds ?? 0;
          totalIdle += s.idle_seconds ?? 0;
        }
      }

      combined.add({
        'id': u.id,
        'name': u.name,
        'username': u.username,
        'role': u.role,
        'login_time': lastLogin,
        'logout_time': lastLogout,
        'is_active': isCurrentlyActive,
        'status': currentStatus,
        'active_seconds': totalActive,
        'idle_seconds': totalIdle,
      });
    }
    
    combined.sort((a, b) {
      if (_timeTrackerSort == 'Status (Online First)') {
        if (a['is_active'] != b['is_active']) return a['is_active'] ? -1 : 1;
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      } else if (_timeTrackerSort == 'Most Active Time') {
        int aTime = (a['active_seconds'] ?? 0) as int;
        int bTime = (b['active_seconds'] ?? 0) as int;
        if (aTime != bTime) return bTime.compareTo(aTime);
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      } else {
        return (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase());
      }
    });
    
    return combined;
  }

  Widget _buildTimeTrackerTab(bool isWide) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Time Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _timeTrackerPeriod,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                    items: ['Today', 'This Week', 'This Month', 'Last Month', 'All Time', 'Custom'].map((String value) {
                      String displayText = value;
                      if (value == 'Custom' && _timeTrackerPeriod == 'Custom' && _customDateRange != null) {
                        if (_customDateRange!.start.isAtSameMomentAs(_customDateRange!.end)) {
                          displayText = 'On ${DateFormat('MMM dd').format(_customDateRange!.start)}';
                        } else {
                          displayText = '${DateFormat('MMM dd').format(_customDateRange!.start)} - ${DateFormat('MMM dd').format(_customDateRange!.end)}';
                        }
                      }
                      
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          displayText, 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)
                        ),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      if (val == 'Custom') {
                        final picked = await _showCompactDateRangePicker();
                        if (picked != null) {
                          setState(() {
                            _customDateRange = picked;
                            _timeTrackerPeriod = 'Custom';
                          });
                        }
                      } else if (val != null) {
                        setState(() {
                          _timeTrackerPeriod = val;
                          _customDateRange = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _timeTrackerSort,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.sort_rounded, color: AppTheme.primaryColor, size: 18),
                    items: ['Name (A-Z)', 'Most Active Time', 'Status (Online First)'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _timeTrackerSort = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                  tooltip: 'Refresh',
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchStaffTimeStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              
              final users = snapshot.data ?? [];
              if (users.isEmpty) return const Center(child: Text('No staff found.'));
              
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final u = users[index];
                  final bool isActive = u['is_active'] == true;
                  final String status = u['status'];
                  
                  Color statusColor = Colors.grey;
                  if (status == 'Active') {
                    statusColor = Colors.green;
                  } else if (status == 'Minimized') statusColor = Colors.orange;
                  else if (status == 'Idle') statusColor = Colors.redAccent;
                  
                  final activeMins = (u['active_seconds'] as int) ~/ 60;
                  final idleMins = (u['idle_seconds'] as int) ~/ 60;
                  final totalMins = activeMins + idleMins;
                  final double activeRatio = totalMins > 0 ? activeMins / totalMins : 0;

                  final lastLogin = u['login_time'] != null ? DateFormat('HH:mm').format(DateTime.parse(u['login_time']).toLocal()) : '--:--';
                  final lastLogout = u['logout_time'] != null ? DateFormat('HH:mm').format(DateTime.parse(u['logout_time']).toLocal()) : (isActive ? 'Active' : '--:--');

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: statusColor.withValues(alpha: 0.1),
                                child: Text(u['name']?[0] ?? '?', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(u['role'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: AppTheme.mutedTextColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Status', style: TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        if (isWide)
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Latest Session', style: TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                                const SizedBox(height: 4),
                                Text('$lastLogin - $lastLogout', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                              ],
                            ),
                          ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Active: ${activeMins}m', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                                  Text('Idle: ${idleMins}m', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: (activeRatio * 100).toInt() == 0 && totalMins == 0 ? 1 : (activeRatio * 100).toInt(),
                                      child: Container(height: 6, color: totalMins == 0 ? Colors.grey.shade200 : Colors.green),
                                    ),
                                    if (totalMins > 0)
                                      Expanded(
                                        flex: ((1 - activeRatio) * 100).toInt(),
                                        child: Container(height: 6, color: Colors.orange),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHRManagementTab(bool isWide) {
    if (_isLoadingDirectory || _isLoadingAttendance || _isLoadingOverallLogs || _isLoadingBillings) {
      return const Center(child: CircularProgressIndicator());
    }

    final hrStaffList = _staff.toList();
    hrStaffList.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('HR Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _hrDashboardPeriod,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                    items: ['Today', 'This Week', 'This Month', 'Last Month', 'All Time', 'Custom'].map((String value) {
                      String displayText = value;
                      if (value == 'Custom' && _hrDashboardPeriod == 'Custom' && _hrCustomDateRange != null) {
                        if (_hrCustomDateRange!.start.isAtSameMomentAs(_hrCustomDateRange!.end)) {
                          displayText = 'On ${DateFormat('MMM dd').format(_hrCustomDateRange!.start)}';
                        } else {
                          displayText = '${DateFormat('MMM dd').format(_hrCustomDateRange!.start)} - ${DateFormat('MMM dd').format(_hrCustomDateRange!.end)}';
                        }
                      }
                      
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          displayText, 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)
                        ),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      if (val == 'Custom') {
                        final picked = await _showCompactDateRangePicker();
                        if (picked != null) {
                          setState(() {
                            _hrCustomDateRange = picked;
                            _hrDashboardPeriod = 'Custom';
                          });
                        }
                      } else if (val != null) {
                        setState(() {
                          _hrDashboardPeriod = val;
                          _hrCustomDateRange = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _fetchStaff().then((_) => _fetchAttendance()).then((_) => _fetchOverallLogs()).then((_) => _fetchBillings()),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, 
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting full data migration... Please wait.')));
                    final s = SupabaseBackupService();
                    await s.importMissingClients();
                    await s.importMissingDeals();
                    await s.importMissingDocuments();
                    await s.importMissingBillings();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Migration complete! Refreshing...')));
                      _fetchOverallLogs();
                      _fetchBillings();
                    }
                  },
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Sync Legacy Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, 
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!_isLoadingOverallLogs && !_isLoadingBillings) ...[
          Builder(
            builder: (context) {
              final boundaries = _getPeriodBoundaries(_hrDashboardPeriod, _hrCustomDateRange);
              final startDate = boundaries.$1;
              final endDate = boundaries.$2;

              final filteredLogs = _overallLogs.where((l) {
                final t = (l.created_at != null ? DateTime.tryParse(l.created_at!)?.toLocal() : null) ?? l.createdAt?.getDateTimeInUtc().toLocal();
                if (t == null) return false;
                if (t.isBefore(startDate)) return false;
                if (endDate != null && t.isAfter(endDate)) return false;
                return true;
              }).toList();

              final filteredBillings = _overallBillings.where((b) {
                if (b.date == null || b.date!.isEmpty) return false;
                try {
                  final parts = b.date!.split('/');
                  if (parts.length != 3) return false;
                  final d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                  return d.isAfter(startDate.subtract(const Duration(days: 1))) && d.isBefore(endDate != null ? endDate.add(const Duration(days: 1)) : DateTime.now().add(const Duration(days: 1)));
                } catch (e) { return false; }
              }).toList();

              int totalClientsCreated = filteredLogs.where((l) => l.action == 'CLIENT_CREATED').length;
              int totalWorkFilesCreated = filteredLogs.where((l) => ['WORK_CREATED', 'WORK_FILE_CREATED'].contains(l.action)).length;
              int totalWorkStatusUpdated = filteredLogs.where((l) => ['DRAFT_SHARED', 'DRAFT_VERIFIED', 'WORK_SENT_TO_VERIFICATION', 'WORK_COMPLETED', 'WORK_UPDATED'].contains(l.action)).length;
              int totalFilesUploaded = filteredLogs.where((l) => l.action == 'FILE_UPLOADED').length;
              
              double totalBillAmountCreated = 0;
              double totalBillAmountReceived = 0;
              double totalPending = 0;
              double totalQuotationAmount = 0;
              Set<String> pendingInvoiceNos = {};
              Set<String> quotationInvoiceNos = {};

              final createdInvoiceNos = filteredLogs.where((l) => l.action == 'INVOICE_CREATED').map((l) => l.target_id).toSet();
              final createdBillings = _overallBillings.where((b) => createdInvoiceNos.contains(b.invoice_no)).toList();
              
              for (var b in createdBillings) {
                double billAmount = _parseCurrency(b.amount);
                if (b.data != null) {
                  try {
                    final dataJson = jsonDecode(b.data!);
                    if (dataJson['grand_total'] != null && dataJson['grand_total'].toString().isNotEmpty) {
                      billAmount = _parseCurrency(dataJson['grand_total'].toString());
                    }
                  } catch (_) {}
                }

                if (b.type == 'QUOTATION') {
                  totalQuotationAmount += billAmount;
                  if (b.invoice_no != null) quotationInvoiceNos.add(b.invoice_no!);
                } else {
                  bool isPending = false;
                  if (b.data != null) {
                    try {
                      final dataJson = jsonDecode(b.data!);
                      String? balDueStr = dataJson['balance_due']?.toString();
                      if (balDueStr != null && balDueStr.isNotEmpty) {
                        double p = _parseCurrency(balDueStr);
                        totalPending += p;
                        if (p > 0) isPending = true;
                      } else {
                        String? advStr = dataJson['advance_received']?.toString();
                        if (advStr == null || advStr.isEmpty || _parseCurrency(advStr) == 0) {
                          totalPending += billAmount;
                          if (billAmount > 0) isPending = true;
                        }
                      }
                    } catch (_) {}
                  } else {
                    totalPending += billAmount;
                    if (billAmount > 0) isPending = true;
                  }
                  totalBillAmountCreated += billAmount;
                  if (isPending && b.invoice_no != null) {
                    pendingInvoiceNos.add(b.invoice_no!);
                  }
                }
              }

              // Calculate received amount directly from the bills to match Created and Pending exactly
              totalBillAmountReceived = totalBillAmountCreated - totalPending;

              // Calculate Best Performer
              Map<String, int> staffScores = {};
              for (var user in hrStaffList) {
                final uname = (user['username'] ?? '').toString().toLowerCase();
                final email = (user['email'] ?? '').toString().toLowerCase();
                final name = (user['name'] ?? '').toString().toLowerCase();
                
                int? uid = _usernameToIdMap[uname] ?? _usernameToIdMap[email];
                if (uid == null) {
                  uid = _usernameToIdMap[name] ?? _usernameToIdMap[name.replaceAll(' ', '')];
                  if (uid == null) {
                    final firstName = name.split(' ').first;
                    if (firstName.length > 2) {
                      for (var entry in _usernameToIdMap.entries) {
                        if (entry.key == firstName || name.contains(entry.key) || entry.key.contains(firstName)) {
                          uid = entry.value;
                          break;
                        }
                      }
                    }
                  }
                }
                uid ??= 0;
                
                int score = filteredLogs.where((l) => l.user_id == uid).length;
                staffScores[user['name'] ?? 'Unknown'] = score;
              }
              
              String bestPerformerName = 'None';
              int bestPerformerScore = 0;
              staffScores.forEach((name, score) {
                if (score > bestPerformerScore) {
                  bestPerformerScore = score;
                  bestPerformerName = name;
                }
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (bestPerformerScore > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade600]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.emoji_events, color: Colors.white, size: 36),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('⭐ BEST PERFORMER (${_hrDashboardPeriod.toUpperCase()})', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const SizedBox(height: 6),
                                Text(
                                  bestPerformerName,
                                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('ACTIONS LOGGED', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(
                                bestPerformerScore.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isWide ? 3.0 : 2.0,
                    children: [
                      _buildMetricCard('Total Clients Created', totalClientsCreated.toString(), Icons.person_add, Colors.blue, onTap: () => _showMetricDetailsModal('Total Clients Created', filteredLogs.where((l) => l.action == 'CLIENT_CREATED').toList())),
                      _buildMetricCard('Total Work Files', totalWorkFilesCreated.toString(), Icons.folder, Colors.orange, onTap: () => _showMetricDetailsModal('Total Work Files', filteredLogs.where((l) => ['WORK_CREATED', 'WORK_FILE_CREATED'].contains(l.action)).toList())),
                      _buildMetricCard('Total Work Updated', totalWorkStatusUpdated.toString(), Icons.update, Colors.purple, onTap: () => _showMetricDetailsModal('Total Work Updated', filteredLogs.where((l) => ['DRAFT_SHARED', 'DRAFT_VERIFIED', 'WORK_SENT_TO_VERIFICATION', 'WORK_COMPLETED', 'WORK_UPDATED'].contains(l.action)).toList())),
                      _buildMetricCard('Total Files Uploaded', totalFilesUploaded.toString(), Icons.upload_file, Colors.green, onTap: () => _showMetricDetailsModal('Total Files Uploaded', filteredLogs.where((l) => l.action == 'FILE_UPLOADED').toList())),
                      _buildMetricCard('Amount Created', _formatCurrency(totalBillAmountCreated), Icons.receipt, Colors.indigo, onTap: () => _showMetricDetailsModal('Bills Created', filteredLogs.where((l) => l.action == 'INVOICE_CREATED' && !quotationInvoiceNos.contains(l.target_id)).toList())),
                      _buildMetricCard('Amount Received', _formatCurrency(totalBillAmountReceived), Icons.account_balance_wallet, Colors.teal, onTap: () => _showMetricDetailsModal('Payments Recorded', filteredLogs.where((l) => l.action == 'INVOICE_PAYMENT').toList())),
                      _buildMetricCard('Pending Bills', _formatCurrency(totalPending), Icons.pending_actions, Colors.redAccent, onTap: () => _showMetricDetailsModal('Pending Bills', filteredLogs.where((l) => l.action == 'INVOICE_CREATED' && pendingInvoiceNos.contains(l.target_id)).toList())),
                      _buildMetricCard('Quotations Value', _formatCurrency(totalQuotationAmount), Icons.request_quote, Colors.cyan, onTap: () => _showMetricDetailsModal('Quotations Created', filteredLogs.where((l) => l.action == 'INVOICE_CREATED' && quotationInvoiceNos.contains(l.target_id)).toList())),
                    ],
                  ),
                ],
              );
            }
          ),
          const SizedBox(height: 24),
        ],
        Expanded(
          child: ListView.separated(
            itemCount: hrStaffList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = hrStaffList[index];
              final role = s['role']?.toString() ?? 'staff';
              final color = _getRoleColor(role);
              
              final atts = _attendanceLogs.where((a) => a.user_id?.toString() == s['id']).toList();
              atts.sort((a, b) => (b.attendance_date ?? '').compareTo(a.attendance_date ?? ''));
              final latestAtt = atts.isNotEmpty ? atts.first : null;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: color.withAlpha(25),
                          child: Text(s['name']?[0] ?? '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(role.toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Latest Attendance', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            if (latestAtt != null) ...[
                              Text(latestAtt.attendance_date ?? 'No Date', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text('${latestAtt.check_in_time ?? '--:--'} - ${latestAtt.check_out_time ?? '--:--'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ] else ...[
                              const Text('No records', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ]
                          ],
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _buildHRInfoItem(Icons.monetization_on, 'Salary', s['salary']),
                        _buildHRInfoItem(Icons.access_time, 'Work Time', s['work_time']),
                        _buildHRInfoItem(Icons.bloodtype, 'Blood Group', s['blood_group']),
                        _buildHRInfoItem(Icons.contact_emergency, 'Emergency Contact', s['emergency_contact']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPerformanceModal(s),
                        icon: const Icon(Icons.bar_chart, size: 16),
                        label: const Text('View Performance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.withAlpha(20),
                          foregroundColor: color,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: color.withAlpha(50)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHRInfoItem(IconData icon, String label, String? value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            Text(
              (value == null || value.trim().isEmpty) ? 'N/A' : value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: value == null || value.trim().isEmpty ? Colors.grey.shade400 : Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showPerformanceModal(Map<String, dynamic> user) async {
    final uname = (user['username'] ?? '').toString().toLowerCase();
    final email = (user['email'] ?? '').toString().toLowerCase();
    final name = (user['name'] ?? '').toString().toLowerCase();

    int? supabaseUserId;
    if (uname.isNotEmpty) supabaseUserId = _usernameToIdMap[uname];
    if (supabaseUserId == null && email.isNotEmpty) supabaseUserId = _usernameToIdMap[email];
    if (supabaseUserId == null && name.isNotEmpty) {
      supabaseUserId = _usernameToIdMap[name] ?? _usernameToIdMap[name.replaceAll(' ', '')];
      if (supabaseUserId == null) {
        final firstName = name.split(' ').first;
        if (firstName.length > 2) {
          for (var entry in _usernameToIdMap.entries) {
            if (entry.key == firstName || name.contains(entry.key) || entry.key.contains(firstName)) {
              supabaseUserId = entry.value;
              break;
            }
          }
        }
      }
    }

    if (supabaseUserId == null) {
      debugPrint('Could not resolve user ID for performance tracking. Defaulting to 0 for empty state.');
      supabaseUserId = 0;
    }

    String period = _hrDashboardPeriod;
    DateTimeRange? customDateRange = _hrCustomDateRange;
    List<amplify_models.ActivityLogs> userLogs = [];
    bool isLoadingLogs = true;

    Future<void> fetchLogs(StateSetter setModalState) async {
      setModalState(() => isLoadingLogs = true);
      try {
        final boundaries = _getPeriodBoundaries(period, customDateRange);
        final startDate = boundaries.$1;
        final endDate = boundaries.$2;

        var logs = _overallLogs.where((l) {
          if (l.user_id != supabaseUserId) return false;
          final t = (l.created_at != null ? DateTime.tryParse(l.created_at!)?.toLocal() : null) ?? 
                    l.createdAt?.getDateTimeInUtc().toLocal();
          if (t == null) return false;
          if (t.isBefore(startDate)) return false;
          if (endDate != null && t.isAfter(endDate)) return false;
          return true;
        }).toList();

        setModalState(() {
          userLogs = logs;
          isLoadingLogs = false;
        });
      } catch (e) {
        debugPrint('Error fetching performance logs: $e');
        if (mounted) setModalState(() => isLoadingLogs = false);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        bool initialized = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!initialized) {
              initialized = true;
              fetchLogs(setModalState);
            }
            
            int clientsCreated = userLogs.where((l) => l.action == 'CLIENT_CREATED').length;
            int workFilesCreated = userLogs.where((l) => ['WORK_CREATED', 'WORK_FILE_CREATED'].contains(l.action)).length;
            int workStatusUpdated = userLogs.where((l) => ['DRAFT_SHARED', 'DRAFT_VERIFIED', 'WORK_SENT_TO_VERIFICATION', 'WORK_COMPLETED', 'WORK_UPDATED'].contains(l.action)).length;
            int filesUploaded = userLogs.where((l) => l.action == 'FILE_UPLOADED').length;
            
            final staffCreatedInvoiceNos = userLogs.where((l) => l.action == 'INVOICE_CREATED').map((l) => l.target_id).toSet();
            final staffBillings = _overallBillings.where((b) => staffCreatedInvoiceNos.contains(b.invoice_no)).toList();
            
            double staffAmountCreated = 0;
            double staffAmountReceived = 0;
            double staffPending = 0;
            double staffQuotationAmount = 0;
            Set<String> staffPendingInvoiceNos = {};
            Set<String> staffQuotationInvoiceNos = {};
            
            for (var b in staffBillings) {
              double billAmount = _parseCurrency(b.amount);
              if (b.data != null) {
                try {
                  final dataJson = jsonDecode(b.data!);
                  if (dataJson['grand_total'] != null && dataJson['grand_total'].toString().isNotEmpty) {
                    billAmount = _parseCurrency(dataJson['grand_total'].toString());
                  }
                } catch (_) {}
              }

              if (b.type == 'QUOTATION') {
                staffQuotationAmount += billAmount;
                if (b.invoice_no != null) staffQuotationInvoiceNos.add(b.invoice_no!);
              } else {
                bool isPending = false;
                if (b.data != null) {
                  try {
                    final dataJson = jsonDecode(b.data!);
                    String? balDueStr = dataJson['balance_due']?.toString();
                    if (balDueStr != null && balDueStr.isNotEmpty) {
                      double p = _parseCurrency(balDueStr);
                      staffPending += p;
                      if (p > 0) isPending = true;
                    } else {
                      String? advStr = dataJson['advance_received']?.toString();
                      if (advStr == null || advStr.isEmpty || _parseCurrency(advStr) == 0) {
                        staffPending += billAmount;
                        if (billAmount > 0) isPending = true;
                      }
                    }
                  } catch (_) {}
                } else {
                  staffPending += billAmount;
                  if (billAmount > 0) isPending = true;
                }
                staffAmountCreated += billAmount;
                if (isPending && b.invoice_no != null) {
                  staffPendingInvoiceNos.add(b.invoice_no!);
                }
              }
            }

            // Calculate received amount directly from the bills to match Created and Pending exactly
            staffAmountReceived = staffAmountCreated - staffPending;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Performance: ${user['name']} (ID: ${supabaseUserId == 0 ? 'None (0)' : supabaseUserId})', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filter by Period:', style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: period,
                          items: ['Today', 'This Week', 'This Month', 'Last Month', 'All Time', 'Custom'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (val) async {
                            if (val == 'Custom') {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDateRange: customDateRange,
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor)),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                customDateRange = picked;
                                period = 'Custom';
                                fetchLogs(setModalState);
                              }
                            } else if (val != null) {
                              period = val;
                              customDateRange = null;
                              fetchLogs(setModalState);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (isLoadingLogs)
                      const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
                    else
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          _buildMetricCard('Clients Created', clientsCreated.toString(), Icons.person_add, Colors.blue, onTap: () => _showMetricDetailsModal('Clients Created', userLogs.where((l) => l.action == 'CLIENT_CREATED').toList())),
                          _buildMetricCard('Work Files Created', workFilesCreated.toString(), Icons.folder, Colors.orange, onTap: () => _showMetricDetailsModal('Work Files Created', userLogs.where((l) => ['WORK_CREATED', 'WORK_FILE_CREATED'].contains(l.action)).toList())),
                          _buildMetricCard('Work Status Updated', workStatusUpdated.toString(), Icons.update, Colors.purple, onTap: () => _showMetricDetailsModal('Work Status Updated', userLogs.where((l) => ['DRAFT_SHARED', 'DRAFT_VERIFIED', 'WORK_SENT_TO_VERIFICATION', 'WORK_COMPLETED', 'WORK_UPDATED'].contains(l.action)).toList())),
                          _buildMetricCard('Files Uploaded', filesUploaded.toString(), Icons.upload_file, Colors.green, onTap: () => _showMetricDetailsModal('Files Uploaded', userLogs.where((l) => l.action == 'FILE_UPLOADED').toList())),
                          _buildMetricCard('Amount Created', _formatCurrency(staffAmountCreated), Icons.receipt, Colors.indigo, onTap: () => _showMetricDetailsModal('Bills Created', userLogs.where((l) => l.action == 'INVOICE_CREATED' && !staffQuotationInvoiceNos.contains(l.target_id)).toList())),
                          _buildMetricCard('Amount Received', _formatCurrency(staffAmountReceived), Icons.account_balance_wallet, Colors.teal, onTap: () => _showMetricDetailsModal('Payments Recorded', userLogs.where((l) => l.action == 'INVOICE_PAYMENT').toList())),
                          _buildMetricCard('Pending Bills', _formatCurrency(staffPending), Icons.pending_actions, Colors.redAccent, onTap: () => _showMetricDetailsModal('Pending Bills', userLogs.where((l) => l.action == 'INVOICE_CREATED' && staffPendingInvoiceNos.contains(l.target_id)).toList())),
                          _buildMetricCard('Quotations Value', _formatCurrency(staffQuotationAmount), Icons.request_quote, Colors.cyan, onTap: () => _showMetricDetailsModal('Quotations Created', userLogs.where((l) => l.action == 'INVOICE_CREATED' && staffQuotationInvoiceNos.contains(l.target_id)).toList())),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  void _showMetricDetailsModal(String title, List<amplify_models.ActivityLogs> logs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MetricDetailsScreen(
          title: title,
          logs: logs,
          usernameToIdMap: _usernameToIdMap,
          staffList: _staff,
          billings: _overallBillings,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String displayValue, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withAlpha(40), child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(displayValue, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                  ),
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MAIN BUILD - TABS
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: _buildHRManagementTab(isWide),
        );
      },
    );
  }
}

