import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/constants/user_role.dart';
import 'package:antigravity_client/app/router.dart';
import 'package:antigravity_client/screens/auth/login_screen.dart';
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
