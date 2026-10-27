import '../models/course.dart';
import '../services/course_data_source.dart';

class CourseRepository {
  final CourseDataSource dataSource;

  CourseRepository(this.dataSource);

  // Mengambil daftar mata kuliah
  Future<List<Course>> getCourses() {
    return dataSource.getCourses();
  }

  // Menambahkan mata kuliah
  Future<Course> createCourse(Course course) {
    return dataSource.createCourse(course);
  }

  // Memperbarui mata kuliah
  Future<void> updateCourse(int id, Course course) {
    return dataSource.updateCourse(id, course);
  }

  // Menghapus mata kuliah
  Future<void> deleteCourse(int id) {
    return dataSource.deleteCourse(id);
  }
}