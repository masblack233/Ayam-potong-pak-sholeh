import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../models/product.dart';

class FlashSaleBanner extends StatefulWidget {
  final List<Product> products;
  final void Function(Product) onProductTap;

  const FlashSaleBanner({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<FlashSaleBanner> createState() => _FlashSaleBannerState();
}

class _FlashSaleBannerState extends State<FlashSaleBanner> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (!mounted) return;
    if (widget.products.isEmpty) return;
    final end = widget.products.first.flashSaleEnd;
    if (end == null) return;
    final r = end.difference(DateTime.now());
    setState(() => _remaining = r.isNegative ? Duration.zero : r);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A00), Color(0xFF3D1500), Color(0xFF1A0A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⚡', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 4),
                      Text(
                        'FLASH SALE',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Countdown
                _CountdownSegment(label: 'JAM', value: _remaining.inHours.remainder(24)),
                _colon(),
                _CountdownSegment(label: 'MNT', value: _remaining.inMinutes.remainder(60)),
                _colon(),
                _CountdownSegment(label: 'DTK', value: _remaining.inSeconds.remainder(60)),
              ],
            ),
          ),

          // Products horizontal scroll
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              itemCount: widget.products.length,
              itemBuilder: (ctx, i) {
                final p = widget.products[i];
                return GestureDetector(
                  onTap: () => widget.onProductTap(p),
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                            child: p.imageUrl != null
                                ? Image.network(
                                    p.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Text('🍗', style: TextStyle(fontSize: 40)),
                                    ),
                                  )
                                : const Center(
                                    child: Text('🍗', style: TextStyle(fontSize: 40)),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Formatters.currency(p.flashSalePrice!),
                                style: const TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                Formatters.currency(p.basePrice),
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _colon() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          ':',
          style: TextStyle(
            color: AppTheme.accent,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      );
}

class _CountdownSegment extends StatelessWidget {
  final String label;
  final int value;

  const _CountdownSegment({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
