// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fasting_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FastingModel {

 String get id; int get order; String get title; String get description;@JsonKey(name: 'content_markdown') String get contentMarkdown;
/// Create a copy of FastingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FastingModelCopyWith<FastingModel> get copyWith => _$FastingModelCopyWithImpl<FastingModel>(this as FastingModel, _$identity);

  /// Serializes this FastingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FastingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentMarkdown, contentMarkdown) || other.contentMarkdown == contentMarkdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,title,description,contentMarkdown);

@override
String toString() {
  return 'FastingModel(id: $id, order: $order, title: $title, description: $description, contentMarkdown: $contentMarkdown)';
}


}

/// @nodoc
abstract mixin class $FastingModelCopyWith<$Res>  {
  factory $FastingModelCopyWith(FastingModel value, $Res Function(FastingModel) _then) = _$FastingModelCopyWithImpl;
@useResult
$Res call({
 String id, int order, String title, String description,@JsonKey(name: 'content_markdown') String contentMarkdown
});




}
/// @nodoc
class _$FastingModelCopyWithImpl<$Res>
    implements $FastingModelCopyWith<$Res> {
  _$FastingModelCopyWithImpl(this._self, this._then);

  final FastingModel _self;
  final $Res Function(FastingModel) _then;

/// Create a copy of FastingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? order = null,Object? title = null,Object? description = null,Object? contentMarkdown = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,contentMarkdown: null == contentMarkdown ? _self.contentMarkdown : contentMarkdown // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FastingModel].
extension FastingModelPatterns on FastingModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FastingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FastingModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FastingModel value)  $default,){
final _that = this;
switch (_that) {
case _FastingModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FastingModel value)?  $default,){
final _that = this;
switch (_that) {
case _FastingModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int order,  String title,  String description, @JsonKey(name: 'content_markdown')  String contentMarkdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FastingModel() when $default != null:
return $default(_that.id,_that.order,_that.title,_that.description,_that.contentMarkdown);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int order,  String title,  String description, @JsonKey(name: 'content_markdown')  String contentMarkdown)  $default,) {final _that = this;
switch (_that) {
case _FastingModel():
return $default(_that.id,_that.order,_that.title,_that.description,_that.contentMarkdown);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int order,  String title,  String description, @JsonKey(name: 'content_markdown')  String contentMarkdown)?  $default,) {final _that = this;
switch (_that) {
case _FastingModel() when $default != null:
return $default(_that.id,_that.order,_that.title,_that.description,_that.contentMarkdown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FastingModel implements FastingModel {
  const _FastingModel({required this.id, required this.order, required this.title, required this.description, @JsonKey(name: 'content_markdown') required this.contentMarkdown});
  factory _FastingModel.fromJson(Map<String, dynamic> json) => _$FastingModelFromJson(json);

@override final  String id;
@override final  int order;
@override final  String title;
@override final  String description;
@override@JsonKey(name: 'content_markdown') final  String contentMarkdown;

/// Create a copy of FastingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FastingModelCopyWith<_FastingModel> get copyWith => __$FastingModelCopyWithImpl<_FastingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FastingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FastingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentMarkdown, contentMarkdown) || other.contentMarkdown == contentMarkdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,title,description,contentMarkdown);

@override
String toString() {
  return 'FastingModel(id: $id, order: $order, title: $title, description: $description, contentMarkdown: $contentMarkdown)';
}


}

/// @nodoc
abstract mixin class _$FastingModelCopyWith<$Res> implements $FastingModelCopyWith<$Res> {
  factory _$FastingModelCopyWith(_FastingModel value, $Res Function(_FastingModel) _then) = __$FastingModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int order, String title, String description,@JsonKey(name: 'content_markdown') String contentMarkdown
});




}
/// @nodoc
class __$FastingModelCopyWithImpl<$Res>
    implements _$FastingModelCopyWith<$Res> {
  __$FastingModelCopyWithImpl(this._self, this._then);

  final _FastingModel _self;
  final $Res Function(_FastingModel) _then;

/// Create a copy of FastingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? order = null,Object? title = null,Object? description = null,Object? contentMarkdown = null,}) {
  return _then(_FastingModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,contentMarkdown: null == contentMarkdown ? _self.contentMarkdown : contentMarkdown // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
