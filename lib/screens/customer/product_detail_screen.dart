import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/gradient_button.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  double _weightKg = 1.0;

  void _addToCart(Product product) {
    context.read<CartProvider>().addItem(
          product,
          quantity: _quantity,
          weightKg: _weightKg,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        backgroundColor: AppTheme.success,
        action: SnackBarAction(
          label: 'Lihat Keranjang',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Image SliverAppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppTheme.surfaceCard.withValues(alpha: 0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AppTheme.textPrimary, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  product.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _FallbackImage(),
                        )
                      : const _FallbackImage(),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.surface],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Flash sale badge
                  if (product.hasActiveFlashSale)
                    Positioned(
                      top: 80,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          '⚡ FLASH -${product.discountPercent.toInt()}%',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  if (product.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category!,
                        style: const TextStyle(
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        Formatters.currency(product.effectivePrice),
                        style: TextStyle(
                          color: product.hasActiveFlashSale
                              ? AppTheme.accent
                              : AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                      Text(
                        product.type == ProductType.perKg
                            ? '/kg'
                            : '/ekor',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      if (product.hasActiveFlashSale) ...[
                        const SizedBox(width: 12),
                        Text(
                          Formatters.currency(product.basePrice),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Weight info
                  if (product.minWeightKg != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.scale_outlined,
                            size: 16, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Perkiraan berat: ${Formatters.weight(product.minWeightKg!)}'
                          '${product.maxWeightKg != null ? ' - ${Formatters.weight(product.maxWeightKg!)}' : ''} per ekor',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Deskripsi Produk',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'Ayam segar potong langsung dari kandang pilihan, '
                            'dijamin halal dan bersih. Dipotong sesuai pesanan.'
                        : product.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Quality badges
                  Row(
                    children: [
                      _QualityBadge(icon: '🌙', label: 'Halal'),
                      const SizedBox(width: 8),
                      _QualityBadge(icon: '🌿', label: 'Segar'),
                      const SizedBox(width: 8),
                      _QualityBadge(icon: '✂️', label: 'Potong Langsung'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quantity selector
                  if (product.isAvailable && product.stock > 0) ...[
                    Text(
                      product.type == ProductType.perEkor
                          ? 'Jumlah (ekor)'
                          : 'Berat (kg)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    if (product.type == ProductType.perEkor)
                      Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            '$_quantity ekor',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(width: 20),
                          _QuantityButton(
                            icon: Icons.add,
                            onPressed: _quantity < product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      )
                    else
                      // Weight selector for perKg products
                      Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onPressed: _weightKg > product.weightStep
                                ? () => setState(() =>
                                    _weightKg -= product.weightStep)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            Formatters.weight(_weightKg),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(width: 20),
                          _QuantityButton(
                            icon: Icons.add,
                            onPressed: () =>
                                setState(() => _weightKg += product.weightStep),
                          ),
                        ],
                      ),
                    const SizedBox(height: 100),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom bar
      bottomNavigationBar: product.isAvailable && product.stock > 0
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceCard,
                border: Border(
                    top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                      Text(
                        Formatters.currency(
                          product.effectivePrice *
                              (product.type == ProductType.perEkor
                                  ? _quantity
                                  : _weightKg),
                        ),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientButton(
                      label: 'Tambah ke Keranjang',
                      icon: Icons.shopping_basket_outlined,
                      onPressed: () => _addToCart(product),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceElevated,
      child: const Center(
        child: Text('🍗', style: TextStyle(fontSize: 80)),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final String icon;
  final String label;

  const _QualityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: const Border.fromBorderSide(
            BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: disabled ? AppTheme.surfaceCard : AppTheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled ? AppTheme.divider : AppTheme.primary,
          ),
        ),
        child: Icon(
          icon,
          color: disabled ? AppTheme.textMuted : AppTheme.primary,
          size: 20,
        ),
      ),
    );
  }
}
