
import 'package:flutter/material.dart';

import 'detail_page.dart';
import '../widgets/course_menu_item.dart';

// ============================================================
// HOME PAGE - COURSE EXPLORER
// ============================================================

class HomePage extends StatefulWidget {
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;

  const HomePage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ========================================================
    // DATA COURSE
    // ========================================================

    final List<Map<String, dynamic>> courses = [
      {
        'code': 'MOB01',
        'title': 'Git & GitHub',
        'subtitle': 'Version control dan kolaborasi proyek',
        'credits': 2,
        'status': 'Selesai',
        'icon': Icons.code,
        'iconColor': Colors.indigo,
      },
      {
        'code': 'MOB02',
        'title': 'Dart Fundamentals',
        'subtitle': 'Dasar-dasar pemrograman Dart',
        'credits': 2,
        'status': 'Selesai',
        'icon': Icons.menu_book,
        'iconColor': Colors.blue,
      },
      {
        'code': 'MOB03',
        'title': 'Flutter UI',
        'subtitle': 'Membangun tampilan aplikasi Flutter',
        'credits': 3,
        'status': 'Aktif',
        'icon': Icons.grid_view,
        'iconColor': Colors.teal,
      },
      {
        'code': 'MOB04',
        'title': 'Navigation',
        'subtitle': 'Navigasi antarhalaman Flutter',
        'credits': 2,
        'status': 'Rencana',
        'icon': Icons.navigation,
        'iconColor': Colors.orange,
      },
      {
        'code': 'MOB05',
        'title': 'State Management',
        'subtitle': 'Mengelola state pada aplikasi',
        'credits': 3,
        'status': 'Rencana',
        'icon': Icons.settings,
        'iconColor': Colors.deepPurple,
      },
    ];

    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text('matakuliah'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

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
                  Icon(
                    Icons.school,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Course Explorer',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Jelajahi materi pembelajaran '
                    'Pemrograman Berbasis Mobile.',
                    style: TextStyle(fontSize: 14),
                  ),
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

            // ==================================================
            // JUDUL MATERI
            // ==================================================

            const Text(
              'Materi Pembelajaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Materi yang sedang dipelajari.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 14),
            // ==================================================
            // LIST COURSE
            // ==================================================

            ...courses.map((course) {
              final String title = course['title'] as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CourseMenuItem(
                  icon: course['icon'] as IconData,
                  iconColor: course['iconColor'] as Color,
                  title: title,
                  subtitle: course['subtitle'] as String,
                  credits: '${course['credits']} SKS',
                  status: course['status'] as String,

                  // STATE FAVORIT BERSAMA
                  isFavorite: widget.favorites.contains(title),
                  onFavoriteTap: () {
                    widget.onToggleFavorite(title);
                  },

                  // PASSING DATA KE DETAIL PAGE
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(course: course),
                      ),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 14),

            // ==================================================
            // KETERANGAN TAHAP 8
            // ==================================================

            const Center(
              child: Text(
                'Passing Data ke Detail Page',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
