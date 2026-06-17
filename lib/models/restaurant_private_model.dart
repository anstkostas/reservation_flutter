import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_private_model.freezed.dart';
part 'restaurant_private_model.g.dart';

/// Owner-only description shape — both locales so the edit form can pre-fill each.
///
/// [el] is null when no Greek translation has been saved yet.
@freezed
abstract class RestaurantDescription with _$RestaurantDescription {
  const factory RestaurantDescription({required String en, String? el}) =
      _RestaurantDescription;

  factory RestaurantDescription.fromJson(Map<String, Object?> json) =>
      _$RestaurantDescriptionFromJson(json);
}

/// Owner-facing restaurant shape returned by GET /restaurants/me and PUT /restaurants/me.
///
/// Maps to the backend `RestaurantPrivateOutput` DTO. Unlike [RestaurantModel],
/// this exposes [address], [phone], and [description] as both locales so the
/// owner edit form can pre-fill and submit each field independently.
@freezed
abstract class RestaurantPrivateModel with _$RestaurantPrivateModel {
  const factory RestaurantPrivateModel({
    required String id,
    required String name,
    required RestaurantDescription description,
    required String address,
    required String phone,
    required int capacity,
    required String logoUrl,
    required String coverImageUrl,
    String? ownerId,
  }) = _RestaurantPrivateModel;

  factory RestaurantPrivateModel.fromJson(Map<String, Object?> json) =>
      _$RestaurantPrivateModelFromJson(json);
}
