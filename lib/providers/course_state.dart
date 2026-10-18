import 'package:flutter/foundation.dart';

class CourseState extends ChangeNotifier {
  // Menyimpan daftar mata kuliah favorit.
  final Set<String> favorites = {};

  // Memeriksa apakah mata kuliah sudah menjadi favorit.
  bool isFavorite(String id) {
    return favorites.contains(id);
  }

  // Menambah atau menghapus mata kuliah dari favorit.
  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    // Memberi tahu widget bahwa data favorit berubah.
    notifyListeners();
  }

  // Menghapus semua mata kuliah favorit.
  void clearFavorites() {
    if (favorites.isEmpty) {
      return;
    }

    favorites.clear();
    notifyListeners();
  }

  // Menghitung jumlah mata kuliah favorit.
  int get totalFavorites => favorites.length;
}

class Course {
  final String code;
  final String title;
  final int credits;
  final String status;

  Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: json['status'] as String,
    );
  }
}
