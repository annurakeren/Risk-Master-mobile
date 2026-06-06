// lib/screens/user/user_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/assessment.dart';
import '../../models/alternative.dart';
import '../../providers/assessment_provider.dart';

import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';
import '../auth/login_screen.dart';
import '../admin/alternative_screen.dart';
import 'input_nilai_screen.dart';
import 'edas_result_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<Assessment> _assessments = [];
  bool _isLoading = true;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _assessments = await _api.getAssessments();
    setState(() => _isLoading = false);
  }

  void _showCreateAssessment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateAssessmentSheet(),
    ).then((created) {
      if (created == true) _load();
    });
  }

  Future<void> _confirmDelete(Assessment a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Assessment'),
        content: Text('Yakin ingin menghapus assessment "${a.title}"? Seluruh data matriks akan hilang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Hapus')
          ),
        ],
      )
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      await _api.deleteAssessment(a.id);
      _load();
    }
  }

  Future<void> _showEditDialog(Assessment a) async {
    final titleCtrl = TextEditingController(text: a.title);
    final descCtrl = TextEditingController(text: a.description);
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Assessment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Judul', filled: true),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Deskripsi', filled: true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(ctx), 
                child: const Text('Batal')
              ),
              FilledButton(
                onPressed: loading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setDialogState(() => loading = true);
                    final success = await _api.updateAssessment(a.id, title: titleCtrl.text, description: descCtrl.text);
                    setDialogState(() => loading = false);
                    if (!ctx.mounted) return;
                    if (success) {
                      Navigator.pop(ctx);
                      _load();
                    } else {
                      showSnackBar(ctx, 'Gagal mengedit assessment', isError: true);
                    }
                  }
                },
                child: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Simpan'),
              ),
            ],
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.currentUser?.name ?? 'User';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((e) => e[0]).join().toUpperCase()
        : 'U';

    final completed = _assessments.where((a) => a.isCompleted).length;
    final draft = _assessments.where((a) => !a.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Keluar',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Greeting Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: const Text(
                              'RISK ANALYST',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ─── Stats Row ─────────────────────────────────────────────
              if (!_isLoading) ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        label: 'Selesai',
                        value: completed.toString(),
                        color: AppColors.success,
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _StatChip(
                        label: 'Draft',
                        value: draft.toString(),
                        color: AppColors.warning,
                        icon: Icons.pending_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _StatChip(
                        label: 'Total',
                        value: _assessments.length.toString(),
                        color: AppColors.primary,
                        icon: Icons.assignment_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ─── Action Buttons ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AlternativeScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(Icons.list_alt_outlined, size: 16),
                      label: const Text('Lihat Alternatif'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _showCreateAssessment,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Assessment Baru'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ─── Section Header ────────────────────────────────────────
              const SectionHeader(title: 'Assessment Saya'),
              const SizedBox(height: AppSpacing.md),

              // ─── Assessment List ───────────────────────────────────────
              if (_isLoading)
                const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                )
              else if (_assessments.isEmpty)
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                          ),
                          child: const Icon(Icons.assignment_outlined,
                              size: 36, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Belum ada assessment',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tekan "Assessment Baru" untuk memulai',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _assessments.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (ctx, i) {
                    final a = _assessments[i];
                    return _AssessmentCard(
                      assessment: a,
                      onTap: () {
                         if (a.isCompleted) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => EdasResultScreen(assessmentId: a.id, title: a.title)));
                         } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => InputNilaiScreen(assessment: a)));
                         }
                      },
                      onEdit: () => _showEditDialog(a),
                      onDelete: () => _confirmDelete(a),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final Assessment assessment;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AssessmentCard({required this.assessment, required this.onTap, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isCompleted = assessment.isCompleted;
    final statusColor = isCompleted ? AppColors.success : AppColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Accent Bar
                Container(
                  width: 3,
                  color: statusColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_circle_outline
                                : Icons.pending_outlined,
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                assessment.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (assessment.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  assessment.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF475569),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StatusBadge(isCompleted: isCompleted),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                          padding: EdgeInsets.zero,
                          onSelected: (val) {
                            if (val == 'edit') onEdit();
                            if (val == 'delete') onDelete();
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(fontSize: 13))),
                            const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(fontSize: 13, color: AppColors.error))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateAssessmentSheet extends StatefulWidget {
  const _CreateAssessmentSheet();
  @override
  State<_CreateAssessmentSheet> createState() => _CreateAssessmentSheetState();
}

class _CreateAssessmentSheetState extends State<_CreateAssessmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  List<Alternative> _alternatives = [];
  final Set<int> _selectedIds = {};
  bool _loading = false;
  bool _loadingAlts = true;

  @override
  void initState() {
    super.initState();
    _loadAlternatives();
  }

  Future<void> _loadAlternatives() async {
    final altsList = await ApiService().getAlternatives();
    if (mounted) {
      setState(() {
        _alternatives = altsList;
        _loadingAlts = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIds.isEmpty) {
      showSnackBar(context, 'Pilih minimal 1 alternatif', isError: true);
      return;
    }

    setState(() => _loading = true);
    final res = await context.read<AssessmentProvider>().createAssessment(
      _titleCtrl.text.trim(),
      _descCtrl.text.trim(),
      _selectedIds.toList(),
    );
    setState(() => _loading = false);

    if (!mounted) return;
    if (res['success'] == true) {
      Navigator.pop(context, true);
    } else {
      showSnackBar(context, res['message'] ?? 'Gagal membuat assessment', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, MediaQuery.of(context).viewInsets.bottom + AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const Text(
              'Buat Assessment Baru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul Assessment *'),
              validator: (v) => v == null || v.isEmpty ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Pilih Alternatif (minimal 1)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: AppSpacing.xs),
            
            // Container for checkboxes
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                color: AppColors.surface,
              ),
              child: _loadingAlts
                  ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                  : _alternatives.isEmpty
                      ? const Padding(padding: EdgeInsets.all(16), child: Text('Belum ada alternatif tersedia'))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _alternatives.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final alt = _alternatives[i];
                            return CheckboxListTile(
                              title: Text(alt.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              subtitle: alt.description.isNotEmpty 
                                  ? Text(alt.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)) 
                                  : null,
                              value: _selectedIds.contains(alt.id),
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedIds.add(alt.id);
                                  } else {
                                    _selectedIds.remove(alt.id);
                                  }
                                });
                              },
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            );
                          },
                        ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.assignment_add, size: 18),
              label: Text(_loading ? 'Menyimpan...' : 'Buat Assessment'),
            ),
          ],
        ),
      ),
    );
  }
}
