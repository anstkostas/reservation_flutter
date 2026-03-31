import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_summary.freezed.dart';
part 'user_summary.g.dart';

/// A lightweight projection of a user, returned when a user is embedded
/// inside another resource's API response (e.g. a customer inside a reservation).
///
/// ## Why this exists
/// The full [UserModel] is returned only by auth endpoints (`/auth/me`,
/// `/auth/login`) where the app needs `role` for routing decisions.
/// When user data appears inside other resources, the backend returns only
/// the fields relevant to that context — currently `id`, `firstname`,
/// `lastname`, and `email`.
///
/// ## Naming guide
/// This model is named after **what the data is** (a summary of a user),
/// not **where it appears** (e.g. `ReservationCustomer`). This keeps the
/// model reusable if the same projection appears in future responses
/// (reviews, notifications, etc.) without renaming or duplicating.
///
/// If a future endpoint embeds a meaningfully different user shape, a new
/// named projection should be created following the same principle.
///
/// ---
/// ## Generated code (do not write these manually)
///
/// ### By `freezed` → `user_summary.freezed.dart`
/// - `copyWith({String? id, ...})` — clones with overrides.
/// - `operator ==` and `hashCode` — value equality.
/// - `toString()` — readable debug string.
///
/// ### By `json_serializable` → `user_summary.g.dart`
/// - `UserSummary.fromJson(Map<String, Object?> json)` — deserializes
///   the embedded user object from an API response.
/// - `toJson()` — serializes back to a map.
///
/// ---
/// ## Docs
/// - freezed: https://pub.dev/packages/freezed
/// - json_serializable: https://pub.dev/packages/json_serializable
@freezed
abstract class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String id,
    required String firstname,
    required String lastname,
    required String email,
  }) = _UserSummary;

  factory UserSummary.fromJson(Map<String, Object?> json) =>
      _$UserSummaryFromJson(json);
}
