import 'package:equatable/equatable.dart';

class Reciter extends Equatable {
  final int id;
  final String name;
  final String? style; // e.g., 'Murattal', 'Mujawwad'

  const Reciter({required this.id, required this.name, this.style});

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'] as int,
      name: json['reciter_name'] as String,
      style: json['style'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, style];
}
