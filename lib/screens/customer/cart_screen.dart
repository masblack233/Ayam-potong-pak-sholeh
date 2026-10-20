import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/formatters.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/gradient_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(
            title: Text('Keranjang (${cart.itemCount})'),
            backgroundColor: AppTheme.surface,
            actions: [
              if (cart.itemCount > 0)
                TextButton(
                  onPressed: () => _confirmClear(context, cart),
                  child: const Text(
                    'Kosongkan',
                    style: TextStyle(color: AppTheme.error, fontSize: 13),
                  ),
                ),
            ],
          ),
          body: cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🛒', style: TextStyle(fontSize: 72)),
                      const SizedBox(height: 16),
                      Text(
                        'Keranjang masih kosong',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan ayam segar ke keranjang Anda',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        onPressed: () => Navigator.pop(context),
                        label: 'Belanja Sekarang',
                        width: 200,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Info bar
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Total berat: ${Formatters.weight(cart.totalWeightKg)}'
                              '  •  Gratis ongkir ≥ ${AppConstants.freeDeliveryMinWeightKg.toInt()} kg (radius ${AppConstants.freeDeliveryMaxRadiusKm.toInt()} km)',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Items list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, i) {
                          final item = cart.items[i];
                          return _CartItemTile(
                            item: item,
                            onIncrease: () => cart.updateItem(
                              item.product.id,
                              quantity: item.quantity + 1,
                            ),
                            onDecrease: () => cart.updateItem(
                              item.product.id,
                              quantity: item.quantity - 1,
                            ),
                            onRemove: () =>
                                cart.removeItem(item.product.id),
                          );
                        },
                      ),
                    ),

                    // Bottom summary
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceCard,
                        border: Border(
                            top: BorderSide(color: AppTheme.divider)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Subtotal',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Spacer(),
                              Text(
                                Formatters.currency(cart.subtotal),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.checkout),
                            label: 'Lanjut ke Checkout',
                            icon: Icons.arrow_forward,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _confirmClear(BuildContext ctx, CartProvider cart) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Kosongkan Keranjang?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Semua item akan dihapus dari keranjang.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(_);
            },
            child: const Text('Hapus', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
            BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.product.imageUrl != null
                  ? Image.network(
                      item.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('🍗', style: TextStyle(fontSize: 32)),
                      ),
                    )
                  : const Center(
                      child: Text('🍗', style: TextStyle(fontSize: 32)),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(item.product.effectivePrice) +
                      (item.product.type.name == 'perKg' ? '/kg' : '/ekor'),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Qty controls
                    _QtyBtn(icon: Icons.remove, onPressed: onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _QtyBtn(icon: Icons.add, onPressed: onIncrease),
                    const Spacer(),
                    Text(
                      Formatters.currency(item.subtotal),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppTheme.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QtyBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: const Border.fromBorderSide(
              BorderSide(color: AppTheme.divider)),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textPrimary),
      ),
    );
  }
}
