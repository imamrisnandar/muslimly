import 'package:equatable/equatable.dart';

enum AudioSourceType { quranComChapter, alQuranCloudVerse }

class Reciter extends Equatable {
  final String id; // identifier (e.g. ar.alafasy or quran_com_1)
  final String name; // englishName
  final String? style; // bitrate or type
  final AudioSourceType source;

  const Reciter({
    required this.id,
    required this.name,
    this.style,
    required this.source,
  });

  factory Reciter.fromAlQuranCloudJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['identifier'] as String,
      name: json['englishName'] as String,
      style: json['bitrate'] != null ? '${json['bitrate']}kbps' : json['type'],
      source: AudioSourceType.alQuranCloudVerse,
    );
  }

  factory Reciter.fromQuranComJson(Map<String, dynamic> json) {
    // Quran.com returns { id: 2, reciter_name: "...", style: "Murattal" }
    return Reciter(
      id: 'quran_com_${json['id']}',
      name: json['reciter_name'] as String,
      style: json['style'] as String?,
      source: AudioSourceType.quranComChapter,
    );
  }

  // Backward compatibility / Generic
  factory Reciter.fromJson(Map<String, dynamic> json) {
    // Determine source heuristic or just default
    if (json.containsKey('identifier')) {
      return Reciter.fromAlQuranCloudJson(json);
    }
    if (json.containsKey('reciter_name')) {
      return Reciter.fromQuranComJson(json);
    }
    // Fallback?
    return Reciter(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      source: AudioSourceType.alQuranCloudVerse,
    );
  }

  @override
  List<Object?> get props => [id, name, style, source];
}
