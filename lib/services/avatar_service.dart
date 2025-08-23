import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for handling user avatar/profile photo functionality
/// Supports gallery import, camera capture, cloud storage, and local caching
class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Cache for storing avatar data locally
  final Map<String, Uint8List> _avatarCache = {};

  /// Pick image from gallery
  Future<AvatarResult> pickFromGallery({
    int maxWidth = 512,
    int maxHeight = 512,
    int quality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (image == null) {
        return AvatarResult.cancelled();
      }

      return await _processImage(image, AvatarSource.gallery);
    } catch (e) {
      debugPrint('❌ Error picking image from gallery: $e');
      return AvatarResult.error('Failed to pick image from gallery: $e');
    }
  }

  /// Take photo with camera
  Future<AvatarResult> takePhoto({
    int maxWidth = 512,
    int maxHeight = 512,
    int quality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (image == null) {
        return AvatarResult.cancelled();
      }

      return await _processImage(image, AvatarSource.camera);
    } catch (e) {
      debugPrint('❌ Error taking photo: $e');
      return AvatarResult.error('Failed to take photo: $e');
    }
  }

  /// Process and optimize the image
  Future<AvatarResult> _processImage(
    XFile imageFile,
    AvatarSource source,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final optimizedBytes = await _optimizeImage(bytes);
      final hash = _generateImageHash(optimizedBytes);

      final avatarData = AvatarData(
        bytes: optimizedBytes,
        fileName: 'avatar_${hash}.jpg',
        size: optimizedBytes.length,
        source: source,
        timestamp: DateTime.now(),
      );

      return AvatarResult.success(avatarData);
    } catch (e) {
      debugPrint('❌ Error processing image: $e');
      return AvatarResult.error('Failed to process image: $e');
    }
  }

  /// Optimize image for avatar use
  Future<Uint8List> _optimizeImage(Uint8List bytes) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception('Invalid image format');

      // Resize to square aspect ratio and optimal size
      final size = 512;
      image = img.copyResizeCropSquare(image, size: size);

      // Apply subtle enhancements
      image = img.adjustColor(
        image,
        brightness: 1.02,
        contrast: 1.05,
        saturation: 1.03,
      );

      // Encode as JPEG with good quality
      final optimizedBytes = img.encodeJpg(image, quality: 90);
      return Uint8List.fromList(optimizedBytes);
    } catch (e) {
      debugPrint('❌ Error optimizing image: $e');
      return bytes; // Return original if optimization fails
    }
  }

  /// Generate hash for image deduplication
  String _generateImageHash(Uint8List bytes) {
    final digest = md5.convert(bytes);
    return digest.toString().substring(0, 8);
  }

  /// Upload avatar to Firebase Storage
  Future<String?> uploadAvatar(AvatarData avatarData, String userId) async {
    try {
      final ref = _storage
          .ref()
          .child('avatars')
          .child(userId)
          .child(avatarData.fileName);

      // Set metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'source': avatarData.source.name,
          'optimized': 'true',
        },
      );

      // Upload the file
      final uploadTask = ref.putData(avatarData.bytes, metadata);

      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint(
          '🔄 Avatar upload progress: ${(progress * 100).toStringAsFixed(1)}%',
        );
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Cache the avatar locally
      _avatarCache[userId] = avatarData.bytes;

      debugPrint('✅ Avatar uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading avatar: $e');
      return null;
    }
  }

  /// Download and cache avatar from URL
  Future<Uint8List?> downloadAvatar(String url, String userId) async {
    try {
      // Check cache first
      if (_avatarCache.containsKey(userId)) {
        return _avatarCache[userId];
      }

      final ref = _storage.refFromURL(url);
      final bytes = await ref.getData();

      if (bytes != null) {
        _avatarCache[userId] = bytes;
        debugPrint('✅ Avatar downloaded and cached for user: $userId');
      }

      return bytes;
    } catch (e) {
      debugPrint('❌ Error downloading avatar: $e');
      return null;
    }
  }

  /// Get cached avatar or download if needed
  Future<Uint8List?> getAvatar(String? photoURL, String userId) async {
    if (photoURL == null) return null;

    // Check cache first
    if (_avatarCache.containsKey(userId)) {
      return _avatarCache[userId];
    }

    // Download and cache
    return await downloadAvatar(photoURL, userId);
  }

  /// Delete avatar from storage
  Future<bool> deleteAvatar(String photoURL, String userId) async {
    try {
      final ref = _storage.refFromURL(photoURL);
      await ref.delete();

      // Remove from cache
      _avatarCache.remove(userId);

      debugPrint('✅ Avatar deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting avatar: $e');
      return false;
    }
  }

  /// Clear avatar cache
  void clearCache() {
    _avatarCache.clear();
    debugPrint('🧹 Avatar cache cleared');
  }

  /// Get avatar cache size in bytes
  int getCacheSize() {
    return _avatarCache.values.fold(0, (sum, bytes) => sum + bytes.length);
  }

  /// Show avatar source selection dialog
  Future<AvatarResult?> showAvatarSourceDialog() async {
    // This will be implemented in the UI layer
    // Returns null to indicate that UI should handle the dialog
    return null;
  }

  /// Create default avatar with user initials
  static Uint8List createDefaultAvatar({
    required String initials,
    int size = 512,
    Color? backgroundColor,
    Color? textColor,
  }) {
    // Create a simple colored avatar with initials
    // This is a placeholder - in a real app you'd use a canvas or image library
    final image = img.Image(width: size, height: size);
    img.fill(
      image,
      color: backgroundColor != null
          ? img.ColorRgb8(
              backgroundColor.red,
              backgroundColor.green,
              backgroundColor.blue,
            )
          : img.ColorRgb8(76, 175, 80),
    ); // Default green

    // In a real implementation, you'd draw the initials text here
    // For now, we'll create a simple solid color image
    return Uint8List.fromList(img.encodePng(image));
  }
}

