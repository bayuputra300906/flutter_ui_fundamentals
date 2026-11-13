import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  User? _mockUser;
  bool _mockLoggedIn = false;

  User? get currentUser => _mockUser ?? _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => _mockLoggedIn || currentSession != null;

  void setMockUser({
    required String email,
    required String role,
    String name = '',
  }) {
    _mockLoggedIn = true;
    _mockUser = User(
      id: role == 'owner' ? 'owner-888-bayu' : 'seeker-111-bayu',
      appMetadata: const {},
      userMetadata: {
        'role': role,
        'name': name.isNotEmpty
            ? name
            : (role == 'owner'
                ? 'Gede Bayu (Pemilik Kos)'
                : 'Gede Bayu (Pencari Kos)'),
      },
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String name = '',
    String role = 'seeker', // 'seeker' atau 'owner'
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role}, // dibaca oleh trigger handle_new_user
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    _mockLoggedIn = false;
    _mockUser = null;
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    _mockLoggedIn = false;
    _mockUser = null;
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }
}
