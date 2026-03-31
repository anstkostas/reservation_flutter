import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../constants/constants.dart';
import 'user_summary.dart';

part 'reservation_model.freezed.dart';
part 'reservation_model.g.dart';

/// Converts between [ReservationStatus] and its JSON string representation.
///
/// Needed because [ReservationStatus.noShow] maps to `'no-show'` in the API
/// (with a hyphen), which does not match the Dart enum name `noShow`.
/// All other values match their `.name` directly.
class _ReservationStatusConverter
    implements JsonConverter<ReservationStatus, String> {
  const _ReservationStatusConverter();

  @override
  ReservationStatus fromJson(String json) => ReservationStatus.fromString(json);

  @override
  String toJson(ReservationStatus status) =>
      status == ReservationStatus.noShow ? 'no-show' : status.name;
}

/// Represents a reservation returned by the API.
///
/// Matches the backend `ReservationOutput` DTO exactly. Restaurant data is
/// flattened into top-level fields (not a nested object) because the backend
/// returns only the fields relevant to each context — not the full restaurant.
///
/// The same model handles two response shapes depending on the endpoint:
/// - **Customer view** (`GET /reservations/my-reservations`): restaurant
///   fields (`restaurantName`, `restaurantAddress`, `restaurantPhone`) are
///   populated; [customer] is null.
/// - **Owner view** (`GET /reservations/owner-reservations`): [customer] is
///   populated with a [UserSummary]; restaurant fields may be null.
///
/// Fields absent from the API response deserialize to null automatically.
///
/// ---
/// ## Generated code (do not write these manually)
///
/// ### By `freezed` → `reservation_model.freezed.dart`
/// - `copyWith({String? id, DateTime? scheduledAt, ...})` — clones with overrides.
/// - `operator ==` and `hashCode` — value equality across all fields.
/// - `toString()` — readable debug string.
///
/// ### By `json_serializable` → `reservation_model.g.dart`
/// - `ReservationModel.fromJson(Map<String, Object?> json)` — deserializes
///   the API response. The `status` field uses [_ReservationStatusConverter]
///   to handle the `no-show` ↔ `noShow` mismatch.
/// - `toJson()` — serializes back to a map.
///
/// ---
/// ## Docs
/// - freezed: https://pub.dev/packages/freezed
/// - json_serializable: https://pub.dev/packages/json_serializable
/// - JsonConverter: https://pub.dev/documentation/json_annotation/latest/json_annotation/JsonConverter-class.html
@freezed
abstract class ReservationModel with _$ReservationModel {
  const factory ReservationModel({
    required String id,
    required DateTime scheduledAt,
    required int people,
    @_ReservationStatusConverter() required ReservationStatus status,
    required String restaurantId,
    required String customerId,
    // Populated in customer view (my-reservations)
    String? restaurantName,
    String? restaurantAddress,
    String? restaurantPhone,
    // Populated in owner view (owner-reservations)
    UserSummary? customer,
  }) = _ReservationModel;

  factory ReservationModel.fromJson(Map<String, Object?> json) =>
      _$ReservationModelFromJson(json);
}
