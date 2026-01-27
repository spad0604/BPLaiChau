import '../../models/incident_model.dart';
import 'csv_exporter.dart';

class ExportService {
  static Future<void> exportIncidentsCsv(List<IncidentModel> items) async {
    final headers = <String>[
      'incident_id',
      'title',
      'location',
      'station_name',
      'incident_type',
      'severity',
      'status',
      'occurred_at',
      'created_at',
      'evidence_count',
    ];

    final rows = items
        .map((i) => <String>[
              i.incidentId,
              i.title,
              i.location,
              i.stationName ?? '',
              i.incidentType ?? '',
              i.severity ?? '',
              i.status ?? '',
              i.occurredAt ?? '',
              i.createdAt ?? '',
              i.evidence.length.toString(),
            ])
        .toList();

    await CsvExporter.export(
      filename: 'incidents.csv',
      headers: headers,
      rows: rows,
    );
  }

  static Future<void> exportAdminsCsv(List<Map<String, dynamic>> items) async {
    final headers = <String>[
      'username',
      'full_name',
      'role',
      'phone_number',
      'date_of_birth',
      'indentity_card_number',
      'gender',
    ];

    String s(dynamic v) => (v ?? '').toString();

    final rows = items
        .map((u) => <String>[
              s(u['username']),
              s(u['full_name']),
              s(u['role']),
              s(u['phone_number']),
              s(u['date_of_birth']),
              s(u['indentity_card_number']),
              s(u['gender']),
            ])
        .toList();

    await CsvExporter.export(
      filename: 'admins.csv',
      headers: headers,
      rows: rows,
    );
  }
}
