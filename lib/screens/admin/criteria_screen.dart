// lib/screens/admin/criteria_screen.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/criteria.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class CriteriaScreen extends StatefulWidget {
  const CriteriaScreen({super.key});
  @override
  State<CriteriaScreen> createState() => _CriteriaScreenState();
}

class _CriteriaScreenState extends State<CriteriaScreen> {
  List<Criteria> _criteria = [];
  bool _isLoading = true;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _criteria = await _api.getCriteria();
    setState(() => _isLoading = false);
  }

  double get _totalWeight => _criteria.fold(0, (sum, c) => sum + c.weight);
  bool get _isWeightValid => (_totalWeight - 1.0).abs() < 0.01;

  void _showForm({Criteria? criteria}) {
    final nameCtrl = TextEditingController(text: criteria?.name);
    final descCtrl = TextEditingController(text: criteria?.description);
    final weightCtrl =
        TextEditingController(text: criteria?.weight.toString() ?? '');
    String type = criteria?.type ?? 'benefit';
    final formKey = GlobalKey<FormState>();
    final isEdit = criteria != null;

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
                isEdit ? 'Edit Kriteria' : 'Tambah Kriteria',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nama Kriteria'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: descCtrl,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Deskripsi (opsional)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              StatefulBuilder(
                builder: (ctx, setSt) => DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Tipe'),
                  items: const [
                    DropdownMenuItem(
                        value: 'benefit',
                        child: Text('Benefit (semakin besar semakin baik)')),
                    DropdownMenuItem(
                        value: 'cost',
                        child: Text('Cost (semakin kecil semakin baik)')),
                  ],
                  onChanged: (v) => setSt(() => type = v!),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Bobot (0.0 – 1.0)',
                  helperText: 'Total bobot semua kriteria sebaiknya = 1.0',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bobot wajib diisi';
                  final w = double.tryParse(v);
                  if (w == null || w <= 0 || w > 1) {
                    return 'Bobot harus antara 0 dan 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final weight = double.parse(weightCtrl.text);
                  bool ok;
                  if (isEdit) {
                    ok = await _api.updateCriteria(
                        criteria.id, nameCtrl.text, descCtrl.text, type, weight);
                  } else {
                    ok = await _api.createCriteria(
                        nameCtrl.text, descCtrl.text, type, weight);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    showSnackBar(
                        context, ok ? 'Berhasil disimpan' : 'Gagal menyimpan',
                        isError: !ok);
                    _load();
                  }
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Kriteria'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kriteria Penilaian'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isWeightValid
                    ? AppColors.successContainer
                    : AppColors.warningContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'Total: ${_totalWeight.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: _isWeightValid ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kriteria'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _criteria.isEmpty
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
                        child: const Icon(Icons.fact_check_outlined,
                            size: 32, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Belum ada kriteria',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tambahkan kriteria penilaian pertama',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _criteria.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (ctx, i) {
                    final c = _criteria[i];
                    return _CriteriaCard(
                      criteria: c,
                      index: i,
                      onEdit: () => _showForm(criteria: c),
                      onDelete: () async {
                        final confirm =
                            await showDeleteDialog(context, c.name);
                        if (confirm == true) {
                          await _api.deleteCriteria(c.id);
                          _load();
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class _CriteriaCard extends StatelessWidget {
  final Criteria criteria;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CriteriaCard({
    required this.criteria,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.tertiary,
      AppColors.error,
    ];
    final accent = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: const Border.fromBorderSide(
            BorderSide(color: AppColors.outlineVariant)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top blue bar
          Container(height: 3, color: accent),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        criteria.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TypeBadge(type: criteria.type),
                    const SizedBox(width: AppSpacing.sm),
                    // Edit/Delete buttons
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
                ),
                if (criteria.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    criteria.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                // Weight bar
                Row(
                  children: [
                    const Icon(Icons.scale_outlined,
                        size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Bobot ${(criteria.weight * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: criteria.weight.clamp(0.0, 1.0),
                          backgroundColor: AppColors.surfaceVariant,
                          color: accent,
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      criteria.weight.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
