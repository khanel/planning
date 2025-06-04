import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planning/src/core/auth/platform_oauth_config.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

void main() {
  group('PlatformOAuthConfig - TDD Implementation Tests', () {
    late PlatformOAuthConfig oauthConfig;

    setUp(() {
      oauthConfig = PlatformOAuthConfig();
    });

    group('Android Configuration', () {
      test('should generate correct Android OAuth redirect URI', () async {
        // Arrange
        const packageName = 'com.example.planning';

        // Act
        final result = await oauthConfig.getAndroidRedirectUri(packageName);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (uri) => expect(uri, equals('com.example.planning://oauth/callback')),
        );
      });

      test('should validate Android custom URI scheme configuration', () async {
        // Arrange
        const customScheme = 'com.example.planning';

        // Act
        final result = await oauthConfig.validateAndroidUriScheme(customScheme);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (isValid) => expect(isValid, true),
        );
      });

      test('should fail validation for invalid Android URI scheme', () async {
        // Arrange
        const invalidScheme = 'invalid..scheme';

        // Act
        final result = await oauthConfig.validateAndroidUriScheme(invalidScheme);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<PlatformConfigFailure>()),
          (isValid) => fail('Expected Left but got Right: $isValid'),
        );
      });

      test('should generate Android manifest intent filter configuration', () async {
        // Arrange
        const packageName = 'com.example.planning';

        // Act
        final result = await oauthConfig.generateAndroidManifestConfig(packageName);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (config) {
            expect(config, contains('android.intent.action.VIEW'));
            expect(config, contains('com.example.planning'));
            expect(config, contains('android.intent.category.BROWSABLE'));
          },
        );
      });
    });

    group('iOS Configuration', () {
      test('should generate correct iOS OAuth redirect URI', () async {
        // Arrange
        const bundleId = 'com.example.planning';

        // Act
        final result = await oauthConfig.getIOSRedirectUri(bundleId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (uri) => expect(uri, equals('com.example.planning://oauth/callback')),
        );
      });

      test('should generate reversed client ID for iOS URL scheme', () async {
        // Arrange
        const clientId = '123456789-abcdefgh.apps.googleusercontent.com';

        // Act
        final result = await oauthConfig.generateIOSReversedClientId(clientId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (reversedId) => expect(reversedId, equals('com.googleusercontent.apps.123456789-abcdefgh')),
        );
      });

      test('should validate iOS bundle identifier format', () async {
        // Arrange
        const validBundleId = 'com.example.planning';

        // Act
        final result = await oauthConfig.validateIOSBundleId(validBundleId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (isValid) => expect(isValid, true),
        );
      });

      test('should fail validation for invalid iOS bundle identifier', () async {
        // Arrange
        const invalidBundleId = 'invalid.bundle.id.with.spaces and special chars!';

        // Act
        final result = await oauthConfig.validateIOSBundleId(invalidBundleId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<PlatformConfigFailure>()),
          (isValid) => fail('Expected Left but got Right: $isValid'),
        );
      });

      test('should generate iOS Info.plist URL scheme configuration', () async {
        // Arrange
        const bundleId = 'com.example.planning';
        const clientId = '123456789-abcdefgh.apps.googleusercontent.com';

        // Act
        final result = await oauthConfig.generateIOSInfoPlistConfig(bundleId, clientId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (config) {
            expect(config, contains('CFBundleURLTypes'));
            expect(config, contains('CFBundleURLSchemes'));
            expect(config, contains('com.example.planning'));
            expect(config, contains('GIDClientID'));
          },
        );
      });
    });

    group('Cross-Platform Configuration', () {
      test('should generate platform-appropriate OAuth configuration', () async {
        // Arrange
        const clientId = '123456789-abcdefgh.apps.googleusercontent.com';
        const platformId = 'com.example.planning';

        // Act
        final result = await oauthConfig.generatePlatformConfig(clientId, platformId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (config) {
            expect(config, isA<Map<String, dynamic>>());
            expect(config['clientId'], equals(clientId));
            expect(config['redirectUri'], isA<String>());
          },
        );
      });

      test('should validate OAuth configuration completeness', () async {
        // Arrange
        final config = {
          'clientId': '123456789-abcdefgh.apps.googleusercontent.com',
          'redirectUri': 'com.example.planning://oauth/callback',
          'scopes': ['https://www.googleapis.com/auth/calendar'],
        };

        // Act
        final result = await oauthConfig.validateOAuthConfig(config);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (isValid) => expect(isValid, true),
        );
      });

      test('should fail validation for incomplete OAuth configuration', () async {
        // Arrange
        final incompleteConfig = {
          'clientId': '123456789-abcdefgh.apps.googleusercontent.com',
          // Missing redirectUri and scopes
        };

        // Act
        final result = await oauthConfig.validateOAuthConfig(incompleteConfig);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<PlatformConfigFailure>()),
          (isValid) => fail('Expected Left but got Right: $isValid'),
        );
      });
    });

    group('Production Configuration', () {
      test('should generate production-ready Android configuration', () async {
        // Arrange
        const packageName = 'com.example.planning';
        const clientId = '123456789-abcdefgh.apps.googleusercontent.com';
        const sha1Fingerprint = 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD';

        // Act
        final result = await oauthConfig.generateProductionAndroidConfig(
          packageName, 
          clientId, 
          sha1Fingerprint,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (config) {
            expect(config['packageName'], equals(packageName));
            expect(config['clientId'], equals(clientId));
            expect(config['sha1Fingerprint'], equals(sha1Fingerprint));
            expect(config['verificationRequired'], true);
          },
        );
      });

      test('should generate production-ready iOS configuration with App Check', () async {
        // Arrange
        const bundleId = 'com.example.planning';
        const teamId = 'ABC123XYZ0';
        const clientId = '123456789-abcdefgh.apps.googleusercontent.com';

        // Act
        final result = await oauthConfig.generateProductionIOSConfig(
          bundleId, 
          teamId, 
          clientId,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (config) {
            expect(config['bundleId'], equals(bundleId));
            expect(config['teamId'], equals(teamId));
            expect(config['clientId'], equals(clientId));
            expect(config['appCheckEnabled'], true);
          },
        );
      });

      test('should validate production deployment readiness', () async {
        // Arrange
        final productionConfig = {
          'android': {
            'packageName': 'com.example.planning',
            'sha1Fingerprint': 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD',
            'clientId': '123456789-abcdefgh.apps.googleusercontent.com',
          },
          'ios': {
            'bundleId': 'com.example.planning',
            'teamId': 'ABC123XYZ0',
            'clientId': '123456789-abcdefgh.apps.googleusercontent.com',
          },
        };

        // Act
        final result = await oauthConfig.validateProductionReadiness(productionConfig);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (isReady) => expect(isReady, true),
        );
      });
    });

    group('Error Handling', () {
      test('should handle invalid client ID format', () async {
        // Arrange
        const invalidClientId = 'invalid-client-id-format';

        // Act
        final result = await oauthConfig.generateIOSReversedClientId(invalidClientId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<PlatformConfigFailure>()),
          (reversedId) => fail('Expected Left but got Right: $reversedId'),
        );
      });

      test('should handle empty package name', () async {
        // Arrange
        const emptyPackageName = '';

        // Act
        final result = await oauthConfig.getAndroidRedirectUri(emptyPackageName);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<PlatformConfigFailure>()),
          (uri) => fail('Expected Left but got Right: $uri'),
        );
      });

      test('should handle null configuration values gracefully', () async {
        // Arrange
        final nullConfig = <String, dynamic>{};

        // Act
        final result = await oauthConfig.validateOAuthConfig(nullConfig);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<PlatformConfigFailure>()),
          (isValid) => fail('Expected Left but got Right: $isValid'),
        );
      });
    });
  });
}
