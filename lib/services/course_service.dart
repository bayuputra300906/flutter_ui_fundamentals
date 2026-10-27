import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/course.dart';

const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

class CourseService {
  // Fungsi lama: membaca mata kuliah dari JSON lokal.
  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;

    return list
        .map(
          (e) => Course.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

// Fungsi untuk menguji REST API menggunakan HTTP GET.
Future<List<Course>> fetchCourses() async {
  debugPrint('=== MULAI REST API ===');

  final response = await http.get(Uri.parse(apiUrl));

  debugPrint('HTTP Status Code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;

    final courses = data
        .map(
          (item) => Course.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    debugPrint('Jumlah item: ${courses.length}');

    return courses;
  }

  throw Exception('HTTP ${response.statusCode}');
}
}