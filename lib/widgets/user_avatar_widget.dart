import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../providers/user_provider.dart';
import '../services/avatar_service.dart';
import '../services/theme_service.dart';

/// A comprehensive avatar widget that handles user profile photos
/// Supports custom photos, initials, and various sizes
class UserAvatarWidget extends StatefulWidget {
  final double radius;
  final VoidCallback? onTap;
  final bool showEditButton;
  final bool showBorder;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool isClickable;

  const UserAvatarWidget({
    Key? key,
    this.radius = 24.0,
    this.onTap,
    this.showEditButton = false,
    this.showBorder = true,
    this.borderColor,
    this.backgroundColor,
    this.isClickable = false,
  }) : super(key: key);

  @override
  State<UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget>
    with SingleTickerProviderStateMixin {
  Uint8List? _avatarData;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadAvatar();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.userProfile?.photoURL != null) {
      setState(() => _isLoading = true);

      try {
        final avatarData = await userProvider.getAvatarData();
        if (mounted) {
          setState(() {
            _avatarData = avatarData;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        debugPrint('❌ Failed to load avatar: $e');
      }
    }
  }

  Future<void> _showAvatarOptions() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAvatarOptionsBottomSheet(),
    );
  }

  Widget _buildAvatarOptionsBottomSheet() {
    final themeService = Provider.of<ThemeService>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Update Profile Photo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeService.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you\'d like to update your profile picture',
            style: TextStyle(
              fontSize: 16,
              color: themeService.getTextColor(context).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Options
          _buildOptionTile(
            icon: Icons.photo_library,
            title: 'Choose from Gallery',
            subtitle: 'Select a photo from your photo library',
            onTap: () async {
              Navigator.pop(context);
              await _pickFromGallery();
            },
          ),

          _buildOptionTile(
            icon: Icons.camera_alt,
            title: 'Take Photo',
            subtitle: 'Use your camera to take a new photo',
            onTap: () async {
              Navigator.pop(context);
              await _takePhoto();
            },
          ),

          if (userProvider.hasCustomAvatar)
            _buildOptionTile(
              icon: Icons.delete_outline,
              title: 'Remove Photo',
              subtitle: 'Remove your current profile photo',
              onTap: () async {
                Navigator.pop(context);
                await _removeAvatar();
              },
              isDestructive: true,
            ),

          const SizedBox(height: 24),

          // Cache info
          if (userProvider.getAvatarCacheSize() > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeService.isDarkModeEnabled(context)
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: themeService
                        .getTextColor(context)
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cache size: ${_formatCacheSize(userProvider.getAvatarCacheSize())}',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeService
                            .getTextColor(context)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      userProvider.clearAvatarCache();
                      Navigator.pop(context);
                      _showSnackBar('Avatar cache cleared');
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final themeService = Provider.of<ThemeService>(context);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : themeService.getPrimaryColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? Colors.red
              : themeService.getPrimaryColor(context),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? Colors.red
              : themeService.getTextColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: themeService.getTextColor(context).withValues(alpha: 0.7),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.pickAvatarFromGallery();

    if (success) {
      await _loadAvatar();
      _showSnackBar('Profile photo updated successfully!');
    } else {
      _showSnackBar('Failed to update profile photo', isError: true);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _takePhoto() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.takeAvatarPhoto();

    if (success) {
      await _loadAvatar();
      _showSnackBar('Profile photo updated successfully!');
    } else {
      _showSnackBar('Failed to update profile photo', isError: true);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _removeAvatar() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.deleteAvatar();

    if (success) {
      setState(() => _avatarData = null);
      _showSnackBar('Profile photo removed successfully!');
    } else {
      _showSnackBar('Failed to remove profile photo', isError: true);
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatCacheSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final themeService = Provider.of<ThemeService>(context);

        return GestureDetector(
          onTap: widget.isClickable || widget.showEditButton
              ? (widget.onTap ?? _showAvatarOptions)
              : null,
          onTapDown: widget.isClickable
              ? (_) => _animationController.forward()
              : null,
          onTapUp: widget.isClickable
              ? (_) => _animationController.reverse()
              : null,
          onTapCancel: widget.isClickable
              ? () => _animationController.reverse()
              : null,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildAvatarContent(userProvider, themeService),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAvatarContent(
    UserProvider userProvider,
    ThemeService themeService,
  ) {
    return Stack(
      children: [
        // Main avatar
        Container(
          width: widget.radius * 2,
          height: widget.radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: widget.showBorder
                ? Border.all(
                    color:
                        widget.borderColor ??
                        themeService
                            .getPrimaryColor(context)
                            .withValues(alpha: 0.3),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: _isLoading
                ? _buildLoadingAvatar()
                : _buildFinalAvatar(userProvider, themeService),
          ),
        ),

        // Edit button
        if (widget.showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: widget.radius * 0.6,
              height: widget.radius * 0.6,
              decoration: BoxDecoration(
                color: themeService.getPrimaryColor(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeService.getSurfaceColor(context),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                size: widget.radius * 0.3,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: widget.radius * 0.6,
          height: widget.radius * 0.6,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFinalAvatar(
    UserProvider userProvider,
    ThemeService themeService,
  ) {
    if (_avatarData != null) {
      // Custom photo
      return Image.memory(
        _avatarData!,
        fit: BoxFit.cover,
        width: widget.radius * 2,
        height: widget.radius * 2,
      );
    } else {
      // Fallback to initials
      final initials = userProvider.getUserInitials();
      final backgroundColor =
          widget.backgroundColor ?? themeService.getPrimaryColor(context);

      return Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.radius * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }
}

/// Simplified avatar widget for cases where only display is needed
class SimpleUserAvatar extends StatelessWidget {
  final double size;
  final UserProvider userProvider;

  const SimpleUserAvatar({
    Key? key,
    required this.size,
    required this.userProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: userProvider.getAvatarData(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return CircleAvatar(
            radius: size / 2,
            backgroundImage: MemoryImage(snapshot.data!),
          );
        } else {
          return CircleAvatar(
            radius: size / 2,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              userProvider.getUserInitials(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      },
    );
  }
}
