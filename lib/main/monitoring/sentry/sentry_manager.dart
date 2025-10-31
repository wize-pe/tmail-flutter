import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_context_data.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_initializer.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_reporter.dart';

/// Facade for managing Sentry integration globally.
class SentryManager {
  SentryManager._();

  static final SentryManager instance = SentryManager._();

  /// Initializes Sentry SDK via SentryInitializer.
  Future<void> initialize(Future<void> Function() appRunner) async {
    try {
      if (!PlatformInfo.isWeb) {
        await appRunner();
        return;
      }

      await SentryInitializer.init(appRunner);
    } catch(_) {
      await appRunner();
    }
  }

  /// Sets the current user context once after login.
  Future<void> setUser({
    required String email,
    String? id,
    String? name,
  }) async {
    try {
      if (!PlatformInfo.isWeb) {
        return;
      }

      await Sentry.configureScope((scope) {
        scope.setUser(SentryUser(id: id, email: email, username: name));
      });
      log('[SentryManager] User set: $email');
    } catch (_) {}
  }

  /// Clears user context on logout.
  Future<void> clearUser() async {
    try {
      if (!PlatformInfo.isWeb) {
        return;
      }

      await Sentry.configureScope((scope) {
        scope.setUser(null);
      });
      log('[SentryManager] Cleared user context');
    } catch (_) {}
  }

  /// Forwards to SentryReporter to capture an exception.
  Future<void> reportError(
    dynamic exception, [
    StackTrace? stackTrace,
    SentryContextData? context,
  ]) =>
      SentryReporter.reportError(exception, stackTrace, context);
}
