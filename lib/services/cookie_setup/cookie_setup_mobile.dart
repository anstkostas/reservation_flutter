import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Creates a [CookieManager] interceptor backed by a [PersistCookieJar].
///
/// Cookies are persisted to the app's documents directory so they survive
/// app restarts. The server's httpOnly auth cookie is stored and sent
/// automatically on every subsequent request.
///
/// Returns an [Interceptor] that must be added to the Dio instance.
Future<Interceptor?> buildCookieInterceptor() async {
  final dir = await getApplicationDocumentsDirectory();
  final jar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
  return CookieManager(jar);
}
