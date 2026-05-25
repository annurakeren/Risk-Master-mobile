// lib/screens/admin/alternative_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/alternative.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class AlternativeScreen extends StatefulWidget {
  const AlternativeScreen({super.key});
  @override
  State<AlternativeScreen> createState() => _AlternativeScreenState();
}

class _AlternativeScreenState extends State<AlternativeScreen> {
  List<Alternative> _alternatives = [];
  bool _isLoading = true;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _alternatives = await _api.getAlternatives();
    setState(() => _isLoading = false);
  }

  void _showForm({Alternative? alt}) {
    final nameCtrl = TextEditingController(text: alt?.name);
    final descCtrl = TextEditingController(text: alt?.description);
    final formKey = GlobalKey<FormState>();
    final isEdit = alt != null;
    final auth = context.read<AuthProvider>();
    final source = auth.isAdmin ? 'admin' : 'user';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Text(
                isEdit ? 'Edit Alternatif' : 'Tambah Alternatif',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              if (!auth.isAdmin) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: AppColors.warning),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kamu menambahkan alternatif sebagai User',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Alternatif / Rencana Mitigasi',
                  hintText: 'contoh: Implementasi WAF, Backup Data Harian...',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Deskripsi (opsional)'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  bool ok;
                  if (isEdit) {
                    ok = await _api.updateAlternative(
                        alt.id, nameCtrl.text, descCtrl.text);
                  } else {
                    ok = await _api.createAlternative(
                        nameCtrl.text, descCtrl.text, source);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    showSnackBar(context, ok ? 'Berhasil disimpan' : 'Gagal',
                        isError: !ok);
                    _load();
                  }
                },
                child:
                    Text(isEdit ? 'Simpan Perubahan' : 'Tambah Alternatif'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Rencana Mitigasi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _alternatives.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: const Icon(Icons.list_alt_outlined,
                            size: 32, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text('Belum ada alternatif',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text('Tambahkan rencana mitigasi pertama',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _alternatives.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (ctx, i) {
                    final a = _alternatives[i];
                    final canEdit = auth.isAdmin || a.source == 'user';
                    return _AlternativeCard(
                      alt: a,
                      canEdit: canEdit,
                      canDelete: auth.isAdmin,
                      onEdit: () => _showForm(alt: a),
                      onDelete: () async {
                        final confirm =
                            await showDeleteDialog(context, a.name);
                        if (confirm == true) {
                          await _api.deleteAlternative(a.id);
                          _load();
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  final Alternative alt;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AlternativeCard({
    required this.alt,
    required this.canEdit,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdminSource = alt.source == 'admin';
    final borderColor = isAdminSource ? AppColors.primary : AppColors.warning;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(
          left: BorderSide(color: borderColor, width: 3),
          right: const BorderSide(color: AppColors.outlineVariant),
          top: const BorderSide(color: AppColors.outlineVariant),
          bottom: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                isAdminSource
                    ? Icons.admin_panel_settings_outlined
                    : Icons.person_outline,
                color: borderColor,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alt.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SourceBadge(source: alt.source),
                    ],
                  ),
                  if (alt.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      alt.description,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (canEdit) ...[
              const SizedBox(width: AppSpacing.sm),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textTertiary),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ])),
                  if (canDelete)
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Hapus',
                              style: TextStyle(color: AppColors.error)),
                        ])),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
