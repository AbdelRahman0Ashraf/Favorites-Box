import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostsResult {
  final List<Post> posts;
  final bool isOffline;
  const PostsResult(this.posts, {required this.isOffline});
}

class PostService {
  static const apiUrl = 'https://jsonplaceholder.typicode.com/posts';
  final Box<Post> _box;
  final http.Client _client;

  PostService({Box<Post>? box, http.Client? client})
      : _box = box ?? Hive.box<Post>('postsBox'),
        _client = client ?? http.Client();

  Future<PostsResult> getPosts() async {
    List<Post> posts;
    try {
      final response = await _client.get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final data = jsonDecode(response.body) as List<dynamic>;
      posts = data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      if (_box.isNotEmpty) {
        return PostsResult(_box.values.toList(), isOffline: true);
      }
      throw Exception('No Internet and No Cached Data');
    }
    // Write before deleting stale keys so a failed request cannot erase cache.
    final fresh = {for (final post in posts) post.id: post};
    await _box.putAll(fresh);
    await _box.deleteAll(_box.keys.where((key) => !fresh.containsKey(key)).toList());
    // Never clear or refresh favoritesBox here.
    return PostsResult(_box.values.toList(), isOffline: false);
  }

  void dispose() => _client.close();
}
