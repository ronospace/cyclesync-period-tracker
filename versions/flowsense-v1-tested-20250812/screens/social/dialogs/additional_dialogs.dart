import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/social_service.dart';
import '../../../models/social_models.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_overlay.dart';

/// Partner sharing dialog for simple partner access
class PartnerSharingDialog extends StatefulWidget {
  const PartnerSharingDialog({super.key});

  @override
  State<PartnerSharingDialog> createState() => _PartnerSharingDialogState();
}

class _PartnerSharingDialogState extends State<PartnerSharingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _includeCyclePatterns = true;
  bool _includeSymptoms = false;
  bool _includePainLevels = false;
  bool _includePersonalMessage = false;
  Duration _accessDuration = const Duration(days: 90);
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Share with Partner'),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 24),
                      _buildPartnerInfoSection(),
                      const SizedBox(height: 24),
                      _buildDataSelectionSection(),
                      const SizedBox(height: 24),
                      _buildOptionsSection(),
                      const SizedBox(height: 24),
                      _buildPrivacySection(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, size: 32, color: Colors.pink.shade400),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Share with Your Partner',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Help your partner understand your cycle patterns and provide better support during your menstrual health journey.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPartnerInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Partner Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Partner\'s Email Address *',
                hintText: 'partner@example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include personal message'),
              subtitle: const Text('Add a note to help explain the shared information'),
              value: _includePersonalMessage,
              onChanged: (value) {
                setState(() {
                  _includePersonalMessage = value;
                });
              },
            ),
            
            if (_includePersonalMessage) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Personal Message',
                  hintText: 'Hi! I\'m sharing my cycle information with you so you can better understand and support me...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What to Share',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose what information your partner can see',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              title: const Text('Cycle patterns'),
              subtitle: const Text('Period start/end dates and cycle lengths'),
              value: _includeCyclePatterns,
              onChanged: (value) {
                setState(() {
                  _includeCyclePatterns = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Common symptoms'),
              subtitle: const Text('Physical symptoms you experience during your cycle'),
              value: _includeSymptoms,
              onChanged: (value) {
                setState(() {
                  _includeSymptoms = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Pain levels'),
              subtitle: const Text('Help them understand when you might need extra support'),
              value: _includePainLevels,
              onChanged: (value) {
                setState(() {
                  _includePainLevels = value ?? false;
                });
              },
            ),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Your partner will see general patterns, not detailed personal notes or sensitive information.',
                      style: TextStyle(fontSize: 14),
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

  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sharing Duration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...([
              (const Duration(days: 30), '1 Month', 'Short-term sharing'),
              (const Duration(days: 90), '3 Months', 'Recommended for partners'),
              (const Duration(days: 365), '1 Year', 'Long-term relationship'),
              (null, 'Indefinite', 'Until manually revoked'),
            ].map((option) {
              return RadioListTile<Duration?>(
                title: Text(option.$2),
                subtitle: Text(option.$3),
                value: option.$1,
                groupValue: _accessDuration == null ? null : _accessDuration,
                onChanged: (value) {
                  setState(() {
                    _accessDuration = value ?? const Duration(days: 90);
                  });
                },
              );
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Privacy & Control',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '✅ You can revoke access at any time\n'
              '✅ Your partner cannot see personal notes\n'
              '✅ All data is securely encrypted\n'
              '✅ Your partner cannot share this data with others\n'
              '✅ Access is limited to what you specifically choose',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canShare() ? _shareWithPartner : null,
              child: const Text('Share with Partner'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canShare() {
    return _emailController.text.isNotEmpty &&
           RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text) &&
           (_includeCyclePatterns || _includeSymptoms || _includePainLevels);
  }

  Future<void> _shareWithPartner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dataTypes = <DataType>[];
      if (_includeCyclePatterns) dataTypes.add(DataType.cyclePattern);
      if (_includeSymptoms) dataTypes.add(DataType.symptoms);
      if (_includePainLevels) dataTypes.add(DataType.wellbeing);

      final result = await SocialService.shareWithProvider(
        providerEmail: _emailController.text.trim(),
        permission: SharePermission.viewOnly,
        dateRange: DateRange(
          start: DateTime.now().subtract(const Duration(days: 180)),
          end: DateTime.now().add(const Duration(days: 365)),
        ),
        dataTypes: dataTypes,
        personalMessage: _includePersonalMessage ? _messageController.text.trim() : null,
        expiration: _accessDuration,
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        await _showSuccessDialog();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        await _showErrorDialog(result.error ?? 'Unknown error occurred');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await _showErrorDialog('Failed to share with partner: $e');
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.favorite, color: Colors.pink.shade400, size: 48),
        title: const Text('Shared with Partner!'),
        content: const Text(
          'Your partner will receive an email with a secure link to view your cycle information. They\'ll be able to better understand and support you during your menstrual health journey.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
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
        title: const Text('Sharing Failed'),
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

/// Community preferences management dialog
class CommunityPreferencesDialog extends StatefulWidget {
  const CommunityPreferencesDialog({super.key});

  @override
  State<CommunityPreferencesDialog> createState() => _CommunityPreferencesDialogState();
}

class _CommunityPreferencesDialogState extends State<CommunityPreferencesDialog> {
  CommunityDataPreferences _preferences = CommunityDataPreferences(
    contributionLevel: ContributionLevel.standard,
    shareCyclePatterns: true,
    shareSymptomTrends: true,
    shareWellbeingData: false,
    shareAgeRange: true,
    shareGeographicRegion: false,
  );
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Community Preferences'),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContributionLevelSection(),
                    const SizedBox(height: 24),
                    _buildDataTypesSection(),
                    const SizedBox(height: 24),
                    _buildDemographicsSection(),
                    const SizedBox(height: 24),
                    _buildImpactSection(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionLevelSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contribution Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...ContributionLevel.values.map((level) {
              return RadioListTile<ContributionLevel>(
                title: Text(level.displayName),
                subtitle: Text(level.description),
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
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize exactly what data you contribute',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              title: const Text('Cycle Patterns'),
              subtitle: const Text('Anonymous cycle length and regularity data'),
              value: _preferences.shareCyclePatterns,
              onChanged: (value) {
                setState(() {
                  _preferences = CommunityDataPreferences(
                    contributionLevel: _preferences.contributionLevel,
                    shareCyclePatterns: value ?? false,
                    shareSymptomTrends: _preferences.shareSymptomTrends,
                    shareWellbeingData: _preferences.shareWellbeingData,
                    shareAgeRange: _preferences.shareAgeRange,
                    shareGeographicRegion: _preferences.shareGeographicRegion,
                  );
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Symptom Trends'),
              subtitle: const Text('Help researchers understand common symptoms'),
              value: _preferences.shareSymptomTrends,
              onChanged: (value) {
                setState(() {
                  _preferences = CommunityDataPreferences(
                    contributionLevel: _preferences.contributionLevel,
                    shareCyclePatterns: _preferences.shareCyclePatterns,
                    shareSymptomTrends: value ?? false,
                    shareWellbeingData: _preferences.shareWellbeingData,
                    shareAgeRange: _preferences.shareAgeRange,
                    shareGeographicRegion: _preferences.shareGeographicRegion,
                  );
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Wellbeing Data'),
              subtitle: const Text('Mood and energy patterns (sensitive data)'),
              value: _preferences.shareWellbeingData,
              onChanged: (value) {
                setState(() {
                  _preferences = CommunityDataPreferences(
                    contributionLevel: _preferences.contributionLevel,
                    shareCyclePatterns: _preferences.shareCyclePatterns,
                    shareSymptomTrends: _preferences.shareSymptomTrends,
                    shareWellbeingData: value ?? false,
                    shareAgeRange: _preferences.shareAgeRange,
                    shareGeographicRegion: _preferences.shareGeographicRegion,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demographics (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              title: const Text('Age Range'),
              subtitle: const Text('Share your age bracket (e.g., 25-29)'),
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
              title: const Text('Geographic Region'),
              subtitle: const Text('Share your general region (e.g., North America)'),
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
    );
  }

  Widget _buildImpactSection() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'Your Impact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'By participating in community research, you\'re helping:\n\n'
              '🔬 Advance menstrual health research\n'
              '📊 Improve medical understanding of cycles\n'
              '👩‍⚕️ Train better healthcare providers\n'
              '🌍 Support menstrual health globally\n'
              '📱 Enhance period tracking apps',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _stopParticipation,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Leave Community'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _savePreferences,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await SocialService.joinCommunityDataSharing(_preferences);
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences updated successfully')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update preferences')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _stopParticipation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Community Research'),
        content: const Text(
          'Are you sure you want to stop participating in community research? '
          'You can rejoin at any time, but past contributions will remain anonymous.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave Community'),
          ),
        ],
      ),
    );
  }
}

/// Share details bottom sheet
class ShareDetailsSheet extends StatelessWidget {
  final ShareSummary share;

  const ShareDetailsSheet({super.key, required this.share});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                share.isActive ? Icons.share : Icons.history,
                color: share.isActive 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Share Details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('Recipient', share.providerEmail),
                  _buildDetailSection('Status', share.isActive ? 'Active' : 'Inactive'),
                  _buildDetailSection('Created', _formatDate(share.createdAt)),
                  _buildDetailSection('Expires', share.expiresAt != null 
                      ? _formatDate(share.expiresAt!)
                      : 'Never'),
                  _buildDetailSection('Access Count', '${share.accessCount} times'),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Shared Data Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: share.dataTypes
                        .map((type) => Chip(
                              label: Text(type),
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  Card(
                    color: share.isActive 
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            share.isActive 
                                ? Icons.check_circle
                                : Icons.warning,
                            color: share.isActive 
                                ? Colors.green.shade600
                                : Colors.orange.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              share.isActive
                                  ? 'This share is currently active. The recipient can access your data until ${share.timeRemaining}.'
                                  : 'This share is no longer active. The recipient cannot access your data.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (share.isActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _revokeAccess(context),
                icon: const Icon(Icons.block),
                label: const Text('Revoke Access'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _revokeAccess(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Access'),
        content: Text(
          'Are you sure you want to revoke access for ${share.providerEmail}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke Access'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SocialService.revokeAccess(share.shareId);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Access revoked successfully'
                : 'Failed to revoke access'),
          ),
        );
      }
    }
  }
}
