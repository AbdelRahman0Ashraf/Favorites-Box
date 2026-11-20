import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/favorites_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final FavoritesService favorites;
  const PostCard({super.key, required this.post, required this.favorites});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(child: Text('${post.id}')),
      title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        tooltip: favorites.isFavorite(post.id) ? 'Remove from favorites' : 'Add to favorites',
        icon: Icon(favorites.isFavorite(post.id) ? Icons.star : Icons.star_border,
            color: Colors.amber.shade800),
        onPressed: () async {
          try {
            await favorites.toggleFavorite(post);
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not save your favorite. Please try again.')),
              );
            }
          }
        },
      ),
    ),
  );
}
