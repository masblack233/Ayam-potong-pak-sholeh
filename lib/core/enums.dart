// ── Enums ──────────────────────────────────────────────────

enum UserRole { customer, admin }

enum OrderStatus {
  menungguPembayaran,
  menungguVerifikasi,
  diVerifikasi,
  diproses,
  siapAntar,
  dalamPengiriman,
  selesai,
  dibatalkan,
}

enum DeliveryMethod { antar, ambilSendiri }

enum ProductType { perEkor, perKg }

// ── Extensions ─────────────────────────────────────────────

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.menungguPembayaran: return 'Menunggu Pembayaran';
      case OrderStatus.menungguVerifikasi: return 'Menunggu Verifikasi';
      case OrderStatus.diVerifikasi: return 'Pembayaran Terverifikasi';
      case OrderStatus.diproses: return 'Sedang Diproses';
      case OrderStatus.siapAntar: return 'Siap Diantar';
      case OrderStatus.dalamPengiriman: return 'Dalam Pengiriman';
      case OrderStatus.selesai: return 'Selesai';
      case OrderStatus.dibatalkan: return 'Dibatalkan';
    }
  }

  String get dbValue {
    switch (this) {
      case OrderStatus.menungguPembayaran: return 'menunggu_pembayaran';
      case OrderStatus.menungguVerifikasi: return 'menunggu_verifikasi';
      case OrderStatus.diVerifikasi: return 'di_verifikasi';
      case OrderStatus.diproses: return 'diproses';
      case OrderStatus.siapAntar: return 'siap_antar';
      case OrderStatus.dalamPengiriman: return 'dalam_pengiriman';
      case OrderStatus.selesai: return 'selesai';
      case OrderStatus.dibatalkan: return 'dibatalkan';
    }
  }

  static OrderStatus fromDb(String s) {
    switch (s) {
      case 'menunggu_pembayaran': return OrderStatus.menungguPembayaran;
      case 'menunggu_verifikasi': return OrderStatus.menungguVerifikasi;
      case 'di_verifikasi': return OrderStatus.diVerifikasi;
      case 'diproses': return OrderStatus.diproses;
      case 'siap_antar': return OrderStatus.siapAntar;
      case 'dalam_pengiriman': return OrderStatus.dalamPengiriman;
      case 'selesai': return OrderStatus.selesai;
      case 'dibatalkan': return OrderStatus.dibatalkan;
      default: return OrderStatus.menungguPembayaran;
    }
  }
}
