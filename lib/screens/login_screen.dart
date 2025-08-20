import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import '../l10n/generated/app_localizations.dart';
import '../widgets/app_logo.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-login for development
    _emailController.text = 'test@cyclesync.dev';
    _passwordController.text = 'testpassword123';
    
    // Check if already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        context.go('/home');
      }
    });
  }

  Future<void> _login() async {
    setState(() => _error = null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      context.go('/home');
    } catch (e) {
      setState(() => _error = 'Login failed: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if this is a new user
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          // New user, go to display name setup
          context.go('/display-name-setup');
        } else {
          // Existing user, go to home
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() => _error = 'Google sign-in failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // Anonymous users always need to set up display name
      context.go('/display-name-setup');
    } catch (e) {
      setState(() => _error = 'Anonymous sign-in failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Compact Logo and Welcome
                    Column(
                      children: [
                        const AppLogo(
                          size: 80,
                          showText: false,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.appTitle ?? 'CycleSync',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.homeWelcomeSubtitle ?? 'Your personal health companion',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
              
                    // Compact Sign-in Options Card
                    Card(
                      elevation: 8,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Social Sign-in Buttons
                            _buildModernSignInButton(
                              onPressed: _signInWithGoogle,
                              icon: Icons.email,
                              label: l10n?.signInWithGoogle ?? 'Continue with Google',
                              backgroundColor: theme.colorScheme.surface,
                              textColor: theme.colorScheme.onSurface,
                              borderColor: theme.colorScheme.outline,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Apple Sign-in (iOS only)
                            if (Platform.isIOS) ...[
                              _buildModernSignInButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n?.comingSoon ?? 'Apple Sign-In coming soon!')),
                                  );
                                },
                                icon: Icons.apple,
                                label: l10n?.signInWithApple ?? 'Continue with Apple',
                                backgroundColor: theme.colorScheme.onSurface,
                                textColor: theme.colorScheme.surface,
                              ),
                              const SizedBox(height: 12),
                            ],
                            
                            // Guest User Button
                            _buildModernSignInButton(
                              onPressed: _signInAnonymously,
                              icon: Icons.person_outline,
                              label: l10n?.tryAsGuest ?? 'Try as Guest',
                              backgroundColor: theme.colorScheme.secondary,
                              textColor: theme.colorScheme.onSecondary,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Compact Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: theme.colorScheme.outline)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    l10n?.orContinueWithEmail ?? 'or email',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: theme.colorScheme.outline)),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Compact Email/Password Form
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: l10n?.email ?? 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.email_outlined),
                                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: l10n?.password ?? 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.lock_outlined),
                                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading 
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: theme.colorScheme.onPrimary, 
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      l10n?.signIn ?? 'Sign In',
                                      style: const TextStyle(
                                        fontSize: 16, 
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Compact Sign Up Link
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: RichText(
                        text: TextSpan(
                          text: l10n?.dontHaveAccount ?? "Don't have an account? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: l10n?.signUp ?? 'Sign up',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Compact Error Display
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline, 
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildModernSignInButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
