import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: product.hasActiveFlashSale
                ? AppTheme.accent.withValues(alpha: 0.5)
                : AppTheme.divider,
          ),
          boxShadow: product.hasActiveFlashSale
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    blurRadius: 16,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: product.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _shimmer(),
                            errorWidget: (_, __, ___) => _fallbackImage(),
                          )
                        : _fallbackImage(),
                  ),
                ),
                // Flash sale badge
                if (product.hasActiveFlashSale)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 2),
                          Text(
                            'FLASH -${product.discountPercent.toInt()}%',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Sold out overlay
                if (!product.isAvailable || product.stock == 0)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        child: const Center(
                          child: Text(
                            'HABIS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  if (product.category != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category!,
                        style: const TextStyle(
                          color: AppTheme.primaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Weight info
                  if (product.minWeightKg != null)
                    Text(
                      '~${Formatters.weight(product.minWeightKg!)}'
                      '${product.maxWeightKg != null ? ' - ${Formatters.weight(product.maxWeightKg!)}' : ''}/ekor',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.currency(product.effectivePrice),
                              style: TextStyle(
                                color: product.hasActiveFlashSale
                                    ? AppTheme.accent
                                    : AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            if (product.hasActiveFlashSale) ...[
                              Text(
                                Formatters.currency(product.basePrice),
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Add to cart button
                      if (product.isAvailable && product.stock > 0)
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceCard,
      highlightColor: AppTheme.surfaceElevated,
      child: Container(color: AppTheme.surfaceCard),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: AppTheme.surfaceElevated,
      child: const Center(
        child: Text('🍗', style: TextStyle(fontSize: 48)),
      ),
    );
  }
}
