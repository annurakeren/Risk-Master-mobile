// lib/screens/auth/register_screen.dart
// CATATAN: Endpoint /auth/register TIDAK ADA di backend Laravel.
// Pembuatan user hanya bisa dilakukan oleh admin melalui UserManagementScreen.
// File ini disimpan sebagai placeholder jika nanti backend menambahkan fitur register.

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.info_outline, size: 36, color: AppColors.warning),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Registrasi Tidak Tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Pembuatan akun hanya dapat dilakukan oleh Administrator.\n'
                'Hubungi admin untuk mendapatkan akses.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
