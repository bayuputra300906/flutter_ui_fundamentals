import 'package:supabase_flutter/supabase_flutter.dart';

class KosService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser?.id ?? '';

  // Data kos awal sekitar kampus Undiksha jika database masih baru/kosong
  static final List<Map<String, dynamic>> _sampleKos = [
    {
      'id': 'kos-sample-01',
      'owner_id': 'owner-sample-id',
      'name': 'Kos Melati Kampus Tengah Undiksha',
      'address': 'Jl. Udayana No. 12, Singaraja, Bali',
      'price': 750000,
      'is_promoted': true,
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'kos-sample-02',
      'owner_id': 'owner-sample-id',
      'name': 'Kos Graha Mahasiswa Putri',
      'address': 'Jl. Ahmad Yani Gg. Remaja No. 5, Singaraja',
      'price': 650000,
      'is_promoted': true,
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'kos-sample-03',
      'owner_id': 'owner-sample-id',
      'name': 'Kos Eksklusif Garuda Putra',
      'address': 'Jl. Dewi Sartika No. 88, Buleleng',
      'price': 1200000,
      'is_promoted': false,
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
      if (list.isNotEmpty) {
        return list;
      }
    } catch (_) {}

    return List<Map<String, dynamic>>.from(_sampleKos);
  }

  Future<void> add({
    required String name,
    required String address,
    required int price,
    bool isPromoted = false,
  }) async {
    final newKos = {
      'owner_id': _uid,
      'name': name,
      'address': address,
      'price': price,
    };

    try {
      await _client.from('kos').insert(newKos);
    } catch (_) {
      // Jika RLS atau offline, simpan ke sample kos sementara untuk preview UI
      _sampleKos.insert(0, {
        'id': 'kos-local-${DateTime.now().millisecondsSinceEpoch}',
        'owner_id': _uid,
        'name': name,
        'address': address,
        'price': price,
        'is_promoted': isPromoted,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// true = berhasil, false = ditolak RLS / data tidak ditemukan
  Future<bool> update(String id, Map<String, dynamic> values) async {
    try {
      final rows =
          await _client.from('kos').update(values).eq('id', id).select();
      if (rows.isNotEmpty) return true;
    } catch (_) {}

    final index = _sampleKos.indexWhere((k) => k['id'] == id);
    if (index != -1 && _sampleKos[index]['owner_id'] == _uid) {
      _sampleKos[index].addAll(values);
      return true;
    }
    return false;
  }

  /// true = berhasil, false = ditolak RLS / data tidak ditemukan
  Future<bool> delete(String id) async {
    try {
      final rows = await _client.from('kos').delete().eq('id', id).select();
      if (rows.isNotEmpty) return true;
    } catch (_) {}

    final index = _sampleKos.indexWhere((k) => k['id'] == id);
    if (index != -1 && _sampleKos[index]['owner_id'] == _uid) {
      _sampleKos.removeAt(index);
      return true;
    }
    return false;
  }
}
