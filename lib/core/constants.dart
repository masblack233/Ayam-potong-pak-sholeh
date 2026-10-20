// ============================================================
// CONSTANTS — Ayam Potong Pak Soleh
// Ganti SUPABASE_URL & SUPABASE_ANON_KEY dengan nilai Anda
// ============================================================

class AppConstants {
  // ── Supabase ──────────────────────────────────────────────
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  // ── Toko ──────────────────────────────────────────────────
  static const String appName = 'Pak Soleh';
  static const String appTagline = 'Ayam Segar, Potong Langsung';
  static const String storeName = 'Ayam Potong Pak Soleh';
  static const String storeWhatsApp = '6281234567890'; // ganti nomor WA admin
  static const double storeLatitude = -6.200000;
  static const double storeLongitude = 106.816666;
  static const String storeAddress = 'Jl. Pasar Baru No. 1, Jakarta';
  static const String storeOpenTime = '06:00';
  static const String storeCloseTime = '18:00';

  // ── Pengiriman ────────────────────────────────────────────
  static const double deliveryPricePerKm = 3000;
  static const double maxDeliveryRadiusKm = 12.0;
  static const double freeDeliveryMinWeightKg = 5.0;
  static const double freeDeliveryMaxRadiusKm = 7.0;

  // ── Pembayaran ────────────────────────────────────────────
  static const int paymentTimeoutMinutes = 45;
  static const String bankName = 'BCA';
  static const String bankAccountNumber = '1234567890';
  static const String bankAccountName = 'SOLEH';

  // ── Supabase Storage Buckets ──────────────────────────────
  static const String bucketProducts = 'products';
  static const String bucketPayments = 'payment-proofs';

  // ── Warna Brand ───────────────────────────────────────────
  static const int colorPrimaryValue = 0xFFE8521A;    // oranye hangat
  static const int colorSecondaryValue = 0xFF1A1A2E;  // navy gelap
  static const int colorAccentValue = 0xFFF4C430;     // kuning emas
}
