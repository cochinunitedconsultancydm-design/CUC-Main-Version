import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ModelProvider.dart' as amplify_models;
/// Lightweight Supabase backup service.
/// Mirrors critical DynamoDB data to Supabase for disaster recovery.
class SupabaseBackupService {
  static final SupabaseBackupService _instance = SupabaseBackupService._();
  factory SupabaseBackupService() => _instance;
  SupabaseBackupService._();

  static const String _supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
  static const String _supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';

  /// Table name mapping from DynamoDB model names to Supabase table names.
  static const Map<String, String> _tableMap = {
    'Clients': 'clients',
    'Billings': 'billings',
    'Tasks': 'tasks',
    'Deals': 'deals',
    'Users': 'users',
    'Messages': 'messages',
    'StaffAttendance': 'staff_attendance',
    'ClientDocuments': 'client_documents',
    'ActivityLogs': 'activity_logs',
    'InwardPosts': 'inward_posts',
    'UserSessions': 'user_sessions',
    'Notifications': 'notifications',

    'ClientLicenses': 'client_licenses',
    'LicenseTypes': 'license_types',
    'LicenseBilling': 'license_billing',
    'Contacts': 'contacts',
    'DealActivities': 'deal_activities',
  };


  /// Known columns per Supabase table — only these fields will be sent.
  /// This prevents 400 errors when DynamoDB has fields that Supabase doesn't.
  static const Map<String, List<String>> _knownColumns = {
    'users': ['id', 'username', 'password', 'role', 'name', 'created_at', 'last_seen', 'email', 'wedding_anniversary'],
    'clients': ['id', 'name', 'email', 'phone', 'address', 'city', 'state', 'pincode', 'gst', 'pan', 'category', 'status', 'created_at', 'assigned_to', 'company_name', 'data'],
    'billings': ['id', 'client_name', 'invoice_no', 'date', 'amount', 'type', 'category', 'authorities', 'status', 'created_at', 'data'],
    'tasks': ['id', 'title', 'description', 'assigned_to', 'assigned_by', 'status', 'priority', 'due_date', 'created_at', 'client_name', 'data'],
    'deals': [
      'id', 'name', 'client_id', 'client_name', 'contact_info', 'company', 
      'work_type', 'stage', 'responsible_id', 'responsible_name', 'amount', 
      'currency', 'pipeline', 'priority', 'description', 'created_at', 
      'updated_at', 'closed_at', 'is_won', 'reg_fee_required', 'files_received', 
      'contact_status', 'files_asked', 'est_amount_work', 'create_invoice_share', 
      'expense_spent', 'upload_invoice_path', 'send_to_customer', 'register_no', 
      'invoice_amount', 'payment_type', 'drive_link', 'billing_id', 'quotation_id', 
      'payment_received', 'part_payment_amount', 'noc_obtained', 'referred_by', 
      'expenses_list', 'status', 'data'
    ],
    'messages': ['id', 'sender', 'receiver', 'content', 'timestamp', 'read', 'data'],
    'staff_attendance': ['id', 'user_id', 'check_in_time', 'check_out_time', 'attendance_date', 'data'],
    'client_documents': ['id', 'client_name', 'document_name', 'file_url', 'uploaded_by', 'uploaded_at', 'data'],
    'activity_logs': ['id', 'username', 'action', 'details', 'timestamp', 'data'],
    'inward_posts': ['id', 'date', 'from_whom', 'to_whom', 'subject', 'reference_no', 'data'],
    'user_sessions': ['id', 'username', 'session_start', 'session_end', 'duration', 'data'],
    'notifications': ['id', 'user_id', 'title', 'message', 'type', 'is_read', 'created_at', 'deal_id', 'task_id', 'data'],
    'client_licenses': ['id', 'client_name', 'license_type', 'license_number', 'issue_date', 'expiry_date', 'status', 'data'],
    'license_types': ['id', 'name', 'description', 'data'],
    'license_billing': ['id', 'client_name', 'license_type', 'amount', 'date', 'status', 'data'],
    'contacts': ['id', 'name', 'email', 'phone', 'company', 'designation', 'data'],
    'deal_activities': ['id', 'deal_id', 'type', 'title', 'description', 'created_by', 'created_at', 'due_date', 'is_completed', 'data'],
  };

  Map<String, String> get _headers => {
        'apikey': _supabaseKey,
        'Authorization': 'Bearer $_supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates',
      };

