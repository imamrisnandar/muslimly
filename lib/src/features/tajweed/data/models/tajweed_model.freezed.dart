// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tajweed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TajweedCategory {

 String get id; String get title; String get description; List<TajweedLesson> get lessons;
/// Create a copy of TajweedCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TajweedCategoryCopyWith<TajweedCategory> get copyWith => _$TajweedCategoryCopyWithImpl<TajweedCategory>(this as TajweedCategory, _$identity);

  /// Serializes this TajweedCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TajweedCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.lessons, lessons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(lessons));

@override
String toString() {
  return 'TajweedCategory(id: $id, title: $title, description: $description, lessons: $lessons)';
}


}

/// @nodoc
abstract mixin class $TajweedCategoryCopyWith<$Res>  {
  factory $TajweedCategoryCopyWith(TajweedCategory value, $Res Function(TajweedCategory) _then) = _$TajweedCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, List<TajweedLesson> lessons
});




}
/// @nodoc
class _$TajweedCategoryCopyWithImpl<$Res>
    implements $TajweedCategoryCopyWith<$Res> {
  _$TajweedCategoryCopyWithImpl(this._self, this._then);

  final TajweedCategory _self;
  final $Res Function(TajweedCategory) _then;

/// Create a copy of TajweedCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? lessons = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,lessons: null == lessons ? _self.lessons : lessons // ignore: cast_nullable_to_non_nullable
as List<TajweedLesson>,
  ));
}

}


/// Adds pattern-matching-related methods to [TajweedCategory].
extension TajweedCategoryPatterns on TajweedCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TajweedCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TajweedCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TajweedCategory value)  $default,){
final _that = this;
switch (_that) {
case _TajweedCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TajweedCategory value)?  $default,){
final _that = this;
switch (_that) {
case _TajweedCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  List<TajweedLesson> lessons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TajweedCategory() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.lessons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  List<TajweedLesson> lessons)  $default,) {final _that = this;
switch (_that) {
case _TajweedCategory():
return $default(_that.id,_that.title,_that.description,_that.lessons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  List<TajweedLesson> lessons)?  $default,) {final _that = this;
switch (_that) {
case _TajweedCategory() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.lessons);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TajweedCategory implements TajweedCategory {
  const _TajweedCategory({required this.id, required this.title, required this.description, required final  List<TajweedLesson> lessons}): _lessons = lessons;
  factory _TajweedCategory.fromJson(Map<String, dynamic> json) => _$TajweedCategoryFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
 final  List<TajweedLesson> _lessons;
@override List<TajweedLesson> get lessons {
  if (_lessons is EqualUnmodifiableListView) return _lessons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lessons);
}


/// Create a copy of TajweedCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TajweedCategoryCopyWith<_TajweedCategory> get copyWith => __$TajweedCategoryCopyWithImpl<_TajweedCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TajweedCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TajweedCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._lessons, _lessons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(_lessons));

@override
String toString() {
  return 'TajweedCategory(id: $id, title: $title, description: $description, lessons: $lessons)';
}


}

/// @nodoc
abstract mixin class _$TajweedCategoryCopyWith<$Res> implements $TajweedCategoryCopyWith<$Res> {
  factory _$TajweedCategoryCopyWith(_TajweedCategory value, $Res Function(_TajweedCategory) _then) = __$TajweedCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, List<TajweedLesson> lessons
});




}
/// @nodoc
class __$TajweedCategoryCopyWithImpl<$Res>
    implements _$TajweedCategoryCopyWith<$Res> {
  __$TajweedCategoryCopyWithImpl(this._self, this._then);

  final _TajweedCategory _self;
  final $Res Function(_TajweedCategory) _then;

/// Create a copy of TajweedCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? lessons = null,}) {
  return _then(_TajweedCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,lessons: null == lessons ? _self._lessons : lessons // ignore: cast_nullable_to_non_nullable
as List<TajweedLesson>,
  ));
}


}


/// @nodoc
mixin _$TajweedLesson {

 String get id; String get title; String get definition; List<String> get letters; List<TajweedExample> get examples; String? get note;
/// Create a copy of TajweedLesson
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TajweedLessonCopyWith<TajweedLesson> get copyWith => _$TajweedLessonCopyWithImpl<TajweedLesson>(this as TajweedLesson, _$identity);

  /// Serializes this TajweedLesson to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TajweedLesson&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.definition, definition) || other.definition == definition)&&const DeepCollectionEquality().equals(other.letters, letters)&&const DeepCollectionEquality().equals(other.examples, examples)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,definition,const DeepCollectionEquality().hash(letters),const DeepCollectionEquality().hash(examples),note);

@override
String toString() {
  return 'TajweedLesson(id: $id, title: $title, definition: $definition, letters: $letters, examples: $examples, note: $note)';
}


}

