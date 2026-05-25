// lib/models/alternative.dart
class Alternative {
  final int id;
  final String name;
  final String description;
  final String source; // 'admin' atau 'user'
  final int? createdBy;

  Alternative({
    required this.id,
    required this.name,
    required this.description,
    required this.source,
    this.createdBy,
  });

  factory Alternative.fromJson(Map<String, dynamic> json) => Alternative(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    source: json['source'],
    createdBy: json['created_by'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'source': source,
  };

  bool get isFromAdmin => source == 'admin';
}
