import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';

/// Platform-specific OAuth configuration for Google Calendar integration
/// 
/// This class handles the configuration of OAuth 2.0 settings for both Android and iOS platforms,
/// including redirect URIs, manifest/plist configurations, and validation.
class PlatformOAuthConfig {
  
  // Android OAuth Configuration Methods
  
  /// Generates the OAuth redirect URI for Android platform
  /// 
  /// Uses the package name as the custom URI scheme following Google's recommendations
  /// Format: packageName://oauth/callback
  Future<Either<PlatformConfigFailure, String>> getAndroidRedirectUri(String packageName) async {
    if (packageName.isEmpty) {
      return const Left(PlatformConfigFailure('Package name cannot be empty'));
    }
    
    return Right('$packageName://oauth/callback');
  }

  /// Validates Android custom URI scheme format
  /// 
  /// Checks if the scheme follows Android URI scheme requirements
  Future<Either<PlatformConfigFailure, bool>> validateAndroidUriScheme(String scheme) async {
    // Check for invalid characters
    if (scheme.contains('..') || scheme.contains(' ') || scheme.isEmpty) {
      return const Left(PlatformConfigFailure('Invalid Android URI scheme format'));
    }
    
    // Basic validation - should be a valid reverse domain notation
    if (!RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$').hasMatch(scheme)) {
      return const Left(PlatformConfigFailure('URI scheme must follow reverse domain notation'));
    }
    
    return const Right(true);
  }

  /// Generates Android manifest intent filter configuration
  /// 
  /// Creates the XML configuration needed for AndroidManifest.xml
  Future<Either<PlatformConfigFailure, String>> generateAndroidManifestConfig(String packageName) async {
    if (packageName.isEmpty) {
      return const Left(PlatformConfigFailure('Package name cannot be empty'));
    }

    final config = '''
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="$packageName" />
</intent-filter>''';

    return Right(config);
  }

  // iOS OAuth Configuration Methods

  /// Generates the OAuth redirect URI for iOS platform
  /// 
  /// Uses the bundle ID as the custom URI scheme
  /// Format: bundleId://oauth/callback
  Future<Either<PlatformConfigFailure, String>> getIOSRedirectUri(String bundleId) async {
    if (bundleId.isEmpty) {
      return const Left(PlatformConfigFailure('Bundle ID cannot be empty'));
    }
    
    return Right('$bundleId://oauth/callback');
  }

  /// Generates reversed client ID for iOS URL scheme
  /// 
  /// Converts Google OAuth client ID to reversed format for iOS
  Future<Either<PlatformConfigFailure, String>> generateIOSReversedClientId(String clientId) async {
    if (clientId.isEmpty || !clientId.contains('.apps.googleusercontent.com')) {
      return const Left(PlatformConfigFailure('Invalid Google OAuth client ID format'));
    }
    
    // Extract the client ID part before .apps.googleusercontent.com
    final parts = clientId.split('.apps.googleusercontent.com');
    if (parts.isEmpty) {
      return const Left(PlatformConfigFailure('Invalid client ID format'));
    }
    
    final clientIdPart = parts[0];
    return Right('com.googleusercontent.apps.$clientIdPart');
  }

