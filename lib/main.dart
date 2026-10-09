import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/navigation_page.dart';


// ============================================================
// LOAD STUDENT DATA
// ============================================================

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString);
}


// ============================================================
// SUMMARY CARD
// ============================================================

Widget buildSummaryCard({
  required IconData icon,
  required String value,
  required String label,
}) {
  return Expanded(
    child: Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    ),
  );
}


// ============================================================
// STATUS ICON
// ============================================================

Icon buildStatusIcon(String status) {
  if (status == 'done') {
    return const Icon(
      Icons.check_circle,
      color: Colors.green,
    );
  }

  if (status == 'active') {
    return const Icon(
      Icons.play_circle,
      color: Colors.orange,
    );
  }

  return const Icon(
    Icons.schedule,
    color: Colors.grey,
  );
}


// ============================================================
// COURSE CARD
// ============================================================

Widget buildCourseCard(Map<String, dynamic> course) {
  final String status = course['status'];

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: buildStatusIcon(status),
      title: Text(
        course['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${course['code']} • ${course['credits']} SKS',
      ),
      trailing: Text(
        status,
      ),
    ),
  );
}


// ============================================================
// COMPACT LAYOUT
// ============================================================

class CompactLayout extends StatelessWidget {
  final Map<String, dynamic> student;

  const CompactLayout({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Learning Dashboard',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 8),

        Text(
          'Nama: ${student['name']}',
        ),

        Text(
          'NIM: ${student['nim']}',
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            buildSummaryCard(
              icon: Icons.menu_book,
              value: '${student['courses'].length}',
              label: 'Materi',
            ),

            const SizedBox(width: 12),

            buildSummaryCard(
              icon: Icons.school,
              value: '${student['semester']}',
              label: 'Semester',
            ),
          ],
        ),

        const SizedBox(height: 20),

        ...student['courses']
            .map<Widget>(
              (course) => buildCourseCard(course),
            )
            .toList(),
      ],
    );
  }
}


// ============================================================
// MEDIUM LAYOUT
// ============================================================

class MediumLayout extends StatelessWidget {
  final Map<String, dynamic> student;

  const MediumLayout({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Learning Dashboard',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 8),

        Text(
          'Nama: ${student['name']}',
        ),

        Text(
          'NIM: ${student['nim']}',
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            buildSummaryCard(
              icon: Icons.menu_book,
              value: '${student['courses'].length}',
              label: 'Materi',
            ),

            const SizedBox(width: 16),

            buildSummaryCard(
              icon: Icons.school,
              value: '${student['semester']}',
              label: 'Semester',
            ),
          ],
        ),

        const SizedBox(height: 24),

        ...student['courses']
            .map<Widget>(
              (course) => buildCourseCard(course),
            )
            .toList(),
      ],
    );
  }
}


// ============================================================
// EXPANDED LAYOUT
// ============================================================

class ExpandedLayout extends StatelessWidget {
  final Map<String, dynamic> student;

  const ExpandedLayout({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: student['courses'].length,
      itemBuilder: (context, index) {
        return buildCourseCard(
          student['courses'][index],
        );
      },
    );
  }
}


// ============================================================
// DASHBOARD PAGE
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends State<DashboardPage> {

  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();

    studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Dashboard',
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Data tidak ditemukan.',
              ),
            );
          }

          final student = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {

              if (constraints.maxWidth < 600) {
                return CompactLayout(
                  student: student,
                );
              }

              if (constraints.maxWidth < 1000) {
                return MediumLayout(
                  student: student,
                );
              }

              return ExpandedLayout(
                student: student,
              );
            },
          );
        },
      ),
    );
  }
}


// ============================================================
// MY APP
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Course Explorer',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      home: const NavigationPage(),
    );
  }
}


// ============================================================
// MAIN
// ============================================================

void main() {
  runApp(
    const MyApp(),
  );
}