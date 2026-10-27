import 'dart:convert';


import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/course.dart';

const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  // Mengambil data dari REST API
  Future<List<Course>> getCourses() async {
    debugPrint('=== MULAI REST API ===');

    final response = await http.get(Uri.parse(baseUrl));

    debugPrint('HTTP Status Code: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    final courses = data.map((item) {
      final post = item as Map<String, dynamic>;

      return Course(
        id: post['id'] as int?,
        code: 'API-${post['id']}',
        title: post['title'] as String? ?? 'Tanpa judul',
        credits: post['userId'] as int? ?? 0,
        status: 'planned',
      );
    }).toList();

    debugPrint('Jumlah item: ${courses.length}');

    return courses;
  }

  // Mengambil lima mata kuliah dari JSON lokal
  Future<List<Course>> loadLocalCourses() async {
    debugPrint('=== MEMUAT MATA KULIAH LOKAL ===');

    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final List<dynamic> list = data['courses'] as List<dynamic>;

    final courses = list
        .map(
          (item) => Course.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    debugPrint('Jumlah mata kuliah lokal: ${courses.length}');

    return courses;
  }
 // Membuat mata kuliah baru melalui HTTP POST
  Future<Course> createCourse(Course course) async {
    debugPrint('=== MEMBUAT COURSE BARU ===');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    debugPrint('HTTP Status Code: ${response.statusCode}');

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return Course.fromJson(data);
    }

    throw Exception('Gagal membuat course');
  }

  // Memperbarui mata kuliah melalui HTTP PUT
  Future<void> updateCourse(int id, Course course) async {
    debugPrint('=== MEMPERBARUI COURSE ===');

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    debugPrint('HTTP Status Code: ${response.statusCode}');

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception('Gagal memperbarui course');
    }
  }
}