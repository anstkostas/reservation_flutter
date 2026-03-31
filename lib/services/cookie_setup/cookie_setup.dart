// Selects the correct cookie setup implementation at compile time.
// On web: cookie_setup_web.dart (no-op — browser handles Set-Cookie natively).
// On all other platforms: cookie_setup_mobile.dart (PersistCookieJar).
export 'cookie_setup_mobile.dart'
    if (dart.library.html) 'cookie_setup_web.dart';
