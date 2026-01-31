import 'package:equatable/equatable.dart';

class City extends Equatable {
  final String id;
  final String name;

  final double latitude;
  final double longitude;

  const City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}
