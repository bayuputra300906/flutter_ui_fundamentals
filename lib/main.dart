import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Membaca data dari JSON
Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

// Reusable widget untuk summary card
Widget buildSummaryCard(
  String value,
  String label,
  IconData icon,
) {
  return Expanded(
    child: Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

// Reusable widget untuk status course
Widget buildStatusIcon(String status) {
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

// Reusable widget untuk item course
Widget buildCourseCard(
  Map<String, dynamic> course,
) {
  final String status = course['status'] as String;

  String statusText;

  if (status == 'done') {
    statusText = 'Selesai';
  } else if (status == 'active') {
    statusText = 'Aktif';
  } else {
    statusText = 'Rencana';
  }

  return Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: buildStatusIcon(status),

      title: Text(
        course['title'] as String,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
        '${course['code']} • ${course['credits']} SKS',
      ),

      trailing: Text(
        statusText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

// Dashboard utama
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();

    // Future dijalankan satu kali
    studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        centerTitle: true,
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,

        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Gagal memuat data:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Jika data kosong
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Data tidak tersedia'),
            );
          }

          // Mengambil data JSON
          final data = snapshot.data!;

          final student =
              data['student'] as Map<String, dynamic>;

          final courses =
              data['courses'] as List<dynamic>;

          final String studentName =
              student['name'] as String;

          final String studentId =
              student['nim'] as String;

          final int semester =
              student['semester'] as int;

          // Menghitung total SKS
          int totalCredits = 0;

          for (final item in courses) {
            final course =
                item as Map<String, dynamic>;

            totalCredits +=
                course['credits'] as int;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =========================
                  // PROFILE CARD
                  // =========================
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 42,
                            backgroundImage: AssetImage(
                              'assets/images/profile.jpg',
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  studentId,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Semester $semester',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // CASE A - RENDERFLEX OVERFLOW
                  // =========================
                  Row(
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${student['nim']} - ${student['name']} - saya suka bermain game mobile legends dan efootball',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // SUMMARY
                  // =========================
                  const Text(
                    'Ringkasan Pembelajaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      buildSummaryCard(
                        '${courses.length}',
                        'Mata Kuliah',
                        Icons.menu_book,
                      ),

                      const SizedBox(width: 8),

                      buildSummaryCard(
                        '$totalCredits',
                        'Total SKS',
                        Icons.school,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // COURSE LIST
                  // =========================
                  const Text(
                    'Daftar Mata Kuliah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course =
                          courses[index]
                              as Map<String, dynamic>;

                      return buildCourseCard(course);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF7F4FC),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6750A4),
          foregroundColor: Colors.white,
          elevation: 3,
          centerTitle: true,
        ),

        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 3,
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme:
            const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF3EFFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
        ),
      ),

      home: const DashboardPage(),
    );
  }
}