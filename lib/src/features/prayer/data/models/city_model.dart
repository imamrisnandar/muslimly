class CityModel {
  final String id;
  final String lokasi;

  CityModel({required this.id, required this.lokasi});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['id'] ?? '', lokasi: json['lokasi'] ?? '');
  }
}
