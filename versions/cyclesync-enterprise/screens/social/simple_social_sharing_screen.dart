import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SimpleSocialSharingScreen extends StatelessWidget {
  const SimpleSocialSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤝 Social Sharing'),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.grey.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Share Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '🔗 Quick Share',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showComingSoonDialog(context, 'Healthcare Provider Sharing'),
                            icon: const Icon(Icons.local_hospital),
                            label: const Text('Healthcare\nProvider'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showComingSoonDialog(context, 'Partner Sharing'),
                            icon: const Icon(Icons.favorite),
                            label: const Text('Partner'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Provider Access Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Secure Provider Access',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create secure, long-term access for your healthcare providers with customizable permissions and automatic expiration.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showComingSoonDialog(context, 'Provider Access'),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Provider Access'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Community Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.groups, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Community Research',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Join thousands of users contributing anonymous data to help improve menstrual health understanding.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showComingSoonDialog(context, 'Community Research'),
                        icon: const Icon(Icons.add_circle),
                        label: const Text('Join Community'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Privacy Info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy & Security',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• All shared data is encrypted and secure\n'
                      '• Community data is completely anonymous\n'
                      '• You can revoke access at any time\n'
                      '• Healthcare providers follow HIPAA compliance\n'
                      '• No personal information is shared without consent',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text('$feature is coming soon! This feature will allow secure data sharing with full privacy controls.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
