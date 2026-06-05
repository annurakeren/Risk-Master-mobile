// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Step 0 = input email, Step 1 = input code + new password
  int _step = 0;

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _successMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }

  Future<void> _sendResetCode() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final result = await auth.forgotPassword(_emailCtrl.text.trim());

    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _step = 1;
        _successMessage = result['message'];
      });
      _showSnackBar(result['message'] ?? 'Kode reset telah dikirim', isError: false);
    } else {
      _showSnackBar(result['message'] ?? 'Gagal mengirim kode reset');
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final result = await auth.resetPassword(
      _emailCtrl.text.trim(),
      _codeCtrl.text.trim(),
      _newPassCtrl.text,
      _confirmPassCtrl.text,
    );

    if (!mounted) return;
    if (result['success'] == true) {
      _showSnackBar(result['message'] ?? 'Password berhasil direset!', isError: false);
      // Return to login after short delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
    } else {
      _showSnackBar(result['message'] ?? 'Gagal mereset password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lupa Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.2 : AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 0 ? _buildStep0(auth) : _buildStep1(auth),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 0: Input Email ─────────────────────────────────────────────────
  Widget _buildStep0(AuthProvider auth) {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.lock_reset, size: 36, color: AppColors.warning),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text(
            'Atur Ulang Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Masukkan email yang terdaftar. Kami akan mengirimkan kode verifikasi untuk mereset password Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),

          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetCode(),
            decoration: const InputDecoration(
              labelText: 'Alamat Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
          ),
          const SizedBox(height: AppSpacing.lg),

          FilledButton(
            onPressed: auth.isLoading ? null : _sendResetCode,
            child: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Kirim Kode Reset'),
          ),
          const SizedBox(height: AppSpacing.md),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali ke Login'),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Input Code + New Password ───────────────────────────────────
  Widget _buildStep1(AuthProvider auth) {
    return Form(
      key: _resetFormKey,
      child: Column(
        key: const ValueKey(1),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.mark_email_read_outlined, size: 36, color: AppColors.success),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text(
            'Masukkan Kode Verifikasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kode verifikasi telah dikirim ke\n${_emailCtrl.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          if (_successMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                _successMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.success),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),

          // Kode Verifikasi
          TextFormField(
            controller: _codeCtrl,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Kode Verifikasi',
              prefixIcon: Icon(Icons.pin_outlined),
              helperText: 'Masukkan kode yang dikirim ke email',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Kode wajib diisi' : null,
          ),
          const SizedBox(height: AppSpacing.md),

          // New Password
          TextFormField(
            controller: _newPassCtrl,
            obscureText: _obscureNew,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password Baru',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              helperText: 'Minimal 8 karakter',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password wajib diisi';
              if (v.length < 8) return 'Password minimal 8 karakter';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Confirm New Password
          TextFormField(
            controller: _confirmPassCtrl,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _resetPassword(),
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password Baru',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
              if (v != _newPassCtrl.text) return 'Password tidak sama';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          FilledButton(
            onPressed: auth.isLoading ? null : _resetPassword,
            child: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Reset Password'),
          ),
          const SizedBox(height: AppSpacing.md),

          // Resend code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tidak menerima kode?',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: auth.isLoading ? null : _sendResetCode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Kirim Ulang',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          TextButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('Ganti email'),
          ),
        ],
      ),
    );
  }
}
