/// Unit tests for CustomerReservationCubit.
/// Type: unit (repository mocked with mocktail).
/// Covers: fetchMine success (Loading → Loaded) + failure (Loading → Failure);
///   create success (dual-emit Loading → ActionSuccess → Loaded) + failure (re-fetch skipped);
///   update success (dual-emit Loading → ActionSuccess → Loaded) + failure (re-fetch skipped);
///   cancel success (dual-emit Loading → ActionSuccess → Loaded) + failure (re-fetch skipped);
///   failure states thread message and code;
///   isClosed-guard: fetchMine pre-Loaded, create pre-ActionSuccess, create pre-Loaded;
///   failure with null code (fetchMine + create).
/// Not yet covered: catch-block isClosed guard (all methods — closing cubit between throw
///   and catch is not realistically testable with blocTest); ActionSuccess guard for update
///   and cancel (structurally identical to create — representative coverage applied).
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:antigravity_client/constants/reservation_status.dart';
import 'package:antigravity_client/cubits/reservations/customer/customer_reservation_cubit.dart';
import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/repositories/reservation_repository.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late MockReservationRepository repo;

  setUp(() => repo = MockReservationRepository());

  group('fetchMine', () {
    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'emits [Loading, Loaded] when the fetch succeeds',
      setUp: () => when(
        () => repo.getMyReservations(),
      ).thenAnswer((_) async => const <ReservationModel>[]),
      build: () => CustomerReservationCubit(repo),
      act: (cubit) => cubit.fetchMine(),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationLoaded([]),
      ],
      verify: (_) => verify(() => repo.getMyReservations()).called(1),
    );

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'emits [Loading, Failure] carrying message and code when the fetch throws',
      setUp: () => when(() => repo.getMyReservations()).thenThrow(
        const AppException(
          message: 'Server error',
          statusCode: 500,
          code: 'INTERNAL',
        ),
      ),
      build: () => CustomerReservationCubit(repo),
      act: (cubit) => cubit.fetchMine(),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationFailure('Server error', code: 'INTERNAL'),
      ],
    );
  });

  group('create', () {
    final scheduledAt = DateTime(2026, 8, 15, 19, 30);

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'emits [Loading, ActionSuccess, Loaded] when create succeeds',
      setUp: () {
        when(
          () => repo.create(
            restaurantId: 'rest1',
            scheduledAt: scheduledAt,
            people: 2,
          ),
        ).thenAnswer((_) async => _buildReservation());
        when(
          () => repo.getMyReservations(),
        ).thenAnswer((_) async => const <ReservationModel>[]);
      },
      build: () => CustomerReservationCubit(repo),
      act: (cubit) => cubit.create(
        restaurantId: 'rest1',
        scheduledAt: scheduledAt,
        people: 2,
      ),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationActionSuccess(),
        CustomerReservationLoaded([]),
      ],
      verify: (_) {
        verify(
          () => repo.create(
            restaurantId: 'rest1',
            scheduledAt: scheduledAt,
            people: 2,
          ),
        ).called(1);
        verify(() => repo.getMyReservations()).called(1);
      },
    );

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'emits [Loading, Failure] and skips the re-fetch when create throws',
      setUp: () => when(
        () => repo.create(
          restaurantId: 'rest1',
          scheduledAt: scheduledAt,
          people: 2,
        ),
      ).thenThrow(
        const AppException(
          message: 'Conflict',
          statusCode: 409,
          code: 'CONFLICT',
        ),
      ),
      build: () => CustomerReservationCubit(repo),
      act: (cubit) => cubit.create(
        restaurantId: 'rest1',
        scheduledAt: scheduledAt,
        people: 2,
      ),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationFailure('Conflict', code: 'CONFLICT'),
      ],
      verify: (_) => verifyNever(() => repo.getMyReservations()),
    );
  });

  group('update', () {
    final scheduledAt = DateTime(2026, 8, 20, 20);

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'emits [Loading, ActionSuccess, Loaded] when update succeeds',
      setUp: () {
        when(
          () => repo.update(id: 'r1', scheduledAt: scheduledAt, people: 3),
        ).thenAnswer((_) async => _buildReservation());
        when(
          () => repo.getMyReservations(),
        ).thenAnswer((_) async => const <ReservationModel>[]);
      },
      build: () => CustomerReservationCubit(repo),
      act: (cubit) =>
          cubit.update(id: 'r1', scheduledAt: scheduledAt, people: 3),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationActionSuccess(),
        CustomerReservationLoaded([]),
      ],
      verify: (_) {
        verify(
          () => repo.update(id: 'r1', scheduledAt: scheduledAt, people: 3),
        ).called(1);
        verify(() => repo.getMyReservations()).called(1);
      },
    );

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'emits [Loading, Failure] and skips the re-fetch when update throws',
      setUp: () => when(
        () => repo.update(id: 'r1', scheduledAt: scheduledAt, people: 3),
      ).thenThrow(
        const AppException(
          message: 'Not found',
          statusCode: 404,
          code: 'NOT_FOUND',
        ),
      ),
      build: () => CustomerReservationCubit(repo),
      act: (cubit) =>
          cubit.update(id: 'r1', scheduledAt: scheduledAt, people: 3),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationFailure('Not found', code: 'NOT_FOUND'),
      ],
      verify: (_) => verifyNever(() => repo.getMyReservations()),
    );
  });

  group('cancel', () {
    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'emits [Loading, ActionSuccess, Loaded] when cancel succeeds',
      setUp: () {
        when(() => repo.cancel('r1')).thenAnswer((_) async {});
        when(
          () => repo.getMyReservations(),
        ).thenAnswer((_) async => const <ReservationModel>[]);
      },
      build: () => CustomerReservationCubit(repo),
      act: (cubit) => cubit.cancel('r1'),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationActionSuccess(),
        CustomerReservationLoaded([]),
      ],
      verify: (_) {
        verify(() => repo.cancel('r1')).called(1);
        verify(() => repo.getMyReservations()).called(1);
      },
    );

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'emits [Loading, Failure] and skips the re-fetch when cancel throws',
      setUp: () => when(() => repo.cancel('r1')).thenThrow(
        const AppException(
          message: 'Not found',
          statusCode: 404,
          code: 'NOT_FOUND',
        ),
      ),
      build: () => CustomerReservationCubit(repo),
      act: (cubit) => cubit.cancel('r1'),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationFailure('Not found', code: 'NOT_FOUND'),
      ],
      verify: (_) => verifyNever(() => repo.getMyReservations()),
    );
  });

  group('isClosed-guard', () {
    late Completer<ReservationModel> createCompleter;
    late Completer<List<ReservationModel>> fetchCompleter;

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'fetchMine: emits only [Loading] when closed before the fetch result arrives',
      setUp: () {
        fetchCompleter = Completer();
        when(
          () => repo.getMyReservations(),
        ).thenAnswer((_) => fetchCompleter.future);
      },
      build: () => CustomerReservationCubit(repo),
      act: (cubit) async {
        unawaited(cubit.fetchMine());
        await cubit.close();
        fetchCompleter.complete([]);
      },
      expect: () => const [CustomerReservationLoading()],
    );

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'create: emits only [Loading] when closed while the mutation is in flight',
      setUp: () {
        createCompleter = Completer();
        when(
          () => repo.create(
            restaurantId: 'rest1',
            scheduledAt: DateTime(2026, 8, 15, 19, 30),
            people: 2,
          ),
        ).thenAnswer((_) => createCompleter.future);
      },
      build: () => CustomerReservationCubit(repo),
      act: (cubit) async {
        unawaited(
          cubit.create(
            restaurantId: 'rest1',
            scheduledAt: DateTime(2026, 8, 15, 19, 30),
            people: 2,
          ),
        );
        await cubit.close();
        createCompleter.complete(_buildReservation());
      },
      expect: () => const [CustomerReservationLoading()],
    );

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'create: emits [Loading, ActionSuccess] when closed after create succeeds '
      'but before re-fetch result arrives',
      setUp: () {
        fetchCompleter = Completer();
        when(
          () => repo.create(
            restaurantId: 'rest1',
            scheduledAt: DateTime(2026, 8, 15, 19, 30),
            people: 2,
          ),
        ).thenAnswer((_) async => _buildReservation());
        when(
          () => repo.getMyReservations(),
        ).thenAnswer((_) => fetchCompleter.future);
      },
      build: () => CustomerReservationCubit(repo),
      act: (cubit) async {
        unawaited(
          cubit.create(
            restaurantId: 'rest1',
            scheduledAt: DateTime(2026, 8, 15, 19, 30),
            people: 2,
          ),
        );
        // yield to the event loop so create() completes and ActionSuccess is emitted
        // before getMyReservations() suspends on fetchCompleter
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
        fetchCompleter.complete([]);
      },
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationActionSuccess(),
      ],
    );
  });

  group('failure with null code', () {
    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'fetchMine: emits [Loading, Failure] carrying null code when AppException omits code',
      setUp: () => when(() => repo.getMyReservations()).thenThrow(
        const AppException(message: 'Service unavailable', statusCode: 503),
      ),
      build: () => CustomerReservationCubit(repo),
      act: (cubit) => cubit.fetchMine(),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationFailure('Service unavailable'),
      ],
    );

    blocTest<CustomerReservationCubit, CustomerReservationState>(
      'create: emits [Loading, Failure] carrying null code when AppException omits code',
      setUp: () => when(
        () => repo.create(
          restaurantId: 'rest1',
          scheduledAt: DateTime(2026, 8, 15, 19, 30),
          people: 2,
        ),
      ).thenThrow(
        const AppException(message: 'Service unavailable', statusCode: 503),
      ),
      build: () => CustomerReservationCubit(repo),
      act: (cubit) => cubit.create(
        restaurantId: 'rest1',
        scheduledAt: DateTime(2026, 8, 15, 19, 30),
        people: 2,
      ),
      expect: () => const [
        CustomerReservationLoading(),
        CustomerReservationFailure('Service unavailable'),
      ],
    );
  });
}

/// Builds a minimal [ReservationModel] for mutation stub return values.
/// The cubit discards mutation return values — field accuracy is not asserted.
ReservationModel _buildReservation() => ReservationModel(
  id: 'r1',
  restaurantId: 'rest1',
  customerId: 'c1',
  scheduledAt: DateTime(2026, 8, 15, 19, 30),
  people: 2,
  status: ReservationStatus.active,
);
