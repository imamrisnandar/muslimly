// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FastingModel _$FastingModelFromJson(Map<String, dynamic> json) =>
    _FastingModel(
      id: json['id'] as String,
      order: (json['order'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      contentMarkdown: json['content_markdown'] as String,
    );

Map<String, dynamic> _$FastingModelToJson(_FastingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'title': instance.title,
      'description': instance.description,
      'content_markdown': instance.contentMarkdown,
    };
