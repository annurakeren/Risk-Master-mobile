// lib/models/assessment.dart
class Assessment {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String status; // 'draft' atau 'completed'

  Assessment({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
    id: json['id'],
    userId: json['user_id'],
    title: json['title'],
    description: json['description'] ?? '',
    status: json['status'],
  );

  bool get isCompleted => status == 'completed';
}

// lib/models/alternative_value.dart
class AlternativeValue {
  final int? id;
  final int assessmentId;
  final int alternativeId;
  final int criteriaId;
  final double value;

  AlternativeValue({
    this.id,
    required this.assessmentId,
    required this.alternativeId,
    required this.criteriaId,
    required this.value,
  });

  factory AlternativeValue.fromJson(Map<String, dynamic> json) => AlternativeValue(
    id: json['id'],
    assessmentId: json['assessment_id'],
    alternativeId: json['alternative_id'],
    criteriaId: json['criteria_id'],
    value: (json['value'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'assessment_id': assessmentId,
    'alternative_id': alternativeId,
    'criteria_id': criteriaId,
    'value': value,
  };
}

// lib/models/edas_result.dart
class EdasResult {
  final int alternativeId;
  final String alternativeName;
  final double pda;
  final double nda;
  final double sp;
  final double sn;
  final double nsp;
  final double nsn;
  final double asScore;
  final int rank;

  EdasResult({
    required this.alternativeId,
    required this.alternativeName,
    required this.pda,
    required this.nda,
    required this.sp,
    required this.sn,
    required this.nsp,
    required this.nsn,
    required this.asScore,
    required this.rank,
  });

  factory EdasResult.fromJson(Map<String, dynamic> json) => EdasResult(
    alternativeId: json['alternative_id'],
    alternativeName: json['alternative_name'] ?? '',
    pda: (json['pda'] as num).toDouble(),
    nda: (json['nda'] as num).toDouble(),
    sp: (json['sp'] as num).toDouble(),
    sn: (json['sn'] as num).toDouble(),
    nsp: (json['nsp'] as num).toDouble(),
    nsn: (json['nsn'] as num).toDouble(),
    asScore: (json['as_score'] as num).toDouble(),
    rank: json['rank'],
  );
}
