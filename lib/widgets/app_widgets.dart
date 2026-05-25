// lib/widgets/app_widgets.dart
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

// ─── Loading Overlay ──────────────────────────────────────────────────────────

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Memproses...',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Type Badge ───────────────────────────────────────────────────────────────

class TypeBadge extends StatelessWidget {
  final String type;
  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isBenefit = type == 'benefit';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isBenefit ? AppColors.successContainer : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isBenefit ? 'Benefit' : 'Cost',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isBenefit ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

// ─── Source Badge ─────────────────────────────────────────────────────────────

class SourceBadge extends StatelessWidget {
  final String source;
  const SourceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final isAdmin = source == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.secondaryContainer : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isAdmin ? AppColors.onSecondaryContainer : AppColors.warning,
        ),
      ),
    );
  }
}

// ─── Role Badge ───────────────────────────────────────────────────────────────

class RoleBadge extends StatelessWidget {
  final bool isAdmin;
  const RoleBadge({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.secondaryContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isAdmin ? AppColors.onSecondaryContainer : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final bool isCompleted;
  const StatusBadge({super.key, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.successContainer : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isCompleted ? 'Selesai' : 'Draft',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isCompleted ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textTertiary,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

// ─── Delete Dialog ────────────────────────────────────────────────────────────

Future<bool?> showDeleteDialog(BuildContext context, String itemName) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 32),
      title: const Text('Konfirmasi Hapus'),
      content: Text('Yakin ingin menghapus\n"$itemName"?', textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(100, 40),
            side: const BorderSide(color: AppColors.outline),
            foregroundColor: AppColors.textSecondary,
          ),
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 40),
            backgroundColor: AppColors.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}

// ─── SnackBar Helper ──────────────────────────────────────────────────────────

void showSnackBar(BuildContext context, String message, {bool isError = false}) {
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
