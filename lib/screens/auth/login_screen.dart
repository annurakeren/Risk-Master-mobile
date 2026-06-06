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

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;
  bool _biometricAvailable = false;
  double _uiOpacity = 0.0; // Animasi mulai dari transparan

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    
    // Memicu animasi setelah frame pertama di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _uiOpacity = 1.0;
        });
      }
    });
  }

  Future<void> _checkBiometric() async {
    final auth = context.read<AuthProvider>();
    final canUse = await auth.canUseBiometric;
    if (mounted) setState(() => _biometricAvailable = canUse);
  }

  @override
  void dispose() {
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
      backgroundColor: const Color(0xFFF0F4F8), // Soft background from Stitch Design
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.25 : 20,
              vertical: 24,
            ),
            child: AnimatedOpacity(
              opacity: _uiOpacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo & Title ──────────────────────────────
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: const Center(
                      child: Icon(Icons.shield, size: 36, color: Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RISKGUARDIAN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3.0,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Main Card ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: const Text(
                              'Selamat Datang\nKembali',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: const Text(
                              'Silakan masukkan kredensial Anda untuk mengakses dasbor.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Email Input ─────────────────────────
                          const Text(
                            'EMAIL INSTANSI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: 'nama@instansi.go.id',
                              prefixIcon: Icon(Icons.mail_outline, size: 20),
                            ),
                            validator: (v) =>
                                v == null || !v.contains('@') ? 'Email tidak valid' : null,
                          ),
                          const SizedBox(height: 20),

                          // ── Password Input ──────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'KATA SANDI',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                ),
                                child: const Text(
                                  'Lupa Kata Sandi?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(fontSize: 15, letterSpacing: 2.0),
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: const TextStyle(letterSpacing: 2.0),
                              prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Password tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 16),

                          // ── Remember Me ─────────────────────────
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                  activeColor: const Color(0xFF0F172A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Ingat perangkat ini selama 30 hari',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // ── Login Button ────────────────────────
                          FilledButton(
                            onPressed: auth.isLoading ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0A0A0A), // Solid black
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(double.infinity, 52),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('MASUK KE SISTEM'),
                          ),
                          const SizedBox(height: 32),

                          // ── Register Link ───────────────────────
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Belum memiliki akses? ',
                                style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                ),
                                child: const Text(
                                  'AJUKAN PENDAFTARAN',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // ── Alternative Logins ────────────────────────
                  const SizedBox(height: 24),
                  if (_biometricAvailable || true) // Show alternative section
                    Column(
                      children: [
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Atau masuk dengan',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          ],
                        ),
                        const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google Button
                              OutlinedButton(
                                onPressed: auth.isLoading ? null : _googleLogin,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size(0, 48), // Fix infinite width
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                ),
                                child: Image.network(
                                  'https://www.google.com/favicon.ico',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (ctx, err, st) => const Icon(Icons.g_mobiledata, color: Colors.black),
                                ),
                              ),
                              if (_biometricAvailable) ...[
                                const SizedBox(width: 16),
                                // Biometric Button
                                OutlinedButton(
                                  onPressed: auth.isLoading ? null : _biometricLogin,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    minimumSize: const Size(0, 48), // Fix infinite width
                                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  ),
                                  child: const Icon(Icons.fingerprint, color: Color(0xFF0F172A)),
                                ),
                              ]
                            ],
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
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