import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import '../constants/supported_locale.dart';
import '../cubits/auth/auth_bloc.dart';
import '../cubits/locale/locale_cubit.dart';
import '../l10n/app_localizations.dart';
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
  const App({super.key, required this.localeCubit});

  final LocaleCubit localeCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _getIt<AuthBloc>()),
        BlocProvider.value(value: localeCubit),
        BlocProvider(create: (_) => _getIt<RestaurantListCubit>()),
        BlocProvider(create: (_) => _getIt<CustomerReservationCubit>()),
        BlocProvider(create: (_) => _getIt<OwnerReservationCubit>()),
      ],
      // BlocBuilder must sit here — inside MultiBlocProvider's subtree — so its
      // context can reach LocaleCubit. App.build's own context is above the
      // provider, so context.watch<LocaleCubit>() would fail there.
      //
      // When LocaleCubit emits a new Locale (user switches language), BlocBuilder
      // rebuilds MaterialApp.router with the updated locale: value. Without this,
      // MaterialApp would only read the locale once at startup and never update.
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'Antigravity',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            locale: locale,

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

            localizationsDelegates: const [
              // Our generated delegate — teaches Flutter how to load app_en.arb
              // and app_el.arb for the active locale. Without this, any call to
              // AppLocalizations.of(context) in a widget would return null.
              AppLocalizations.delegate,
              // Flutter's own delegates — required for date/time pickers and
              // built-in widget labels (e.g. "OK", "Cancel") to be localised.
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Derived from SupportedLocale enum — add languages there, not here.
            supportedLocales:
                SupportedLocale.values.map((e) => e.locale).toList(),
          );
        },
      ),
    );
  }
}
