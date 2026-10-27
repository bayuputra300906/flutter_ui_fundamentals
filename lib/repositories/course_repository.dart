import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  // Digunakan untuk menampilkan lima mata kuliah lokal
  Future<List<Course>> getCourses() {
    return service.loadLocalCourses();
  }

  // Digunakan jika ingin mengambil data dari REST API
  Future<List<Course>> getCoursesFromApi() {
    return service.getCourses();
  }

  // Membuat mata kuliah baru
  Future<Course> createCourse(Course course) {
    return service.createCourse(course);
  }
}