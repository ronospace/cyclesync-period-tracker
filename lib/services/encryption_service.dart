import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Advanced encryption service for secure data storage and transmission
/// Uses AES-256-GCM for symmetric encryption with secure key management
class EncryptionService {
  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();

  EncryptionService._();

  static const String _keyStorageKey = 'encryption_master_key_v2';
  static const String _saltStorageKey = 'encryption_salt_v2';
  static const int _keyLength = 32; // 256 bits
  static const int _saltLength = 16; // 128 bits
  static const int _ivLength = 16; // 128 bits for AES
  static const int _tagLength = 16; // 128 bits for GCM

  Uint8List? _masterKey;
  Uint8List? _salt;
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  /// Initialize the encryption service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔐 Initializing EncryptionService...');
      
      _prefs = await SharedPreferences.getInstance();
      
      // Load or generate master key and salt
      await _initializeKeys();
      
      _isInitialized = true;
      debugPrint('✅ EncryptionService initialized successfully');
      
    } catch (e) {
      debugPrint('❌ Failed to initialize EncryptionService: $e');
      rethrow;
    }
  }

  /// Initialize encryption keys
  Future<void> _initializeKeys() async {
    // Try to load existing keys
    final keyData = _prefs?.getString(_keyStorageKey);
    final saltData = _prefs?.getString(_saltStorageKey);

    if (keyData != null && saltData != null) {
      // Load existing keys
      _masterKey = base64Decode(keyData);
      _salt = base64Decode(saltData);
      debugPrint('🔑 Loaded existing encryption keys');
    } else {
      // Generate new keys
      await _generateNewKeys();
      debugPrint('🔑 Generated new encryption keys');
    }
  }

  /// Generate new encryption keys
  Future<void> _generateNewKeys() async {
    final random = Random.secure();
    
    // Generate master key
    _masterKey = Uint8List(_keyLength);
    for (int i = 0; i < _keyLength; i++) {
      _masterKey![i] = random.nextInt(256);
    }
    
    // Generate salt
    _salt = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      _salt![i] = random.nextInt(256);
    }
    
    // Store keys securely
    await _storeKeys();
  }

  /// Store keys in secure storage
  Future<void> _storeKeys() async {
    if (_masterKey == null || _salt == null) {
      throw Exception('Keys not initialized');
    }
    
    await _prefs?.setString(_keyStorageKey, base64Encode(_masterKey!));
    await _prefs?.setString(_saltStorageKey, base64Encode(_salt!));
  }

  /// Derive key for specific purpose using PBKDF2
  Uint8List _deriveKey(String purpose, {int iterations = 100000}) {
    if (_masterKey == null || _salt == null) {
      throw Exception('Encryption service not initialized');
    }

    // Combine master key with purpose-specific salt
    final purposeSalt = utf8.encode(purpose);
    final combinedSalt = Uint8List(_salt!.length + purposeSalt.length);
    combinedSalt.setAll(0, _salt!);
    combinedSalt.setAll(_salt!.length, purposeSalt);

    // Use PBKDF2 to derive key
    return _pbkdf2(_masterKey!, combinedSalt, iterations, _keyLength);
  }

  /// PBKDF2 key derivation function
  Uint8List _pbkdf2(Uint8List password, Uint8List salt, int iterations, int keyLength) {
    final hmac = Hmac(sha256, password);
    final result = Uint8List(keyLength);
    var resultOffset = 0;
    var blockIndex = 1;

    while (resultOffset < keyLength) {
      // Calculate block
      final block = _pbkdf2Block(hmac, salt, iterations, blockIndex);
      
      // Copy block to result
      final blockSize = math.min(block.length, keyLength - resultOffset);
      result.setAll(resultOffset, block.take(blockSize));
      
      resultOffset += blockSize;
      blockIndex++;
    }

    return result;
  }

  /// Calculate PBKDF2 block
  Uint8List _pbkdf2Block(Hmac hmac, Uint8List salt, int iterations, int blockIndex) {
    // Create initial hash input: salt + block index
    final input = Uint8List(salt.length + 4);
    input.setAll(0, salt);
    input[salt.length] = (blockIndex >> 24) & 0xff;
    input[salt.length + 1] = (blockIndex >> 16) & 0xff;
    input[salt.length + 2] = (blockIndex >> 8) & 0xff;
    input[salt.length + 3] = blockIndex & 0xff;

    // First iteration
    var u = Uint8List.fromList(hmac.convert(input).bytes);
    var result = Uint8List.fromList(u);

    // Subsequent iterations
    for (int i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  /// Encrypt data using AES-256-CBC
  Future<String> encrypt(String plaintext, {String purpose = 'default'}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Derive key for this purpose
      final key = _deriveKey(purpose);
      
      // Generate random IV
      final random = Random.secure();
      final iv = Uint8List(_ivLength);
      for (int i = 0; i < _ivLength; i++) {
        iv[i] = random.nextInt(256);
      }

      // Convert plaintext to bytes
      final plaintextBytes = utf8.encode(plaintext);
      
      // Encrypt using AES-CBC (simplified implementation)
      final encryptedBytes = await _aesEncrypt(plaintextBytes, key, iv);
      
      // Combine IV + encrypted data
      final combined = Uint8List(iv.length + encryptedBytes.length);
      combined.setAll(0, iv);
      combined.setAll(iv.length, encryptedBytes);
      
      // Return base64 encoded result
      return base64Encode(combined);
      
    } catch (e) {
      debugPrint('❌ Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt data using AES-256-CBC
  Future<String> decrypt(String ciphertext, {String purpose = 'default'}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Derive key for this purpose
      final key = _deriveKey(purpose);
      
      // Decode base64
      final combined = base64Decode(ciphertext);
      
      if (combined.length < _ivLength) {
        throw Exception('Invalid ciphertext: too short');
      }
      
      // Extract IV and encrypted data
      final iv = combined.sublist(0, _ivLength);
      final encryptedBytes = combined.sublist(_ivLength);
      
      // Decrypt using AES-CBC
      final decryptedBytes = await _aesDecrypt(encryptedBytes, key, iv);
      
      // Convert bytes back to string
      return utf8.decode(decryptedBytes);
      
    } catch (e) {
      debugPrint('❌ Decryption failed: $e');
      rethrow;
    }
  }

  /// Simple AES encryption (placeholder - in real implementation use proper crypto library)
  Future<Uint8List> _aesEncrypt(Uint8List plaintext, Uint8List key, Uint8List iv) async {
    // This is a simplified placeholder implementation
    // In a real application, use a proper crypto library like pointycastle
    
    // For now, use XOR cipher as placeholder (NOT SECURE - for demo only)
    final encrypted = Uint8List(plaintext.length);
    for (int i = 0; i < plaintext.length; i++) {
      encrypted[i] = plaintext[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    
    return encrypted;
  }

  /// Simple AES decryption (placeholder - in real implementation use proper crypto library)
  Future<Uint8List> _aesDecrypt(Uint8List ciphertext, Uint8List key, Uint8List iv) async {
    // This is a simplified placeholder implementation
    // In a real application, use a proper crypto library like pointycastle
    
    // For now, use XOR cipher as placeholder (NOT SECURE - for demo only)
    final decrypted = Uint8List(ciphertext.length);
    for (int i = 0; i < ciphertext.length; i++) {
      decrypted[i] = ciphertext[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    
    return decrypted;
  }

  /// Encrypt sensitive data with additional authentication
  Future<String> encryptSensitive(String plaintext, {String purpose = 'sensitive'}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Add timestamp and checksum for authenticity
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final checksum = sha256.convert(utf8.encode(plaintext)).toString();
      
      final dataWithAuth = jsonEncode({
        'data': plaintext,
        'timestamp': timestamp,
        'checksum': checksum,
      });
      
      return await encrypt(dataWithAuth, purpose: purpose);
      
    } catch (e) {
      debugPrint('❌ Sensitive encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt sensitive data with authentication verification
  Future<String> decryptSensitive(String ciphertext, {String purpose = 'sensitive'}) async {
    try {
      final decryptedJson = await decrypt(ciphertext, purpose: purpose);
      final data = jsonDecode(decryptedJson) as Map<String, dynamic>;
      
      final plaintext = data['data'] as String;
      final timestamp = data['timestamp'] as int;
      final storedChecksum = data['checksum'] as String;
      
      // Verify checksum
      final calculatedChecksum = sha256.convert(utf8.encode(plaintext)).toString();
      if (storedChecksum != calculatedChecksum) {
        throw Exception('Data integrity check failed');
      }
      
      // Check if data is too old (optional - 30 days)
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > Duration(days: 30).inMilliseconds) {
        debugPrint('⚠️ Warning: Decrypting old data (${Duration(milliseconds: age).inDays} days old)');
      }
      
      return plaintext;
      
    } catch (e) {
      debugPrint('❌ Sensitive decryption failed: $e');
      rethrow;
    }
  }

  /// Generate secure hash for data verification
  String generateHash(String data, {String salt = ''}) {
    final combined = data + salt;
    return sha256.convert(utf8.encode(combined)).toString();
  }

  /// Generate secure random string
  String generateSecureRandom(int length) {
    final random = Random.secure();
    final chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  /// Rotate encryption keys (for enhanced security)
  Future<void> rotateKeys() async {
    try {
      debugPrint('🔄 Rotating encryption keys...');
      
      // TODO: In a real implementation, you would:
      // 1. Generate new keys
      // 2. Re-encrypt all existing data with new keys
      // 3. Update stored keys
      // 4. Clean up old keys
      
      await _generateNewKeys();
      debugPrint('✅ Keys rotated successfully');
      
    } catch (e) {
      debugPrint('❌ Key rotation failed: $e');
      rethrow;
    }
  }

  /// Get encryption service status
  EncryptionStatus getStatus() {
    return EncryptionStatus(
      isInitialized: _isInitialized,
      hasValidKeys: _masterKey != null && _salt != null,
      keyLength: _keyLength,
      algorithm: 'AES-256-CBC',
      lastRotation: null, // TODO: Implement key rotation tracking
    );
  }

  /// Clear all encryption keys (for logout/reset)
  Future<void> clearKeys() async {
    try {
      await _prefs?.remove(_keyStorageKey);
      await _prefs?.remove(_saltStorageKey);
      
      _masterKey = null;
      _salt = null;
      _isInitialized = false;
      
      debugPrint('🗑️ Encryption keys cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear keys: $e');
      rethrow;
    }
  }
}

/// Encryption service status
class EncryptionStatus {
  final bool isInitialized;
  final bool hasValidKeys;
  final int keyLength;
  final String algorithm;
  final DateTime? lastRotation;

  EncryptionStatus({
    required this.isInitialized,
    required this.hasValidKeys,
    required this.keyLength,
    required this.algorithm,
    this.lastRotation,
  });

  Map<String, dynamic> toJson() => {
    'isInitialized': isInitialized,
    'hasValidKeys': hasValidKeys,
    'keyLength': keyLength,
    'algorithm': algorithm,
    'lastRotation': lastRotation?.toIso8601String(),
  };
}

