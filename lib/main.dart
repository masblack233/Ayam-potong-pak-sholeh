import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase_service.dart';
import 'core/theme.dart';
import 'core/routes.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/product_detail_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/checkout_screen.dart';
import 'screens/customer/payment_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init locale
  await initializeDateFormatting('id_ID', null);

  // Init Supabase
  await SupabaseService.initialize();

  runApp(const AyamPotongApp());
}

class AyamPotongApp extends StatelessWidget {
  const AyamPotongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Ayam Potong Pak Soleh',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.productDetail: (_) => const ProductDetailScreen(),
          AppRoutes.cart: (_) => const CartScreen(),
          AppRoutes.checkout: (_) => const CheckoutScreen(),
          AppRoutes.payment: (_) => const PaymentScreen(),
          AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}
