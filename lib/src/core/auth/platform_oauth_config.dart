import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';

/// Platform-specific OAuth configuration for Google Calendar integration
/// 
/// This class handles the configuration of OAuth 2.0 settings for both Android and iOS platforms,
/// including redirect URIs, manifest/plist configurations, and validation.
/// 
/// Follows Google's OAuth 2.0 best practices for mobile applications with PKCE.
class PlatformOAuthConfig {
  // Constants for validation patterns
  static const String _oauth2CallbackPath = '://oauth/callback';
  static const String _googleClientIdSuffix = '.apps.googleusercontent.com';
  static const String _googleReversedPrefix = 'com.googleusercontent.apps.';
  
  // Validation patterns
  static final RegExp _androidSchemePattern = RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$');
  static final RegExp _iosBundleIdPattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)*$');
  static final RegExp _sha1FingerprintPattern = RegExp(r'^[A-F0-9]{2}(:[A-F0-9]{2}){19}$');
  
  // Required OAuth configuration fields
  static const List<String> _requiredOAuthFields = ['clientId', 'redirectUri'];
  static const List<String> _requiredAndroidProdFields = ['packageName', 'sha1Fingerprint', 'clientId'];
  static const List<String> _requiredIOSProdFields = ['bundleId', 'teamId', 'clientId'];
  
  // Private helper methods for validation and utility functions
  
  /// Validates that a string is not empty or whitespace only
  bool _isValidNonEmptyString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
  
  /// Validates Android package name format
  bool _isValidAndroidPackageName(String packageName) {
    return _androidSchemePattern.hasMatch(packageName);
  }
  
  /// Validates iOS bundle identifier format
  bool _isValidIOSBundleId(String bundleId) {
    return _iosBundleIdPattern.hasMatch(bundleId);
  }
  
  /// Validates Google OAuth client ID format
  bool _isValidGoogleClientId(String clientId) {
    return clientId.contains(_googleClientIdSuffix) && clientId.length > _googleClientIdSuffix.length;
  }
  
  /// Validates SHA1 fingerprint format for Android production
  bool _isValidSHA1Fingerprint(String fingerprint) {
    return _sha1FingerprintPattern.hasMatch(fingerprint.toUpperCase());
  }
  
  /// Generates OAuth redirect URI for a given platform identifier
  String _generateRedirectUri(String platformId) {
    return '$platformId$_oauth2CallbackPath';
  }
  
  /// Validates that all required fields are present in a configuration map
  Either<PlatformConfigFailure, bool> _validateRequiredFields(
    Map<String, dynamic> config, 
    List<String> requiredFields,
    String configType,
  ) {
    for (final field in requiredFields) {
      if (!config.containsKey(field) || 
          config[field] == null || 
          config[field].toString().trim().isEmpty) {
        return Left(PlatformConfigFailure(
          'Missing required $configType field: $field'
        ));
      }
    }
    return const Right(true);
  }

  // Android OAuth Configuration Methods
  
  /// Generates the OAuth redirect URI for Android platform
  /// 
  /// Uses the package name as the custom URI scheme following Google's recommendations
  /// Format: packageName://oauth/callback
  Future<Either<PlatformConfigFailure, String>> getAndroidRedirectUri(String packageName) async {
    if (!_isValidNonEmptyString(packageName)) {
      return const Left(PlatformConfigFailure('Android package name cannot be empty'));
    }
    
    if (!_isValidAndroidPackageName(packageName)) {
      return Left(PlatformConfigFailure(
        'Invalid Android package name format: $packageName. Must follow reverse domain notation.'
      ));
    }
    
    return Right(_generateRedirectUri(packageName));
  }

  /// Validates Android custom URI scheme format
  /// 
  /// Checks if the scheme follows Android URI scheme requirements
  Future<Either<PlatformConfigFailure, bool>> validateAndroidUriScheme(String scheme) async {
    if (!_isValidNonEmptyString(scheme)) {
      return const Left(PlatformConfigFailure('Android URI scheme cannot be empty'));
    }
    
    // Check for invalid characters that would break Android intent handling
    if (scheme.contains('..') || scheme.contains(' ') || scheme.contains('@')) {
      return Left(PlatformConfigFailure(
        'Invalid Android URI scheme: $scheme contains forbidden characters'
      ));
    }
    
    if (!_isValidAndroidPackageName(scheme)) {
      return Left(PlatformConfigFailure(
        'Android URI scheme must follow reverse domain notation: $scheme'
      ));
    }
    
    return const Right(true);
  }

  /// Generates Android manifest intent filter configuration
  /// 
  /// Creates the XML configuration needed for AndroidManifest.xml
  Future<Either<PlatformConfigFailure, String>> generateAndroidManifestConfig(String packageName) async {
    if (!_isValidNonEmptyString(packageName)) {
      return const Left(PlatformConfigFailure('Package name cannot be empty for manifest generation'));
    }

    if (!_isValidAndroidPackageName(packageName)) {
      return Left(PlatformConfigFailure(
        'Invalid package name for manifest: $packageName'
      ));
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
    if (!_isValidNonEmptyString(bundleId)) {
      return const Left(PlatformConfigFailure('iOS bundle ID cannot be empty'));
    }
    
    if (!_isValidIOSBundleId(bundleId)) {
      return Left(PlatformConfigFailure(
        'Invalid iOS bundle ID format: $bundleId. Must follow reverse domain notation.'
      ));
    }
    
    return Right(_generateRedirectUri(bundleId));
  }

  /// Generates reversed client ID for iOS URL scheme
  /// 
  /// Converts Google OAuth client ID to reversed format for iOS
  Future<Either<PlatformConfigFailure, String>> generateIOSReversedClientId(String clientId) async {
    if (!_isValidNonEmptyString(clientId)) {
      return const Left(PlatformConfigFailure('Google OAuth client ID cannot be empty'));
    }
    
    if (!_isValidGoogleClientId(clientId)) {
      return Left(PlatformConfigFailure(
        'Invalid Google OAuth client ID format: $clientId. Must end with $_googleClientIdSuffix'
      ));
    }
    
    // Extract the client ID part before .apps.googleusercontent.com
    final parts = clientId.split(_googleClientIdSuffix);
    if (parts.isEmpty || parts[0].isEmpty) {
      return const Left(PlatformConfigFailure('Unable to extract client ID from Google OAuth client ID'));
    }
    
    final clientIdPart = parts[0];
    return Right('$_googleReversedPrefix$clientIdPart');
  }

  /// Validates iOS bundle identifier format
  /// 
  /// Checks if the bundle ID follows Apple's requirements
  Future<Either<PlatformConfigFailure, bool>> validateIOSBundleId(String bundleId) async {
    if (!_isValidNonEmptyString(bundleId)) {
      return const Left(PlatformConfigFailure('iOS bundle ID cannot be empty'));
    }
    
    // Check for invalid characters (spaces, special chars that break iOS schemes)
    if (bundleId.contains(' ') || bundleId.contains('!') || bundleId.contains('@')) {
      return Left(PlatformConfigFailure(
        'iOS bundle ID contains invalid characters: $bundleId'
      ));
    }
    
    if (!_isValidIOSBundleId(bundleId)) {
      return Left(PlatformConfigFailure(
        'iOS bundle ID must follow reverse domain notation: $bundleId'
      ));
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
    if (!_isValidNonEmptyString(clientId) || !_isValidNonEmptyString(platformId)) {
      return const Left(PlatformConfigFailure(
        'Client ID and platform ID cannot be empty for platform configuration'
      ));
    }

    if (!_isValidGoogleClientId(clientId)) {
      return Left(PlatformConfigFailure(
        'Invalid Google OAuth client ID format: $clientId'
      ));
    }

    final redirectUri = _generateRedirectUri(platformId);
    
    final config = {
      'clientId': clientId,
      'redirectUri': redirectUri,
      'scopes': ['https://www.googleapis.com/auth/calendar'],
      'platformId': platformId,
      'responseType': 'code',
      'codeChallenge': 'required', // PKCE requirement indicator
    };

    return Right(config);
  }

  /// Validates OAuth configuration completeness
  /// 
  /// Checks if all required OAuth parameters are present and valid
  Future<Either<PlatformConfigFailure, bool>> validateOAuthConfig(Map<String, dynamic> config) async {
    if (config.isEmpty) {
      return const Left(PlatformConfigFailure('OAuth configuration cannot be empty'));
    }

    // Validate required fields using helper method
    final validationResult = _validateRequiredFields(config, _requiredOAuthFields, 'OAuth');
    return validationResult.fold(
      (failure) => Left(failure),
      (_) {
        // Additional validation for client ID format if present
        final clientId = config['clientId']?.toString();
        if (clientId != null && !_isValidGoogleClientId(clientId)) {
          return const Left(PlatformConfigFailure(
            'OAuth configuration contains invalid Google client ID format'
          ));
        }
        return const Right(true);
      },
    );
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
    // Validate all required fields using helper method
    final tempConfig = {
      'packageName': packageName,
      'clientId': clientId,
      'sha1Fingerprint': sha1Fingerprint,
    };
    
    final validationResult = _validateRequiredFields(
      tempConfig, 
      _requiredAndroidProdFields, 
      'Android production'
    );
    
    return validationResult.fold(
      (failure) => Left(failure),
      (_) {
        // Additional validation for specific field formats
        if (!_isValidAndroidPackageName(packageName)) {
          return Left(PlatformConfigFailure(
            'Invalid Android package name for production: $packageName'
          ));
        }
        
        if (!_isValidGoogleClientId(clientId)) {
          return Left(PlatformConfigFailure(
            'Invalid Google client ID for production: $clientId'
          ));
        }
        
        if (!_isValidSHA1Fingerprint(sha1Fingerprint)) {
          return Left(PlatformConfigFailure(
            'Invalid SHA1 fingerprint format: $sha1Fingerprint. Expected format: AA:BB:CC:...'
          ));
        }

        final config = {
          'packageName': packageName,
          'clientId': clientId,
          'sha1Fingerprint': sha1Fingerprint.toUpperCase(),
          'verificationRequired': true,
          'debugMode': false,
          'redirectUri': _generateRedirectUri(packageName),
          'securityLevel': 'production',
        };

        return Right(config);
      },
    );
  }

  /// Generates production-ready iOS configuration with App Check
  /// 
  /// Creates configuration with security features for production
  Future<Either<PlatformConfigFailure, Map<String, dynamic>>> generateProductionIOSConfig(
    String bundleId,
    String teamId,
    String clientId,
  ) async {
    // Validate all required fields using helper method
    final tempConfig = {
      'bundleId': bundleId,
      'teamId': teamId,
      'clientId': clientId,
    };
    
    final validationResult = _validateRequiredFields(
      tempConfig, 
      _requiredIOSProdFields, 
      'iOS production'
    );
    
    return validationResult.fold(
      (failure) => Left(failure),
      (_) {
        // Additional validation for specific field formats
        if (!_isValidIOSBundleId(bundleId)) {
          return Left(PlatformConfigFailure(
            'Invalid iOS bundle ID for production: $bundleId'
          ));
        }
        
        if (!_isValidGoogleClientId(clientId)) {
          return Left(PlatformConfigFailure(
            'Invalid Google client ID for production: $clientId'
          ));
        }
        
        // Basic team ID validation (10-character alphanumeric)
        if (teamId.length != 10 || !RegExp(r'^[A-Z0-9]{10}$').hasMatch(teamId)) {
          return Left(PlatformConfigFailure(
            'Invalid iOS team ID format: $teamId. Expected 10-character alphanumeric string.'
          ));
        }

        final config = {
          'bundleId': bundleId,
          'teamId': teamId,
          'clientId': clientId,
          'appCheckEnabled': true,
          'debugMode': false,
          'redirectUri': _generateRedirectUri(bundleId),
          'securityLevel': 'production',
        };

        return Right(config);
      },
    );
  }

  /// Validates production deployment readiness
  /// 
  /// Checks if the configuration is ready for production deployment
  Future<Either<PlatformConfigFailure, bool>> validateProductionReadiness(
    Map<String, dynamic> productionConfig,
  ) async {
    if (productionConfig.isEmpty) {
      return const Left(PlatformConfigFailure(
        'Production configuration cannot be empty'
      ));
    }

    // Check for required platform configurations
    if (!productionConfig.containsKey('android') || !productionConfig.containsKey('ios')) {
      return const Left(PlatformConfigFailure(
        'Both Android and iOS configurations are required for production deployment'
      ));
    }

    final android = productionConfig['android'] as Map<String, dynamic>?;
    final ios = productionConfig['ios'] as Map<String, dynamic>?;

    if (android == null || ios == null) {
      return const Left(PlatformConfigFailure(
        'Invalid platform configuration format - configs must be maps'
      ));
    }

    // Validate Android production configuration
    final androidValidation = _validateRequiredFields(
      android, 
      _requiredAndroidProdFields, 
      'Android production'
    );
    
    if (androidValidation.isLeft()) {
      return androidValidation;
    }
    
    // Additional Android-specific validations
    final packageName = android['packageName']?.toString() ?? '';
    final sha1 = android['sha1Fingerprint']?.toString() ?? '';
    final androidClientId = android['clientId']?.toString() ?? '';
    
    if (!_isValidAndroidPackageName(packageName)) {
      return const Left(PlatformConfigFailure(
        'Android production config has invalid package name format'
      ));
    }
    
    if (!_isValidSHA1Fingerprint(sha1)) {
      return const Left(PlatformConfigFailure(
        'Android production config has invalid SHA1 fingerprint format'
      ));
    }
    
    if (!_isValidGoogleClientId(androidClientId)) {
      return const Left(PlatformConfigFailure(
        'Android production config has invalid Google client ID format'
      ));
    }

    // Validate iOS production configuration
    final iosValidation = _validateRequiredFields(
      ios, 
      _requiredIOSProdFields, 
      'iOS production'
    );
    
    if (iosValidation.isLeft()) {
      return iosValidation;
    }
    
    // Additional iOS-specific validations
    final bundleId = ios['bundleId']?.toString() ?? '';
    final teamId = ios['teamId']?.toString() ?? '';
    final iosClientId = ios['clientId']?.toString() ?? '';
    
    if (!_isValidIOSBundleId(bundleId)) {
      return const Left(PlatformConfigFailure(
        'iOS production config has invalid bundle ID format'
      ));
    }
    
    if (teamId.length != 10 || !RegExp(r'^[A-Z0-9]{10}$').hasMatch(teamId)) {
      return const Left(PlatformConfigFailure(
        'iOS production config has invalid team ID format'
      ));
    }
    
    if (!_isValidGoogleClientId(iosClientId)) {
      return const Left(PlatformConfigFailure(
        'iOS production config has invalid Google client ID format'
      ));
    }
    
    return const Right(true);
  }
}
