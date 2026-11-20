import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/post_model.dart';

class FavoritesService {
  final Box<Post> _box;
  FavoritesService({Box<Post>? box})
      : _box = box ?? Hive.box<Post>('favoritesBox');

  ValueListenable<Box<Post>> get listenable => _box.listenable();

  Future<void> toggleFavorite(Post post) async {
    if (isFavorite(post.id)) {
      await _box.delete(post.id);
    } else {
      await _box.put(post.id, post.copy());
    }
  }

  bool isFavorite(int id) => _box.containsKey(id);

  List<Post> getFavorites() => _box.values.toList()
    ..sort((a, b) => a.id.compareTo(b.id));
}
