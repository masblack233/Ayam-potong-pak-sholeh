import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/formatters.dart';
import '../../core/enums.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../widgets/order_tile.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: const [
          _AdminOrdersTab(),
          _AdminProductsTab(),
          _AdminProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Admin Orders Tab ───────────────────────────────────────
class _AdminOrdersTab extends StatefulWidget {
  const _AdminOrdersTab();

  @override
  State<_AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<_AdminOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Order> _allOrders = [];
  bool _loading = true;

  final _tabs = [
    'Semua',
    'Menunggu Verifikasi',
    'Diproses',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await context.read<OrderProvider>().fetchAllOrders();
    setState(() {
      _allOrders = orders;
      _loading = false;
    });
  }

  List<Order> _filteredOrders(int tabIdx) {
    switch (tabIdx) {
      case 1:
        return _allOrders
            .where((o) => o.status == OrderStatus.menungguVerifikasi)
            .toList();
      case 2:
        return _allOrders
            .where((o) => [
                  OrderStatus.diVerifikasi,
                  OrderStatus.diproses,
                  OrderStatus.siapAntar,
                  OrderStatus.dalamPengiriman,
                ].contains(o.status))
            .toList();
      case 3:
        return _allOrders
            .where((o) => o.status == OrderStatus.selesai)
            .toList();
      default:
        return _allOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('🍗', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Admin — Pesanan'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: List.generate(_tabs.length, (i) {
                final orders = _filteredOrders(i);
                if (orders.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada pesanan',
                        style: TextStyle(color: AppTheme.textMuted)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (ctx, j) {
                      final order = orders[j];
                      return _AdminOrderCard(
                        order: order,
                        onRefresh: _loadOrders,
                      );
                    },
                  ),
                );
              }),
            ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onRefresh;

  const _AdminOrderCard({required this.order, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                      Text(
                        Formatters.dateTime(order.createdAt),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _statusBadge(order.status),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('• ${item['product_name']}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                      const Spacer(),
                      Text(
                          '${item['quantity']}x ${Formatters.currency(item['subtotal'])}',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Divider(color: AppTheme.divider, height: 1),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Text(
                  Formatters.currency(order.totalAmount),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Action buttons based on status
                if (order.status == OrderStatus.menungguVerifikasi) ...[
                  _ActionBtn(
                    label: '✗ Tolak',
                    color: AppTheme.error,
                    onTap: () => _reject(context),
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    label: '✓ Setujui',
                    color: AppTheme.success,
                    onTap: () => _approve(context),
                  ),
                ] else if (order.status == OrderStatus.diVerifikasi) ...[
                  _ActionBtn(
                    label: '🍗 Proses',
                    color: AppTheme.primary,
                    onTap: () => _updateStatus(
                        context, OrderStatus.diproses),
                  ),
                ] else if (order.status == OrderStatus.diproses) ...[
                  _ActionBtn(
                    label: '✅ Selesai',
                    color: AppTheme.success,
                    onTap: () =>
                        _updateStatus(context, OrderStatus.selesai),
                  ),
                ],
                // WA button always visible
                const SizedBox(width: 8),
                _ActionBtn(
                  label: '💬',
                  color: const Color(0xFF25D366),
                  onTap: () => _chatCustomer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext ctx) async {
    await ctx.read<OrderProvider>().verifyPayment(order.id, approved: true);
    onRefresh();
  }

  Future<void> _reject(BuildContext ctx) async {
    await ctx.read<OrderProvider>().verifyPayment(order.id, approved: false);
    onRefresh();
  }

  Future<void> _updateStatus(BuildContext ctx, OrderStatus status) async {
    await ctx.read<OrderProvider>().updateOrderStatus(order.id, status);
    onRefresh();
  }

  Future<void> _chatCustomer() async {
    final uri = Uri.parse('https://wa.me/${AppConstants.storeWhatsApp}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _statusBadge(OrderStatus s) {
    Color color;
    switch (s) {
      case OrderStatus.menungguPembayaran:
        color = AppTheme.warning;
        break;
      case OrderStatus.menungguVerifikasi:
        color = AppTheme.info;
        break;
      case OrderStatus.diVerifikasi:
      case OrderStatus.diproses:
        color = AppTheme.primary;
        break;
      case OrderStatus.selesai:
        color = AppTheme.success;
        break;
      case OrderStatus.dibatalkan:
        color = AppTheme.error;
        break;
      default:
        color = AppTheme.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        s.label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Admin Products Tab ─────────────────────────────────────
class _AdminProductsTab extends StatelessWidget {
  const _AdminProductsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.adminAddProduct),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Daftar produk akan ditampilkan di sini',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      ),
    );
  }
}

// ── Admin Profile/Settings Tab ─────────────────────────────
class _AdminProfileTab extends StatelessWidget {
  const _AdminProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Pengaturan Toko'),
        backgroundColor: AppTheme.surface,
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Store info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('🍗', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text(
                    AppConstants.storeName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.profile?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SettingTile(
              icon: Icons.schedule_outlined,
              label: 'Jam Operasional',
              value:
                  '${AppConstants.storeOpenTime} – ${AppConstants.storeCloseTime}',
            ),
            _SettingTile(
              icon: Icons.delivery_dining_outlined,
              label: 'Ongkir per km',
              value: Formatters.currency(AppConstants.deliveryPricePerKm),
            ),
            _SettingTile(
              icon: Icons.map_outlined,
              label: 'Radius Maks Antar',
              value: '${AppConstants.maxDeliveryRadiusKm} km',
            ),
            _SettingTile(
              icon: Icons.account_balance_outlined,
              label: 'Rekening Bank',
              value:
                  '${AppConstants.bankName} ${AppConstants.bankAccountNumber}',
            ),
            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: const Border.fromBorderSide(
            BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
