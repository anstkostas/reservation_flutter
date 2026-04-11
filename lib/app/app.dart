import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import '../cubits/auth/auth_bloc.dart';
import '../cubits/reservations/customer/customer_reservation_cubit.dart';
import '../cubits/reservations/owner/owner_reservation_cubit.dart';
import '../cubits/restaurants/restaurant_list_cubit.dart';
import 'router.dart';
import 'theme.dart';

final _getIt = GetIt.instance;

/// Root widget — wires BLoC providers, GoRouter, and the responsive theme.
///
/// [AuthBloc] is provided via [BlocProvider.value] because it is a singleton
/// owned by [GetIt]. Using [BlocProvider.value] tells Flutter not to close the
/// bloc when this widget is removed — ownership stays with [GetIt], which keeps
/// the Dio 401 interceptor and the widget tree sharing the exact same instance.
///
/// All other cubits use [BlocProvider] with a factory registration so each
/// [BlocProvider] creates a fresh instance from [GetIt].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _getIt<AuthBloc>()),
        BlocProvider(create: (_) => _getIt<RestaurantListCubit>()),
        BlocProvider(create: (_) => _getIt<CustomerReservationCubit>()),
        BlocProvider(create: (_) => _getIt<OwnerReservationCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Antigravity',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,

        /// INFO: builder is a special hook that wraps the entire navigator — it sits just
        /// above every route but just below MaterialApp itself. The child it
        /// receives is GoRouter's full navigator widget.
        // Responsive theme — reads screen size from MediaQuery and builds a
        // TextTheme with font sizes appropriate for the current layout tier.
        // Widgets consume Theme.of(context) as normal — no LayoutBuilder needed.
        builder: (context, child) {
          final size = MediaQuery.sizeOf(context);
          return Theme(data: AppTheme.themeData(size), child: child!);
        },

        // Required for showDatePicker and showTimePicker to render correctly.
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('el')],
      ),
    );
  }
}