/// @nodoc
abstract mixin class $TajweedLessonCopyWith<$Res>  {
  factory $TajweedLessonCopyWith(TajweedLesson value, $Res Function(TajweedLesson) _then) = _$TajweedLessonCopyWithImpl;
@useResult
$Res call({
 String id, String title, String definition, List<String> letters, List<TajweedExample> examples, String? note
});




}
/// @nodoc
class _$TajweedLessonCopyWithImpl<$Res>
    implements $TajweedLessonCopyWith<$Res> {
  _$TajweedLessonCopyWithImpl(this._self, this._then);

  final TajweedLesson _self;
  final $Res Function(TajweedLesson) _then;

/// Create a copy of TajweedLesson
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? definition = null,Object? letters = null,Object? examples = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String,letters: null == letters ? _self.letters : letters // ignore: cast_nullable_to_non_nullable
as List<String>,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<TajweedExample>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TajweedLesson].
extension TajweedLessonPatterns on TajweedLesson {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TajweedLesson value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TajweedLesson() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TajweedLesson value)  $default,){
final _that = this;
switch (_that) {
case _TajweedLesson():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TajweedLesson value)?  $default,){
final _that = this;
switch (_that) {
case _TajweedLesson() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String definition,  List<String> letters,  List<TajweedExample> examples,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TajweedLesson() when $default != null:
return $default(_that.id,_that.title,_that.definition,_that.letters,_that.examples,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String definition,  List<String> letters,  List<TajweedExample> examples,  String? note)  $default,) {final _that = this;
switch (_that) {
case _TajweedLesson():
return $default(_that.id,_that.title,_that.definition,_that.letters,_that.examples,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String definition,  List<String> letters,  List<TajweedExample> examples,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _TajweedLesson() when $default != null:
return $default(_that.id,_that.title,_that.definition,_that.letters,_that.examples,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TajweedLesson implements TajweedLesson {
  const _TajweedLesson({required this.id, required this.title, required this.definition, required final  List<String> letters, required final  List<TajweedExample> examples, this.note}): _letters = letters,_examples = examples;
  factory _TajweedLesson.fromJson(Map<String, dynamic> json) => _$TajweedLessonFromJson(json);

@override final  String id;
@override final  String title;
@override final  String definition;
 final  List<String> _letters;
@override List<String> get letters {
  if (_letters is EqualUnmodifiableListView) return _letters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_letters);
}

 final  List<TajweedExample> _examples;
@override List<TajweedExample> get examples {
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examples);
}

@override final  String? note;

/// Create a copy of TajweedLesson
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TajweedLessonCopyWith<_TajweedLesson> get copyWith => __$TajweedLessonCopyWithImpl<_TajweedLesson>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TajweedLessonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TajweedLesson&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.definition, definition) || other.definition == definition)&&const DeepCollectionEquality().equals(other._letters, _letters)&&const DeepCollectionEquality().equals(other._examples, _examples)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,definition,const DeepCollectionEquality().hash(_letters),const DeepCollectionEquality().hash(_examples),note);

@override
String toString() {
  return 'TajweedLesson(id: $id, title: $title, definition: $definition, letters: $letters, examples: $examples, note: $note)';
}


}

