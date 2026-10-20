import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_service.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => SupabaseService.isLoggedIn;
  bool get isAdmin => _profile?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    SupabaseService.authStream.listen((state) {
      if (state.event == AuthChangeEvent.signedIn) {
        _fetchProfile();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _profile = null;
        notifyListeners();
      }
    });
    if (SupabaseService.isLoggedIn) _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final userId = SupabaseService.currentUser!.id;
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      _profile = UserProfile.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch profile: $e');
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      if (response.user != null) {
        // Profile akan dibuat otomatis via Supabase Trigger
        await Future.delayed(const Duration(milliseconds: 800));
        await _fetchProfile();
        return null;
      }
      return 'Pendaftaran gagal, coba lagi.';
    } on AuthException catch (e) {
      _error = _mapAuthError(e.message);
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      _error = _mapAuthError(e.message);
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  Future<String?> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_profile == null) return 'Tidak terautentikasi';
    _isLoading = true;
    notifyListeners();

    try {
      final updated = _profile!.copyWith(name: name, phone: phone, address: address);
      await SupabaseService.client
          .from('profiles')
          .update(updated.toJson())
          .eq('id', _profile!.id);
      _profile = updated;
      return null;
    } catch (e) {
      return 'Gagal memperbarui profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapAuthError(String msg) {
    if (msg.contains('Invalid login credentials')) {
      return 'Email atau kata sandi salah.';
    } else if (msg.contains('Email not confirmed')) {
      return 'Silakan verifikasi email Anda terlebih dahulu.';
    } else if (msg.contains('already registered')) {
      return 'Email sudah terdaftar. Silakan masuk.';
    } else if (msg.contains('Password should be')) {
      return 'Kata sandi minimal 6 karakter.';
    }
    return msg;
  }
}
