import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

class AuthModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? token;

  const AuthModel({
    required this.id,
    required this.email,
    required this.name,
    this.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Check if the response is wrapped in "data"
    final data = json.containsKey('data')
        ? json['data'] as Map<String, dynamic>
        : json;

    final token = data['accessToken'] as String?;

    if (token == null) {
      throw const FormatException('Token not found in response');
    }

    // Decode JWT payload
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token format');
    }

    final payload = parts[1];
    String normalized = base64Url.normalize(payload);
    final String decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> payloadMap = jsonDecode(decoded);

    return AuthModel(
      id: payloadMap['user_id'] as String? ?? 'unknown_id',
      email: payloadMap['email'] as String? ?? 'unknown_email',
      name: payloadMap['role_name'] as String? ?? 'User',
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'token': token};
  }

  User toEntity() => User(id: id, email: email, name: name, token: token);

  @override
  List<Object?> get props => [id, email, name, token];
}
