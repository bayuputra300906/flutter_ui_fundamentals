
import 'package:flutter/material.dart';

import 'detail_page.dart';
import '../widgets/course_menu_item.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../widgets/error_view.dart';
import 'add_course_page.dart';
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
  
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<CourseProvider>().loadCourses();
  });
}

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

    
    return Scaffold(
      // ======================================================
      // APP BAR
      // ======================================================

     appBar: AppBar(
  title: const Text('matakuliah'),
  centerTitle: false,
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      tooltip: 'Tambah mata kuliah',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddCoursePage(),
          ),
        );
      },
    ),

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

           
Consumer<CourseProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

if (provider.error != null) {
  return ErrorView(
    message: provider.error!,
    onRetry: provider.loadCourses,
  );
}

if (provider.courses.isEmpty) {
  return const Center(
    child: Text('Data course belum tersedia'),
  );
}

    final courses = provider.courses;

    return Column(
      children: courses.map((course) {
      
final presentation = {
  'MOB01': {
    'subtitle': 'Version control dan kolaborasi proyek',
    'icon': Icons.code,
    'iconColor': Colors.indigo,
  },
  'MOB02': {
    'subtitle': 'Dasar-dasar pemrograman Dart',
    'icon': Icons.menu_book,
    'iconColor': Colors.blue,
  },
  'MOB03': {
    'subtitle': 'Membangun tampilan aplikasi Flutter',
    'icon': Icons.grid_view,
    'iconColor': Colors.teal,
  },
  'MOB04': {
    'subtitle': 'Navigasi antarhalaman Flutter',
    'icon': Icons.navigation,
    'iconColor': Colors.orange,
  },
  'MOB05': {
    'subtitle': 'Mengelola state pada aplikasi',
    'icon': Icons.settings,
    'iconColor': Colors.deepPurple,
  },
}[course.code];

if (presentation == null) {
  return const SizedBox.shrink();
}
        final title = course.title;

        final status = {
          'done': 'Selesai',
          'active': 'Aktif',
          'planned': 'Rencana',
        }[course.status] ?? course.status;

        final courseMap = {
          'code': course.code,
          'title': course.title,
          'credits': course.credits,
          'status': status,
          'subtitle': presentation['subtitle'],
          'icon': presentation['icon'],
          'iconColor': presentation['iconColor'],
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CourseMenuItem(
            icon: presentation['icon'] as IconData,
            iconColor: presentation['iconColor'] as Color,
            title: title,
            subtitle: presentation['subtitle'] as String,
            credits: '${course.credits} SKS',
            status: status,
            isFavorite: widget.favorites.contains(course.code),
            onFavoriteTap: () {
            widget.onToggleFavorite(course.code);
        },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(course: courseMap),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  },
),


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
