import '../core/enums.dart';

class Order {
  final String id;
  final String userId;
  final String orderNumber;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final int uniqueCode;
  final double totalAmount;       // subtotal + deliveryFee + uniqueCode
  final OrderStatus status;
  final DeliveryMethod deliveryMethod;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? distanceKm;
  final String? pickupCode;
  final String? cancellationReason;
  final String? paymentProofPath;
  final String? paymentProofHash;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? verifiedAt;
  final DateTime? completedAt;
  final DateTime? paymentDeadline;

  const Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.uniqueCode,
    required this.totalAmount,
    required this.status,
    required this.deliveryMethod,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.distanceKm,
    this.pickupCode,
    this.cancellationReason,
    this.paymentProofPath,
    this.paymentProofHash,
    required this.createdAt,
    this.paidAt,
    this.verifiedAt,
    this.completedAt,
    this.paymentDeadline,
  });

  bool get isExpired =>
      paymentDeadline != null &&
      DateTime.now().isAfter(paymentDeadline!) &&
      status == OrderStatus.menungguPembayaran;

  Duration get remainingPaymentTime {
    if (paymentDeadline == null) return Duration.zero;
    final remaining = paymentDeadline!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        orderNumber: json['order_number'] as String,
        items: List<Map<String, dynamic>>.from(json['items'] as List),
        subtotal: (json['subtotal'] as num).toDouble(),
        deliveryFee: (json['delivery_fee'] as num).toDouble(),
        uniqueCode: json['unique_code'] as int,
        totalAmount: (json['total_amount'] as num).toDouble(),
        status: OrderStatusExt.fromDb(json['status'] as String),
        deliveryMethod: json['delivery_method'] == 'antar'
            ? DeliveryMethod.antar
            : DeliveryMethod.ambilSendiri,
        deliveryAddress: json['delivery_address'] as String?,
        deliveryLat: (json['delivery_lat'] as num?)?.toDouble(),
        deliveryLng: (json['delivery_lng'] as num?)?.toDouble(),
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        pickupCode: json['pickup_code'] as String?,
        cancellationReason: json['cancellation_reason'] as String?,
        paymentProofPath: json['payment_proof_path'] as String?,
        paymentProofHash: json['payment_proof_hash'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        paidAt: json['paid_at'] != null
            ? DateTime.parse(json['paid_at'] as String)
            : null,
        verifiedAt: json['verified_at'] != null
            ? DateTime.parse(json['verified_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        paymentDeadline: json['payment_deadline'] != null
            ? DateTime.parse(json['payment_deadline'] as String)
            : null,
      );
}
