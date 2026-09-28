/// Isi dengan data project Supabase Anda:
/// Dashboard -> Project Settings -> API
///
/// `anonKey` aman ditaruh di aplikasi karena akses data
/// dilindungi Row Level Security (lihat supabase/schema.sql).
/// JANGAN pernah memasukkan `service_role` key ke aplikasi.
class SupabaseConfig {
  static const String url = 'https://tetzwfmyigxnhzbjyhyt.supabase.co';
  static const String anonKey = 'sb_publishable_UIPWhJxGBRUjjA5N7Sp2_A_9fd-6d7w';

  static bool get isConfigured =>
      !url.contains('YOUR-PROJECT-REF') && !anonKey.contains('YOUR-ANON-KEY');
}
