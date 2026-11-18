import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import '../models/inward_post_model.dart';
import 'package:cuc_app/services/backup_aware_api.dart';

class InwardPostService {
  /// Fetch all posts (both inward and outward sent letters)
  static Future<List<InwardPost>> getPosts() async {
    try {
      final req = ModelQueries.list(InwardPosts.classType, limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<InwardPosts>().toList() ?? [];
      
      items.sort((a, b) => (b.received_date ?? '').compareTo(a.received_date ?? ''));
          
      return items.map((e) => InwardPost.fromDb(
        id: e.id.toString(),
        senderName: e.sender_name?.toString() ?? '',
        receivedBy: e.received_by?.toString() ?? '',
        recipientName: e.recipient_name?.toString() ?? '',
        rawDescription: e.description?.toString(),
        receivedDate: DateTime.parse(e.received_date?.toString() ?? DateTime.now().toIso8601String()),
        status: PostStatus.values.firstWhere(
          (s) => s.toString() == e.status?.toString(),
          orElse: () => PostStatus.pendingConfirmation,
        ),
      )).toList();
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      return [];
    }
  }

  /// Get posts linked to a specific workfile
  static Future<List<InwardPost>> getPostsForWorkfile(String workfileId) async {
    final all = await getPosts();
    return all.where((p) => p.workfileId == workfileId).toList();
  }

  /// Add a new post / sent letter
  static Future<void> addPost(InwardPost post) async {
    try {
      final newPost = InwardPosts(
        id: post.id,
        sender_name: post.senderName,
        received_by: post.receivedBy,
        recipient_name: post.recipientName,
        description: post.toStoredDescription(),
        status: post.status.toString(),
        received_date: post.receivedDate.toIso8601String(),
      );
      await BackupAwareApi().create(newPost);
    } catch (e) {
      debugPrint('Error adding post: $e');
      rethrow;
    }
  }

  /// Update an existing post
  static Future<void> updatePost(InwardPost post) async {
    try {
      final req = ModelQueries.list(InwardPosts.classType, where: InwardPosts.ID.eq(post.id), limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final item = res.data!.items.first!;
        final updated = item.copyWith(
          sender_name: post.senderName,
          recipient_name: post.recipientName,
          description: post.toStoredDescription(),
          status: post.status.toString(),
        );
        await BackupAwareApi().update(updated);
      }
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }
  
  /// Update/attach sent letter document for an existing post
  static Future<void> updateLetterDocument(
    String id, {
    required String letterPath,
    required String letterFileName,
  }) async {
    try {
      final req = ModelQueries.list(InwardPosts.classType, where: InwardPosts.ID.eq(id), limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final item = res.data!.items.first!;
        final post = InwardPost.fromDb(
          id: item.id,
          senderName: item.sender_name ?? '',
          recipientName: item.recipient_name ?? '',
          receivedBy: item.received_by ?? '',
          receivedDate: item.received_date != null
              ? DateTime.tryParse(item.received_date!) ?? DateTime.now()
              : DateTime.now(),
          status: PostStatus.values.firstWhere(
            (e) => e.toString() == item.status,
            orElse: () => PostStatus.pendingConfirmation,
          ),
          rawDescription: item.description,
        );

        final updatedPost = post.copyWith(
          letterStoragePath: letterPath,
          letterFileName: letterFileName,
        );

        final updated = item.copyWith(
          description: updatedPost.toStoredDescription(),
        );
        await BackupAwareApi().update(updated);
      }
    } catch (e) {
      debugPrint('Error updating letter document: $e');
      rethrow;
    }
  }

  /// Update acknowledgement for a sent letter
  static Future<void> updateAcknowledgement(
    String id, {
    required String ackPath,
    required String ackFileName,
    DateTime? ackDate,
  }) async {
    try {
      final req = ModelQueries.list(InwardPosts.classType, where: InwardPosts.ID.eq(id), limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final item = res.data!.items.first!;
        final post = InwardPost.fromDb(
          id: item.id.toString(),
          senderName: item.sender_name?.toString() ?? '',
          recipientName: item.recipient_name?.toString() ?? '',
          receivedBy: item.received_by?.toString() ?? '',
          receivedDate: DateTime.parse(item.received_date?.toString() ?? DateTime.now().toIso8601String()),
          status: PostStatus.values.firstWhere(
            (s) => s.toString() == item.status?.toString(),
            orElse: () => PostStatus.pendingConfirmation,
          ),
          rawDescription: item.description,
        );

        final updatedPost = post.copyWith(
          hasAcknowledgement: true,
          ackStatus: 'received',
          ackStoragePath: ackPath,
          ackFileName: ackFileName,
          ackReceivedDate: ackDate ?? DateTime.now(),
        );

        final updated = item.copyWith(
          description: updatedPost.toStoredDescription(),
          status: PostStatus.confirmedReceived.toString(),
        );
        await BackupAwareApi().update(updated);
      }
    } catch (e) {
      debugPrint('Error updating acknowledgement: $e');
      rethrow;
    }
  }

  /// Update post status
  static Future<void> updatePostStatus(String id, PostStatus status) async {
    try {
      final req = ModelQueries.list(InwardPosts.classType, where: InwardPosts.ID.eq(id), limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final item = res.data!.items.first!;
        final updated = item.copyWith(status: status.toString());
        await BackupAwareApi().update(updated);
      }
    } catch (e) {
      debugPrint('Error updating inward post status: $e');
      rethrow;
    }
  }

  /// Delete an existing inward post
  static Future<void> deletePost(String id) async {
    try {
      final req = ModelQueries.list(InwardPosts.classType, where: InwardPosts.ID.eq(id), limit: 10000);
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final item = res.data!.items.first!;
        await BackupAwareApi().delete(item);
      }
    } catch (e) {
      debugPrint('Error deleting inward post: $e');
      rethrow;
    }
  }
}
