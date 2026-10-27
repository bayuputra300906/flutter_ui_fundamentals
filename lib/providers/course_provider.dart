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
    final createdCourse = await repository.createCourse(course);

    // Tambahkan hasil POST ke daftar saat ini.
    courses = [...courses, createdCourse];
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
  // Memperbarui mata kuliah dan memuat ulang daftar
  Future<void> updateCourse(int id, Course course) async {
    if (isSaving) return;

    isSaving = true;
    error = null;
    notifyListeners();

    try {
      await repository.updateCourse(id, course);

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
Future<void> deleteCourse(int id) async {
  if (isSaving) return;

  isSaving = true;
  error = null;
  notifyListeners();

  try {
    await repository.deleteCourse(id);

    // Hapus mata kuliah dari daftar lokal setelah DELETE berhasil.
    courses = courses.where((course) => course.id != id).toList();
  } catch (e) {
    error = e.toString();
    rethrow;
  } finally {
    isSaving = false;
    notifyListeners();
  }
}
}
