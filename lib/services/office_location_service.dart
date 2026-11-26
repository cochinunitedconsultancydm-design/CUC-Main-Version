import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/OfficeLocations.dart';
import '../models/ModelProvider.dart';
import '../services/supabase_backup_service.dart';

class OfficeLocationService {
  static const String _storageKey = 'local_cached_office_locations_v1';

  Future<List<OfficeLocations>> _getLocalLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list.map((item) => OfficeLocations.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      safePrint('Note reading local office locations cache: $e');
    }
    return [];
  }

  Future<void> _saveLocalLocations(List<OfficeLocations> locations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = locations.map((loc) => loc.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      safePrint('Note saving local office locations cache: $e');
    }
  }

  Future<List<OfficeLocations>> getLocations() async {
    final localList = await _getLocalLocations();
    try {
      final request = ModelQueries.list(OfficeLocations.classType, limit: 10000);
      final response = await Amplify.API.query(request: request).response;
      final remoteList = (response.data?.items ?? []).whereType<OfficeLocations>().toList();
      
      // Merge remote into local by id
      final Map<String, OfficeLocations> map = {};
      for (var loc in localList) {
        map[loc.id] = loc;
      }
      for (var loc in remoteList) {
        map[loc.id] = loc;
      }
      
      final merged = map.values.toList();
      if (remoteList.isNotEmpty) {
        await _saveLocalLocations(merged);
      }
      return merged;
    } catch (e) {
      safePrint('AppSync office locations query note (using local cache): $e');
      return localList;
    }
  }

  Future<bool> createLocation(OfficeLocations location) async {
    try {
      // 1. Ensure persistent local cache
      final localList = await _getLocalLocations();
      localList.removeWhere((l) => l.id == location.id);
      localList.insert(0, location);
      await _saveLocalLocations(localList);

      // 2. Attempt AppSync mutation in background/best-effort
      try {
        final request = ModelMutations.create(location);
        final response = await Amplify.API.mutate(request: request).response;
        if (response.hasErrors) {
          safePrint('AppSync office location mutation notice: ${response.errors.map((e) => e.message).join(", ")}');
        }
      } catch (e) {
        safePrint('AppSync create office location notice: $e');
      }

      return true;
    } catch (e) {
      safePrint('Error creating office location: $e');
      return false;
    }
  }

  Future<bool> updateLocation(OfficeLocations location) async {
    try {
      // 1. Update local cache
      final localList = await _getLocalLocations();
      final idx = localList.indexWhere((l) => l.id == location.id);
      if (idx >= 0) {
        localList[idx] = location;
      } else {
        localList.insert(0, location);
      }
      await _saveLocalLocations(localList);

      // 2. Attempt AppSync mutation
      try {
        final request = ModelMutations.update(location);
        final response = await Amplify.API.mutate(request: request).response;
        if (response.hasErrors) {
          safePrint('AppSync office location update notice: ${response.errors.map((e) => e.message).join(", ")}');
        }
      } catch (e) {
        safePrint('AppSync update office location notice: $e');
      }

      return true;
    } catch (e) {
      safePrint('Error updating office location: $e');
      return false;
    }
  }

  Future<bool> deleteLocation(OfficeLocations location) async {
    try {
      // 1. Remove from local cache
      final localList = await _getLocalLocations();
      localList.removeWhere((l) => l.id == location.id);
      await _saveLocalLocations(localList);

      // 2. Attempt AppSync deletion
      try {
        final request = ModelMutations.delete(location);
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        safePrint('AppSync delete office location notice: $e');
      }

      return true;
    } catch (e) {
      safePrint('Error deleting office location: $e');
      return false;
    }
  }

  Future<String?> uploadImage(PlatformFile file, String pathPrefix) async {
    try {
      final filename = file.name.replaceAll('\\', '/').split('/').last;
      final key = '$pathPrefix/${DateTime.now().millisecondsSinceEpoch}_$filename';
      
      AWSFile localFile;
      if (file.bytes != null) {
        localFile = AWSFile.fromData(file.bytes!);
      } else if (!kIsWeb && file.path != null) {
        localFile = AWSFile.fromPath(file.path!);
      } else {
        safePrint('Error uploading image: no data or path available');
        return null;
      }

      try {
        await Amplify.Storage.uploadFile(
          localFile: localFile,
          path: StoragePath.fromString(key),
        ).result;
      } catch (s3Err) {
        safePrint('S3 upload notice: $s3Err');
      }

      try {
        final bytes = file.bytes ?? (!kIsWeb && file.path != null ? await File(file.path!).readAsBytes() : null);
        if (bytes != null) {
          SupabaseBackupService().backupFileInBackground(key, bytes);
        }
      } catch (_) {}

      return key;
    } catch (e) {
      safePrint('Error uploading image: $e');
      return null;
    }
  }
}
