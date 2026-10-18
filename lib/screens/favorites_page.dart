import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FavoriteSummary(favorites: favorites),
          const SizedBox(height: 12),
          CourseFavoriteList(
            favorites: favorites,
            onToggleFavorite: onToggleFavorite,
          ),
        ],
      ),
    );
  }
}

class FavoriteSummary extends StatelessWidget {
  final Set<String> favorites;

  const FavoriteSummary({
    super.key,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.favorite,
          color: Colors.red,
        ),
        title: const Text('Total Mata Kuliah Favorit'),
        trailing: Text(
          '${favorites.length}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CourseFavoriteList extends StatelessWidget {
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;

  const CourseFavoriteList({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.favorite_border,
                size: 48,
              ),
              SizedBox(height: 12),
              Text('Belum ada mata kuliah favorit.'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: favorites.map((course) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.school),
            title: Text(course),
            trailing: IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              tooltip: 'Hapus dari favorit',
              onPressed: () => onToggleFavorite(course),
            ),
          ),
        );
      }).toList(),
    );
  }
}