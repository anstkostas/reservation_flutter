/// Request payload for PUT /restaurants/me.
///
/// All fields are optional — at least one must be non-null (enforced by the backend).
/// [descriptionEn] and [descriptionEl] are serialized into a nested `description`
/// object only when at least one locale value is present.
class UpdateRestaurantRequest {
  const UpdateRestaurantRequest({
    this.name,
    this.descriptionEn,
    this.descriptionEl,
    this.address,
    this.phone,
    this.capacity,
  });

  final String? name;
  final String? descriptionEn;
  final String? descriptionEl;
  final String? address;
  final String? phone;
  final int? capacity;

  Map<String, dynamic> toMap() {
    final description = <String, dynamic>{
      if (descriptionEn != null) 'en': descriptionEn,
      if (descriptionEl != null) 'el': descriptionEl,
    };
    return {
      if (name != null) 'name': name,
      if (description.isNotEmpty) 'description': description,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (capacity != null) 'capacity': capacity,
    };
  }
}
