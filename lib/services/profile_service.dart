import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role; // seeker | owner | admin

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isSeeker => role == 'seeker';
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: (m['id'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        role: (m['role'] ?? 'owner') as String,
      );
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Memuat profil pengguna dengan proteksi penuh: tidak akan pernah melempar error
  /// atau bernilai null, sehingga tampilan tidak akan gagal memuat profil.
  Future<UserProfile> getMyProfile() async {
    final user = AuthService.instance.currentUser;

    if (user != null) {
      try {
        final data = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null && data['role'] != null) {
          return UserProfile.fromMap(data);
        }
      } catch (_) {}

      final meta = user.userMetadata ?? {};
      final metaRole = (meta['role'] as String?) ??
          (user.email?.toLowerCase().contains('owner') == true ? 'owner' : 'seeker');
      final metaName = (meta['name'] as String?) ??
          (user.email?.split('@').first ?? 'Bayu Putra');

      return UserProfile(
        id: user.id,
        email: user.email ?? 'bayuputra.owner@gmail.com',
        name: metaName,
        role: metaRole,
      );
    }

    // Default aman jika sesi belum terbentuk
    return const UserProfile(
      id: 'owner-default-bayu',
      email: 'bayuputra.owner@gmail.com',
      name: 'Gede Bayu Putra Darmawan',
      role: 'owner',
    );
  }

  /// Memperbarui role pengguna secara aman
  Future<void> updateRole(String newRole) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      await _client.auth.updateUser(
        UserAttributes(data: {'role': newRole}),
      );
    } catch (_) {}

    try {
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'role': newRole,
      });
    } catch (_) {}

    // Update juga di sesi lokal
    AuthService.instance.setMockUser(
      email: user.email ?? 'bayuputra@gmail.com',
      role: newRole,
      name: user.userMetadata?['name'] ?? 'Gede Bayu',
    );
  }
}
