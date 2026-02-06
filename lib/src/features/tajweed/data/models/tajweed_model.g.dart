// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tajweed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TajweedCategory _$TajweedCategoryFromJson(Map<String, dynamic> json) =>
    _TajweedCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => TajweedLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TajweedCategoryToJson(_TajweedCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'lessons': instance.lessons,
    };

_TajweedLesson _$TajweedLessonFromJson(Map<String, dynamic> json) =>
    _TajweedLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      definition: json['definition'] as String,
      letters: (json['letters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      examples: (json['examples'] as List<dynamic>)
          .map((e) => TajweedExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$TajweedLessonToJson(_TajweedLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'definition': instance.definition,
      'letters': instance.letters,
      'examples': instance.examples,
      'note': instance.note,
    };

_TajweedExample _$TajweedExampleFromJson(Map<String, dynamic> json) =>
    _TajweedExample(
      label: json['label'] as String,
      surah: (json['surah'] as num).toInt(),
      ayah: (json['ayah'] as num).toInt(),
      highlight: json['highlight'] as String,
      audioUrls:
          (json['audio_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      subCategory: json['sub_category'] as String?,
    );

Map<String, dynamic> _$TajweedExampleToJson(_TajweedExample instance) =>
    <String, dynamic>{
      'label': instance.label,
      'surah': instance.surah,
      'ayah': instance.ayah,
      'highlight': instance.highlight,
      'audio_urls': instance.audioUrls,
      'sub_category': instance.subCategory,
    };
