class IncidentModel {
  final String incidentId; // UUID
  final String caseCode; // Mã hồ sơ (user input)
  final String title;
  final String location;
  final String? stationId;
  final String? stationName;
  final String? description;
  final List<String> evidence;
  final String? createdAt;
  final String? occurredAt;
  final String? incidentType;
  final String? severity;
  final String? status;

  IncidentModel({
    required this.incidentId,
    required this.caseCode,
    required this.title,
    required this.location,
    this.stationId,
    this.stationName,
    this.description,
    List<String>? evidence,
    this.createdAt,
    this.occurredAt,
    this.incidentType,
    this.severity,
    this.status,
  }) : evidence = evidence ?? [];

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      incidentId:
          json['incident_id']?.toString() ?? json['id']?.toString() ?? '',
      caseCode: json['case_code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      stationId: json['station_id']?.toString(),
      stationName: json['station_name']?.toString(),
      description: json['description']?.toString(),
      evidence: (json['evidence'] is List)
          ? List<String>.from(json['evidence'])
          : [],
      createdAt: json['created_at']?.toString(),
      occurredAt: json['occurred_at']?.toString(),
      incidentType: json['incident_type']?.toString(),
      severity: json['severity']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'incident_id': incidentId,
    'case_code': caseCode,
    'title': title,
    'location': location,
    'station_id': stationId,
    'station_name': stationName,
    'description': description,
    'evidence': evidence,
    'created_at': createdAt,
    'occurred_at': occurredAt,
    'incident_type': incidentType,
    'severity': severity,
    'status': status,
  };
}
