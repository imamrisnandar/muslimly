import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final int surahNumber;
  final int ayahNumber;
  final String verseKey; // "2:45"
  final String text; // Arabic snippet or full text
  final String translation; // Highlighted translation

  const SearchResult({
    required this.surahNumber,
    required this.ayahNumber,
    required this.verseKey,
    required this.text,
    required this.translation,
  });

  @override
  List<Object?> get props => [
    surahNumber,
    ayahNumber,
    verseKey,
    text,
    translation,
  ];
}
