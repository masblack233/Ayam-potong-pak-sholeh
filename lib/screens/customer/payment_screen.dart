import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/formatters.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/gradient_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _uploading = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1920,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _uploadProof(Order order) async {
    if (_selectedImage == null) return;
    setState(() => _uploading = true);

    final success = await context.read<OrderProvider>().uploadPaymentProof(
          orderId: order.id,
          imageFile: _selectedImage!,
        );

    if (!mounted) return;
    setState(() => _uploading = false);

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<OrderProvider>().error ??
              'Gagal mengunggah bukti bayar'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_circle,
                    color: AppTheme.success, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bukti Bayar Dikirim!',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Admin akan memverifikasi pembayaran Anda. Harap tunggu konfirmasi via WhatsApp.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            GradientButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.home, (_) => false);
              },
              label: 'Kembali ke Toko',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chatAdmin() async {
    final uri = Uri.parse('https://wa.me/${AppConstants.storeWhatsApp}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.home, (_) => false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Order number card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: const Border.fromBorderSide(
                    BorderSide(color: AppTheme.divider)),
              ),
              child: Column(
                children: [
                  const Text(
                    'No. Pesanan',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total amount (animated pulse)
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) => Transform.scale(
                scale: _pulse.value,
                child: child,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A2A0A), Color(0xFF0A2A1A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL YANG HARUS DIBAYAR',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.currency(order.totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Termasuk kode unik: +${order.uniqueCode}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Countdown timer
            _CountdownTimer(deadline: order.paymentDeadline),

            const SizedBox(height: 20),

            // Bank info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: const Border.fromBorderSide(
                    BorderSide(color: AppTheme.divider)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transfer ke Rekening',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005EB8).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF005EB8)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'BCA',
                          style: TextStyle(
                            color: Color(0xFF4FA3E0),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppConstants.bankAccountNumber,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text:
                                            AppConstants.bankAccountNumber));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text('Nomor rekening disalin'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.copy_rounded,
                                    size: 18,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'a.n. ${AppConstants.bankAccountName}',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: '${AppConstants.bankAccountNumber}|${order.totalAmount}|${order.orderNumber}',
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'QR Code QRIS Pembayaran',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upload proof section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedImage != null
                      ? AppTheme.success.withValues(alpha: 0.5)
                      : AppTheme.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Bukti Pembayaran',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Screenshot/foto struk transfer yang valid',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.divider,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedImage != null
                                ? Icons.image_outlined
                                : Icons.cloud_upload_outlined,
                            size: 36,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedImage != null
                                ? 'Ganti Foto'
                                : 'Pilih dari Galeri',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GradientButton(
              onPressed: _selectedImage == null || _uploading
                  ? null
                  : () => _uploadProof(order),
              isLoading: _uploading,
              label: 'Konfirmasi Pembayaran',
              icon: Icons.check_circle_outline,
            ),

            const SizedBox(height: 16),

            // WhatsApp chat
            OutlinedButton.icon(
              onPressed: _chatAdmin,
              icon: const Text('💬', style: TextStyle(fontSize: 16)),
              label: const Text('Chat Admin via WhatsApp'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF25D366),
                side: const BorderSide(color: Color(0xFF25D366)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Countdown timer widget
class _CountdownTimer extends StatefulWidget {
  final DateTime? deadline;
  const _CountdownTimer({this.deadline});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Duration _remaining = Duration.zero;
  late final timer = Stream.periodic(const Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    if (widget.deadline == null) return const SizedBox.shrink();
    final remaining = widget.deadline!.difference(DateTime.now());
    if (remaining.isNegative) return const SizedBox.shrink();

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (_, __) {
        final r = widget.deadline!.difference(DateTime.now());
        if (r.isNegative) return const SizedBox.shrink();

        final isUrgent = r.inMinutes < 10;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUrgent
                ? AppTheme.error.withValues(alpha: 0.1)
                : AppTheme.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUrgent
                  ? AppTheme.error.withValues(alpha: 0.4)
                  : AppTheme.warning.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: isUrgent ? AppTheme.error : AppTheme.warning,
              ),
              const SizedBox(width: 8),
              Text(
                'Bayar dalam ${Formatters.countdown(r)}',
                style: TextStyle(
                  color: isUrgent ? AppTheme.error : AppTheme.warning,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
