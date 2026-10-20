import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // ── Auth helpers ──────────────────────────────────────────
  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static Stream<AuthState> get authStream => client.auth.onAuthStateChange;

  // ── Storage URL helpers ───────────────────────────────────
  static String getProductImageUrl(String path) =>
      client.storage.from(AppConstants.bucketProducts).getPublicUrl(path);

  static Future<String> getPaymentProofSignedUrl(String path) async {
    final response = await client.storage
        .from(AppConstants.bucketPayments)
        .createSignedUrl(path, 3600); // 1 hour
    return response;
  }
}
