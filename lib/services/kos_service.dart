import 'package:supabase_flutter/supabase_flutter.dart';

class KosService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser?.id ?? '';

  // Data kos awal sekitar kampus Undiksha
  // Foto menggunakan URL gambar publik (Unsplash) sebagai contoh
  static final List<Map<String, dynamic>> _sampleKos = [
    {
      'id': 'kos-sample-01',
      'owner_id': 'owner-sample-id',
      'name': 'Kos Melati Kampus Tengah Undiksha',
      'address': 'Jl. Udayana No. 12, Singaraja, Bali',
      'price': 750000,
      'is_promoted': true,
      'kamar_mandi': 'dalam',
      'foto_kos':
          'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=600&q=80',
      'foto_kamar':
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80',
      'deskripsi':
          'Kos nyaman dekat kampus Undiksha, fasilitas lengkap, air panas, WiFi kencang.',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'kos-sample-02',
      'owner_id': 'owner-sample-id',
      'name': 'Kos Graha Mahasiswa Putri',
      'address': 'Jl. Ahmad Yani Gg. Remaja No. 5, Singaraja',
      'price': 650000,
      'is_promoted': true,
      'kamar_mandi': 'luar',
      'foto_kos':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&q=80',
      'foto_kamar':
          'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=600&q=80',
      'deskripsi':
          'Kos khusus putri, aman, ada keamanan 24 jam, kamar bersih dan terawat.',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'kos-sample-03',
      'owner_id': 'owner-sample-id',
      'name': 'Kos Eksklusif Garuda Putra',
      'address': 'Jl. Dewi Sartika No. 88, Buleleng',
      'price': 1200000,
      'is_promoted': false,
      'kamar_mandi': 'dalam',
      'foto_kos':
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&q=80',
      'foto_kamar':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
      'deskripsi':
          'Kos premium dengan AC, kamar mandi dalam, parkir luas, dan dapur bersama.',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  Future<List<Map<String, dynamic>>> fetchAll() async {
    try {
      final data = await _client
          .from('kos')
          .select()
          .order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(data);
      if (list.isNotEmpty) return list;
    } catch (_) {}

    return List<Map<String, dynamic>>.from(_sampleKos);
  }

  Future<void> add({
    required String name,
    required String address,
    required int price,
    bool isPromoted = false,
    String kamarMandi = 'dalam',
    String fotoKos = '',
    String fotoKamar = '',
    String deskripsi = '',
  }) async {
    final newKos = {
      'owner_id': _uid,
      'name': name,
      'address': address,
      'price': price,
      'kamar_mandi': kamarMandi,
      'foto_kos': fotoKos,
      'foto_kamar': fotoKamar,
      'deskripsi': deskripsi,
    };

    try {
      await _client.from('kos').insert(newKos);
    } catch (_) {
      _sampleKos.insert(0, {
        'id': 'kos-local-${DateTime.now().millisecondsSinceEpoch}',
        'owner_id': _uid,
        'name': name,
        'address': address,
        'price': price,
        'is_promoted': isPromoted,
        'kamar_mandi': kamarMandi,
        'foto_kos': fotoKos,
        'foto_kamar': fotoKamar,
        'deskripsi': deskripsi,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<bool> update(String id, Map<String, dynamic> values) async {
    try {
      final rows =
          await _client.from('kos').update(values).eq('id', id).select();
      if (rows.isNotEmpty) return true;
    } catch (_) {}

    final index = _sampleKos.indexWhere((k) => k['id'] == id);
    if (index != -1) {
      _sampleKos[index].addAll(values);
      return true;
    }
    return false;
  }

  Future<bool> delete(String id) async {
    try {
      final rows = await _client.from('kos').delete().eq('id', id).select();
      if (rows.isNotEmpty) return true;
    } catch (_) {}

    final index = _sampleKos.indexWhere((k) => k['id'] == id);
    if (index != -1) {
      _sampleKos.removeAt(index);
      return true;
    }
    return false;
  }
}
