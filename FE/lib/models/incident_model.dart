class IncidentModel {
  final String incidentId;
  final String title;
  final String? description;
  final List<String> evidence;
  final String? createdAt;
  final String? status;

  IncidentModel({
    required this.incidentId,
    required this.title,
    this.description,
    List<String>? evidence,
    this.createdAt,
    this.status,
  }) : evidence = evidence ?? [];

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      incidentId: json['incident_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      evidence: (json['evidence'] is List) ? List<String>.from(json['evidence']) : [],
      createdAt: json['created_at']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'incident_id': incidentId,
        'title': title,
        'description': description,
        'evidence': evidence,
        'created_at': createdAt,
        'status': status,
      };
}
