import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_manager.dart';

/// Runs the app inside a guarded zone with logger + Sentry enabled.
Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
      logError('FlutterError: ${details.exception} | stack: ${details.stack}');
      if (PlatformInfo.isWeb) {
        // Capture Flutter framework errors in Sentry (if available)
        SentryManager.instance.reportError(details.exception, details.stack);
      }
    };

    // Initialize Sentry
    await SentryManager.instance.initialize(runTmail);
  }, (error, stack) {
    logError('Uncaught zone error: $error\n$stack');
    if (PlatformInfo.isWeb) {
      // Send unexpected errors to Sentry too
      SentryManager.instance.reportError(error, stack);
    }
  });
}
