import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart';
import 'excel_service.dart';

/// Automatic daily backup service.
///
/// On each app launch it checks when the last successful backup was taken.
/// If more than [backupIntervalHours] hours have elapsed it silently runs a
/// full JSON + Excel backup in the background, saving the files to the
/// user's Documents folder.  Old auto-backups beyond the retention window
/// are pruned automatically to avoid unbounded disk usage.
class AutoBackupService {
  // ── Singleton ──────────────────────────────────────────────────────────
  static final AutoBackupService _instance = AutoBackupService._();
  factory AutoBackupService() => _instance;
  AutoBackupService._();

  // ── Configuration ──────────────────────────────────────────────────────
  static const String _lastBackupKey = 'auto_backup_last_run';
  static const int backupIntervalHours = 24;
  static const int maxBackupsToKeep = 7; // keep one week of daily backups

  // ── Guard against concurrent runs ──────────────────────────────────────
  bool _isRunning = false;

  /// Tables to include in the backup (mirrors the admin manual backup).
  static final Map<String, ModelType> _tables = {
    'Users': Users.classType,
    'Clients': Clients.classType,
    'Deals': Deals.classType,
    'Billings': Billings.classType,
    'Tasks': Tasks.classType,
    'ActivityLogs': ActivityLogs.classType,
    'UserSessions': UserSessions.classType,
    'Messages': Messages.classType,
    'StaffAttendance': StaffAttendance.classType,
    'ClientDocuments': ClientDocuments.classType,
    'InwardPosts': InwardPosts.classType,
    'Notifications': Notifications.classType,
  };

  // ── Public API ─────────────────────────────────────────────────────────

  /// Call this once from any dashboard's [initState].
  /// It will check the timestamp and, if needed, kick off a silent backup.
  Future<void> runIfNeeded() async {
    if (_isRunning) return; // already in progress

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRunMs = prefs.getInt(_lastBackupKey);

      if (lastRunMs != null) {
        final lastRun = DateTime.fromMillisecondsSinceEpoch(lastRunMs);
        final elapsed = DateTime.now().difference(lastRun);
        if (elapsed.inHours < backupIntervalHours) {
          debugPrint('⏩ Auto-backup skipped – last run ${elapsed.inHours}h ago');
          return;
        }
      }

      // Run in the background – don't await from the caller's perspective
      _runBackup();
    } catch (e) {
      debugPrint('Auto-backup check error: $e');
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────

  Future<void> _runBackup() async {
    _isRunning = true;
    debugPrint('🔄 Auto-backup starting...');
    final stopwatch = Stopwatch()..start();

    try {
      final Map<String, List<Map<String, dynamic>>> backupData = {};

      for (var entry in _tables.entries) {
        try {
          final req = ModelQueries.list(entry.value, limit: 10000);
          final res = await Amplify.API.query(request: req).response;
          final items = res.data?.items ?? [];
          backupData[entry.key] = items
              .where((item) => item != null)
              .map((item) => item!.toJson())
              .toList();
        } catch (e) {
          debugPrint('Auto-backup: error fetching ${entry.key}: $e');
          backupData[entry.key] = [];
        }
      }

      if (kIsWeb) {
        debugPrint('Auto-backup local saving is not supported on Web. Skipping local file generation.');
        _isRunning = false;
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());

      // 1) JSON backup
      final jsonString = const JsonEncoder.withIndent('  ').convert({
        'backup_date': DateTime.now().toIso8601String(),
        'app_version': 'CUC Main Version',
        'backup_type': 'auto',
        'tables': backupData,
      });
      final jsonFile = File('${dir.path}/CUC_AutoBackup_$timestamp.json');
      await jsonFile.writeAsString(jsonString);
      debugPrint('✅ Auto-backup JSON saved: ${jsonFile.path}');

      // 2) Excel backup
      try {
        final excelPath = await ExcelService().generateFullBackup(backupData);
        if (excelPath != null) {
          // Rename to clearly mark it as auto
          final excelFile = File(excelPath);
          final autoExcelPath =
              '${dir.path}/CUC_AutoBackup_$timestamp.xlsx';
          await excelFile.rename(autoExcelPath);
          debugPrint('✅ Auto-backup Excel saved: $autoExcelPath');
        }
      } catch (e) {
        debugPrint('Auto-backup: Excel generation failed (JSON still saved): $e');
      }

      // 3) Record success timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastBackupKey, DateTime.now().millisecondsSinceEpoch);

      // 4) Prune old auto-backups
      await _pruneOldBackups(dir);

      stopwatch.stop();
      debugPrint('✅ Auto-backup completed in ${stopwatch.elapsed.inSeconds}s');
    } catch (e) {
      debugPrint('❌ Auto-backup failed: $e');
    } finally {
      _isRunning = false;
    }
  }

  /// Keeps only the most recent [maxBackupsToKeep] auto-backup files.
  Future<void> _pruneOldBackups(Directory dir) async {
    try {
      final allFiles = dir.listSync().whereType<File>().toList();

      // Gather JSON auto-backups
      final jsonBackups = allFiles
          .where((f) => f.path.contains('CUC_AutoBackup_') && f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      // Gather Excel auto-backups
      final excelBackups = allFiles
          .where((f) => f.path.contains('CUC_AutoBackup_') && f.path.endsWith('.xlsx'))
          .toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      // Delete excess
      for (var i = maxBackupsToKeep; i < jsonBackups.length; i++) {
        debugPrint('🗑️ Pruning old backup: ${jsonBackups[i].path}');
        await jsonBackups[i].delete();
      }
      for (var i = maxBackupsToKeep; i < excelBackups.length; i++) {
        debugPrint('🗑️ Pruning old backup: ${excelBackups[i].path}');
        await excelBackups[i].delete();
      }
    } catch (e) {
      debugPrint('Auto-backup prune error: $e');
    }
  }
}
