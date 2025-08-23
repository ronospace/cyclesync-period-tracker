import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/dimensional_theme.dart';

class OnboardingCompletionScreen extends StatelessWidget {
  const OnboardingCompletionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.purple.shade700,
              Colors.pink.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Success Animation Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha(51),
                        Colors.white.withAlpha(25),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withAlpha(76),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 60)),
                  ),
                ),

                const SizedBox(height: 32),

                // Welcome Message
                const Text(
                  'Welcome to FlowSense!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Your journey to better cycle tracking starts now',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Next Steps Cards
                _buildNextStepCard(
                  icon: Icons.home,
                  title: 'Explore Your Dashboard',
                  description: 'View your health insights and predictions',
                  onTap: () => context.go('/home'),
                ),

                const SizedBox(height: 16),

                _buildNextStepCard(
                  icon: Icons.calendar_today,
                  title: 'Track Your Cycle',
                  description: 'Log periods, symptoms, and daily notes',
                  onTap: () => context.go('/log-cycle'),
                ),

                const SizedBox(height: 16),

                _buildNextStepCard(
                  icon: Icons.insights,
                  title: 'AI Health Insights',
                  description: 'Get personalized health recommendations',
                  onTap: () => context.go('/health-insights'),
                ),

                const SizedBox(height: 60),

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Secondary Action
                TextButton(
                  onPressed: () => context.go('/settings'),
                  child: const Text(
                    'Customize Settings',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha(153),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
