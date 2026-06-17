import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:antigravity_client/app/app.dart';
import 'package:antigravity_client/app/router.dart';
import 'package:antigravity_client/cubits/auth/auth_bloc.dart';
import 'package:antigravity_client/cubits/locale/locale_cubit.dart';
import 'package:antigravity_client/cubits/restaurants/owner_restaurant_cubit.dart';
import 'package:antigravity_client/cubits/restaurants/restaurant_detail_cubit.dart';
import 'package:antigravity_client/cubits/restaurants/unowned_restaurant_cubit.dart';
import 'package:antigravity_client/repositories/auth_repository.dart';
import 'package:antigravity_client/repositories/reservation_repository.dart';
import 'package:antigravity_client/repositories/restaurant_repository.dart';

import 'mock_repositories.dart';

/// Pumps [tester] in fixed [step] increments until [finder] matches at least
/// one widget. Throws if the widget is not found within [maxTries] steps.
///
/// Use instead of [pumpAndSettle] whenever a continuous animation
/// (e.g. CircularProgressIndicator) would prevent pumpAndSettle from settling.
///
/// Conversely, [pumpAndSettle] is safe even when a path passes *through* a
/// spinner, as long as the terminal state has no continuous animation and the
/// awaited work resolves immediately — the transient spinner is left before
/// settle. That is why the submit success/error flows can settle directly
/// after tapping, while the initial load (which ends on a spinner until data
/// arrives) must use [pumpUntilFound].
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 100),
  int maxTries = 50,
}) async {
  for (int i = 0; i < maxTries; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw Exception(
    'pumpUntilFound: widget not found after ${maxTries * step.inMilliseconds}ms',
  );
}

/// Boots the app for integration tests with mock
/// repositories injected via GetIt.
/// Stubs on [authRepo], [reservationRepo],
/// and [restaurantRepo] must be
/// configured by the caller **before** calling this function
///  — the app settles fully (including the initial auth check)
/// inside [pumpAndSettle]. Resets GetIt on every call so test
/// registrations never bleed across tests.
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
  GetIt.instance.registerFactory<OwnerRestaurantCubit>(
    () => OwnerRestaurantCubit(GetIt.instance<RestaurantRepository>()),
  );

  final localeCubit = LocaleCubit();
  await tester.pumpWidget(App(localeCubit: localeCubit));
  // Mirror main.dart: dispatch the startup auth check so AuthBloc leaves
  // AuthInitial and the router evaluates its redirect guard.
  GetIt.instance<AuthBloc>().add(const AuthCheckRequested());
  await tester.pumpAndSettle();
  // Force router redirect re-evaluation — needed after GetIt.reset() which
  // invalidates the GoRouterRefreshStream subscription on the old AuthBloc stream.
  appRouter.refresh();
  await tester.pumpAndSettle();
}
