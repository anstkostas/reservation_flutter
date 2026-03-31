import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../constants/constants.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Represents a user returned by the API.
///
/// The `password` field is never included in API responses —
/// only the fields listed here are returned by the backend.
///
/// ---
/// ## Generated code (do not write these manually)
///
/// ### By `freezed` → `user_model.freezed.dart`
/// - `copyWith({String? id, String? firstname, ...})` — returns a new instance
///   with the specified fields replaced; unspecified fields keep their current value.
/// - `operator ==` and `hashCode` — value equality based on all fields.
/// - `toString()` — readable debug string listing all field values.
///
/// ### By `json_serializable` → `user_model.g.dart`
/// - `UserModel.fromJson(Map<String, Object?> json)` — deserializes a raw API
///   response map into a typed [UserModel]. Field names must match JSON keys
///   (camelCase matches by default). Use `@JsonKey(name: '...')` to override.
/// - `toJson()` — serializes this instance back to a `Map<String, dynamic>`.
///   Useful when sending data to the API (e.g. in request bodies).
///
/// ### Field getters (from the `const factory` constructor)
/// Every field (`id`, `firstname`, `lastname`, `email`, `role`) is accessible
/// as a named getter on any instance — no manual getter definitions needed.
///
/// ---
/// ## Docs
/// - freezed: https://pub.dev/packages/freezed
/// - json_serializable: https://pub.dev/packages/json_serializable
/// - @JsonKey options: https://pub.dev/documentation/json_annotation/latest/json_annotation/JsonKey-class.html
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firstname,
    required String lastname,
    required String email,
    required UserRole role,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object?> json) =>
      _$UserModelFromJson(json);
}
