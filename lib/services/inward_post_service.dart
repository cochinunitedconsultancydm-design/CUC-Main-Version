import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import '../models/inward_post_model.dart';

class InwardPostService {
  /// Fetch all inward posts
  static Future<List<InwardPost>> getPosts() async {
    try {
      final req = ModelQueries.list(InwardPosts.classType);
      final res = await Amplify.API.query(request: req).response;
      var items = res.data?.items.where((e) => e != null).cast<InwardPosts>().toList() ?? [];
      
      items.sort((a, b) => (b.received_date ?? '').compareTo(a.received_date ?? ''));
          
      return items.map((e) => InwardPost(
        id: e.id.toString(),
        senderName: e.sender_name?.toString() ?? '',
        receivedBy: e.received_by?.toString() ?? '',
        recipientName: e.recipient_name?.toString() ?? '',
        description: e.description?.toString() ?? '',
        receivedDate: DateTime.parse(e.received_date?.toString() ?? DateTime.now().toIso8601String()),
        status: PostStatus.values.firstWhere(
          (s) => s.toString() == e.status?.toString(),
          orElse: () => PostStatus.pendingConfirmation,
        ),
      )).toList();
    } catch (e) {
      debugPrint('Error fetching inward posts: $e');
      return [];
    }
  }

  /// Add a new inward post
  static Future<void> addPost(InwardPost post) async {
    try {
      final newPost = InwardPosts(
        sender_name: post.senderName,
        received_by: post.receivedBy,
        recipient_name: post.recipientName,
        description: post.description,
        status: post.status.toString(),
        received_date: post.receivedDate.toIso8601String(),
      );
      await Amplify.API.mutate(request: ModelMutations.create(newPost).response);
    } catch (e) {
      debugPrint('Error adding inward post: $e');
    }
  }
  
  /// Update post status
  static Future<void> updatePostStatus(String id, PostStatus status) async {
    try {
      final req = ModelQueries.list(InwardPosts.classType, where: InwardPosts.ID.eq(id));
      final res = await Amplify.API.query(request: req).response;
      if (res.data?.items.isNotEmpty == true) {
        final item = res.data!.items.first!;
        final updated = item.copyWith(status: status.toString());
        await Amplify.API.mutate(request: ModelMutations.update(updated).response);
      }
    } catch (e) {
      debugPrint('Error updating inward post status: $e');
    }
  }
}
