import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/app_user.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  bool get isConfigured => SupabaseConfig.isConfigured;
  bool get isSignedIn => isConfigured && _client.auth.currentUser != null;
  String? get currentUserId => isConfigured ? _client.auth.currentUser?.id : null;

  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) {
    _requireConfigured();
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'phone': phone.trim(),
        'role': role,
      },
    );
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    _requireConfigured();
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final profile = await getCurrentProfile();
    if (profile == null) {
      throw AuthException('Profile not found for this account.');
    }
    return profile;
  }

  Future<AppUser?> getCurrentProfile() async {
    _requireConfigured();
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    final data = await _client.from('profiles').select().eq('id', authUser.id).maybeSingle();
    return data == null ? null : AppUser.fromJson(data);
  }

  Future<void> signOut() async {
    if (!isConfigured) return;
    await _client.auth.signOut();
  }

  void _requireConfigured() {
    if (!isConfigured) {
      throw AuthException(
        'Supabase is not configured. Start the app with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.',
      );
    }
  }
}
