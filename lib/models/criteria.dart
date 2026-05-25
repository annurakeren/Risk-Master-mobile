// lib/models/criteria.dart
class Criteria {
  final int id;
  final String name;
  final String description;
  final String type; // 'benefit' atau 'cost'
  final double weight;

  Criteria({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.weight,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) => Criteria(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    type: json['type'],
    weight: (json['weight'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'type': type,
    'weight': weight,
  };

  bool get isBenefit => type == 'benefit';
}
