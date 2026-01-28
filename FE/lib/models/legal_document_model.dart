class LegalDocumentModel {
  final String documentId;
  final String title;
  final String description;
  final String fileUrl;
  final String fileType;
  final String createdAt;

  LegalDocumentModel({
    required this.documentId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileType,
    required this.createdAt,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      documentId: json['document_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileType: json['file_type'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'file_type': fileType,
      'created_at': createdAt,
    };
  }
}
