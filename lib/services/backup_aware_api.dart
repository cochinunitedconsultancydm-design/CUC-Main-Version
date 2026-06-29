import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'supabase_backup_service.dart';

/// Wrapper around Amplify API that automatically backs up mutations to Supabase.
/// Use this instead of calling Amplify.API.mutate() directly for critical data.
class BackupAwareApi {
  static final BackupAwareApi _instance = BackupAwareApi._();
  factory BackupAwareApi() => _instance;
  BackupAwareApi._();

  final _backup = SupabaseBackupService();

  /// Create a record in DynamoDB and backup to Supabase.
  Future<GraphQLResponse<T>> create<T extends Model>(T model) async {
    final response = await Amplify.API
        .mutate(request: ModelMutations.create(model))
        .response;

    if (response.data != null) {
      _backupInBackground(model.getInstanceType().modelName(), model.toJson());
    }
    return response;
  }

  /// Update a record in DynamoDB and backup to Supabase.
  Future<GraphQLResponse<T>> update<T extends Model>(T model) async {
    final response = await Amplify.API
        .mutate(request: ModelMutations.update(model))
        .response;

    if (response.data != null) {
      _backupInBackground(model.getInstanceType().modelName(), model.toJson());
    }
    return response;
  }

  /// Delete a record from DynamoDB and Supabase.
  Future<GraphQLResponse<T>> delete<T extends Model>(T model) async {
    final response = await Amplify.API
        .mutate(request: ModelMutations.delete(model))
        .response;

    if (response.data != null) {
      String modelId;
      try {
        modelId = (model as dynamic).id.toString();
      } catch (e) {
        modelId = (model as dynamic).getId().toString();
      }
      _deleteBackupInBackground(
          model.getInstanceType().modelName(), modelId);
    }
    return response;
  }

  /// Delete a record by ID from DynamoDB and Supabase.
  Future<GraphQLResponse<T>> deleteById<T extends Model>(ModelType<T> classType, ModelIdentifier<T> id) async {
    final response = await Amplify.API
        .mutate(request: ModelMutations.deleteById(classType, id))
        .response;

    if (response.data != null) {
      _deleteBackupInBackground(
          classType.modelName(), id.serializeAsString());
    }
    return response;
  }

  /// Fire-and-forget backup to Supabase (non-blocking).
  void _backupInBackground(String modelName, Map<String, dynamic> data) {
    _backup.backupRecord(modelName, data).then((success) {
      if (!success) {
        debugPrint('Supabase backup queued retry for $modelName');
      }
    }).catchError((e) {
      debugPrint('Supabase backup error: $e');
    });
  }

  void _deleteBackupInBackground(String modelName, String id) {
    _backup.deleteRecord(modelName, id).catchError((e) {
      debugPrint('Supabase delete backup error: $e');
    });
  }
}
