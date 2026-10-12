
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'favorites_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int selectedIndex = 0;

  // Satu sumber data favorit untuk Courses dan Favorites.
  final ValueNotifier<Set<String>> favorites =
    ValueNotifier<Set<String>>({});

  void toggleFavorite(String course) {
  final updatedFavorites = Set<String>.from(favorites.value);

  if (updatedFavorites.contains(course)) {
    updatedFavorites.remove(course);
  } else {
    updatedFavorites.add(course);
  }

  favorites.value = updatedFavorites;
}

  Widget buildSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const HomeTab();

      case 1:
  return HomePage(
    favorites: favorites.value,
    onToggleFavorite: toggleFavorite,
  );

      case 2:
        return const ProfilePage();

     case 3:
  return FavoritesPage(
    favorites: favorites,
    onToggleFavorite: toggleFavorite,
  );

      default:
        return const HomeTab();
    }
  }

  Widget buildNavigationBar() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
      ],
    );
  }

  Widget buildNavigationRail() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: Text('Courses'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: Text('Favorites'),
        ),
      ],
    );
  }

 @override
void dispose() {
  favorites.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Scaffold(
            body: buildSelectedPage(),
            bottomNavigationBar: buildNavigationBar(),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              buildNavigationRail(),
              const VerticalDivider(width: 1),
              Expanded(child: buildSelectedPage()),
            ],
          ),
        );
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school, size: 45),
                  const SizedBox(height: 12),
                  const Text(
                    'Course Explorer',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Selamat datang di Course Explorer.'),
                  const SizedBox(height: 16),
                  const Text(
                    'Nama: Gede Bayu Putra Darmawan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text('NIM: 2415051105'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Selamat Belajar!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gunakan menu Courses untuk melihat daftar mata kuliah.',
            ),
          ],
        ),
      ),
    );
  }
}
