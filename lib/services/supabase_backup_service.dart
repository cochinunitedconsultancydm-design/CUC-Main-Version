import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
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
    'LocationHistory': 'location_history',
    'StaffLocations': 'staff_locations',
    'ClientLicenses': 'client_licenses',
    'LicenseTypes': 'license_types',
    'LicenseBilling': 'license_billing',
  };

  Map<String, String> get _headers => {
        'apikey': _supabaseKey,
        'Authorization': 'Bearer $_supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates',
      };

  /// Backup a single record to Supabase (upsert).
  /// [modelName] is the DynamoDB model name (e.g. 'Clients').
  /// [data] is a Map of the record fields.
  Future<bool> backupRecord(String modelName, Map<String, dynamic> data) async {
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

      // Convert ID to int if it's a numeric string (Supabase uses int IDs)
      if (cleanData['id'] != null) {
        final idVal = int.tryParse(cleanData['id'].toString());
        if (idVal != null) {
          cleanData['id'] = idVal;
        } else {
          // If it's a UUID, remove it so Supabase can auto-generate an integer ID
          cleanData.remove('id');
        }
      }

      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/$table'),
        headers: _headers,
        body: jsonEncode(cleanData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        debugPrint('Supabase backup failed for $modelName: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Supabase backup error for $modelName: $e');
      return false;
    }
  }

  /// Backup multiple records to Supabase (batch upsert).
  Future<bool> backupRecords(String modelName, List<Map<String, dynamic>> records) async {
    final table = _tableMap[modelName];
    if (table == null) return false;

    try {
      final cleanRecords = records.map((data) {
        final clean = Map<String, dynamic>.from(data)
          ..remove('__typename')
          ..remove('createdAt')
          ..remove('updatedAt');
        if (clean['id'] != null) {
          final idVal = int.tryParse(clean['id'].toString());
          if (idVal != null) {
            clean['id'] = idVal;
          } else {
            clean.remove('id');
          }
        }
        return clean;
      }).toList();

      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/$table'),
        headers: _headers,
        body: jsonEncode(cleanRecords),
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
}
