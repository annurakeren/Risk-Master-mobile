// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _biometricAvailable = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final auth = context.read<AuthProvider>();
    final canUse = await auth.canUseBiometric;
    if (mounted) setState(() => _biometricAvailable = canUse);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _navigateToDashboard(AuthProvider auth) {
    final user = auth.currentUser!;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            user.isAdmin ? const AdminDashboard() : const UserDashboard(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      _navigateToDashboard(auth);
    } else {
      _showError(auth.errorMessage ?? 'Login gagal');
    }
  }

  Future<void> _googleLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.googleLogin();
    if (!mounted) return;
    if (ok) {
      _navigateToDashboard(auth);
    } else {
      _showError(auth.errorMessage ?? 'Login Google gagal');
    }
  }

  Future<void> _biometricLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.biometricLogin();
    if (!mounted) return;
    if (ok) {
      _navigateToDashboard(auth);
    } else {
      _showError(auth.errorMessage ?? 'Autentikasi biometrik gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.2 : AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Logo & Brand ────────────────────────────
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.security, size: 38, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Risk Master',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sistem Evaluasi Mitigasi Risiko',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Email ───────────────────────────────────
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) =>
                            v == null || !v.contains('@') ? 'Email tidak valid' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Password ────────────────────────────────
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Password tidak boleh kosong' : null,
                      ),

                      // ── Forgot Password ─────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Login Button ────────────────────────────
                      FilledButton(
                        onPressed: auth.isLoading ? null : _login,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Masuk'),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Divider ─────────────────────────────────
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Text(
                              'atau',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Google Sign-In Button ───────────────────
                      OutlinedButton.icon(
                        onPressed: auth.isLoading ? null : _googleLogin,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.outline),
                          foregroundColor: AppColors.textPrimary,
                        ),
                        icon: Image.network(
                          'https://www.google.com/favicon.ico',
                          width: 20,
                          height: 20,
                          errorBuilder: (ctx, err, st) =>
                              const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                        ),
                        label: const Text('Masuk dengan Google'),
                      ),

                      // ── Biometric Button ────────────────────────
                      if (_biometricAvailable) ...[
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: auth.isLoading ? null : _biometricLogin,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.outline),
                            foregroundColor: AppColors.textPrimary,
                          ),
                          icon: const Icon(Icons.fingerprint, size: 22, color: AppColors.primary),
                          label: const Text('Masuk dengan Biometrik'),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),

                      // ── Register Link ───────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Daftar Sekarang',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}