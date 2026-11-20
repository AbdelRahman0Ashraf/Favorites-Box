import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../widgets/post_card.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesService favorites;
  const FavoritesScreen({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Favorites')),
    body: ValueListenableBuilder(
      valueListenable: favorites.listenable,
      builder: (context, box, child) {
        final posts = favorites.getFavorites();
        if (posts.isEmpty) {
          return const Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text('No favorites yet', style: TextStyle(fontSize: 20)),
              Text('Tap a star on the Posts screen to save a post.'),
            ],
          ));
        }
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index], favorites: favorites),
        );
      },
    ),
  );
}
