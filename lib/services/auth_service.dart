import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  /// Nama yang ditampilkan di layar (nama profil, atau bagian depan email).
  static String get displayName {
    final user = currentUser;
    if (user == null) return '';
    final name = user.userMetadata?['full_name'];
    if (name is String && name.trim().isNotEmpty) return name;
    return (user.email ?? '').split('@').first;
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() => _client.auth.signOut();
}
