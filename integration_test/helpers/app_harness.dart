import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:antigravity_client/app/app.dart';
import 'package:antigravity_client/cubits/auth/auth_bloc.dart';
import 'package:antigravity_client/cubits/locale/locale_cubit.dart';
import 'package:antigravity_client/cubits/restaurants/restaurant_detail_cubit.dart';
import 'package:antigravity_client/cubits/restaurants/unowned_restaurant_cubit.dart';
import 'package:antigravity_client/repositories/auth_repository.dart';
import 'package:antigravity_client/repositories/reservation_repository.dart';
import 'package:antigravity_client/repositories/restaurant_repository.dart';

import 'mock_repositories.dart';

/// Boots the app for integration tests with mock repositories injected via GetIt.
///
/// Stubs on [authRepo], [reservationRepo], and [restaurantRepo] must be
/// configured by the caller **before** calling this function — the app settles
/// fully (including the initial auth check) inside [pumpAndSettle].
///
/// Resets GetIt on every call so test registrations never bleed across tests.
Future<void> pumpApp(
  WidgetTester tester, {
  required MockAuthRepository authRepo,
  required MockReservationRepository reservationRepo,
  required MockRestaurantRepository restaurantRepo,
}) async {
  await dotenv.load();
  await initializeDateFormatting('el');

  await GetIt.instance.reset();

  GetIt.instance.registerSingleton<AuthRepository>(authRepo);
  GetIt.instance.registerSingleton<ReservationRepository>(reservationRepo);
  GetIt.instance.registerSingleton<RestaurantRepository>(restaurantRepo);

  // AuthBloc singleton — shared between MultiBlocProvider and the Dio 401 interceptor.
  GetIt.instance.registerLazySingleton<AuthBloc>(
    () => AuthBloc(GetIt.instance<AuthRepository>()),
  );

  // Route-scoped cubits — factories so the router gets a fresh instance per
  // navigation, matching the production registration in service_locator.dart.
  GetIt.instance.registerFactory<RestaurantDetailCubit>(
    () => RestaurantDetailCubit(GetIt.instance<RestaurantRepository>()),
  );
  GetIt.instance.registerFactory<UnownedRestaurantCubit>(
    () => UnownedRestaurantCubit(GetIt.instance<RestaurantRepository>()),
  );

  final localeCubit = LocaleCubit();
  await tester.pumpWidget(App(localeCubit: localeCubit));
  await tester.pumpAndSettle();
}
