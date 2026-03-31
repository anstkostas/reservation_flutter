import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_model.freezed.dart';
part 'restaurant_model.g.dart';

/// Represents a restaurant returned by the API.
///
/// Maps to the backend `restaurantOutputDTO` shape. Note: `address` and
/// `phone` are intentionally omitted — the backend DTO does not expose
/// them on restaurant list/detail endpoints.
@freezed
abstract class RestaurantModel with _$RestaurantModel {
  const factory RestaurantModel({
    required String id,
    required String name,
    required String description,
    required int capacity,
    required String logoUrl,
    required String coverImageUrl,
    String? ownerId,
  }) = _RestaurantModel;

  factory RestaurantModel.fromJson(Map<String, Object?> json) =>
      _$RestaurantModelFromJson(json);
}
