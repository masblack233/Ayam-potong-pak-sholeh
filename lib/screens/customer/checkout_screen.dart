import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/formatters.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/enums.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DeliveryMethod _deliveryMethod = DeliveryMethod.ambilSendiri;
  final _addressCtrl = TextEditingController();
  double _distanceKm = 0;
  double _deliveryFee = 0;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  void _onDeliveryMethodChanged(DeliveryMethod? m) {
    if (m == null) return;
    setState(() {
      _deliveryMethod = m;
      if (m == DeliveryMethod.ambilSendiri) {
        _distanceKm = 0;
        _deliveryFee = 0;
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_deliveryMethod == DeliveryMethod.antar &&
        _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat pengiriman wajib diisi'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();

    final order = await orderProv.createOrder(
      items: cart.items.toList(),
      subtotal: cart.subtotal,
      deliveryFee: _deliveryFee,
      deliveryMethod: _deliveryMethod,
      deliveryAddress: _deliveryMethod == DeliveryMethod.antar
          ? _addressCtrl.text.trim()
          : null,
      distanceKm: _distanceKm > 0 ? _distanceKm : null,
    );

    if (!mounted) return;
    if (order != null) {
      cart.clear();
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.payment,
        arguments: order,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProv.error ?? 'Gagal membuat pesanan'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orderProv = context.watch<OrderProvider>();
    final uniqueCode = cart.generateUniqueCode();
    final total = cart.subtotal + _deliveryFee + uniqueCode;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery method
            Text(
              'Metode Pengambilan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            // Ambil sendiri card
            _DeliveryOptionCard(
              title: 'Ambil di Toko',
              subtitle: AppConstants.storeAddress,
              icon: Icons.store_outlined,
              isSelected: _deliveryMethod == DeliveryMethod.ambilSendiri,
              onTap: () => _onDeliveryMethodChanged(DeliveryMethod.ambilSendiri),
            ),
            const SizedBox(height: 10),

            // Antar card
            _DeliveryOptionCard(
              title: 'Diantar ke Alamat',
              subtitle: 'Radius maks ${AppConstants.maxDeliveryRadiusKm.toInt()} km dari toko',
              icon: Icons.delivery_dining_outlined,
              isSelected: _deliveryMethod == DeliveryMethod.antar,
              onTap: () => _onDeliveryMethodChanged(DeliveryMethod.antar),
            ),

            // Address input
            if (_deliveryMethod == DeliveryMethod.antar) ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressCtrl,
                label: 'Alamat Lengkap',
                hint: 'Jl. Contoh No. 1, RT/RW, Kel, Kec',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 3,
                onChanged: (v) {
                  // Simulasi perhitungan ongkir (di prod pakai OSRM)
                  setState(() {
                    _distanceKm = 5.0; // placeholder
                    _deliveryFee = cart.computeDeliveryFee(_distanceKm);
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                '💡 Ongkir dihitung dari lokasi toko. Gratis ongkir ≥ ${AppConstants.freeDeliveryMinWeightKg.toInt()} kg dalam radius ${AppConstants.freeDeliveryMaxRadiusKm.toInt()} km.',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],

            const SizedBox(height: 28),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 20),

            // Order items summary
            Text(
              'Ringkasan Pesanan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} ×${item.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        Formatters.currency(item.subtotal),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 12),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 12),

            _SummaryRow('Subtotal', Formatters.currency(cart.subtotal)),
            if (_deliveryFee > 0)
              _SummaryRow('Ongkos Kirim', Formatters.currency(_deliveryFee)),
            if (_deliveryFee == 0 && _deliveryMethod == DeliveryMethod.antar)
              const _SummaryRow('Ongkos Kirim', 'GRATIS'),
            _SummaryRow('Kode Unik', '+$uniqueCode',
                color: AppTheme.textMuted, small: true),

            const Divider(color: AppTheme.divider),
            const SizedBox(height: 8),
            _SummaryRow('TOTAL BAYAR', Formatters.currency(total),
                color: AppTheme.primary, large: true),

            // Unique code info
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_outlined,
                      size: 16, color: AppTheme.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kode unik 3 digit ditambahkan untuk keamanan verifikasi pembayaran Anda.',
                      style: const TextStyle(
                          color: AppTheme.info, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            GradientButton(
              onPressed: orderProv.isLoading ? null : _placeOrder,
              isLoading: orderProv.isLoading,
              label: 'Buat Pesanan',
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DeliveryOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.2)
                    : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isSelected ? AppTheme.primary : AppTheme.textMuted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppTheme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool large;
  final bool small;

  const _SummaryRow(this.label, this.value,
      {this.color, this.large = false, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color ?? AppTheme.textSecondary,
              fontSize: small ? 12 : (large ? 15 : 14),
              fontWeight: large ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppTheme.textPrimary,
              fontSize: small ? 12 : (large ? 18 : 14),
              fontWeight: large ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
