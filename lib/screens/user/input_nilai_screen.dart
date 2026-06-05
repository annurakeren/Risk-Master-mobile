// lib/screens/user/input_nilai_screen.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/assessment.dart';
import '../../models/alternative.dart';
import '../../models/criteria.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';
import 'edas_result_screen.dart';

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
  bool _isCalculating = false;
  
  Map<String, dynamic>? _assessmentData;

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
    
    // getAssessmentDetail returns {success, data: {assessment, criteria, matrix, ...}}
    final res = await _api.getAssessmentDetail(widget.assessment.id);
    
    if (res['success'] == true) {
      final detail = res['data'] as Map<String, dynamic>;
      _assessmentData = detail;
      
      // Ambil alternatif dari assessment.alternatives
      final assessmentData = detail['assessment'];
      if (assessmentData != null) {
        final altsList = assessmentData['alternatives'] as List? ?? [];
        _alternatives = altsList.map((e) => Alternative.fromJson(e)).toList();
      }
      
      // Ambil kriteria dari detail.criteria
      final criteriaList = detail['criteria'] as List? ?? [];
      if (criteriaList.isNotEmpty) {
        _criteria = criteriaList.map((e) => Criteria.fromJson(e)).toList();
      } else {
        _criteria = await _api.getCriteria();
      }

      for (final alt in _alternatives) {
        _controllers[alt.id] = {};
        for (final c in _criteria) {
          _controllers[alt.id]![c.id] = TextEditingController();
        }
      }
      
      // Auto-fill existing values from matrix
      // matrix format: { "alt_id": { "crit_id": value } }
      final matrix = detail['matrix'];
      if (matrix != null && matrix is Map) {
        matrix.forEach((altIdStr, critMap) {
          final aId = int.tryParse(altIdStr.toString());
          if (aId != null && critMap is Map) {
            critMap.forEach((critIdStr, value) {
              final cId = int.tryParse(critIdStr.toString());
              if (cId != null && _controllers.containsKey(aId) && _controllers[aId]!.containsKey(cId)) {
                _controllers[aId]![cId]!.text = value.toString();
              }
            });
          }
        });
      }
    } else {
      // Fallback: load criteria separately if detail failed
      _criteria = await _api.getCriteria();
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
  bool get _isCompleted => widget.assessment.status == 'completed' || (_assessmentData?['assessment']?['status'] == 'completed');

  Future<void> _submitAndCalculate() async {
    if (!_isAllFilled) {
      showSnackBar(context, 'Semua nilai wajib diisi dengan angka', isError: true);
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

    // submitValues sekarang return Map {success, data, message}
    final submitRes = await _api.submitValues(widget.assessment.id, values);
    if (submitRes['success'] != true) {
      setState(() => _isSaving = false);
      if (mounted) showSnackBar(context, submitRes['message'] ?? 'Gagal menyimpan nilai', isError: true);
      return;
    }
    
    setState(() {
      _isSaving = false;
      _isCalculating = true;
    });
    
    final calcRes = await _api.calculateEdas(widget.assessment.id);
    setState(() => _isCalculating = false);
    
    if (mounted) {
      if (calcRes['success'] == true) {
         showSnackBar(context, 'Kalkulasi berhasil!');
         // Langsung push ke halaman hasil
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (_) => EdasResultScreen(assessmentId: widget.assessment.id, title: widget.assessment.title)),
         );
      } else {
         showSnackBar(context, calcRes['message'] ?? 'Gagal kalkulasi EDAS', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalCount > 0 ? (_filledCount / _totalCount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assessment.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (_isCompleted)
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                   context,
                   MaterialPageRoute(builder: (_) => EdasResultScreen(assessmentId: widget.assessment.id, title: widget.assessment.title)),
                );
              },
              child: const Text('Lihat Hasil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceVariant,
                color: _isAllFilled ? AppColors.success : AppColors.primary,
                minHeight: 3,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 6, AppSpacing.md, 8),
                child: Row(
                  children: [
                    const Icon(Icons.table_chart_outlined, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _isCompleted ? 'Penilaian selesai. Matriks telah dikalkulasi.' : 'Isi nilai untuk setiap alternatif berdasarkan kriteria',
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ),
                    Text(
                      '$_filledCount / $_totalCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isAllFilled ? AppColors.success : AppColors.primary,
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : LoadingOverlay(
              isLoading: _isSaving || _isCalculating,
              child: Column(
                children: [
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 130,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: const Text(
                            'ALTERNATIF',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.textTertiary),
                          ),
                        ),
                        ..._criteria.map(
                          (c) => Expanded(
                            child: Column(
                              children: [
                                Text(
                                  c.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                TypeBadge(type: c.type),
                                const SizedBox(height: 2),
                                Text(
                                  'W:${c.weight.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: _alternatives.length,
                      itemBuilder: (ctx, i) {
                        final alt = _alternatives[i];
                        final isEven = i % 2 == 0;
                        return Container(
                          color: isEven ? AppColors.surface : AppColors.background,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alt.name,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                ..._criteria.map(
                                  (c) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      child: TextFormField(
                                        controller: _controllers[alt.id]?[c.id],
                                        readOnly: _isCompleted,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        decoration: InputDecoration(
                                          hintText: '–',
                                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                          filled: true,
                                          fillColor: _isCompleted ? AppColors.surfaceVariant : AppColors.surfaceContainerLow,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                            borderSide: const BorderSide(color: AppColors.outlineVariant),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                            borderSide: const BorderSide(color: AppColors.outlineVariant),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
      bottomNavigationBar: _isCompleted ? null : Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceVariant,
                      color: _isAllFilled ? AppColors.success : AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _isAllFilled ? 'Siap dihitung ✓' : '$_filledCount/$_totalCount terisi',
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
              onPressed: (_isAllFilled && !_isSaving && !_isCalculating) ? _submitAndCalculate : null,
              icon: const Icon(Icons.calculate_outlined, size: 18),
              label: Text(_isCalculating ? 'Menghitung EDAS...' : 'Simpan & Hitung EDAS'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}
