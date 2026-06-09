/// Unit tests for OwnerReservationCubit.
/// Type: unit (repository mocked with mocktail).
/// Covers: fetchOwner success + failure; resolve success (dual-emit
///   ActionSuccess → Loaded) + failure; failure states thread message and code;
///   isClosed-guard: fetchOwner pre-Loaded, resolve pre-ActionSuccess, resolve pre-Loaded;
///   failure with null code (fetchOwner + resolve).
/// Not yet covered: catch-block isClosed guard (on AppException catch — closing cubit
///   between throw and catch is not realistically testable with blocTest).
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:antigravity_client/constants/reservation_status.dart';
import 'package:antigravity_client/cubits/reservations/owner/owner_reservation_cubit.dart';
import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/repositories/reservation_repository.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late MockReservationRepository repo;

  setUpAll(() => registerFallbackValue(ReservationStatus.completed));

  setUp(() => repo = MockReservationRepository());

  group('fetchOwner', () {
    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'emits [Loading, Loaded] when the fetch succeeds',
      setUp: () => when(
        () => repo.getOwnerReservations(),
      ).thenAnswer((_) async => const <ReservationModel>[]),
      build: () => OwnerReservationCubit(repo),
      act: (cubit) => cubit.fetchOwner(),
      expect: () => const [
        OwnerReservationLoading(),
        OwnerReservationLoaded([]),
      ],
      verify: (_) => verify(() => repo.getOwnerReservations()).called(1),
    );

    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'emits [Loading, Failure] carrying message and code when the fetch throws',
      setUp: () => when(() => repo.getOwnerReservations()).thenThrow(
        const AppException(
          message: 'Server error',
          statusCode: 500,
          code: 'INTERNAL',
        ),
      ),
      build: () => OwnerReservationCubit(repo),
      act: (cubit) => cubit.fetchOwner(),
      expect: () => const [
        OwnerReservationLoading(),
        OwnerReservationFailure('Server error', code: 'INTERNAL'),
      ],
    );
  });

  group('resolve', () {
    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'emits [Loading, ActionSuccess, Loaded] when the resolve succeeds',
      setUp: () {
        when(
          () => repo.resolve(
            id: any(named: 'id'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => _buildReservation());
        when(
          () => repo.getOwnerReservations(),
        ).thenAnswer((_) async => const <ReservationModel>[]);
      },
      build: () => OwnerReservationCubit(repo),
      act: (cubit) =>
          cubit.resolve(id: 'r1', status: ReservationStatus.completed),
      expect: () => const [
        OwnerReservationLoading(),
        OwnerReservationActionSuccess(),
        OwnerReservationLoaded([]),
      ],
      verify: (_) {
        verify(
          () => repo.resolve(id: 'r1', status: ReservationStatus.completed),
        ).called(1);
        verify(() => repo.getOwnerReservations()).called(1);
      },
    );

    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'emits [Loading, Failure] and skips the re-fetch when the resolve throws',
      setUp: () => when(
        () => repo.resolve(id: any(named: 'id'), status: any(named: 'status')),
      ).thenThrow(
        const AppException(
          message: 'Not allowed',
          statusCode: 403,
          code: 'FORBIDDEN',
        ),
      ),
      build: () => OwnerReservationCubit(repo),
      act: (cubit) =>
          cubit.resolve(id: 'r1', status: ReservationStatus.noShow),
      expect: () => const [
        OwnerReservationLoading(),
        OwnerReservationFailure('Not allowed', code: 'FORBIDDEN'),
      ],
      verify: (_) => verifyNever(() => repo.getOwnerReservations()),
    );
  });

  group('isClosed-guard', () {
    late Completer<ReservationModel> resolveCompleter;
    late Completer<List<ReservationModel>> fetchCompleter;

    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'fetchOwner: emits only [Loading] when closed before the fetch result arrives',
      setUp: () {
        fetchCompleter = Completer();
        when(
          () => repo.getOwnerReservations(),
        ).thenAnswer((_) => fetchCompleter.future);
      },
      build: () => OwnerReservationCubit(repo),
      act: (cubit) async {
        unawaited(cubit.fetchOwner());
        await cubit.close();
        fetchCompleter.complete([]);
      },
      expect: () => const [OwnerReservationLoading()],
    );

    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'resolve: emits only [Loading] when closed while the mutation is in flight',
      setUp: () {
        resolveCompleter = Completer();
        when(
          () => repo.resolve(
            id: any(named: 'id'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) => resolveCompleter.future);
      },
      build: () => OwnerReservationCubit(repo),
      act: (cubit) async {
        unawaited(
          cubit.resolve(id: 'r1', status: ReservationStatus.completed),
        );
        await cubit.close();
        resolveCompleter.complete(_buildReservation());
      },
      expect: () => const [OwnerReservationLoading()],
    );

    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'resolve: emits [Loading, ActionSuccess] when closed after resolve succeeds '
      'but before re-fetch result arrives',
      setUp: () {
        fetchCompleter = Completer();
        when(
          () => repo.resolve(
            id: any(named: 'id'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => _buildReservation());
        when(
          () => repo.getOwnerReservations(),
        ).thenAnswer((_) => fetchCompleter.future);
      },
      build: () => OwnerReservationCubit(repo),
      act: (cubit) async {
        unawaited(
          cubit.resolve(id: 'r1', status: ReservationStatus.completed),
        );
        // yield to the event loop so resolve() completes and ActionSuccess is emitted
        // before getOwnerReservations() suspends on fetchCompleter
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
        fetchCompleter.complete([]);
      },
      expect: () => const [
        OwnerReservationLoading(),
        OwnerReservationActionSuccess(),
      ],
    );
  });

  group('failure with null code', () {
    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'fetchOwner: emits [Loading, Failure] carrying null code when AppException omits code',
      setUp: () => when(() => repo.getOwnerReservations()).thenThrow(
        const AppException(message: 'Service unavailable', statusCode: 503),
      ),
      build: () => OwnerReservationCubit(repo),
      act: (cubit) => cubit.fetchOwner(),
      expect: () => const [
        OwnerReservationLoading(),
        OwnerReservationFailure('Service unavailable'),
      ],
    );

    blocTest<OwnerReservationCubit, OwnerReservationState>(
      'resolve: emits [Loading, Failure] carrying null code when AppException omits code',
      setUp: () => when(
        () => repo.resolve(
          id: any(named: 'id'),
          status: any(named: 'status'),
        ),
      ).thenThrow(
        const AppException(message: 'Service unavailable', statusCode: 503),
      ),
      build: () => OwnerReservationCubit(repo),
      act: (cubit) =>
          cubit.resolve(id: 'r1', status: ReservationStatus.noShow),
      expect: () => const [
        OwnerReservationLoading(),
        OwnerReservationFailure('Service unavailable'),
      ],
    );
  });
}

/// Builds a minimal reservation for resolve() stubs.
/// The cubit ignores the returned value, so field accuracy is not asserted.
ReservationModel _buildReservation() => ReservationModel(
  id: 'r1',
  restaurantId: 'rest1',
  customerId: 'c1',
  scheduledAt: DateTime(2026, 1, 1, 19),
  people: 2,
  status: ReservationStatus.completed,
);
