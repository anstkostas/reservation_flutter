/// Unit tests for RestaurantListCubit.
/// Type: unit (repository mocked with mocktail).
/// Covers: fetchAll success (threads the fetched restaurants into Loaded);
///   fetchAll failure carrying message and code; fetchAll failure with null code;
///   isClosed-guard: pre-Loaded (closed before the fetch result arrives → only Loading).
/// Not yet covered: catch-block isClosed guard (on AppException catch — closing the cubit
///   between throw and catch is not realistically testable with blocTest).
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:antigravity_client/cubits/restaurants/restaurant_list_cubit.dart';
import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/repositories/restaurant_repository.dart';

class MockRestaurantRepository extends Mock implements RestaurantRepository {}

void main() {
  late MockRestaurantRepository repo;

  setUp(() => repo = MockRestaurantRepository());

  group('fetchAll', () {
    blocTest<RestaurantListCubit, RestaurantListState>(
      'emits [Loading, Loaded] threading the fetched restaurants when the fetch succeeds',
      setUp: () => when(
        () => repo.getAll(),
      ).thenAnswer((_) async => [_buildRestaurant()]),
      build: () => RestaurantListCubit(repo),
      act: (cubit) => cubit.fetchAll(),
      expect: () => [
        const RestaurantListLoading(),
        RestaurantListLoaded([_buildRestaurant()]),
      ],
      verify: (_) => verify(() => repo.getAll()).called(1),
    );

    blocTest<RestaurantListCubit, RestaurantListState>(
      'emits [Loading, Failure] carrying message and code when the fetch throws',
      setUp: () => when(() => repo.getAll()).thenThrow(
        const AppException(
          message: 'Server error',
          statusCode: 500,
          code: 'INTERNAL',
        ),
      ),
      build: () => RestaurantListCubit(repo),
      act: (cubit) => cubit.fetchAll(),
      expect: () => const [
        RestaurantListLoading(),
        RestaurantListFailure('Server error', code: 'INTERNAL'),
      ],
    );
  });

  group('failure with null code', () {
    blocTest<RestaurantListCubit, RestaurantListState>(
      'fetchAll: emits [Loading, Failure] carrying null code when AppException omits code',
      setUp: () => when(() => repo.getAll()).thenThrow(
        const AppException(message: 'Service unavailable', statusCode: 503),
      ),
      build: () => RestaurantListCubit(repo),
      act: (cubit) => cubit.fetchAll(),
      expect: () => const [
        RestaurantListLoading(),
        RestaurantListFailure('Service unavailable'),
      ],
    );
  });

  group('isClosed-guard', () {
    late Completer<List<RestaurantModel>> fetchCompleter;

    blocTest<RestaurantListCubit, RestaurantListState>(
      'fetchAll: emits only [Loading] when closed before the fetch result arrives',
      setUp: () {
        fetchCompleter = Completer();
        when(() => repo.getAll()).thenAnswer((_) => fetchCompleter.future);
      },
      build: () => RestaurantListCubit(repo),
      act: (cubit) async {
        unawaited(cubit.fetchAll());
        await cubit.close();
        fetchCompleter.complete([_buildRestaurant()]);
      },
      expect: () => const [RestaurantListLoading()],
    );
  });
}

/// Builds a minimal restaurant fixture for the success path.
RestaurantModel _buildRestaurant() => const RestaurantModel(
  id: 'rest1',
  name: 'Test Bistro',
  description: 'A cozy spot.',
  address: '1 Test Lane',
  phone: '555-0001',
  capacity: 20,
  logoUrl: 'https://example.com/logo.png',
  coverImageUrl: 'https://example.com/cover.png',
);
