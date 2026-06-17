/// Integration tests for reservation flows (customer role, desktop viewport 1200×800).
/// Type: integration (repository layer mocked via pumpApp harness).
/// Covers: cancel reservation (card → detail sheet → confirm dialog → ActionSuccess snackbar);
///   create reservation (restaurant detail → booking dialog → form submit → sheet closes);
///   update reservation (card → detail sheet → edit mode → save → ActionSuccess snackbar);
///   owner resolve reservation (DataTable action button → completed → ActionSuccess snackbar).
library;

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:antigravity_client/app/router.dart';
import 'package:antigravity_client/constants/reservation_status.dart';
import 'package:antigravity_client/constants/user_role.dart';
import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/screens/owner/owner_dashboard_screen.dart';
import 'package:antigravity_client/widgets/reservations/reservation_card.dart';

import 'helpers/app_harness.dart';
import 'helpers/mock_repositories.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reservation flows', () {
    late MockAuthRepository mockAuth;
    late MockReservationRepository mockReservations;
    late MockRestaurantRepository mockRestaurants;

    final fakeCustomer = UserModel(
      id: 'cust-id',
      firstname: 'Test',
      lastname: 'Customer',
      email: 'cust@test.com',
      role: UserRole.customer,
    );

    final fakeRestaurant = RestaurantModel(
      id: 'rest-id-1',
      name: 'Test Restaurant',
      description: 'A test restaurant',
      address: '1 Test Street',
      phone: '555-0001',
      capacity: 5,
      logoUrl: 'https://example.com/logo.png',
      coverImageUrl: 'https://example.com/cover.png',
    );

    final fakeActiveReservation = ReservationModel(
      id: 'res-id-1',
      scheduledAt: DateTime.now().add(const Duration(days: 2)),
      people: 2,
      status: ReservationStatus.active,
      restaurantId: 'rest-id-1',
      customerId: 'cust-id',
      restaurantName: 'Test Restaurant',
    );

    setUp(() {
      mockAuth = MockAuthRepository();
      mockReservations = MockReservationRepository();
      mockRestaurants = MockRestaurantRepository();
      when(() => mockAuth.getMe()).thenAnswer((_) async => fakeCustomer);
      when(() => mockAuth.logout()).thenAnswer((_) async {});
      // Authenticated customer lands on /restaurants first — stub getAll()
      // so RestaurantListCubit does not fail when initState calls fetchAll().
      when(
        () => mockRestaurants.getAll(),
      ).thenAnswer((_) async => [fakeRestaurant]);
    });

    testWidgets(
      'cancel reservation: tap card → confirm cancel → success snackbar visible',
      (tester) async {
        // Why: verifies the full cancel flow — detail sheet, confirmation dialog,
        // and ActionSuccess → list refresh are all wired together correctly.
        //
        // Set viewport to desktop size: the default test window (~728px) hits the
        // phone layout path (ListView). ReservationCard uses
        // CrossAxisAlignment.stretch in a Row, which fails with unbounded height.
        // Desktop size forces the GridView path where item height is bounded via
        // childAspectRatio — matching how the card is used on macOS in production.
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        when(
          () => mockReservations.getMyReservations(),
        ).thenAnswer((_) async => [fakeActiveReservation]);
        when(() => mockReservations.cancel(any())).thenAnswer((_) async {});

        await pumpApp(
          tester,
          authRepo: mockAuth,
          reservationRepo: mockReservations,
          restaurantRepo: mockRestaurants,
        );

        // Navigate to reservation history and wait for the card to appear.
        appRouter.go('/reservations');
        await pumpUntilFound(tester, find.byType(ReservationCard));

        // Open the detail sheet by tapping the reservation card.
        await tester.tap(find.byType(ReservationCard).first);
        await tester.pumpAndSettle();

        // Tap Cancel in the view mode — reservationDetailCancelButton = "Cancel"
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Confirmation dialog must appear before the action fires.
        expect(find.byType(AlertDialog), findsOneWidget);

        // Confirm the cancel — reservationCancelDialogConfirm = "Cancel reservation"
        await tester.tap(find.text('Cancel reservation'));
        await tester.pumpAndSettle();

        // SnackBar from ReservationHistoryScreen BlocConsumer confirms
        // ActionSuccess was emitted — reservationUpdatedSnackbar = "Reservation updated."
        expect(find.byType(SnackBar), findsOneWidget);
        verify(
          () => mockReservations.cancel(fakeActiveReservation.id),
        ).called(1);
      },
    );

    testWidgets(
      'create reservation: book from restaurant detail → sheet closes on success',
      (tester) async {
        // Why: verifies the create flow — navigation to detail, booking sheet
        // opening, form submit, and ActionSuccess → sheet close are all wired
        // correctly. Repository mock confirms the right args were passed.
        //
        // Viewport matches the cancel test: 1200×800 (desktop — width >= Breakpoints.lg=1024).
        // - shortestSide=800 >= md(768) → not phone → showDialog (not showModalBottomSheet).
        //   showDialog renders the form in a centered Dialog overlay so the
        //   FormBuilderDateTimePicker widgets are fully hit-testable.
        // - Desktop breakpoint avoids tablet-range pumpAndSettle hangs.
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final newReservation = fakeActiveReservation.copyWith(id: 'res-id-2');

        when(
          () => mockRestaurants.getById('rest-id-1'),
        ).thenAnswer((_) async => fakeRestaurant);
        when(
          () => mockReservations.create(
            restaurantId: any(named: 'restaurantId'),
            scheduledAt: any(named: 'scheduledAt'),
            people: any(named: 'people'),
          ),
        ).thenAnswer((_) async => newReservation);
        // Stubbed for the post-create re-fetch that CustomerReservationCubit
        // triggers automatically after ActionSuccess.
        when(
          () => mockReservations.getMyReservations(),
        ).thenAnswer((_) async => [fakeActiveReservation, newReservation]);

        await pumpApp(
          tester,
          authRepo: mockAuth,
          reservationRepo: mockReservations,
          restaurantRepo: mockRestaurants,
        );

        // Navigate directly to restaurant detail.
        appRouter.go('/restaurants/rest-id-1');
        // pumpUntilFound returns as soon as the widget appears — which is
        // mid-navigation-animation (~100ms into a 300ms transition). The button
        // is at an off-screen animated offset at that point.
        // pump(600ms) advances the test clock past the transition (300ms) in a
        // single call: AnimationController clips to complete when elapsed > duration.
        // pumpAndSettle is intentionally avoided — CachedNetworkImage keeps frame
        // callbacks active while the cover image HTTP request is pending, causing
        // pumpAndSettle to time out after 10 minutes.
        await pumpUntilFound(tester, find.text('Book a Table'));
        await tester.pump(const Duration(milliseconds: 600));

        // Open the booking dialog.
        await tester.tap(find.text('Book a Table'));
        await tester.pumpAndSettle();

        // Set form values directly via FormBuilderState — driving the picker
        // dialogs (showDatePicker / showTimePicker) does not reliably propagate
        // the selected value back to the FormBuilderField in the macOS
        // integration test context: tapping 'OK' resolves the Future in a
        // microtask that doesn't always complete before pumpAndSettle returns,
        // leaving the field null and causing saveAndValidate() to short-circuit.
        //
        // 26 hours from now is within the 2-month booking window and past any
        // minimum lead time enforced by the backend (mocked here anyway).
        final scheduledAt = DateTime.now().add(const Duration(hours: 26));
        final formState = tester.state<FormBuilderState>(
          find.byType(FormBuilder),
        );
        formState.fields['date']!.didChange(scheduledAt);
        formState.fields['time']!.didChange(scheduledAt);
        formState.fields['people']!.didChange('2');
        await tester.pump();

        // Submit the form — reservationCreateConfirmButton = "Confirm"
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Sheet closed on ActionSuccess — back on detail screen.
        // "Book a Table" is only present on the detail screen button,
        // making it an unambiguous marker that the sheet has closed.
        // (restaurantDetailMakeReservationTitle and reservationCreateTitle
        // share the same string, so that text is ambiguous.)
        expect(find.text('Book a Table'), findsOneWidget);
        verify(
          () => mockReservations.create(
            restaurantId: 'rest-id-1',
            scheduledAt: any(named: 'scheduledAt'),
            people: any(named: 'people'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'update reservation: edit from detail sheet → success snackbar visible',
      (tester) async {
        // Why: verifies the full update flow — detail sheet edit mode, form
        // save dispatch, and ActionSuccess → sheet close + history screen
        // snackbar are all wired together correctly.
        //
        // Viewport matches the cancel test: 1200×800 (desktop).
        // Edit button only renders when reservation.status == active && !isPast
        // — fakeActiveReservation is 2 days in the future so both conditions hold.
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final updatedReservation = fakeActiveReservation.copyWith(people: 3);

        when(
          () => mockReservations.getMyReservations(),
        ).thenAnswer((_) async => [fakeActiveReservation]);
        when(
          () => mockReservations.update(
            id: any(named: 'id'),
            scheduledAt: any(named: 'scheduledAt'),
            people: any(named: 'people'),
          ),
        ).thenAnswer((_) async => updatedReservation);

        await pumpApp(
          tester,
          authRepo: mockAuth,
          reservationRepo: mockReservations,
          restaurantRepo: mockRestaurants,
        );

        // Navigate to reservation history and wait for the card to appear.
        appRouter.go('/reservations');
        await pumpUntilFound(tester, find.byType(ReservationCard));

        // Open the detail sheet by tapping the reservation card.
        await tester.tap(find.byType(ReservationCard).first);
        await tester.pumpAndSettle();

        // Switch to edit mode.
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        // Set form values directly via FormBuilderState — mirrors create test approach.
        // 26 hours ahead is within the booking window and past any lead time.
        final scheduledAt = DateTime.now().add(const Duration(hours: 26));
        final formState = tester.state<FormBuilderState>(
          find.byType(FormBuilder),
        );
        formState.fields['date']!.didChange(scheduledAt);
        formState.fields['time']!.didChange(scheduledAt);
        formState.fields['people']!.didChange('3');
        await tester.pump();

        // Submit — reservationEditSaveButton = "Save changes".
        await tester.tap(find.text('Save changes'));
        await tester.pumpAndSettle();

        // SnackBar from ReservationHistoryScreen BlocConsumer confirms ActionSuccess.
        expect(find.byType(SnackBar), findsOneWidget);
        verify(
          () => mockReservations.update(
            id: fakeActiveReservation.id,
            scheduledAt: any(named: 'scheduledAt'),
            people: 3,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'owner resolve: mark active reservation as completed → snackbar visible',
      (tester) async {
        // Why: verifies the owner's resolve flow — the DataTable action button
        // dispatches resolve() on OwnerReservationCubit, ActionSuccess triggers
        // the OwnerDashboardScreen BlocConsumer listener which shows the snackbar.
        //
        // Viewport: 1200×800 (desktop) — renders ReservationTable (DataTable).
        // Action buttons only appear when _canUpdate() is true, which requires
        // scheduledAt to be in the past — fixture is 2 hours ago.
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeOwner = UserModel(
          id: 'owner-id',
          firstname: 'Owner',
          lastname: 'User',
          email: 'owner@test.com',
          role: UserRole.owner,
        );

        // Past + active: shows in the Active tab AND enables action buttons.
        final fakeOwnerReservation = ReservationModel(
          id: 'owner-res-id',
          scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
          people: 2,
          status: ReservationStatus.active,
          restaurantId: 'rest-id-1',
          customerId: 'cust-id',
          restaurantName: 'Test Restaurant',
        );

        final resolvedReservation = fakeOwnerReservation.copyWith(
          status: ReservationStatus.completed,
        );

        when(() => mockAuth.getMe()).thenAnswer((_) async => fakeOwner);
        when(
          () => mockReservations.getOwnerReservations(),
        ).thenAnswer((_) async => [fakeOwnerReservation]);
        when(
          () => mockReservations.resolve(
            id: fakeOwnerReservation.id,
            status: ReservationStatus.completed,
          ),
        ).thenAnswer((_) async => resolvedReservation);

        await pumpApp(
          tester,
          authRepo: mockAuth,
          reservationRepo: mockReservations,
          restaurantRepo: mockRestaurants,
        );

        // Owner lands on /owner — wait for screen and then the action buttons.
        await pumpUntilFound(tester, find.byType(OwnerDashboardScreen));
        await pumpUntilFound(tester, find.byIcon(Icons.check_circle_outline));

        // Tap "Mark as completed" icon button.
        await tester.tap(find.byIcon(Icons.check_circle_outline));

        // Wait for OwnerReservationActionSuccess listener to fire the snackbar.
        await pumpUntilFound(tester, find.byType(SnackBar));

        // ownerResolvedSnackbar = "Reservation resolved."
        expect(find.text('Reservation resolved.'), findsOneWidget);
        verify(
          () => mockReservations.resolve(
            id: fakeOwnerReservation.id,
            status: ReservationStatus.completed,
          ),
        ).called(1);
      },
    );
  });
}
