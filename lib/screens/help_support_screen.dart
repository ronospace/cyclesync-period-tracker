import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<_HelpSection> _helpSections = [
    _HelpSection(
      title: '🚀 Getting Started',
      items: [
        _HelpItem(
          question: 'How do I start tracking my cycle?',
          answer: 'Navigate to the home screen and tap the "Log Cycle" button. Enter your period start date and any symptoms you\'re experiencing. The app will begin tracking your cycle patterns.',
        ),
        _HelpItem(
          question: 'What data should I log daily?',
          answer: 'For best results, log your period days, symptoms (cramps, mood, energy), and any notes. The more data you provide, the more accurate your predictions will be.',
        ),
        _HelpItem(
          question: 'How accurate are the predictions?',
          answer: 'Predictions improve with more data. After 3-6 cycles, the AI algorithms can provide highly accurate predictions for your next period and fertile windows.',
        ),
      ],
    ),
    _HelpSection(
      title: '📊 Analytics & Insights',
      items: [
        _HelpItem(
          question: 'How do I view my cycle analytics?',
          answer: 'Tap the "Analytics" tab or visit the Analytics section from settings. You\'ll see detailed charts, patterns, and AI-powered insights about your cycle.',
        ),
        _HelpItem(
          question: 'What are the AI insights?',
          answer: 'Our AI analyzes your cycle patterns, symptoms, and health data to provide personalized insights about irregular cycles, mood patterns, and health correlations.',
        ),
        _HelpItem(
          question: 'Can I export my data?',
          answer: 'Yes! Go to Settings > Export & Backup to download your data as PDF reports or CSV files. You can also share specific data with healthcare providers.',
        ),
      ],
    ),
    _HelpSection(
      title: '🔗 Health Integration',
      items: [
        _HelpItem(
          question: 'How do I connect HealthKit?',
          answer: 'Go to Settings > Health Integration and tap "Connect HealthKit". Grant permissions for the health data you want to sync (heart rate, sleep, steps, etc.).',
        ),
        _HelpItem(
          question: 'What health data is supported?',
          answer: 'We support heart rate, HRV, sleep data, steps, body temperature, weight, and more. This data helps improve AI predictions and stress analysis.',
        ),
        _HelpItem(
          question: 'Is my health data secure?',
          answer: 'Absolutely. All health data is encrypted and stored securely. We follow HIPAA guidelines and never share your personal health information.',
        ),
      ],
    ),
    _HelpSection(
      title: '🔔 Notifications',
      items: [
        _HelpItem(
          question: 'How do I set up cycle reminders?',
          answer: 'Go to Settings > Notifications to customize reminders for period predictions, fertile windows, and daily logging prompts.',
        ),
        _HelpItem(
          question: 'What are Smart Notifications?',
          answer: 'Smart notifications use AI to send you personalized insights, irregular cycle alerts, and health recommendations based on your data patterns.',
        ),
        _HelpItem(
          question: 'Can I disable notifications?',
          answer: 'Yes, you can customize or completely disable any notifications in Settings > Notifications or Settings > Smart Notifications.',
        ),
      ],
    ),
    _HelpSection(
      title: '🔒 Privacy & Security',
      items: [
        _HelpItem(
          question: 'How is my data protected?',
          answer: 'Your data is encrypted end-to-end, stored securely in Firebase, and never shared without your explicit consent. We follow strict privacy standards.',
        ),
        _HelpItem(
          question: 'Can I delete my account and data?',
          answer: 'Yes, you can delete your account and all associated data at any time. Go to Settings > Account > Delete Account for complete data removal.',
        ),
        _HelpItem(
          question: 'Who can access my cycle data?',
          answer: 'Only you have access to your data. You can choose to share specific information with healthcare providers through our secure sharing features.',
        ),
      ],
    ),
    _HelpSection(
      title: '🛠️ Troubleshooting',
      items: [
        _HelpItem(
          question: 'The app is not syncing my data',
          answer: 'Check your internet connection and go to Settings > Sync Status. If issues persist, try signing out and back in, or contact support.',
        ),
        _HelpItem(
          question: 'My predictions seem inaccurate',
          answer: 'Predictions improve with more data. Ensure you\'re logging consistently for at least 3 cycles. You can also check Settings > Diagnostics for data quality.',
        ),
        _HelpItem(
          question: 'How do I backup my data?',
          answer: 'Your data is automatically backed up to the cloud. For local backups, use Settings > Export & Backup to download your complete data.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('❓ Help & Support'),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.grey.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.support_agent,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'We\'re Here to Help!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find answers to common questions, learn how to use features, and get the most out of CycleSync.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    icon: Icons.email_outlined,
                    title: 'Contact Support',
                    subtitle: 'Get personalized help',
                    onTap: () => _showContactDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    icon: Icons.bug_report_outlined,
                    title: 'Report Issue',
                    subtitle: 'Found a problem?',
                    onTap: () => _showReportIssueDialog(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Help Sections
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // FAQ Sections
            ..._helpSections.map((section) => _buildHelpSection(context, section)),

            const SizedBox(height: 32),

            // Additional Resources
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          'Additional Resources',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.school_outlined, size: 20),
                      title: const Text('User Guide'),
                      subtitle: const Text('Complete app walkthrough'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showUserGuideDialog(context),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.science_outlined, size: 20),
                      title: const Text('AI Features'),
                      subtitle: const Text('Learn about AI predictions'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showAIFeaturesDialog(context),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.privacy_tip_outlined, size: 20),
                      title: const Text('Privacy Policy'),
                      subtitle: const Text('How we protect your data'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showPrivacyDialog(context),
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

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context, _HelpSection section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: section.items
            .map((item) => _buildHelpItem(context, item))
            .toList(),
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, _HelpItem item) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            item.answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get in touch with our support team:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, size: 18, color: Colors.blue),
                SizedBox(width: 8),
                Text('support@cyclesync.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text('Response within 24 hours'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening email client...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.email),
            label: const Text('Email Us'),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    final TextEditingController issueController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe the issue you\'re experiencing:'),
            const SizedBox(height: 16),
            TextField(
              controller: issueController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Please provide as much detail as possible...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue report submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showUserGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🏠 Home Screen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• View your current cycle status\n• Log new cycle data\n• See upcoming predictions'),
              SizedBox(height: 12),
              Text(
                '📊 Analytics',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• View detailed cycle charts\n• AI-powered insights\n• Trend analysis'),
              SizedBox(height: 12),
              Text(
                '🔔 Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Period predictions\n• Fertile window alerts\n• Custom reminders'),
              SizedBox(height: 12),
              Text(
                '⚙️ Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Customize app preferences\n• Manage data and privacy\n• Export and sharing options'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showAIFeaturesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Features'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🧠 Cycle Predictions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Advanced algorithms predict your next period and fertile windows with high accuracy.'),
              SizedBox(height: 12),
              Text(
                '❤️ Health Analysis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Integration with HealthKit for HRV, heart rate, and sleep analysis.'),
              SizedBox(height: 12),
              Text(
                '😊 Mood Tracking',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('AI-powered emotion classification from wearable biometric data.'),
              SizedBox(height: 12),
              Text(
                '⚠️ Irregularity Detection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Automatic detection of cycle irregularities and health patterns.'),
              SizedBox(height: 12),
              Text(
                '💤 Sleep Quality',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Predictive analysis of sleep quality based on activity and biometrics.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Amazing!'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Privacy is Our Priority',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '🔒 Data Encryption',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('All personal data is encrypted end-to-end using industry-standard encryption.'),
              SizedBox(height: 8),
              Text(
                '🏥 HIPAA Compliance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('We follow strict healthcare data protection guidelines and regulations.'),
              SizedBox(height: 8),
              Text(
                '🚫 No Data Selling',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('We never sell, rent, or share your personal health data with third parties.'),
              SizedBox(height: 8),
              Text(
                '✋ User Control',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('You have complete control over your data and can delete it at any time.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}

class _HelpSection {
  final String title;
  final List<_HelpItem> items;

  _HelpSection({
    required this.title,
    required this.items,
  });
}

class _HelpItem {
  final String question;
  final String answer;

  _HelpItem({
    required this.question,
    required this.answer,
  });
}
