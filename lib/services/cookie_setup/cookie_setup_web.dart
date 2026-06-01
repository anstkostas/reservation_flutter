import 'package:dio/dio.dart';

/// Returns null on web — the browser handles Set-Cookie automatically
/// when Dio's BaseOptions has `extra: {'withCredentials': true}`.
///
/// No Dart-side cookie interceptor is needed or safe to use on web
/// (dart:io is unavailable in the browser runtime).
Future<Interceptor?> buildCookieInterceptor() async => null;

/// No-op on web — the browser manages its own cookie store.
Future<void> clearCookies() async {}
