import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/flash_sale_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: const [
          _CatalogTab(),
          _OrderHistoryTab(),
          _ProfileTab(),
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
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Toko',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Catalog Tab ────────────────────────────────────────────
class _CatalogTab extends StatelessWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Consumer<ProductProvider>(
        builder: (ctx, productProv, _) {
          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppTheme.surface,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Consumer<AuthProvider>(
                      builder: (_, auth, __) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang, 👋',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      auth.profile?.displayName ?? 'Pelanggan',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                              ),
                              // Cart button
                              Consumer<CartProvider>(
                                builder: (_, cart, __) => Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context, AppRoutes.cart),
                                      icon: const Icon(Icons.shopping_basket_outlined,
                                          color: AppTheme.textPrimary, size: 28),
                                    ),
                                    if (cart.itemCount > 0)
                                      Positioned(
                                        right: 6,
                                        top: 6,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                            gradient: AppTheme.primaryGradient,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${cart.itemCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
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
                  ),
                ),
              ),

              // Flash sale
              if (productProv.flashSaleProducts.isNotEmpty)
                SliverToBoxAdapter(
                  child: FlashSaleBanner(
                    products: productProv.flashSaleProducts,
                    onProductTap: (p) => Navigator.pushNamed(
                      context,
                      AppRoutes.productDetail,
                      arguments: p,
                    ),
                  ),
                ),

              // Category chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: productProv.categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = productProv.categories[i];
                      final isSelected = cat == productProv.selectedCategory;
                      return GestureDetector(
                        onTap: () => productProv.setCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppTheme.primaryGradient
                                : null,
                            color: isSelected ? null : AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.divider,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Section title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Pilihan Ayam Segar',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Spacer(),
                      if (productProv.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),

              // Products grid
              if (productProv.isLoading && productProv.allProducts.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ShimmerCard(),
                      childCount: 6,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final p = productProv.filteredProducts[i];
                        return ProductCard(
                          product: p,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.productDetail,
                            arguments: p,
                          ),
                          onAddToCart: () {
                            context.read<CartProvider>().addItem(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${p.name} ditambahkan ke keranjang'),
                                backgroundColor: AppTheme.success,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                      childCount: productProv.filteredProducts.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Order History Tab ──────────────────────────────────────
class _OrderHistoryTab extends StatefulWidget {
  const _OrderHistoryTab();

  @override
  State<_OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends State<_OrderHistoryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Will be implemented via OrderProvider
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: AppTheme.surface,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📦', style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Tab ────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppTheme.surface,
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final profile = auth.profile;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      profile?.initials ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  profile?.displayName ?? 'Pengguna',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Center(
                child: Text(
                  profile?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),

              _ProfileTile(
                icon: Icons.phone_outlined,
                label: 'No. WhatsApp',
                value: profile?.phone ?? 'Belum diisi',
              ),
              _ProfileTile(
                icon: Icons.home_outlined,
                label: 'Alamat',
                value: profile?.address ?? 'Belum diisi',
              ),
              const SizedBox(height: 24),

              // Sign Out
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
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder ────────────────────────────────────
class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
