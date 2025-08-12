import 'package:flutter/material.dart';
import '../../../services/social_service.dart';
import '../../../models/social_models.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_overlay.dart';

class JoinCommunityDialog extends StatefulWidget {
  const JoinCommunityDialog({super.key});

  @override
  State<JoinCommunityDialog> createState() => _JoinCommunityDialogState();
}

class _JoinCommunityDialogState extends State<JoinCommunityDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Community preferences
  CommunityDataPreferences _preferences = CommunityDataPreferences();
  bool _understoodPrivacy = false;
  bool _agreeToContribution = false;
  bool _readResearchInfo = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Join Community Research',
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeStep(),
                  _buildDataContributionStep(),
                  _buildPrivacyStep(),
                  _buildConsentStep(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Join the CycleSync Community',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Help advance menstrual health research by contributing anonymous data to our community insights.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 32),
          _buildBenefitCard(
            icon: Icons.science,
            title: 'Advance Medical Research',
            description: 'Your anonymous data helps researchers understand menstrual health patterns and improve care for everyone.',
          ),
          
          _buildBenefitCard(
            icon: Icons.insights,
            title: 'Gain Community Insights',
            description: 'Access aggregated insights about cycle patterns, symptoms, and wellbeing from thousands of anonymous users.',
          ),
          
          _buildBenefitCard(
            icon: Icons.privacy_tip,
            title: '100% Anonymous & Private',
            description: 'Your personal information is never shared. All data is completely anonymized before analysis.',
          ),
          
          _buildBenefitCard(
            icon: Icons.volunteer_activism,
            title: 'Help Others',
            description: 'Contribute to a better understanding of menstrual health that benefits all menstruating individuals.',
          ),
          
          const SizedBox(height: 24),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Community Impact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join over 10,000 users who have already contributed to advancing menstrual health research. Together, we\'re creating the largest anonymous dataset for better understanding and care.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataContributionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Contribution Level',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select what types of anonymous data you\'re comfortable sharing',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Contribution Level Cards
          ...ContributionLevel.values.map((level) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: RadioListTile<ContributionLevel>(
                title: Text(
                  level.displayName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      level.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Includes:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: level.includedDataTypes
                          .map((type) => Chip(
                                label: Text(
                                  type.displayName,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                ),
                value: level,
                groupValue: _preferences.contributionLevel,
                onChanged: (value) {
                  setState(() {
                    _preferences = CommunityDataPreferences(
                      contributionLevel: value!,
                      shareCyclePatterns: level.includedDataTypes.contains(DataType.cyclePattern),
                      shareSymptomTrends: level.includedDataTypes.contains(DataType.symptoms),
                      shareWellbeingData: level.includedDataTypes.contains(DataType.wellbeing),
                      shareAgeRange: _preferences.shareAgeRange,
                      shareGeographicRegion: _preferences.shareGeographicRegion,
                    );
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune),
                      const SizedBox(width: 8),
                      const Text(
                        'Additional Demographics (Optional)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Help researchers understand patterns across different groups:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  
                  CheckboxListTile(
                    title: const Text('Share age range (e.g., 25-29)'),
                    subtitle: const Text('Helps understand age-related patterns'),
                    value: _preferences.shareAgeRange,
                    onChanged: (value) {
                      setState(() {
                        _preferences = CommunityDataPreferences(
                          contributionLevel: _preferences.contributionLevel,
                          shareCyclePatterns: _preferences.shareCyclePatterns,
                          shareSymptomTrends: _preferences.shareSymptomTrends,
                          shareWellbeingData: _preferences.shareWellbeingData,
                          shareAgeRange: value ?? false,
                          shareGeographicRegion: _preferences.shareGeographicRegion,
                        );
                      });
                    },
                  ),
                  
                  CheckboxListTile(
                    title: const Text('Share geographic region (e.g., North America)'),
                    subtitle: const Text('Helps understand regional differences'),
                    value: _preferences.shareGeographicRegion,
                    onChanged: (value) {
                      setState(() {
                        _preferences = CommunityDataPreferences(
                          contributionLevel: _preferences.contributionLevel,
                          shareCyclePatterns: _preferences.shareCyclePatterns,
                          shareSymptomTrends: _preferences.shareSymptomTrends,
                          shareWellbeingData: _preferences.shareWellbeingData,
                          shareAgeRange: _preferences.shareAgeRange,
                          shareGeographicRegion: value ?? false,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your Privacy is Protected',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildPrivacyFeature(
            icon: Icons.visibility_off,
            title: 'Complete Anonymization',
            description: 'All personal identifiers are removed before data analysis. Your identity cannot be traced back from the research data.',
          ),
          
          _buildPrivacyFeature(
            icon: Icons.lock,
            title: 'Secure Data Processing',
            description: 'Data is encrypted and processed using industry-standard security protocols. Only aggregated insights are generated.',
          ),
          
          _buildPrivacyFeature(
            icon: Icons.group_remove,
            title: 'No Individual Profiling',
            description: 'Your specific data patterns are never analyzed individually. All insights are based on large group statistics.',
          ),
          
          _buildPrivacyFeature(
            icon: Icons.settings,
            title: 'Full Control',
            description: 'You can modify your preferences or stop contributing at any time. Past contributions remain anonymous.',
          ),
          
          const SizedBox(height: 24),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'How It Works',
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
                    '1. Your data is anonymized and combined with thousands of others\n'
                    '2. Researchers analyze group patterns and trends\n'
                    '3. Insights are published for medical research and education\n'
                    '4. You benefit from community insights in your app',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text('I understand how my data will be anonymized and used'),
            value: _understoodPrivacy,
            onChanged: (value) {
              setState(() {
                _understoodPrivacy = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConsentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Research Participation Consent',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Contribution Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildSummaryRow('Contribution Level', _preferences.contributionLevel.displayName),
                  _buildSummaryRow('Data Types', _getIncludedDataTypes()),
                  _buildSummaryRow('Age Range', _preferences.shareAgeRange ? 'Included' : 'Not included'),
                  _buildSummaryRow('Geographic Region', _preferences.shareGeographicRegion ? 'Included' : 'Not included'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Research Ethics & Rights',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'By participating in community research, you acknowledge:\n\n'
                    '• Participation is completely voluntary\n'
                    '• You can withdraw at any time\n'
                    '• Data will be used for legitimate medical research\n'
                    '• No compensation is provided for participation\n'
                    '• Research results may be published in scientific journals\n'
                    '• Your anonymity is guaranteed throughout the process',
                    style: TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          CheckboxListTile(
            title: const Text('I understand and agree to participate in community research'),
            subtitle: const Text('You can change these preferences at any time in settings'),
            value: _agreeToContribution,
            onChanged: (value) {
              setState(() {
                _agreeToContribution = value ?? false;
              });
            },
          ),

          CheckboxListTile(
            title: const Text('I have read and understand the research participation information'),
            value: _readResearchInfo,
            onChanged: (value) {
              setState(() {
                _readResearchInfo = value ?? false;
              });
            },
          ),

          const SizedBox(height: 24),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Thank you for helping advance menstrual health research and supporting the community!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              child: Text(_currentStep == 3 ? 'Join Community' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
        color: Colors.green.shade50,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Welcome step
      case 1:
        return true; // Data contribution step
      case 2:
        return _understoodPrivacy;
      case 3:
        return _agreeToContribution && _readResearchInfo;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _joinCommunity();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _getIncludedDataTypes() {
    final types = <String>[];
    if (_preferences.shareCyclePatterns) types.add('Cycle patterns');
    if (_preferences.shareSymptomTrends) types.add('Symptoms');
    if (_preferences.shareWellbeingData) types.add('Wellbeing');
    
    return types.isEmpty ? 'None selected' : types.join(', ');
  }

  Future<void> _joinCommunity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await SocialService.joinCommunityDataSharing(_preferences);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        await _showSuccessDialog();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        await _showErrorDialog('Failed to join community research');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await _showErrorDialog('Failed to join community: $e');
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.celebration, color: Colors.green, size: 48),
        title: const Text('Welcome to the Community!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thank you for joining the CycleSync community research program. Your contribution will help advance menstrual health understanding for everyone.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'You can now access community insights and modify your preferences at any time in the Social & Sharing section.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String error) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('Unable to Join'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
