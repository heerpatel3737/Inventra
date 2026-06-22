/// Platform-specific database access.
///
/// - Mobile/desktop: SQLite ([database_helper_io.dart])
/// - Web/Chrome: SharedPreferences ([database_helper_web.dart])
export 'database_helper_io.dart' if (dart.library.html) 'database_helper_web.dart';