/// Enum for avatar source
enum AvatarSource { gallery, camera, url, default_ }

extension AvatarSourceExtension on AvatarSource {
  String get displayName {
    switch (this) {
      case AvatarSource.gallery:
        return 'Gallery';
      case AvatarSource.camera:
        return 'Camera';
      case AvatarSource.url:
        return 'URL';
      case AvatarSource.default_:
        return 'Default';
    }
  }

  String get description {
    switch (this) {
      case AvatarSource.gallery:
        return 'Choose from photo library';
      case AvatarSource.camera:
        return 'Take a new photo';
      case AvatarSource.url:
        return 'From web URL';
      case AvatarSource.default_:
        return 'Use default avatar';
    }
  }
}

/// Avatar data model
class AvatarData {
  final Uint8List bytes;
  final String fileName;
  final int size;
  final AvatarSource source;
  final DateTime timestamp;

  const AvatarData({
    required this.bytes,
    required this.fileName,
    required this.size,
    required this.source,
    required this.timestamp,
  });

  /// Get size in human readable format
  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Result class for avatar operations
class AvatarResult {
  final bool success;
  final AvatarData? data;
  final String? error;
  final bool cancelled;

  const AvatarResult._({
    required this.success,
    this.data,
    this.error,
    this.cancelled = false,
  });

  factory AvatarResult.success(AvatarData data) {
    return AvatarResult._(success: true, data: data);
  }

  factory AvatarResult.error(String error) {
    return AvatarResult._(success: false, error: error);
  }

  factory AvatarResult.cancelled() {
    return const AvatarResult._(success: false, cancelled: true);
  }

  @override
  String toString() {
    if (success && data != null) {
      return 'AvatarResult.success(${data!.fileName}, ${data!.sizeFormatted})';
    }
    if (cancelled) {
      return 'AvatarResult.cancelled()';
    }
    return 'AvatarResult.error($error)';
  }
}
