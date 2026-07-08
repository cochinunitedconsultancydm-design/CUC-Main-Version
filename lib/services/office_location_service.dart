import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/OfficeLocations.dart';
import '../models/ModelProvider.dart';
import 'dart:convert';

class OfficeLocationService {
  Future<List<OfficeLocations>> getLocations() async {
    try {
      final request = ModelQueries.list(OfficeLocations.classType);
      final response = await Amplify.API.query(request: request).response;
      return response.data?.items.whereType<OfficeLocations>().toList() ?? [];
    } catch (e) {
      safePrint('Error fetching office locations: $e');
      return [];
    }
  }

  Future<bool> createLocation(OfficeLocations location) async {
    try {
      final request = ModelMutations.create(location);
      final response = await Amplify.API.mutate(request: request).response;
      return !response.hasErrors;
    } catch (e) {
      safePrint('Error creating office location: $e');
      return false;
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

  Future<String?> uploadImage(File file, String pathPrefix) async {
    try {
      final key = '$pathPrefix/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(file.path),
        path: StoragePath.fromString(key),
      ).result;
      return result.uploadedItem.path;
    } catch (e) {
      safePrint('Error uploading image: $e');
      return null;
    }
  }
}
