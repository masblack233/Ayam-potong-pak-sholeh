import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/enums.dart';
import '../core/formatters.dart';
import '../models/order.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderTile({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.dateTime(order.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: order.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 12),

            // Items preview
            Text(
              '${order.items.length} item — '
              '${order.items.take(2).map((i) => i['product_name']).join(', ')}'
              '${order.items.length > 2 ? '...' : ''}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),

            // Bottom row
            Row(
              children: [
                Icon(
                  order.deliveryMethod == DeliveryMethod.antar
                      ? Icons.delivery_dining_outlined
                      : Icons.store_outlined,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  order.deliveryMethod == DeliveryMethod.antar
                      ? 'Diantar'
                      : 'Ambil Sendiri',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  Formatters.currency(order.totalAmount),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // Payment countdown
            if (order.status == OrderStatus.menungguPembayaran &&
                !order.isExpired) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 14, color: AppTheme.warning),
                    const SizedBox(width: 6),
                    Text(
                      'Bayar dalam ${Formatters.countdown(order.remainingPaymentTime)}',
                      style: const TextStyle(
                          color: AppTheme.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.menungguPembayaran:
        return AppTheme.warning;
      case OrderStatus.menungguVerifikasi:
        return AppTheme.info;
      case OrderStatus.diVerifikasi:
      case OrderStatus.diproses:
        return AppTheme.primary;
      case OrderStatus.siapAntar:
      case OrderStatus.dalamPengiriman:
        return AppTheme.accent;
      case OrderStatus.selesai:
        return AppTheme.success;
      case OrderStatus.dibatalkan:
        return AppTheme.error;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
