class StationModel {
  final String stationId;
  final String name;
  final String code;
  final String address;
  final String phone;
  final String? createdAt;

  StationModel({
    required this.stationId,
    required this.name,
    required this.code,
    required this.address,
    required this.phone,
    this.createdAt,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      stationId: json['station_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'station_id': stationId,
        'name': name,
        'code': code,
        'address': address,
        'phone': phone,
        'created_at': createdAt,
      };
}
