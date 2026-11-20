import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_assignment_3/models/post_model.dart';
import 'package:mobile_assignment_3/services/favorites_service.dart';
import 'package:mobile_assignment_3/services/post_service.dart';

void main() {
  late Directory directory;
  late Box<Post> posts;
  late Box<Post> favorites;
  Post sample() => Post(id: 1, title: 'First post', body: 'Body', userId: 1);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('posts_test_');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PostAdapter());
    posts = await Hive.openBox<Post>('postsBox');
    favorites = await Hive.openBox<Post>('favoritesBox');
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('copies a HiveObject into favorites and toggles by post id', () async {
    final post = sample();
    await posts.put(post.id, post);
    final service = FavoritesService(box: favorites);
    await service.toggleFavorite(post);
    expect(service.isFavorite(1), isTrue);
    expect(identical(service.getFavorites().single, post), isFalse);
    expect(service.getFavorites().single.title, 'First post');
    await service.toggleFavorite(post);
    expect(service.isFavorite(1), isFalse);
    expect(service.getFavorites(), isEmpty);
    expect(posts.length, 1);
  });

  test('favorites survive clearing posts and reopening Hive', () async {
    await posts.put(1, sample());
    await FavoritesService(box: favorites).toggleFavorite(posts.get(1)!);
    await posts.clear();
    await Hive.close();
    favorites = await Hive.openBox<Post>('favoritesBox');
    final saved = FavoritesService(box: favorites).getFavorites().single;
    expect(saved.id, 1);
    expect(saved.body, 'Body');
    expect(saved.userId, 1);
  });

  test('online refresh caches posts without changing favorites', () async {
    await FavoritesService(box: favorites).toggleFavorite(sample());
    final client = MockClient((_) async => http.Response(
      '[{"id":2,"title":"New","body":"Updated","userId":3}]', 200));
    final service = PostService(box: posts, client: client);
    final result = await service.getPosts();
    expect(result.isOffline, isFalse);
    expect(posts.get(2)!.title, 'New');
    expect(favorites.get(1)!.title, 'First post');
    service.dispose();
  });

  test('offline restart returns cached posts and saved favorites', () async {
    await posts.put(1, sample());
    await FavoritesService(box: favorites).toggleFavorite(posts.get(1)!);
    await Hive.close();
    posts = await Hive.openBox<Post>('postsBox');
    favorites = await Hive.openBox<Post>('favoritesBox');
    final service = PostService(box: posts, client: MockClient((_) async {
      throw const SocketException('Offline');
    }));
    final result = await service.getPosts();
    expect(result.isOffline, isTrue);
    expect(result.posts.single.title, 'First post');
    expect(FavoritesService(box: favorites).isFavorite(1), isTrue);
    service.dispose();
  });

  test('first offline launch reports no cache; HTTP errors keep cache', () async {
    final service = PostService(box: posts,
      client: MockClient((_) async => http.Response('Unavailable', 503)));
    await expectLater(service.getPosts(), throwsException);
    await posts.put(1, sample());
    expect((await service.getPosts()).isOffline, isTrue);
    expect(posts.get(1)!.title, 'First post');
    service.dispose();
  });
}
