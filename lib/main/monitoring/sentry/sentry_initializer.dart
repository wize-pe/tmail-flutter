import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/main_entry.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_config.dart';

class SentryInitializer {
  /// Initialize Sentry
  static Future<void> init(VoidCallback runAppCallback) async {
    final config = await SentryConfig.load();

    await SentryFlutter.init(
      (options) {
        options.dsn = config.dsn;                 // DSN endpoint for the Sentry project
        options.environment = config.environment; // Running environment (production/staging/dev)
        options.release = config.release;         // Current app release version
        options.tracesSampleRate = 1.0;           // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
        options.profilesSampleRate = 1.0;
        options.enableLogs = true;                // Enable logs to be sent to Sentry
        options.debug = BuildUtils.isDebugMode;

        // Assign the callback to process events before sending them to Sentry
        options.beforeSend = _beforeSendHandler;
      },
      appRunner: () async {
        await runTmailPreload(); // Prepare before UI starts
        runApp(
          SentryWidget(
            child: const TMailApp(),
          ),
        );
      },
    );
  }

  /// Handler executed before sending an event to Sentry
  static Future<SentryEvent?> _beforeSendHandler(SentryEvent event, Hint? hint,) async {
    // Ignore AssertionError events
    if (event.throwable is AssertionError) {
      return null;
    }
    return event;
  }
}