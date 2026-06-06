import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/gemini_service.dart';
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

  void _showAiRecommendation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AiRecommendationSheet(
        assessmentTitle: widget.title,
        results: _results,
        topRecommendation: _topRecommendation,
      ),
    );
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
      floatingActionButton: _isLoading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAiRecommendation,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: const Text('AI Insight'),
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              elevation: 4,
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
                      const SizedBox(height: 80), // Extra space for FAB
                    ],
                  ),
                ),
    );
  }
}

// ─── AI Recommendation Bottom Sheet ──────────────────────────────────────────

class _AiRecommendationSheet extends StatefulWidget {
  final String assessmentTitle;
  final List<EdasResult> results;
  final String? topRecommendation;

  const _AiRecommendationSheet({
    required this.assessmentTitle,
    required this.results,
    required this.topRecommendation,
  });

  @override
  State<_AiRecommendationSheet> createState() => _AiRecommendationSheetState();
}

class _AiRecommendationSheetState extends State<_AiRecommendationSheet>
    with SingleTickerProviderStateMixin {
  bool _isGenerating = true;
  String _displayedText = '';
  String _fullText = '';
  String? _error;
  bool _isTyping = false;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _generate();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    try {
      final result = await GeminiService.generateRecommendation(
        assessmentTitle: widget.assessmentTitle,
        results: widget.results,
        topRecommendation: widget.topRecommendation,
      );
      if (mounted) {
        _fullText = result;
        setState(() {
          _isGenerating = false;
          _isTyping = true;
        });
        _animateText();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _animateText() async {
    // Type out text character by character with variable speed
    for (int i = 0; i < _fullText.length; i++) {
      if (!mounted) return;
      setState(() {
        _displayedText = _fullText.substring(0, i + 1);
      });
      // Speed: faster for spaces/newlines, slower for other chars
      final char = _fullText[i];
      final delay = (char == ' ' || char == '\n') ? 2 : 8;
      await Future.delayed(Duration(milliseconds: delay));
    }
    if (mounted) {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Recommendation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Powered by Gemini AI',
                        style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textTertiary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Content
          Flexible(
            child: _isGenerating
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _buildResultContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          // Animated AI icon
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_shimmerController.value * 0.1),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7C3AED).withValues(alpha: 0.2),
                        const Color(0xFFA855F7).withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Color.lerp(
                      const Color(0xFF7C3AED),
                      const Color(0xFFA855F7),
                      _shimmerController.value,
                    ),
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Menganalisis hasil EDAS...',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI sedang menyusun rekomendasi berdasarkan data ranking kamu',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          const LinearProgressIndicator(
            color: Color(0xFF7C3AED),
            backgroundColor: Color(0xFFEDE9FE),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, color: AppColors.error, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gagal Menghasilkan Rekomendasi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _isGenerating = true;
                _error = null;
                _displayedText = '';
                _fullText = '';
              });
              _generate();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommendation text with typing cursor
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.7,
              ),
              children: [
                ..._parseStyledText(_displayedText),
                if (_isTyping)
                  const WidgetSpan(
                    child: _BlinkingCursor(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Disclaimer
          if (!_isTyping)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rekomendasi ini dihasilkan oleh AI dan bersifat sugestif. Selalu pertimbangkan konteks spesifik organisasi Anda sebelum mengambil keputusan.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Parse bold text (**text**) into styled TextSpans
  List<InlineSpan> _parseStyledText(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the bold part
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      // Add bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
      ));
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }
}

// ─── Blinking Cursor ─────────────────────────────────────────────────────────

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: 16,
            margin: const EdgeInsets.only(left: 2),
            color: const Color(0xFF7C3AED),
          ),
        );
      },
    );
  }
}

// ─── Existing Sub-components ─────────────────────────────────────────────────

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
