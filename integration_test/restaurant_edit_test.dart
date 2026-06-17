/// Integration tests for restaurant edit flows (owner role, desktop viewport 1200×800).
/// Type: integration (repository layer mocked via pumpApp harness).
/// Covers: load → pre-filled form visible;
///   submit valid update → success snackbar shown + screen popped;
///   submit that triggers backend error → ErrorDisplay shown.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:antigravity_client/app/router.dart';
import 'package:antigravity_client/constants/user_role.dart';
import 'package:antigravity_client/models/models.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:antigravity_client/widgets/error_display.dart';

import 'helpers/app_harness.dart';
import 'helpers/mock_repositories.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant edit flows', () {
    setUpAll(() {
      // Required by mocktail — any() on a non-primitive type needs a fallback instance.
      registerFallbackValue(const UpdateRestaurantRequest());
    });

    late MockAuthRepository mockAuth;
    late MockReservationRepository mockReservations;
    late MockRestaurantRepository mockRestaurants;

    final fakeOwner = UserModel(
      id: 'owner-id',
      firstname: 'Owner',
      lastname: 'User',
      email: 'owner@test.com',
      role: UserRole.owner,
    );

    final fakeRestaurantPrivate = RestaurantPrivateModel(
      id: 'rest-id-1',
      name: 'Test Restaurant',
      description: const RestaurantDescription(
        en: 'A test restaurant',
        el: null,
      ),
      address: '123 Test St',
      phone: '+1234567890',
      capacity: 10,
      logoUrl: 'https://example.com/logo.png',
      coverImageUrl: 'https://example.com/cover.png',
    );

    setUp(() {
      mockAuth = MockAuthRepository();
      mockReservations = MockReservationRepository();
      mockRestaurants = MockRestaurantRepository();
      when(() => mockAuth.getMe()).thenAnswer((_) async => fakeOwner);
      when(() => mockAuth.logout()).thenAnswer((_) async {});
      // Owner dashboard fires getOwnerReservations() on mount — stub to avoid unhandled call.
      when(
        () => mockReservations.getOwnerReservations(),
      ).thenAnswer((_) async => []);
      // Stubbed in case any route in the owner flow triggers a restaurant list fetch.
      when(() => mockRestaurants.getAll()).thenAnswer((_) async => []);
    });

    testWidgets('load: navigating to /owner/restaurant shows pre-filled form', (
      tester,
    ) async {
      // Why: verifies the fetch-on-mount path — OwnerRestaurantCubit.fetch()
      // fires in initState, getOwn() is called once, and the form renders with
      // the restaurant's current values pre-filled.
      //
      // Desktop viewport (1200×800) — consistent with other integration tests.
      // Router teardown: appRouter is a global singleton — reset to /loading so
      // pumpApp in the next test redirects cleanly from /loading → /owner,
      // rather than finding itself already at /owner/restaurant.
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() => appRouter.go('/loading'));

      when(
        () => mockRestaurants.getOwn(),
      ).thenAnswer((_) async => fakeRestaurantPrivate);

      await pumpApp(
        tester,
        authRepo: mockAuth,
        reservationRepo: mockReservations,
        restaurantRepo: mockRestaurants,
      );

      // push keeps /owner in the stack so Navigator.pop() is always valid.
      appRouter.push('/owner/restaurant');
      // Wait for 'Save changes' — it lives inside the FormBuilder column, so when
      // it's found the FormBuilder State is guaranteed to be mounted.
      await pumpUntilFound(tester, find.text('Save changes'));

      // Form pre-filled — assert the field's bound value via FormBuilderState.
      // (find.text() would also match the field's EditableText, but the bound
      // value is the precise assertion: it checks the form's data, not rendered
      // text, so it can't collide with a label or heading showing the same string.)
      final formState = tester.state<FormBuilderState>(
        find.byType(FormBuilder),
      );
      expect(formState.fields['name']!.value, equals('Test Restaurant'));
      expect(find.text('Save changes'), findsOneWidget);
      verify(() => mockRestaurants.getOwn()).called(1);
    });

    testWidgets('submit valid update: success snackbar shown and screen popped', (
      tester,
    ) async {
      // Why: verifies the full update flow — _submit() dispatches update() on
      // OwnerRestaurantCubit, UpdateSuccess triggers the listenWhen listener which
      // shows a snackbar and pops back to the owner dashboard. All fields are
      // sent on every submit (initialValue populates the form), so the backend's
      // "≥1 field" refine always passes.
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() => appRouter.go('/loading'));

      when(
        () => mockRestaurants.getOwn(),
      ).thenAnswer((_) async => fakeRestaurantPrivate);
      when(
        () => mockRestaurants.updateOwn(any()),
      ).thenAnswer((_) async => fakeRestaurantPrivate);

      await pumpApp(
        tester,
        authRepo: mockAuth,
        reservationRepo: mockReservations,
        restaurantRepo: mockRestaurants,
      );

      appRouter.push('/owner/restaurant');
      await pumpUntilFound(tester, find.text('Save changes'));

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // SnackBar from the BlocConsumer listener — restaurantEditSuccessSnackbar.
      // It survives the listener's Navigator.pop() because ScaffoldMessenger sits
      // above the Navigator (app-level), so the route change doesn't dismiss it.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Restaurant updated.'), findsOneWidget);
      verify(() => mockRestaurants.updateOwn(any())).called(1);
    });

    testWidgets('submit error: backend failure shows ErrorDisplay', (
      tester,
    ) async {
      // Why: verifies the failure path — updateOwn() throws AppException,
      // OwnerRestaurantCubit catches it and emits OwnerRestaurantFailure,
      // buildWhen passes Failure through, and the builder renders ErrorDisplay.
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() => appRouter.go('/loading'));

      when(
        () => mockRestaurants.getOwn(),
      ).thenAnswer((_) async => fakeRestaurantPrivate);
      when(() => mockRestaurants.updateOwn(any())).thenAnswer(
        (_) async => throw const AppException(
          message: 'You do not own any restaurant.',
          statusCode: 403,
          code: 'RESTAURANT_OWNER_ONLY',
        ),
      );

      await pumpApp(
        tester,
        authRepo: mockAuth,
        reservationRepo: mockReservations,
        restaurantRepo: mockRestaurants,
      );

      appRouter.push('/owner/restaurant');
      await pumpUntilFound(tester, find.text('Save changes'));

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDisplay), findsOneWidget);
    });

    testWidgets(
      'invalid form: validation failure short-circuits, update not called',
      (tester) async {
        // Why: verifies _submit()'s saveAndValidate() guard — an invalid field
        // (capacity below min) blocks the submit, so OwnerRestaurantCubit.update()
        // is never dispatched and updateOwn() is never called. The form stays on
        // screen (no pop, no snackbar).
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(() => appRouter.go('/loading'));

        when(
          () => mockRestaurants.getOwn(),
        ).thenAnswer((_) async => fakeRestaurantPrivate);

        await pumpApp(
          tester,
          authRepo: mockAuth,
          reservationRepo: mockReservations,
          restaurantRepo: mockRestaurants,
        );

        appRouter.push('/owner/restaurant');
        await pumpUntilFound(tester, find.text('Save changes'));

        // Capacity is the 6th (index 5) FormBuilderTextField. '0' fails min(1) —
        // a non-empty invalid value, so the validator runs regardless of how
        // form_builder_validators treats empty input.
        await tester.enterText(find.byType(FormBuilderTextField).at(5), '0');
        await tester.tap(find.text('Save changes'));
        await tester.pumpAndSettle();

        verifyNever(() => mockRestaurants.updateOwn(any()));
        // Still on the edit form — no pop, no success snackbar.
        expect(find.text('Save changes'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'fetch failure on mount: shows ErrorDisplay, retry reloads the form',
      (tester) async {
        // Why: verifies the load-failure path — getOwn() throws on mount, fetch()
        // catches it and emits OwnerRestaurantFailure, the builder renders
        // ErrorDisplay with a retry button. Tapping retry re-runs fetch(); with
        // getOwn() now succeeding, the form renders. Covers the fetch() catch
        // branch and the ErrorDisplay onRetry callback.
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(() => appRouter.go('/loading'));

        // First fetch (on mount) fails.
        when(() => mockRestaurants.getOwn()).thenAnswer(
          (_) async => throw const AppException(
            message: 'You do not own any restaurant.',
            statusCode: 403,
            code: 'RESTAURANT_OWNER_ONLY',
          ),
        );

        await pumpApp(
          tester,
          authRepo: mockAuth,
          reservationRepo: mockReservations,
          restaurantRepo: mockRestaurants,
        );

        appRouter.push('/owner/restaurant');
        await pumpUntilFound(tester, find.byType(ErrorDisplay));

        expect(find.byType(ErrorDisplay), findsOneWidget);

        // Retry now succeeds — re-stub before tapping. The latest stub wins;
        // recorded invocation counts accumulate across both stubs.
        when(
          () => mockRestaurants.getOwn(),
        ).thenAnswer((_) async => fakeRestaurantPrivate);

        await tester.tap(find.text('Retry'));
        await pumpUntilFound(tester, find.text('Save changes'));

        expect(find.text('Save changes'), findsOneWidget);
        verify(() => mockRestaurants.getOwn()).called(2);
      },
    );
  });
}
