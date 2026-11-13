import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const u = User(
    id: 'demo-1',
    appMetadata: {},
    userMetadata: {'role': 'owner'},
    aud: 'authenticated',
    createdAt: '2026-01-01',
    email: 'test@example.com',
  );
  print('User created successfully: ');
}
