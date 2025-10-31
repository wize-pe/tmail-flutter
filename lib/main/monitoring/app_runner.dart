import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main/monitoring/sentry_initializer.dart';

/// Runs the app inside a guarded zone with logger + Sentry enabled.
Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
      logError('FlutterError: ${details.exception} | stack: ${details.stack}');
      if (PlatformInfo.isWeb) {
        // Capture Flutter framework errors in Sentry (if available)
        Sentry.captureException(details.exception, stackTrace: details.stack);
      }
    };

    // Initialize Sentry
    await SentryInitializer.init(runTmail);
  }, (error, stack) {
    logError('Uncaught zone error: $error\n$stack');
    if (PlatformInfo.isWeb) {
      // Send unexpected errors to Sentry too
      Sentry.captureException(error, stackTrace: stack);
    }
  });
}
