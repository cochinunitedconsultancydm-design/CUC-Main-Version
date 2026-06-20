import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inward_post_model.dart';

class InwardPostService {
  static final _supabase = Supabase.instance.client;

  /// Fetch all inward posts
  static Future<List<InwardPost>> getPosts() async {
    try {
      final data = await _supabase
          .from('inward_posts')
          .select()
          .order('received_date', ascending: false);
          
      return data.map((e) => InwardPost(
        id: e['id'].toString(),
        senderName: e['sender_name'].toString(),
        receivedBy: e['received_by'].toString(),
        recipientName: e['recipient_name'].toString(),
        description: e['description'].toString(),
        receivedDate: DateTime.parse(e['received_date'].toString()),
        status: PostStatus.values.firstWhere(
          (s) => s.toString() == e['status'].toString(),
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
      await _supabase.from('inward_posts').insert({
        'sender_name': post.senderName,
        'received_by': post.receivedBy,
        'recipient_name': post.recipientName,
        'description': post.description,
        'status': post.status.toString(),
        'received_date': post.receivedDate.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error adding inward post: $e');
    }
  }
  
  /// Update post status
  static Future<void> updatePostStatus(String id, PostStatus status) async {
    try {
      await _supabase.from('inward_posts').update({
        'status': status.toString(),
      }).eq('id', id);
    } catch (e) {
      debugPrint('Error updating inward post status: $e');
    }
  }
}
