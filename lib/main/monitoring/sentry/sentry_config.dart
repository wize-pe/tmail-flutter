import 'package:core/utils/platform_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

/// Holds configuration values for initializing Sentry.
class SentryConfig {
  final String dsn;
  final String environment;
  final String release;

  SentryConfig({
    required this.dsn,
    required this.environment,
    required this.release,
  });

  /// Load configuration based on platform:
  /// - Web: from an env file.
  static Future<SentryConfig> load() async {
    if (PlatformInfo.isWeb) {
      await AppUtils.loadSentryConfigFileToEnv();

      final sentryDSN = dotenv.get('SENTRY_DSN', fallback: '');
      final sentryEnvironment = dotenv.get('SENTRY_ENVIRONMENT', fallback: 'dev');
      final sentryRelease = dotenv.get('SENTRY_RELEASE', fallback: '0.1.0');

      return SentryConfig(
        dsn: sentryDSN,
        environment: sentryEnvironment,
        release: sentryRelease,
      );
    }

    throw Exception('Platform is not supported');
  }
}
