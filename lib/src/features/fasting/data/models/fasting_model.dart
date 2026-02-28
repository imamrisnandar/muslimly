import 'package:freezed_annotation/freezed_annotation.dart';

part 'fasting_model.g.dart';
part 'fasting_model.freezed.dart';

@freezed
abstract class FastingModel with _$FastingModel {
  const factory FastingModel({
    required String id,
    required int order,
    required String title,
    required String description,
    @JsonKey(name: 'content_markdown') required String contentMarkdown,
  }) = _FastingModel;

  factory FastingModel.fromJson(Map<String, dynamic> json) =>
      _$FastingModelFromJson(json);
}
