import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  bool isSaving = false;
  String? error;

  Future<void> createCourse(Course course) async {
  if (isSaving) return;

  isSaving = true;
  error = null;
  notifyListeners();

  try {
    await repository.createCourse(course);

    // Muat ulang daftar mata kuliah.
    await loadCourses();
  } catch (e) {
    error = e.toString();
    rethrow;
  } finally {
    isSaving = false;
    notifyListeners();
  }
}

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