  /// Filter data to only include columns that exist in the Supabase table.
  Map<String, dynamic> _filterToKnownColumns(String table, Map<String, dynamic> data) {
    final known = _knownColumns[table];
    if (known == null) return data; // No whitelist, send as-is
    final filtered = <String, dynamic>{};
    for (final key in known) {
      if (data.containsKey(key)) {
        filtered[key] = data[key];
      }
    }
    return filtered;
  }

  /// Backup a single record to Supabase (upsert).
  /// [modelName] is the DynamoDB model name (e.g. 'Clients').
  /// [data] is a Map of the record fields.
  Future<bool> backupRecord(String modelName, Map<String, dynamic> data, {int retryCount = 0}) async {
    final table = _tableMap[modelName];
    if (table == null) {
      debugPrint('Supabase backup: No mapping for $modelName');
      return false;
    }

    try {
      // Clean data: remove Amplify-specific fields
      final cleanData = Map<String, dynamic>.from(data)
        ..remove('__typename')
        ..remove('createdAt')
        ..remove('updatedAt');

      if (modelName == 'Users' && cleanData['password'] == null) {
        cleanData['password'] = 'managed_by_cognito';
      }

      // Convert ID to int if it's a numeric string (Supabase uses int IDs for some tables)
      if (cleanData['id'] != null) {
        final idVal = int.tryParse(cleanData['id'].toString());
        if (idVal != null) {
          cleanData['id'] = idVal;
        } else {
          // Keep UUIDs for tables that use UUID primary keys.
          // Drop UUIDs for tables like Notifications, ActivityLogs that use BIGSERIAL integer IDs.
          final uuidTables = ['Deals', 'Tasks', 'Contacts', 'ClientLicenses', 'LicenseTypes', 'DealActivities', 'Billings'];
          if (uuidTables.contains(modelName)) {
            cleanData['id'] = cleanData['id'].toString();
          } else {
            cleanData.remove('id');
          }
        }
      }

      // Filter to only include columns that exist in the Supabase table
      final filteredData = _filterToKnownColumns(table, cleanData);

      String url = '$_supabaseUrl/rest/v1/$table';
      if (modelName == 'Users') {
        url += '?on_conflict=username';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(filteredData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        if (retryCount < 3 && response.statusCode == 409 && response.body.contains('23503')) {
          final resolved = await _resolveForeignKeyAndRetry(modelName, data, response.body, retryCount);
          if (resolved) return true;
        }
        debugPrint('Supabase backup failed for $modelName: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Supabase backup error for $modelName: $e');
      return false;
    }
  }

  /// Backup multiple records to Supabase (batch upsert).
  Future<bool> backupRecords(String modelName, List<Map<String, dynamic>> records, {int retryCount = 0}) async {
    final table = _tableMap[modelName];
    if (table == null) return false;

    try {
      final cleanRecords = records.map((data) {
        final clean = Map<String, dynamic>.from(data)
          ..remove('__typename')
          ..remove('createdAt')
          ..remove('updatedAt');
        
        if (modelName == 'Users' && clean['password'] == null) {
          clean['password'] = 'managed_by_cognito';
        }

        if (clean['id'] != null) {
          final idVal = int.tryParse(clean['id'].toString());
          if (idVal != null) {
            clean['id'] = idVal;
          } else {
            final uuidTables = ['Deals', 'Tasks', 'Contacts', 'ClientLicenses', 'LicenseTypes', 'DealActivities', 'Billings'];
            if (uuidTables.contains(modelName)) {
              clean['id'] = clean['id'].toString();
            } else {
              clean.remove('id');
            }
          }
        }
        return clean;
      }).toList();

      // Filter to only include columns that exist in the Supabase table
      final filteredRecords = cleanRecords.map((r) => _filterToKnownColumns(table, r)).toList();

      String url = '$_supabaseUrl/rest/v1/$table';
      if (modelName == 'Users') {
        url += '?on_conflict=username';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(filteredRecords),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Supabase backup: ${records.length} records backed up to $table');
        return true;
      } else {
        debugPrint('Supabase batch backup failed for $modelName: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Supabase batch backup error for $modelName: $e');
      return false;
    }
  }

  Future<bool> _resolveForeignKeyAndRetry(String modelName, Map<String, dynamic> data, String errorBody, int retryCount) async {
    try {
      bool resolvedAny = false;

      // 1. Deal
      if ((errorBody.contains('deal_id') || errorBody.contains('deals')) && data['deal_id'] != null) {
        final dealIdStr = data['deal_id'].toString();
        debugPrint('Supabase backup: resolving missing foreign key deal_id = $dealIdStr');
        final req = ModelQueries.list(amplify_models.Deals.classType, where: amplify_models.Deals.ID.eq(dealIdStr), limit: 10000);
        final res = await Amplify.API.query(request: req).response;
        final items = (res.data?.items ?? []).whereType<amplify_models.Deals>().toList() ?? [];
        if (items.isNotEmpty) {
          final parentBackedUp = await backupRecord('Deals', items.first.toJson(), retryCount: retryCount + 1);
          if (parentBackedUp) resolvedAny = true;
        } else {
          debugPrint('Supabase backup: Deal $dealIdStr not found in Amplify.');
        }
      }

      // 2. Task
      if ((errorBody.contains('task_id') || errorBody.contains('tasks')) && data['task_id'] != null) {
        final taskIdStr = data['task_id'].toString();
        debugPrint('Supabase backup: resolving missing foreign key task_id = $taskIdStr');
        final req = ModelQueries.list(amplify_models.Tasks.classType, where: amplify_models.Tasks.ID.eq(taskIdStr), limit: 10000);
        final res = await Amplify.API.query(request: req).response;
        final items = (res.data?.items ?? []).whereType<amplify_models.Tasks>().toList() ?? [];
        if (items.isNotEmpty) {
          final parentBackedUp = await backupRecord('Tasks', items.first.toJson(), retryCount: retryCount + 1);
          if (parentBackedUp) resolvedAny = true;
        } else {
          debugPrint('Supabase backup: Task $taskIdStr not found in Amplify.');
        }
      }

      // 3. Client
      if (errorBody.contains('clients') || errorBody.contains('client_id') || errorBody.contains('client_name')) {
        dynamic clientIdVal = data['client_id'] ?? data['client_name'];
        if (clientIdVal != null) {
          final clientStr = clientIdVal.toString();
          debugPrint('Supabase backup: resolving missing foreign key client = $clientStr');
          var req = ModelQueries.list(amplify_models.Clients.classType, where: amplify_models.Clients.ID.eq(clientStr), limit: 10000);
          var res = await Amplify.API.query(request: req).response;
          var items = (res.data?.items ?? []).whereType<amplify_models.Clients>().toList() ?? [];
          if (items.isEmpty) {
            req = ModelQueries.list(amplify_models.Clients.classType, where: amplify_models.Clients.NAME.eq(clientStr), limit: 10000);
            res = await Amplify.API.query(request: req).response;
            items = (res.data?.items ?? []).whereType<amplify_models.Clients>().toList() ?? [];
          }
          if (items.isNotEmpty) {
            final parentBackedUp = await backupRecord('Clients', items.first.toJson(), retryCount: retryCount + 1);
            if (parentBackedUp) resolvedAny = true;
          } else {
            debugPrint('Supabase backup: Client $clientStr not found in Amplify.');
          }
        }
      }

      // 4. User
      if (errorBody.contains('users') || errorBody.contains('user_id') || errorBody.contains('assigned_to') || errorBody.contains('responsible_id') || errorBody.contains('created_by')) {
        dynamic missingUserId = data['user_id'] ?? data['assigned_to'] ?? data['responsible_id'] ?? data['created_by'];
        if (missingUserId != null) {
          final userIdStr = missingUserId.toString();
          debugPrint('Supabase backup: resolving missing foreign key user_id = $userIdStr');
          final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.ID.eq(userIdStr), limit: 10000);
          final res = await Amplify.API.query(request: req).response;
          final items = (res.data?.items ?? []).whereType<amplify_models.Users>().toList() ?? [];
          if (items.isNotEmpty) {
            final parentBackedUp = await backupRecord('Users', items.first.toJson(), retryCount: retryCount + 1);
            if (parentBackedUp) resolvedAny = true;
          } else {
            debugPrint('Supabase backup: User $userIdStr not found in Amplify.');
          }
        }
      }

      if (resolvedAny) {
        debugPrint('Supabase backup: resolved parent record(s). Retrying backup for $modelName...');
        return await backupRecord(modelName, data, retryCount: retryCount + 1);
      }
    } catch (e) {
      debugPrint('Supabase backup: error during foreign key resolution: $e');
    }
    return false;
  }

  /// Delete a record from Supabase backup.
  Future<bool> deleteRecord(String modelName, dynamic id) async {
    final table = _tableMap[modelName];
    if (table == null) return false;

    // Do not attempt to delete by UUID since Supabase uses integer IDs
    if (int.tryParse(id.toString()) == null) {
      return true; // Skip gracefully
    }

    try {
      final response = await http.delete(
        Uri.parse('$_supabaseUrl/rest/v1/$table?id=eq.$id'),
        headers: _headers,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Supabase delete backup error: $e');
      return false;
    }
  }

  /// Check if Supabase is reachable.
  Future<bool> isAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/users?select=id&limit=1'),
        headers: {'apikey': _supabaseKey, 'Authorization': 'Bearer $_supabaseKey'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Imports missing billings from Supabase to Amplify.
  Future<void> importMissingBillings() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/billings?select=*'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> sbBillings = json.decode(response.body);
        
        // Fetch existing Amplify billings
        var req = ModelQueries.list(amplify_models.Billings.classType, limit: 10000);
        var res = await Amplify.API.query(request: req).response;
        final existingIds = (res.data?.items ?? []).map((b) => b?.id).toSet();
        
        int importedCount = 0;
        for (var sbData in sbBillings) {
          final String sbId = sbData['id'].toString();
          if (!existingIds.contains(sbId)) {
            final newBilling = amplify_models.Billings(
              id: sbId,
              client_name: sbData['client_name']?.toString(),
              invoice_no: sbData['invoice_no']?.toString(),
              date: sbData['date']?.toString(),
              amount: sbData['amount']?.toString(),
              type: sbData['type']?.toString(),
              category: sbData['category']?.toString(),
              authorities: sbData['authorities']?.toString(),
              status: sbData['status']?.toString(),
              created_at: sbData['created_at']?.toString(),
              data: sbData['data'] != null ? (sbData['data'] is String ? sbData['data'] : jsonEncode(sbData['data'])) : null,
            );
            final mutReq = ModelMutations.create(newBilling);
            await Amplify.API.mutate(request: mutReq).response;
            importedCount++;
          }
        }
        debugPrint('Successfully imported $importedCount missing billings from Supabase.');
      } else {
        debugPrint('Supabase import failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Supabase import error: $e');
    }
  }

  Future<Map<String, int>> getUsernameToIdMap() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/users?select=id,username,email'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final map = <String, int>{};
        for (var u in data) {
          final id = u['id'] as int;
          if (u['username'] != null) map[u['username'].toString().toLowerCase()] = id;
          if (u['email'] != null) map[u['email'].toString().toLowerCase()] = id;
        }
        return map;
      }
    } catch (e) {
      debugPrint('Supabase getUsernameToIdMap error: $e');
    }
    return {};
  }

  /// Get user ID by username
  Future<int?> getUserIdByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/users?username=eq.$username&select=id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.first['id'] as int;
        }
      }
    } catch (e) {
      debugPrint('Supabase getUserId error: $e');
    }
    return null;
  }

  /// Backup a file to Supabase Storage.
  Future<bool> backupFile(String key, Uint8List bytes) async {
    try {
      final url = '$_supabaseUrl/storage/v1/object/cuc-backups/$key';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer $_supabaseKey',
          'Content-Type': 'application/octet-stream',
          'x-upsert': 'true',
        },
        body: bytes,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Supabase backup: Uploaded file $key');
        return true;
      }
      debugPrint('Supabase backup file failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Supabase backup file error: $e');
      return false;
    }
  }

  /// Fire-and-forget file backup.
  void backupFileInBackground(String key, Uint8List bytes) {
    Future.microtask(() async {
      await backupFile(key, bytes);
    });
  }

  /// Sync missing files from S3 to Supabase Storage.
  Future<void> syncMissingFiles() async {
    try {
      debugPrint('Starting S3 to Supabase file sync...');
      final result = await Amplify.Storage.list(path: const StoragePath.fromString('public/')).result;
      int syncedCount = 0;

      for (final item in result.items) {
        // Check if file already exists in Supabase
        final checkUrl = '$_supabaseUrl/storage/v1/object/info/cuc-backups/${item.path}';
        final checkRes = await http.get(Uri.parse(checkUrl), headers: _headers);

        if (checkRes.statusCode == 200) {
          continue; // File exists
        }

        // Doesn't exist, download from S3
        debugPrint('Downloading missing file from S3: ${item.path}');
        final tempDir = await getTemporaryDirectory();
        final localFile = File('${tempDir.path}/${item.path.replaceAll('/', '_')}');
        
        await Amplify.Storage.downloadFile(
          path: StoragePath.fromString(item.path),
          localFile: AWSFile.fromPath(localFile.path),
        ).result;

        // Upload to Supabase
        final bytes = await localFile.readAsBytes();
        final success = await backupFile(item.path, bytes);
        if (success) {
          syncedCount++;
        }

        // Cleanup temp file
        if (await localFile.exists()) {
          await localFile.delete();
        }
      }
      debugPrint('Finished file sync. Uploaded $syncedCount missing files.');
    } catch (e) {
      debugPrint('Error syncing missing files: $e');
    }
  }
}
