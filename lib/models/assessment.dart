// lib/models/assessment.dart
class Assessment {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String status; // 'draft' atau 'completed'
  final int alternativesCount;
  final int expectedCount;
  final int filledCount;
  final bool isComplete;
  final String ownerName;

  Assessment({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    this.alternativesCount = 0,
    this.expectedCount = 0,
    this.filledCount = 0,
    this.isComplete = false,
    this.ownerName = '',
  });

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
    id: json['id'],
    // AssessmentResource tidak expose user_id langsung, pakai owner.id
    userId: json['owner']?['id'] ?? json['user_id'] ?? 0,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? 'draft',
    alternativesCount: json['alternatives_count'] ?? 0,
    expectedCount: json['expected_count'] ?? 0,
    filledCount: json['filled_count'] ?? 0,
    isComplete: json['is_complete'] == true || json['is_complete'] == 1,
    ownerName: json['owner']?['name'] ?? '',
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
  // pda & nda: hanya ada di response POST /calculate
  // GET /results tidak mengembalikan field ini
  final double pda;
  final double nda;
  final double sp;
  final double sn;
  final double nsp;
  final double nsn;
  final double asScore;
  final int rank;
  final String qualityLabel;

  EdasResult({
    required this.alternativeId,
    required this.alternativeName,
    this.pda = 0,
    this.nda = 0,
    required this.sp,
    required this.sn,
    required this.nsp,
    required this.nsn,
    required this.asScore,
    required this.rank,
    this.qualityLabel = '',
  });

  factory EdasResult.fromJson(Map<String, dynamic> json) => EdasResult(
    // GET /results: { rank, alternative: {id, name, ...}, sp, sn, nsp, nsn, as_score, ... }
    alternativeId: json['alternative']?['id'] ?? json['alternative_id'] ?? 0,
    alternativeName: json['alternative']?['name'] ?? json['alternative_name'] ?? '',
    pda: (json['pda'] as num?)?.toDouble() ?? 0,
    nda: (json['nda'] as num?)?.toDouble() ?? 0,
    sp: (json['sp'] as num?)?.toDouble() ?? 0,
    sn: (json['sn'] as num?)?.toDouble() ?? 0,
    nsp: (json['nsp'] as num?)?.toDouble() ?? 0,
    nsn: (json['nsn'] as num?)?.toDouble() ?? 0,
    asScore: (json['as_score'] as num?)?.toDouble() ?? 0,
    rank: json['rank'] ?? 0,
    qualityLabel: json['quality_label'] ?? '',
  );
}
