import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_context_data.dart';

/// A helper class to safely report errors to Sentry.
/// Handles different kinds of reports (error, info, warning, breadcrumb, etc.)
class SentryReporter {
  /// Reports an exception with optional context and tags.
  static Future<void> reportError(
    dynamic exception, [
    StackTrace? stackTrace,
    SentryContextData? context,
  ]) async {
    try {
      if (!PlatformInfo.isWeb) {
        return;
      }

      if (BuildUtils.isDebugMode) {
        log(
          '[SentryReporter] Skipped (debug mode): $exception',
          level: Level.warning,
        );
        return;
      }

      await Sentry.configureScope((scope) {
        if (context != null) {
          scope.setTag('feature', context.feature ?? 'unknown');
          scope.setContexts('context', context.toMap());
        }
      });

      await Sentry.captureException(exception, stackTrace: stackTrace);
      logError('[SentryReporter] Reported exception: $exception');
    } catch (err, st) {
      logError('[SentryReporter] Failed to report: $err, $st');
    }
  }
}
