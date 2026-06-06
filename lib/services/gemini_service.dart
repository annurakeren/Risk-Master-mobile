import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/assessment.dart';

class GeminiService {
  static const _apiKey = 'AQ.Ab8RN6LtBAcYhHjWLpgQ8rDE8OMSfhvafWaioYevdPlpCvoSgQ';

  static final _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.7,
      maxOutputTokens: 1500,
    ),
  );

  /// Generate AI recommendation based on EDAS results
  static Future<String> generateRecommendation({
    required String assessmentTitle,
    required List<EdasResult> results,
    required String? topRecommendation,
  }) async {
    final buffer = StringBuffer();

    // Build ranking data for the prompt
    for (final r in results) {
      buffer.writeln(
        '  Rank ${r.rank}: "${r.alternativeName}" — '
        'AS Score: ${r.asScore.toStringAsFixed(4)}, '
        'Label: ${r.qualityLabel}',
      );
    }

    final prompt = '''
Kamu adalah seorang pakar analisis risiko dan keamanan siber yang berpengalaman.

Berikut adalah hasil analisis EDAS (Evaluation based on Distance from Average Solution) untuk assessment berjudul "$assessmentTitle":

Peringkat Alternatif Mitigasi Risiko:
${buffer.toString()}
Rekomendasi utama berdasarkan perhitungan: ${topRecommendation ?? 'Belum ditentukan'}

Berdasarkan data di atas, buatkan analisis & rekomendasi dalam format berikut (gunakan Bahasa Indonesia yang jelas dan profesional):

**📊 Ringkasan Analisis**
Berikan ringkasan singkat (2-3 kalimat) tentang hasil EDAS di atas.

**🏆 Rekomendasi Utama**
Jelaskan mengapa alternatif peringkat 1 menjadi yang terbaik dan bagaimana implementasinya.

**📋 Langkah Selanjutnya**
Berikan 3-5 langkah konkret yang harus dilakukan untuk mengimplementasikan rekomendasi ini.

**⚠️ Hal yang Perlu Diperhatikan**
Sebutkan 2-3 risiko atau tantangan yang perlu diwaspadai saat implementasi.

Gunakan emoji yang relevan untuk setiap poin utama. Jangan gunakan format markdown heading (#), cukup gunakan bold (**) dan bullet point.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Tidak ada rekomendasi yang dihasilkan.';
    } catch (e) {
      throw Exception('Gagal menghasilkan rekomendasi AI: $e');
    }
  }
}
