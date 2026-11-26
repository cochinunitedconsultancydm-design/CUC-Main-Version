import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../models/company_vault.dart';
import '../models/OfficeLocations.dart';
import '../models/ModelProvider.dart';
import 'supabase_backup_service.dart';

class CompanyVaultService {
  static const String _storageKey = 'cuc_our_office_vault_data_v1';
  static const String _vaultOfficeId = 'cuc_our_office_vault_singleton';

  CompanyProfile _cachedProfile = const CompanyProfile();
  List<CompanyDocument> _cachedDocuments = [];
  List<PartnerDocument> _cachedPartners = [];
  bool _isInitialized = false;

  CompanyProfile get profile => _cachedProfile;
  List<CompanyDocument> get documents => List.unmodifiable(_cachedDocuments);
  List<PartnerDocument> get partners => List.unmodifiable(_cachedPartners);

  Future<void> init() async {
    if (_isInitialized) return;
    await loadVault();
    _isInitialized = true;
  }

  /// Load vault data from local SharedPreferences first, then sync with cloud
  Future<void> loadVault() async {
    // 1. Read local cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(raw);
        if (data['profile'] != null) {
          _cachedProfile = CompanyProfile.fromMap(data['profile']);
        }
        if (data['documents'] is List) {
          _cachedDocuments = (data['documents'] as List)
              .map((e) => CompanyDocument.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        if (data['partners'] is List) {
          _cachedPartners = (data['partners'] as List)
              .map((e) => PartnerDocument.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading local company vault cache: $e');
    }

    // 2. Fetch and merge from Amplify OfficeLocations
    try {
      final req = ModelQueries.get(
        OfficeLocations.classType,
        OfficeLocationsModelIdentifier(id: _vaultOfficeId),
      );
      final res = await Amplify.API.query(request: req).response;
      final loc = res.data;

      if (loc != null) {
        bool changed = false;

        if (loc.office_phone_numbers != null && loc.office_phone_numbers!.isNotEmpty) {
          try {
            final profMap = jsonDecode(loc.office_phone_numbers!);
            if (profMap is Map<String, dynamic>) {
              _cachedProfile = CompanyProfile.fromMap(profMap);
              changed = true;
            }
          } catch (_) {}
        }

        if (loc.other_photos != null && loc.other_photos!.isNotEmpty) {
          try {
            final docList = jsonDecode(loc.other_photos!);
            if (docList is List && docList.isNotEmpty) {
              _cachedDocuments = docList
                  .map((e) => CompanyDocument.fromMap(Map<String, dynamic>.from(e)))
                  .toList();
              changed = true;
            }
          } catch (_) {}
        }

        if (loc.officers_contacts != null && loc.officers_contacts!.isNotEmpty) {
          try {
            final partList = jsonDecode(loc.officers_contacts!);
            if (partList is List && partList.isNotEmpty) {
              _cachedPartners = partList
                  .map((e) => PartnerDocument.fromMap(Map<String, dynamic>.from(e)))
                  .toList();
              changed = true;
            }
          } catch (_) {}
        }

        if (changed) {
          await _saveLocalCache();
        }
      }
    } catch (e) {
      debugPrint('Cloud sync notice for company vault: $e');
    }
  }

  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'profile': _cachedProfile.toMap(),
        'documents': _cachedDocuments.map((d) => d.toMap()).toList(),
        'partners': _cachedPartners.map((p) => p.toMap()).toList(),
      };
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving local company vault cache: $e');
    }
  }

  /// Sync local state to Amplify OfficeLocations record
  Future<void> _syncToCloud() async {
    try {
      final vaultLocation = OfficeLocations(
        id: _vaultOfficeId,
        name: 'Cochin United Consultancy Head Office',
        place: 'Ernakulam, Kerala',
        office_phone_numbers: jsonEncode(_cachedProfile.toMap()),
        location_link: _cachedProfile.registeredAddress,
        officers_contacts: jsonEncode(_cachedPartners.map((p) => p.toMap()).toList()),
        other_photos: jsonEncode(_cachedDocuments.map((d) => d.toMap()).toList()),
        updated_at: DateTime.now().toIso8601String(),
      );

      try {
        final updateReq = ModelMutations.update(vaultLocation);
        final updateRes = await Amplify.API.mutate(request: updateReq).response;
        if (updateRes.hasErrors) {
          // If update failed (record does not exist yet), create it
          final createReq = ModelMutations.create(vaultLocation);
          await Amplify.API.mutate(request: createReq).response;
        }
      } catch (_) {
        final createReq = ModelMutations.create(vaultLocation);
        await Amplify.API.mutate(request: createReq).response;
      }
    } catch (e) {
      debugPrint('Cloud sync error for company vault: $e');
    }
  }

  void _triggerBackgroundSync() {
    _syncToCloud().catchError((e) {
      debugPrint('[CompanyVaultService] Cloud sync error: $e');
    });
  }

  // --- Profile Operations ---
  Future<bool> updateCompanyProfile(CompanyProfile newProfile) async {
    _cachedProfile = newProfile;
    await _saveLocalCache();
    _triggerBackgroundSync();
    return true;
  }

  // --- Document Operations ---
  Future<bool> addCompanyDocument(CompanyDocument doc) async {
    _cachedDocuments.insert(0, doc);
    await _saveLocalCache();
    _triggerBackgroundSync();
    return true;
  }

  Future<bool> updateCompanyDocument(CompanyDocument doc) async {
    final idx = _cachedDocuments.indexWhere((d) => d.id == doc.id);
    if (idx >= 0) {
      _cachedDocuments[idx] = doc;
    } else {
      _cachedDocuments.insert(0, doc);
    }
    await _saveLocalCache();
    _triggerBackgroundSync();
    return true;
  }

