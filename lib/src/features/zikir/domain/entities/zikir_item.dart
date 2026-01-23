import 'package:equatable/equatable.dart';

class ZikirItem extends Equatable {
  final int id;
  final String title;
  final String arabic;
  final String translation;
  final String transliteration; // Optional, maybe empty for now
  final String source; // "HR. Bukhari", etc.
  final int targetCount; // e.g. 1, 3, 33, 100

  const ZikirItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    this.transliteration = '',
    this.source = '',
    this.targetCount = 1,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    arabic,
    translation,
    transliteration,
    source,
    targetCount,
  ];
}
