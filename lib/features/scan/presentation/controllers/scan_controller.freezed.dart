// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ScanState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get groupId => throw _privateConstructorUsedError;
  File? get imageFile => throw _privateConstructorUsedError;
  String? get tempImageUrl => throw _privateConstructorUsedError;
  ScanResultModel? get result => throw _privateConstructorUsedError;
  DateTime? get playedAt => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScanStateCopyWith<ScanState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanStateCopyWith<$Res> {
  factory $ScanStateCopyWith(ScanState value, $Res Function(ScanState) then) =
      _$ScanStateCopyWithImpl<$Res, ScanState>;
  @useResult
  $Res call(
      {bool isLoading,
      String? groupId,
      File? imageFile,
      String? tempImageUrl,
      ScanResultModel? result,
      DateTime? playedAt,
      String? error});

  $ScanResultModelCopyWith<$Res>? get result;
}

/// @nodoc
class _$ScanStateCopyWithImpl<$Res, $Val extends ScanState>
    implements $ScanStateCopyWith<$Res> {
  _$ScanStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? groupId = freezed,
    Object? imageFile = freezed,
    Object? tempImageUrl = freezed,
    Object? result = freezed,
    Object? playedAt = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      imageFile: freezed == imageFile
          ? _value.imageFile
          : imageFile // ignore: cast_nullable_to_non_nullable
              as File?,
      tempImageUrl: freezed == tempImageUrl
          ? _value.tempImageUrl
          : tempImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ScanResultModel?,
      playedAt: freezed == playedAt
          ? _value.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ScanResultModelCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $ScanResultModelCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScanStateImplCopyWith<$Res>
    implements $ScanStateCopyWith<$Res> {
  factory _$$ScanStateImplCopyWith(
          _$ScanStateImpl value, $Res Function(_$ScanStateImpl) then) =
      __$$ScanStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? groupId,
      File? imageFile,
      String? tempImageUrl,
      ScanResultModel? result,
      DateTime? playedAt,
      String? error});

  @override
  $ScanResultModelCopyWith<$Res>? get result;
}

/// @nodoc
class __$$ScanStateImplCopyWithImpl<$Res>
    extends _$ScanStateCopyWithImpl<$Res, _$ScanStateImpl>
    implements _$$ScanStateImplCopyWith<$Res> {
  __$$ScanStateImplCopyWithImpl(
      _$ScanStateImpl _value, $Res Function(_$ScanStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? groupId = freezed,
    Object? imageFile = freezed,
    Object? tempImageUrl = freezed,
    Object? result = freezed,
    Object? playedAt = freezed,
    Object? error = freezed,
  }) {
    return _then(_$ScanStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      imageFile: freezed == imageFile
          ? _value.imageFile
          : imageFile // ignore: cast_nullable_to_non_nullable
              as File?,
      tempImageUrl: freezed == tempImageUrl
          ? _value.tempImageUrl
          : tempImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ScanResultModel?,
      playedAt: freezed == playedAt
          ? _value.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ScanStateImpl implements _ScanState {
  const _$ScanStateImpl(
      {this.isLoading = false,
      this.groupId,
      this.imageFile,
      this.tempImageUrl,
      this.result,
      this.playedAt,
      this.error});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? groupId;
  @override
  final File? imageFile;
  @override
  final String? tempImageUrl;
  @override
  final ScanResultModel? result;
  @override
  final DateTime? playedAt;
  @override
  final String? error;

  @override
  String toString() {
    return 'ScanState(isLoading: $isLoading, groupId: $groupId, imageFile: $imageFile, tempImageUrl: $tempImageUrl, result: $result, playedAt: $playedAt, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.imageFile, imageFile) ||
                other.imageFile == imageFile) &&
            (identical(other.tempImageUrl, tempImageUrl) ||
                other.tempImageUrl == tempImageUrl) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, groupId, imageFile,
      tempImageUrl, result, playedAt, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanStateImplCopyWith<_$ScanStateImpl> get copyWith =>
      __$$ScanStateImplCopyWithImpl<_$ScanStateImpl>(this, _$identity);
}

abstract class _ScanState implements ScanState {
  const factory _ScanState(
      {final bool isLoading,
      final String? groupId,
      final File? imageFile,
      final String? tempImageUrl,
      final ScanResultModel? result,
      final DateTime? playedAt,
      final String? error}) = _$ScanStateImpl;

  @override
  bool get isLoading;
  @override
  String? get groupId;
  @override
  File? get imageFile;
  @override
  String? get tempImageUrl;
  @override
  ScanResultModel? get result;
  @override
  DateTime? get playedAt;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ScanStateImplCopyWith<_$ScanStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
