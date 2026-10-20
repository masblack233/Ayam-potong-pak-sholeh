import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/supabase_service.dart';
import '../core/constants.dart';
import '../core/enums.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Ambil riwayat pesanan ──────────────────────────────────
  Future<void> fetchMyOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final userId = SupabaseService.currentUser!.id;
      final data = await SupabaseService.client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      _orders = (data as List).map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      _error = 'Gagal memuat pesanan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Ambil semua pesanan (admin) ────────────────────────────
  Future<List<Order>> fetchAllOrders({String? statusFilter}) async {
    try {
      var query = SupabaseService.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      final data = await query;
      final allOrders = (data as List).map((e) => Order.fromJson(e)).toList();

      if (statusFilter != null) {
        return allOrders
            .where((o) => o.status.dbValue == statusFilter)
            .toList();
      }
      return allOrders;
    } catch (e) {
      return [];
    }
  }

  // ── Buat pesanan baru ─────────────────────────────────────
  Future<Order?> createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required DeliveryMethod deliveryMethod,
    String? deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    double? distanceKm,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = SupabaseService.currentUser!.id;
      final uniqueCode = 100 + (DateTime.now().millisecondsSinceEpoch % 900);
      final totalAmount = subtotal + deliveryFee + uniqueCode;
      final orderNumber =
          'PS${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final pickupCode = deliveryMethod == DeliveryMethod.ambilSendiri
          ? (1000 + DateTime.now().second * 17 % 9000).toString()
          : null;
      final deadline =
          DateTime.now().add(Duration(minutes: AppConstants.paymentTimeoutMinutes));

      final itemsJson = items.map((i) => i.toOrderItem()).toList();

      final insertData = {
        'user_id': userId,
        'order_number': orderNumber,
        'items': itemsJson,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'unique_code': uniqueCode,
        'total_amount': totalAmount,
        'status': OrderStatus.menungguPembayaran.dbValue,
        'delivery_method':
            deliveryMethod == DeliveryMethod.antar ? 'antar' : 'ambil_sendiri',
        'delivery_address': deliveryAddress,
        'delivery_lat': deliveryLat,
        'delivery_lng': deliveryLng,
        'distance_km': distanceKm,
        'pickup_code': pickupCode,
        'payment_deadline': deadline.toIso8601String(),
      };

      final response = await SupabaseService.client
          .from('orders')
          .insert(insertData)
          .select()
          .single();

      _currentOrder = Order.fromJson(response);
      _orders.insert(0, _currentOrder!);
      return _currentOrder;
    } catch (e) {
      _error = 'Gagal membuat pesanan: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Upload bukti bayar ────────────────────────────────────
  Future<bool> uploadPaymentProof({
    required String orderId,
    required File imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Hitung SHA-256 hash untuk deduplikasi
      final bytes = await imageFile.readAsBytes();
      final hash = sha256.convert(bytes).toString();

      // 2. Cek duplikasi hash
      final existing = await SupabaseService.client
          .from('orders')
          .select('id')
          .eq('payment_proof_hash', hash)
          .maybeSingle();
      if (existing != null) {
        _error = 'Bukti bayar ini sudah digunakan untuk pesanan lain.';
        return false;
      }

      // 3. Upload ke storage
      final path = 'proofs/$orderId/${const Uuid().v4()}.jpg';
      await SupabaseService.client.storage
          .from(AppConstants.bucketPayments)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ));

      // 4. Update order
      await SupabaseService.client.from('orders').update({
        'status': OrderStatus.menungguVerifikasi.dbValue,
        'payment_proof_path': path,
        'payment_proof_hash': hash,
        'paid_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      // Refresh current order
      final updated = await SupabaseService.client
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();
      _currentOrder = Order.fromJson(updated);

      // Update in list
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) _orders[idx] = _currentOrder!;

      return true;
    } catch (e) {
      _error = 'Gagal mengunggah bukti bayar: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Admin: Verifikasi pembayaran ───────────────────────────
  Future<bool> verifyPayment(String orderId, {bool approved = true}) async {
    try {
      final newStatus = approved
          ? OrderStatus.diVerifikasi.dbValue
          : OrderStatus.dibatalkan.dbValue;

      await SupabaseService.client.from('orders').update({
        'status': newStatus,
        'verified_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        final updated = await SupabaseService.client
            .from('orders')
            .select()
            .eq('id', orderId)
            .single();
        _orders[idx] = Order.fromJson(updated);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Gagal memverifikasi: $e';
      return false;
    }
  }

  // ── Admin: Update status pesanan ──────────────────────────
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final update = <String, dynamic>{'status': status.dbValue};
      if (status == OrderStatus.selesai) {
        update['completed_at'] = DateTime.now().toIso8601String();
      }

      await SupabaseService.client
          .from('orders')
          .update(update)
          .eq('id', orderId);

      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        final updated = await SupabaseService.client
            .from('orders')
            .select()
            .eq('id', orderId)
            .single();
        _orders[idx] = Order.fromJson(updated);
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void setCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners();
  }
}