  Future<bool> deleteCompanyDocument(String docId) async {
    _cachedDocuments.removeWhere((d) => d.id == docId);
    await _saveLocalCache();
    _triggerBackgroundSync();
    return true;
  }

  // --- Partner Operations ---
  Future<bool> addPartner(PartnerDocument partner) async {
    _cachedPartners.add(partner);
    await _saveLocalCache();
    _triggerBackgroundSync();
    return true;
  }

  Future<bool> updatePartner(PartnerDocument partner) async {
    final idx = _cachedPartners.indexWhere((p) => p.id == partner.id);
    if (idx >= 0) {
      _cachedPartners[idx] = partner;
    } else {
      _cachedPartners.add(partner);
    }
    await _saveLocalCache();
    _triggerBackgroundSync();
    return true;
  }

  Future<bool> deletePartner(String partnerId) async {
    _cachedPartners.removeWhere((p) => p.id == partnerId);
    await _saveLocalCache();
    _triggerBackgroundSync();
    return true;
  }

  // --- Cloud File Upload & Backup ---
  Future<String?> uploadVaultFile(PlatformFile file, {required String subfolder}) async {
    try {
      final cleanName = file.name.replaceAll(' ', '_').replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');
      final s3Key = 'public/company_vault/$subfolder/${UUID.getUUID()}_$cleanName';

      Uint8List? bytes = file.bytes;
      if (bytes == null && !kIsWeb && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      bool uploaded = false;
      // 1. Amplify S3
      try {
        AWSFile localFile;
        if (file.bytes != null) {
          localFile = AWSFile.fromData(file.bytes!);
        } else if (!kIsWeb && file.path != null) {
          localFile = AWSFile.fromPath(file.path!);
        } else if (bytes != null) {
          localFile = AWSFile.fromData(bytes);
        } else {
          return null;
        }

        await Amplify.Storage.uploadFile(
          localFile: localFile,
          path: StoragePath.fromString(s3Key),
        ).result;
        uploaded = true;
      } catch (e) {
        debugPrint('Amplify S3 upload notice for $cleanName: $e');
      }

      // 2. Supabase Storage backup
      if (bytes != null) {
        try {
          final supOk = await SupabaseBackupService().backupFile(s3Key, bytes);
          if (supOk) uploaded = true;
        } catch (e) {
          debugPrint('Supabase backup error for $cleanName: $e');
        }
      }

      if (uploaded) return s3Key;
      return null;
    } catch (e) {
      debugPrint('Error uploading vault file: $e');
      return null;
    }
  }

  // --- Document Opening (Native Windows temp launch + Web fallback) ---
  Future<void> openVaultDocument(BuildContext context, String keyOrUrl, {String? fileName}) async {
    try {
      String openUrl = keyOrUrl.trim();
      if (openUrl.isEmpty) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Opening document...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Local file launch
      if (!kIsWeb && File(openUrl).existsSync()) {
        final uri = Uri.file(openUrl);
        await launchUrl(uri);
        return;
      }

      // Normalize key
      String storagePath = openUrl;
      if (!openUrl.startsWith('http://') && !openUrl.startsWith('https://')) {
        storagePath = openUrl.startsWith('public/') ? openUrl : 'public/$openUrl';
      } else if (openUrl.contains('.amazonaws.com/')) {
        final uri = Uri.parse(openUrl);
        String p = uri.path;
        if (p.startsWith('/')) p = p.substring(1);
        if (p.contains('public/')) p = p.substring(p.indexOf('public/'));
        storagePath = p;
      }

      final supabaseFallbackUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co/storage/v1/object/public/cuc-backups/$storagePath';

      // Windows Desktop native launch via temp file
      if (!kIsWeb && Platform.isWindows) {
        try {
          List<int>? bytes;
          // Try Amplify S3 download
          try {
            final downloadRes = await Amplify.Storage.downloadData(
              path: StoragePath.fromString(storagePath),
            ).result;
            bytes = downloadRes.bytes;
          } catch (_) {}

          // Try Supabase Storage HTTP download
          if (bytes == null || bytes.isEmpty) {
            try {
              final res = await http.get(Uri.parse(supabaseFallbackUrl)).timeout(const Duration(seconds: 8));
              if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
                bytes = res.bodyBytes;
              }
            } catch (_) {}
          }

          if (bytes != null && bytes.isNotEmpty) {
            String cleanName = (fileName ?? storagePath.split('/').last).replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
            if (!cleanName.contains('.')) cleanName = '$cleanName.pdf';
            final tempDir = Directory.systemTemp;
            final tempFile = File('${tempDir.path}\\$cleanName');
            await tempFile.writeAsBytes(bytes);
            await Process.run('cmd', ['/c', 'start', '""', tempFile.path]);
            return;
          }
        } catch (e) {
          debugPrint('Windows local document open failed, trying browser: $e');
        }
      }

      // Web / Browser fallback
      if (!openUrl.startsWith('http://') && !openUrl.startsWith('https://')) {
        try {
          final res = await Amplify.Storage.getUrl(path: StoragePath.fromString(storagePath)).result;
          openUrl = res.url.toString();
        } catch (_) {
          openUrl = supabaseFallbackUrl;
        }
      }

      final uri = Uri.parse(openUrl);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
      } catch (_) {}

      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (!launched && !kIsWeb && Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '""', openUrl]);
        launched = true;
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open document automatically: $openUrl'),
          action: SnackBarAction(label: 'Copy Link', onPressed: () => Clipboard.setData(ClipboardData(text: openUrl))),
        ));
      }
    } catch (e) {
      debugPrint('Error opening vault document: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error opening document: $e'),
          backgroundColor: Colors.red.shade800,
        ));
      }
    }
  }
}
