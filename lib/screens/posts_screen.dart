import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../services/favorites_service.dart';
import '../widgets/post_card.dart';
import 'favorites_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late final PostService _service;
  late final FavoritesService _favorites;
  late Future<PostsResult> _future;

  @override
  void initState() {
    super.initState();
    _service = PostService();
    _favorites = FavoritesService();
    _future = _service.getPosts();
  }

  Future<void> _refresh() async {
    final request = _service.getPosts();
    setState(() => _future = request);
    try { await request; } catch (_) { /* FutureBuilder displays the error. */ }
  }

  @override
  void dispose() { _service.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Posts'),
      actions: [IconButton(
        tooltip: 'Open favorites',
        icon: const Icon(Icons.star),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => FavoritesScreen(favorites: _favorites),
        )),
      )],
    ),
    body: FutureBuilder<PostsResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off, size: 56),
              const SizedBox(height: 12),
              const Text('No Internet and No Cached Data'),
              const Text('Connect to the internet and retry. Saved favorites are still available.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
            ]),
          ));
        }
        final result = snapshot.data!;
        return Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: result.isOffline ? Colors.amber.shade100 : Colors.green.shade50,
            child: Text(result.isOffline
                ? 'Offline - showing saved posts'
                : 'Posts updated - available offline'),
          ),
          Expanded(child: ValueListenableBuilder(
            valueListenable: _favorites.listenable,
            builder: (context, box, child) => RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: result.posts.isEmpty ? 1 : result.posts.length,
                itemBuilder: (context, index) => result.posts.isEmpty
                    ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No posts found')))
                    : PostCard(post: result.posts[index], favorites: _favorites),
              ),
            ),
          )),
        ]);
      },
    ),
  );
}
