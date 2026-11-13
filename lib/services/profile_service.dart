import 'package:supabase_flutter/supabase_flutter.dart';

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
        id: m['id'] as String,
        email: (m['email'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        role: (m['role'] ?? 'seeker') as String,
      );
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfile?> getMyProfile() async {
    final user = _client.auth.currentUser; // currentUser
    if (user == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromMap(data);
      }
    } catch (_) {}

    // Fallback dari user_metadata jika profiles belum ada
    final meta = user.userMetadata ?? {};
    final metaRole = (meta['role'] as String?) ?? 'seeker';
    final metaName = (meta['name'] as String?) ?? user.email?.split('@').first ?? '';

    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      name: metaName,
      role: metaRole,
    );
  }

  /// Memperbarui role pengguna (berguna untuk pengujian peran Seeker vs Owner)
  Future<void> updateRole(String newRole) async {
    final user = _client.auth.currentUser;
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
  }
}
