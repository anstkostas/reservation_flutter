/// API path constants — no bare strings across the codebase.
/// All paths are relative to the base URL set in DioClient.
abstract final class ApiConstants {
  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Restaurants
  static const String restaurants = '/restaurants';
  static String restaurantById(String id) => '/restaurants/$id';

  // Reservations
  static String createReservation(String restaurantId) =>
      '/reservations/restaurants/$restaurantId';
  static const String myReservations = '/reservations/my-reservations';
  static const String ownerReservations = '/reservations/owner-reservations';
  static String updateReservation(String id) => '/reservations/$id';
  static String cancelReservation(String id) => '/reservations/$id';
  static String resolveReservation(String id) => '/reservations/$id/resolve';

  // Users
  static const String unownedRestaurants = '/users/unowned-restaurants';
}
