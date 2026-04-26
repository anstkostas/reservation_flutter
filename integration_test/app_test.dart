import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Individual test suites live in auth_test.dart and reservations_test.dart.
  // Run those files directly:
  //   flutter test integration_test/auth_test.dart
  //   flutter test integration_test/reservations_test.dart
}