  /// Validates iOS bundle identifier format
  /// 
  /// Checks if the bundle ID follows Apple's requirements
  Future<Either<PlatformConfigFailure, bool>> validateIOSBundleId(String bundleId) async {
    if (bundleId.isEmpty) {
      return const Left(PlatformConfigFailure('Bundle ID cannot be empty'));
    }
    
    // Check for invalid characters (spaces, special chars)
    if (bundleId.contains(' ') || bundleId.contains('!') || bundleId.contains('@')) {
      return const Left(PlatformConfigFailure('Bundle ID contains invalid characters'));
    }
    
    // Basic validation - should be reverse domain notation
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)*$').hasMatch(bundleId)) {
      return const Left(PlatformConfigFailure('Bundle ID must follow reverse domain notation'));
    }
    
    return const Right(true);
  }

  /// Generates iOS Info.plist URL scheme configuration
  /// 
  /// Creates the plist configuration for URL schemes
  Future<Either<PlatformConfigFailure, String>> generateIOSInfoPlistConfig(String bundleId, String clientId) async {
    if (bundleId.isEmpty || clientId.isEmpty) {
      return const Left(PlatformConfigFailure('Bundle ID and client ID cannot be empty'));
    }

    final reversedClientIdResult = await generateIOSReversedClientId(clientId);
    return reversedClientIdResult.fold(
      (failure) => Left(failure),
      (reversedClientId) {
        final config = '''
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>$bundleId</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>$bundleId</string>
            <string>$reversedClientId</string>
        </array>
    </dict>
</array>
<key>GIDClientID</key>
<string>$clientId</string>''';
        
        return Right(config);
      },
    );
  }

  // Cross-Platform Configuration Methods

  /// Generates platform-appropriate OAuth configuration
  /// 
  /// Creates a configuration map with platform-specific settings
  Future<Either<PlatformConfigFailure, Map<String, dynamic>>> generatePlatformConfig(
    String clientId, 
    String platformId,
  ) async {
    if (clientId.isEmpty || platformId.isEmpty) {
      return const Left(PlatformConfigFailure('Client ID and platform ID cannot be empty'));
    }

    final redirectUri = '$platformId://oauth/callback';
    
    final config = {
      'clientId': clientId,
      'redirectUri': redirectUri,
      'scopes': ['https://www.googleapis.com/auth/calendar'],
      'platformId': platformId,
    };

    return Right(config);
  }

  /// Validates OAuth configuration completeness
  /// 
  /// Checks if all required OAuth parameters are present and valid
  Future<Either<PlatformConfigFailure, bool>> validateOAuthConfig(Map<String, dynamic> config) async {
    if (config.isEmpty) {
      return const Left(PlatformConfigFailure('Configuration cannot be empty'));
    }

    // Check required fields
    final requiredFields = ['clientId', 'redirectUri'];
    for (final field in requiredFields) {
      if (!config.containsKey(field) || config[field] == null || config[field].toString().isEmpty) {
        return Left(PlatformConfigFailure('Missing required field: $field'));
      }
    }

    return const Right(true);
  }

  // Production Configuration Methods

  /// Generates production-ready Android configuration
  /// 
  /// Creates configuration with security considerations for production
  Future<Either<PlatformConfigFailure, Map<String, dynamic>>> generateProductionAndroidConfig(
    String packageName,
    String clientId,
    String sha1Fingerprint,
  ) async {
    if (packageName.isEmpty || clientId.isEmpty || sha1Fingerprint.isEmpty) {
      return const Left(PlatformConfigFailure('All parameters are required for production config'));
    }

    final config = {
      'packageName': packageName,
      'clientId': clientId,
      'sha1Fingerprint': sha1Fingerprint,
      'verificationRequired': true,
      'debugMode': false,
      'redirectUri': '$packageName://oauth/callback',
    };

    return Right(config);
  }

  /// Generates production-ready iOS configuration with App Check
  /// 
  /// Creates configuration with security features for production
  Future<Either<PlatformConfigFailure, Map<String, dynamic>>> generateProductionIOSConfig(
    String bundleId,
    String teamId,
    String clientId,
  ) async {
    if (bundleId.isEmpty || teamId.isEmpty || clientId.isEmpty) {
      return const Left(PlatformConfigFailure('All parameters are required for production config'));
    }

    final config = {
      'bundleId': bundleId,
      'teamId': teamId,
      'clientId': clientId,
      'appCheckEnabled': true,
      'debugMode': false,
      'redirectUri': '$bundleId://oauth/callback',
    };

    return Right(config);
  }

  /// Validates production deployment readiness
  /// 
  /// Checks if the configuration is ready for production deployment
  Future<Either<PlatformConfigFailure, bool>> validateProductionReadiness(
    Map<String, dynamic> productionConfig,
  ) async {
    if (productionConfig.isEmpty) {
      return const Left(PlatformConfigFailure('Production configuration cannot be empty'));
    }

    // Check for required platform configurations
    if (!productionConfig.containsKey('android') || !productionConfig.containsKey('ios')) {
      return const Left(PlatformConfigFailure('Both Android and iOS configurations are required'));
    }

    final android = productionConfig['android'] as Map<String, dynamic>?;
    final ios = productionConfig['ios'] as Map<String, dynamic>?;

    if (android == null || ios == null) {
      return const Left(PlatformConfigFailure('Invalid platform configuration format'));
    }

    // Validate Android config
    final androidRequiredFields = ['packageName', 'sha1Fingerprint', 'clientId'];
    for (final field in androidRequiredFields) {
      if (!android.containsKey(field) || android[field].toString().isEmpty) {
        return Left(PlatformConfigFailure('Missing Android field: $field'));
      }
    }

    // Validate iOS config
    final iosRequiredFields = ['bundleId', 'teamId', 'clientId'];
    for (final field in iosRequiredFields) {
      if (!ios.containsKey(field) || ios[field].toString().isEmpty) {
        return Left(PlatformConfigFailure('Missing iOS field: $field'));
      }
    }

    return const Right(true);
  }
}