/// @nodoc
abstract mixin class _$TajweedLessonCopyWith<$Res> implements $TajweedLessonCopyWith<$Res> {
  factory _$TajweedLessonCopyWith(_TajweedLesson value, $Res Function(_TajweedLesson) _then) = __$TajweedLessonCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String definition, List<String> letters, List<TajweedExample> examples, String? note
});




}
/// @nodoc
class __$TajweedLessonCopyWithImpl<$Res>
    implements _$TajweedLessonCopyWith<$Res> {
  __$TajweedLessonCopyWithImpl(this._self, this._then);

  final _TajweedLesson _self;
  final $Res Function(_TajweedLesson) _then;

/// Create a copy of TajweedLesson
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? definition = null,Object? letters = null,Object? examples = null,Object? note = freezed,}) {
  return _then(_TajweedLesson(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String,letters: null == letters ? _self._letters : letters // ignore: cast_nullable_to_non_nullable
as List<String>,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<TajweedExample>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TajweedExample {

 String get label; int get surah; int get ayah; String get highlight;@JsonKey(name: 'audio_urls') List<String> get audioUrls;@JsonKey(name: 'sub_category') String? get subCategory;
/// Create a copy of TajweedExample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TajweedExampleCopyWith<TajweedExample> get copyWith => _$TajweedExampleCopyWithImpl<TajweedExample>(this as TajweedExample, _$identity);

  /// Serializes this TajweedExample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TajweedExample&&(identical(other.label, label) || other.label == label)&&(identical(other.surah, surah) || other.surah == surah)&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.highlight, highlight) || other.highlight == highlight)&&const DeepCollectionEquality().equals(other.audioUrls, audioUrls)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,surah,ayah,highlight,const DeepCollectionEquality().hash(audioUrls),subCategory);

@override
String toString() {
  return 'TajweedExample(label: $label, surah: $surah, ayah: $ayah, highlight: $highlight, audioUrls: $audioUrls, subCategory: $subCategory)';
}


}

/// @nodoc
abstract mixin class $TajweedExampleCopyWith<$Res>  {
  factory $TajweedExampleCopyWith(TajweedExample value, $Res Function(TajweedExample) _then) = _$TajweedExampleCopyWithImpl;
@useResult
$Res call({
 String label, int surah, int ayah, String highlight,@JsonKey(name: 'audio_urls') List<String> audioUrls,@JsonKey(name: 'sub_category') String? subCategory
});




}
/// @nodoc
class _$TajweedExampleCopyWithImpl<$Res>
    implements $TajweedExampleCopyWith<$Res> {
  _$TajweedExampleCopyWithImpl(this._self, this._then);

  final TajweedExample _self;
  final $Res Function(TajweedExample) _then;

/// Create a copy of TajweedExample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? surah = null,Object? ayah = null,Object? highlight = null,Object? audioUrls = null,Object? subCategory = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,highlight: null == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as String,audioUrls: null == audioUrls ? _self.audioUrls : audioUrls // ignore: cast_nullable_to_non_nullable
as List<String>,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TajweedExample].
extension TajweedExamplePatterns on TajweedExample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TajweedExample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TajweedExample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TajweedExample value)  $default,){
final _that = this;
switch (_that) {
case _TajweedExample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TajweedExample value)?  $default,){
final _that = this;
switch (_that) {
case _TajweedExample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int surah,  int ayah,  String highlight, @JsonKey(name: 'audio_urls')  List<String> audioUrls, @JsonKey(name: 'sub_category')  String? subCategory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TajweedExample() when $default != null:
return $default(_that.label,_that.surah,_that.ayah,_that.highlight,_that.audioUrls,_that.subCategory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int surah,  int ayah,  String highlight, @JsonKey(name: 'audio_urls')  List<String> audioUrls, @JsonKey(name: 'sub_category')  String? subCategory)  $default,) {final _that = this;
switch (_that) {
case _TajweedExample():
return $default(_that.label,_that.surah,_that.ayah,_that.highlight,_that.audioUrls,_that.subCategory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int surah,  int ayah,  String highlight, @JsonKey(name: 'audio_urls')  List<String> audioUrls, @JsonKey(name: 'sub_category')  String? subCategory)?  $default,) {final _that = this;
switch (_that) {
case _TajweedExample() when $default != null:
return $default(_that.label,_that.surah,_that.ayah,_that.highlight,_that.audioUrls,_that.subCategory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TajweedExample implements TajweedExample {
  const _TajweedExample({required this.label, required this.surah, required this.ayah, required this.highlight, @JsonKey(name: 'audio_urls') final  List<String> audioUrls = const [], @JsonKey(name: 'sub_category') this.subCategory}): _audioUrls = audioUrls;
  factory _TajweedExample.fromJson(Map<String, dynamic> json) => _$TajweedExampleFromJson(json);

@override final  String label;
@override final  int surah;
@override final  int ayah;
@override final  String highlight;
 final  List<String> _audioUrls;
@override@JsonKey(name: 'audio_urls') List<String> get audioUrls {
  if (_audioUrls is EqualUnmodifiableListView) return _audioUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_audioUrls);
}

@override@JsonKey(name: 'sub_category') final  String? subCategory;

/// Create a copy of TajweedExample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TajweedExampleCopyWith<_TajweedExample> get copyWith => __$TajweedExampleCopyWithImpl<_TajweedExample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TajweedExampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TajweedExample&&(identical(other.label, label) || other.label == label)&&(identical(other.surah, surah) || other.surah == surah)&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.highlight, highlight) || other.highlight == highlight)&&const DeepCollectionEquality().equals(other._audioUrls, _audioUrls)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,surah,ayah,highlight,const DeepCollectionEquality().hash(_audioUrls),subCategory);

@override
String toString() {
  return 'TajweedExample(label: $label, surah: $surah, ayah: $ayah, highlight: $highlight, audioUrls: $audioUrls, subCategory: $subCategory)';
}


}

/// @nodoc
abstract mixin class _$TajweedExampleCopyWith<$Res> implements $TajweedExampleCopyWith<$Res> {
  factory _$TajweedExampleCopyWith(_TajweedExample value, $Res Function(_TajweedExample) _then) = __$TajweedExampleCopyWithImpl;
@override @useResult
$Res call({
 String label, int surah, int ayah, String highlight,@JsonKey(name: 'audio_urls') List<String> audioUrls,@JsonKey(name: 'sub_category') String? subCategory
});




}
/// @nodoc
class __$TajweedExampleCopyWithImpl<$Res>
    implements _$TajweedExampleCopyWith<$Res> {
  __$TajweedExampleCopyWithImpl(this._self, this._then);

  final _TajweedExample _self;
  final $Res Function(_TajweedExample) _then;

/// Create a copy of TajweedExample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? surah = null,Object? ayah = null,Object? highlight = null,Object? audioUrls = null,Object? subCategory = freezed,}) {
  return _then(_TajweedExample(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,highlight: null == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as String,audioUrls: null == audioUrls ? _self._audioUrls : audioUrls // ignore: cast_nullable_to_non_nullable
as List<String>,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
