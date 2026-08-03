import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:file_picker/file_picker.dart';
import '../models/OfficeLocations.dart';
import '../models/ModelProvider.dart';

class OfficeLocationService {
  Future<List<OfficeLocations>> getLocations() async {
    try {
      final request = ModelQueries.list(OfficeLocations.classType);
      final response = await Amplify.API.query(request: request).response;
      return (response.data?.items ?? []).whereType<OfficeLocations>().toList() ?? [];
    } catch (e) {
      safePrint('Error fetching office locations: $e');
      return [];
    }
  }

  Future<bool> createLocation(OfficeLocations location) async {
    try {
      final request = ModelMutations.create(location);
      final response = await Amplify.API.mutate(request: request).response;
      if (response.hasErrors) {
        throw Exception(response.errors.map((e) => e.message).join(', '));
      }
      return true;
    } catch (e) {
      safePrint('Error creating office location: $e');
      rethrow;
    }
  }

  Future<bool> updateLocation(OfficeLocations location) async {
    try {
      final request = ModelMutations.update(location);
      final response = await Amplify.API.mutate(request: request).response;
      return !response.hasErrors;
    } catch (e) {
      safePrint('Error updating office location: $e');
      return false;
    }
  }

  Future<bool> deleteLocation(OfficeLocations location) async {
    try {
      final request = ModelMutations.delete(location);
      final response = await Amplify.API.mutate(request: request).response;
      return !response.hasErrors;
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
      } else if (file.path != null) {
        localFile = AWSFile.fromPath(file.path!);
      } else {
        safePrint('Error uploading image: no data or path available');
        return null;
      }

      await Amplify.Storage.uploadFile(
        localFile: localFile,
        path: StoragePath.fromString(key),
      ).result;
      return key;
    } catch (e) {
      safePrint('Error uploading image: $e');
      return null;
    }
  }
}
