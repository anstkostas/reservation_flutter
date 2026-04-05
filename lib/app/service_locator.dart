import 'package:get_it/get_it.dart';

import '../cubits/auth/auth_bloc.dart';
import '../cubits/reservations/customer/customer_reservation_cubit.dart';
import '../cubits/reservations/owner/owner_reservation_cubit.dart';
import '../cubits/restaurants/restaurant_cubit.dart';
import '../cubits/restaurants/restaurant_detail_cubit.dart';
import '../cubits/restaurants/restaurant_list_cubit.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';

/// Global service locator instance.
///
/// Access registered dependencies anywhere via `getIt<T>()`.
/// All registrations happen in [setupServiceLocator] — call it once in
/// `main()` before `runApp`.
final getIt = GetIt.instance;

/// Registers all app dependencies with [getIt].
///
/// Must be awaited before [runApp] — [DioClient] requires async
/// initialisation because its cookie jar uses `path_provider`.
///
/// ## Registration strategy
///
/// - [DioClient] — registered as a singleton (manually initialised and awaited)
/// - Services and repositories — lazy singletons (one shared instance, created on first use)
/// - [AuthBloc] — lazy singleton so the Dio 401 interceptor and [MultiBlocProvider]
///   share the exact same instance
/// - Cubits — factories so each [BlocProvider] subtree gets a fresh instance
Future<void> setupServiceLocator() async {
  // HTTP — DioClient initialisation is async (cookie jar needs path_provider)
  final dioClient = DioClient();
  await dioClient.initialize();
  getIt.registerSingleton<DioClient>(dioClient);

  // Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<RestaurantService>(
    () => RestaurantService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ReservationService>(
    () => ReservationService(getIt<DioClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthService>()),
  );
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepository(getIt<RestaurantService>()),
  );
  getIt.registerLazySingleton<ReservationRepository>(
    () => ReservationRepository(getIt<ReservationService>()),
  );

  // Auth BLoC — singleton so the Dio interceptor and MultiBlocProvider
  // share the same instance (both call getIt<AuthBloc>() directly)
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>()),
  );

  // Cubits — factories so BlocProvider gets a fresh instance per subtree
  getIt.registerFactory<RestaurantListCubit>(
    () => RestaurantListCubit(getIt<RestaurantRepository>()),
  );
  getIt.registerFactory<RestaurantDetailCubit>(
    () => RestaurantDetailCubit(getIt<RestaurantRepository>()),
  );
  getIt.registerFactory<CustomerReservationCubit>(
    () => CustomerReservationCubit(getIt<ReservationRepository>()),
  );
  getIt.registerFactory<OwnerReservationCubit>(
    () => OwnerReservationCubit(getIt<ReservationRepository>()),
  );
  getIt.registerFactory<UnownedRestaurantCubit>(
    () => UnownedRestaurantCubit(getIt<RestaurantRepository>()),
  );
}
