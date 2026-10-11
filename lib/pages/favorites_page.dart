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
          // Widget pertama menerima state favorites dari parent.
          FavoriteSummary(
            favorites: favorites,
          ),
          const SizedBox(height: 12),

          // Widget kedua menerima state dan callback dari parent.
          CourseFavoriteList(
            favorites: favorites,
            onToggleFavorite: onToggleFavorite,
          ),
        ],
      ),
    );
  }
}

// ======================================================
// RINGKASAN FAVORIT
// ======================================================

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

// ======================================================
// DAFTAR MATA KULIAH FAVORIT
// ======================================================

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
          child: Center(
            child: Text('Belum ada mata kuliah favorit.'),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: favorites.map((course) {
          return ListTile(
            leading: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text(course),
            trailing: IconButton(
              tooltip: 'Hapus dari favorit',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                onToggleFavorite(course);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
