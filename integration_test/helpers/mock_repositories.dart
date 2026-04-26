import 'package:mocktail/mocktail.dart';
import 'package:antigravity_client/repositories/auth_repository.dart';
import 'package:antigravity_client/repositories/reservation_repository.dart';
import 'package:antigravity_client/repositories/restaurant_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockRestaurantRepository extends Mock implements RestaurantRepository {}
