import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final error = await auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.error),
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Buat Akun',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daftar untuk mulai memesan\nayam segar dari Pak Soleh.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  AppTextField(
                    controller: _nameCtrl,
                    label: 'Nama Lengkap',
                    hint: 'Budi Santoso',
                    prefixIcon: Icons.person_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nama wajib diisi';
                      if (v.length < 3) return 'Nama minimal 3 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _phoneCtrl,
                    label: 'No. WhatsApp',
                    hint: '08xxxxxxxxxx',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nomor HP wajib diisi';
                      if (v.length < 10) return 'Nomor HP tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'contoh@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email wajib diisi';
                      if (!v.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _passCtrl,
                    label: 'Kata Sandi',
                    hint: 'Minimal 6 karakter',
                    obscureText: _obscure,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) return 'Kata sandi minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _confirmPassCtrl,
                    label: 'Konfirmasi Kata Sandi',
                    hint: 'Ulangi kata sandi',
                    obscureText: _obscureConfirm,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v != _passCtrl.text) return 'Kata sandi tidak cocok';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  GradientButton(
                    onPressed: auth.isLoading ? null : _register,
                    isLoading: auth.isLoading,
                    label: 'Daftar Sekarang',
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
