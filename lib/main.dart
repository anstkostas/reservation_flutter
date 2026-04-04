import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'app/service_locator.dart';
import 'cubits/auth/auth_bloc.dart';

Future<void> main() async {
  // Required before any async work or plugin use.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the bundled .env asset.
  await dotenv.load();

  // Initialise Greek locale data for intl (DateFormat, showDatePicker labels).
  // English is built in — only additional locales need explicit initialisation.
  await initializeDateFormatting('el');

  // Enable verbose state transition logging in debug builds only.
  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }

  // Register all services, repositories, and blocs with GetIt.
  // Must complete before runApp so the widget tree can access dependencies.
  await setupServiceLocator();

  runApp(const App());

  // Dispatch session restore after runApp so AuthBloc is in the widget tree
  // and GoRouter's refreshListenable is already wired before the state changes.
  GetIt.instance<AuthBloc>().add(AuthCheckRequested());
}
