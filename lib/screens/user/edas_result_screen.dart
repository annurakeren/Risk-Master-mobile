import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/assessment.dart';

class EdasResultScreen extends StatefulWidget {
  final int assessmentId;
  final String title;

  const EdasResultScreen({
    super.key,
    required this.assessmentId,
    required this.title,
  });

  @override
  State<EdasResultScreen> createState() => _EdasResultScreenState();
}

class _EdasResultScreenState extends State<EdasResultScreen> {
  bool _isLoading = true;
  List<EdasResult> _results = [];
  String? _topRecommendation;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final res = await ApiService().getEdasResults(widget.assessmentId);
    if (mounted) {
      if (res['success']) {
        final data = res['data'];
        final resultsList = data['results'] as List? ?? [];
        _results = resultsList.map((e) => EdasResult.fromJson(e)).toList();
        _topRecommendation = data['top_recommendation'];
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res['message'] ?? 'Gagal memuat hasil';
          _isLoading = false;
        });
      }
    }
  }

  Color _qualityColor(String? label) {
    switch (label) {
      case 'Sangat Direkomendasikan':
        return AppColors.success;
      case 'Direkomendasikan':
        return AppColors.primary;
      case 'Cukup':
        return AppColors.warning;
      case 'Tidak Direkomendasikan':
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hasil EDAS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download PDF',
            onPressed: () => ApiService().downloadReport(widget.assessmentId, 'pdf'),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: 'Download Excel',
            onPressed: () => ApiService().downloadReport(widget.assessmentId, 'excel'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Recommendation Card
                      if (_topRecommendation != null)
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.emoji_events, color: Colors.amberAccent, size: 16),
                                    SizedBox(width: 6),
                                    Text('Rekomendasi Utama', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _topRecommendation!,
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),

                      const Text('Peringkat Keseluruhan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.md),

                      ..._results.map((r) {
                        final color = _qualityColor(r.qualityLabel);
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.outlineVariant),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header Rank & Name
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: r.rank == 1 ? AppColors.primary : AppColors.surfaceVariant,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        r.rank.toString(),
                                        style: TextStyle(
                                          color: r.rank == 1 ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      r.alternativeName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                      border: Border.all(color: color.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      r.qualityLabel,
                                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Appraisal Score Bar
                              Row(
                                children: [
                                  const Text('AS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                      child: LinearProgressIndicator(
                                        value: r.asScore.clamp(0.0, 1.0),
                                        backgroundColor: AppColors.surfaceVariant,
                                        color: color,
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  SizedBox(
                                    width: 48,
                                    child: Text(
                                      r.asScore.toStringAsFixed(4),
                                      style: const TextStyle(fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Sub-scores
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _SubScoreStat(label: 'NSP', value: r.nsp),
                                    _SubScoreStat(label: 'NSN', value: r.nsn),
                                    _SubScoreStat(label: 'SP', value: r.sp),
                                    _SubScoreStat(label: 'SN', value: r.sn),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: AppSpacing.xl),
                      // Legend
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Keterangan Nilai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                            const SizedBox(height: 12),
                            _LegendRow(color: AppColors.success, label: 'Sangat Direkomendasikan', score: '≥ 0.80'),
                            const SizedBox(height: 8),
                            _LegendRow(color: AppColors.primary, label: 'Direkomendasikan', score: '≥ 0.60'),
                            const SizedBox(height: 8),
                            _LegendRow(color: AppColors.warning, label: 'Cukup', score: '≥ 0.40'),
                            const SizedBox(height: 8),
                            _LegendRow(color: AppColors.error, label: 'Tidak Direkomendasikan', score: '< 0.40'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }
}

class _SubScoreStat extends StatelessWidget {
  final String label;
  final double value;
  
  const _SubScoreStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(4),
          style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String score;
  
  const _LegendRow({required this.color, required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Text(score, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
