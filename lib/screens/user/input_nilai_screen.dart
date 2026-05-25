// lib/screens/user/input_nilai_screen.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/assessment.dart';
import '../../models/alternative.dart';
import '../../models/criteria.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class InputNilaiScreen extends StatefulWidget {
  final Assessment assessment;
  const InputNilaiScreen({super.key, required this.assessment});
  @override
  State<InputNilaiScreen> createState() => _InputNilaiScreenState();
}

class _InputNilaiScreenState extends State<InputNilaiScreen> {
  List<Alternative> _alternatives = [];
  List<Criteria> _criteria = [];
  bool _isLoading = true;
  bool _isSaving = false;
  // Map[alternativeId][criteriaId] = nilai
  final Map<int, Map<int, TextEditingController>> _controllers = {};

  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _alternatives = await _api.getAlternatives();
    _criteria = await _api.getCriteria();

    for (final alt in _alternatives) {
      _controllers[alt.id] = {};
      for (final c in _criteria) {
        _controllers[alt.id]![c.id] = TextEditingController();
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    for (final altMap in _controllers.values) {
      for (final ctrl in altMap.values) { ctrl.dispose(); }
    }
    super.dispose();
  }

  int get _filledCount {
    int count = 0;
    for (final alt in _alternatives) {
      for (final c in _criteria) {
        final v = _controllers[alt.id]?[c.id]?.text ?? '';
        if (v.isNotEmpty && double.tryParse(v) != null) count++;
      }
    }
    return count;
  }

  int get _totalCount => _alternatives.length * _criteria.length;
  bool get _isAllFilled => _filledCount == _totalCount && _totalCount > 0;

  Future<void> _submit() async {
    if (!_isAllFilled) {
      showSnackBar(context, 'Semua nilai wajib diisi dengan angka',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final values = <Map<String, dynamic>>[];
    for (final alt in _alternatives) {
      for (final c in _criteria) {
        values.add({
          'alternative_id': alt.id,
          'criteria_id': c.id,
          'value': double.parse(_controllers[alt.id]![c.id]!.text),
        });
      }
    }

    final ok = await _api.submitValues(widget.assessment.id, values);
    setState(() => _isSaving = false);

    if (mounted) {
      if (ok) {
        showSnackBar(context, 'Nilai berhasil disimpan! Menunggu perhitungan EDAS...');
        Navigator.pop(context);
      } else {
        showSnackBar(context, 'Gagal menyimpan nilai', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _totalCount > 0 ? (_filledCount / _totalCount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.assessment.title,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceVariant,
                color: _isAllFilled ? AppColors.success : AppColors.primary,
                minHeight: 3,
              ),
              // Context row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 6, AppSpacing.md, 8),
                child: Row(
                  children: [
                    const Icon(Icons.table_chart_outlined,
                        size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Isi nilai untuk setiap alternatif berdasarkan kriteria',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ),
                    Text(
                      '$_filledCount / $_totalCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isAllFilled
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : LoadingOverlay(
              isLoading: _isSaving,
              child: Column(
                children: [
                  // ─── Criteria Header ────────────────────────────────
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        // Alternative column header
                        Container(
                          width: 130,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: const Text(
                            'ALTERNATIF',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        ..._criteria.map(
                          (c) => Expanded(
                            child: Column(
                              children: [
                                Text(
                                  c.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                TypeBadge(type: c.type),
                                const SizedBox(height: 2),
                                Text(
                                  'W:${c.weight.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // ─── Input Table ────────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.only(bottom: 100),
                      itemCount: _alternatives.length,
                      itemBuilder: (ctx, i) {
                        final alt = _alternatives[i];
                        final isEven = i % 2 == 0;
                        return Container(
                          color: isEven
                              ? AppColors.surface
                              : AppColors.background,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Alternative name col
                                SizedBox(
                                  width: 130,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alt.name,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      SourceBadge(source: alt.source),
                                    ],
                                  ),
                                ),
                                // Input cells
                                ..._criteria.map(
                                  (c) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: TextFormField(
                                        controller:
                                            _controllers[alt.id]?[c.id],
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                                decimal: true),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '–',
                                          hintStyle: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textTertiary),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 8),
                                          filled: true,
                                          fillColor: AppColors.surfaceContainerLow,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppRadius.sm),
                                            borderSide: const BorderSide(
                                                color: AppColors.outlineVariant),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppRadius.sm),
                                            borderSide: const BorderSide(
                                                color: AppColors.outlineVariant),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppRadius.sm),
                                            borderSide: const BorderSide(
                                                color: AppColors.primary,
                                                width: 1.5),
                                          ),
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

      // ─── Submit Bottom Bar ──────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress summary
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceVariant,
                      color:
                          _isAllFilled ? AppColors.success : AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _isAllFilled ? 'Siap dikirim ✓' : '$_filledCount/$_totalCount terisi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isAllFilled ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              onPressed: (_isAllFilled && !_isSaving) ? _submit : null,
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('Kirim Nilai untuk Dihitung EDAS'),
            ),
          ],
        ),
      ),
    );
  }
}
