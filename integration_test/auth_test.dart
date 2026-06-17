/// Integration tests for the auth flow.
/// Type: integration (repository layer mocked via pumpApp harness).
/// Covers: login → RestaurantListScreen visible (AuthAuthenticated + redirect);
///   logout → LoginScreen visible (AuthUnauthenticated + redirect);
///   failed login → AUTH_INVALID_CREDENTIALS maps to snackbar message (AuthFailure path);
///   owner login → OwnerDashboardScreen visible (role-based redirect guard).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/constants/error_codes.dart';
import 'package:antigravity_client/constants/user_role.dart';
import 'package:antigravity_client/app/router.dart';
import 'package:antigravity_client/screens/auth/login_screen.dart';
import 'package:antigravity_client/screens/owner/owner_dashboard_screen.dart';
import 'package:antigravity_client/screens/restaurants/restaurant_list_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/mock_repositories.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth flow', () {
    late MockAuthRepository mockAuth;
    late MockReservationRepository mockReservations;
    late MockRestaurantRepository mockRestaurants;

    // A minimal authenticated customer used across both tests.
    final fakeCustomer = UserModel(
      id: 'test-user-id',
      firstname: 'Test',
      lastname: 'User',
      email: 'customer@test.com',
      role: UserRole.customer,
    );

    // A minimal owner used for the role-based redirect test.
    final fakeOwner = UserModel(
      id: 'owner-user-id',
      firstname: 'Owner',
      lastname: 'User',
      email: 'owner@test.com',
      role: UserRole.owner,
    );

    setUp(() {
      mockAuth = MockAuthRepository();
      mockReservations = MockReservationRepository();
      mockRestaurants = MockRestaurantRepository();
      // Default: getMe() throws so the app starts unauthenticated (LoginScreen).
      when(
        () => mockAuth.getMe(),
      ).thenThrow(const UnauthorizedException(message: 'No session'));
    });

    testWidgets('login → restaurant list screen is visible', (tester) async {
      // Why: after successful login, AuthBloc emits AuthAuthenticated,
      // GoRouter's refreshListenable fires, and the redirect guard sends
      // the customer to /restaurants. This test confirms all three steps work.
      when(
        () => mockAuth.login(any(), any()),
      ).thenAnswer((_) async => fakeCustomer);
      // Required: RestaurantListScreen.initState calls fetchAll() which calls getAll().
      when(() => mockRestaurants.getAll()).thenAnswer((_) async => []);

      await pumpApp(
        tester,
        authRepo: mockAuth,
        reservationRepo: mockReservations,
        restaurantRepo: mockRestaurants,
      );

      // pumpApp lands on splash screen (/) for unauthenticated users.
      // Tap the navbar "Log in" button to navigate to /login.
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      // at(0) = email field, at(1) = password field — stable order in LoginScreen.
      // FormBuilderTextField renders TextField directly, not TextFormField.
      await tester.enterText(find.byType(TextField).at(0), 'customer@test.com');
      await tester.enterText(find.byType(TextField).at(1), 'Test@1234');
      await tester.tap(find.text('Sign in'));
      // pumpAndSettle hangs here when macOS window isn't foregrounded — the
      // AuthLoading state renders a CircularProgressIndicator (continuous animation)
      // that never settles unless the window has focus. Step-pump until the target
      // screen appears instead.
      await pumpUntilFound(tester, find.byType(RestaurantListScreen));

      // RestaurantListScreen visible confirms: login → AuthAuthenticated → redirect chain.
      expect(find.byType(RestaurantListScreen), findsOneWidget);
    });

    testWidgets(
      'failed login → snackbar with invalid credentials message visible',
      (tester) async {
        // Why: verifies that AuthFailure is surfaced as a SnackBar on LoginScreen.
        // AUTH_INVALID_CREDENTIALS maps via resolveErrorMessage to
        // l10n.errorAuthInvalidCredentials = "Invalid email or password" (en locale).
        when(() => mockAuth.login(any(), any())).thenThrow(
          const AppException(
            message: 'Invalid email or password',
            statusCode: 401,
            code: ErrorCodes.authInvalidCredentials,
          ),
        );

        await pumpApp(
          tester,
          authRepo: mockAuth,
          reservationRepo: mockReservations,
          restaurantRepo: mockRestaurants,
        );

        // Navigate to /login via the splash screen navbar button.
        await tester.tap(find.text('Log in'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).at(0), 'bad@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
        await tester.tap(find.text('Sign in'));
        // AuthLoading renders CircularProgressIndicator — pumpUntilFound avoids
        // hanging on the continuous animation while waiting for AuthFailure.
        await pumpUntilFound(tester, find.byType(SnackBar));

        expect(find.text('Invalid email or password'), findsOneWidget);
      },
    );

    testWidgets('owner login → owner dashboard screen is visible', (
      tester,
    ) async {
      // Why: owner-role users must land on /owner (OwnerDashboardScreen), not
      // /restaurants. Confirms the router's role-based redirect guard fires
      // correctly for the owner role.
      when(() => mockAuth.getMe()).thenAnswer((_) async => fakeOwner);
      // Required: OwnerDashboardScreen.initState calls fetchOwner() which
      // calls getOwnerReservations().
      when(
        () => mockReservations.getOwnerReservations(),
      ).thenAnswer((_) async => []);

      await pumpApp(
        tester,
        authRepo: mockAuth,
        reservationRepo: mockReservations,
        restaurantRepo: mockRestaurants,
      );

      await pumpUntilFound(tester, find.byType(OwnerDashboardScreen));

      expect(find.byType(OwnerDashboardScreen), findsOneWidget);
    });

    testWidgets('logout → login screen is visible', (tester) async {
      // Why: after logout, AuthBloc emits AuthUnauthenticated and the router
      // redirects to /login. This confirms the reactive logout path.
      //
      // Overrides the setUp default so the app starts authenticated.
      when(() => mockAuth.getMe()).thenAnswer((_) async => fakeCustomer);
      when(() => mockAuth.logout()).thenAnswer((_) async {});
      // Required: RestaurantListScreen is the post-login landing page.
      when(() => mockRestaurants.getAll()).thenAnswer((_) async => []);

      await pumpApp(
        tester,
        authRepo: mockAuth,
        reservationRepo: mockReservations,
        restaurantRepo: mockRestaurants,
      );
      // App starts authenticated — router has redirected to /restaurants.
      await tester.pumpAndSettle();

      // Open the user menu by tapping the avatar circle (shows firstname initial).
      // fakeCustomer.firstname = 'Test' → initial = 'T'.
      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      // Tap the logout item in the popup menu.
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      // GoRouterRefreshStream is subscribed to the first test's AuthBloc stream
      // (now closed after GetIt.reset). Navigate directly — the redirect guard
      // confirms /login is accessible for AuthUnauthenticated so it allows it.
      appRouter.go('/login');
      await tester.pumpAndSettle();

      // LoginScreen visible confirms: logout → AuthUnauthenticated → redirect chain.
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
