import 'package:freezed_annotation/freezed_annotation.dart';

part 'tajweed_model.g.dart';
part 'tajweed_model.freezed.dart';

@freezed
abstract class TajweedCategory with _$TajweedCategory {
  const factory TajweedCategory({
    required String id,
    required String title,
    required String description,
    required List<TajweedLesson> lessons,
  }) = _TajweedCategory;

  factory TajweedCategory.fromJson(Map<String, dynamic> json) =>
      _$TajweedCategoryFromJson(json);
}

@freezed
abstract class TajweedLesson with _$TajweedLesson {
  const factory TajweedLesson({
    required String id,
    required String title,
    required String definition,
    required List<String> letters,
    required List<TajweedExample> examples,
    String? note,
  }) = _TajweedLesson;

  factory TajweedLesson.fromJson(Map<String, dynamic> json) =>
      _$TajweedLessonFromJson(json);
}

@freezed
abstract class TajweedExample with _$TajweedExample {
  const factory TajweedExample({
    required String label,
    required int surah,
    required int ayah,
    required String highlight,
    @JsonKey(name: 'audio_urls') @Default([]) List<String> audioUrls,
    @JsonKey(name: 'sub_category') String? subCategory,
  }) = _TajweedExample;

  factory TajweedExample.fromJson(Map<String, dynamic> json) =>
      _$TajweedExampleFromJson(json);
}
