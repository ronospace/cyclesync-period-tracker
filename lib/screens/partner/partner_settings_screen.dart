import 'package:flutter/material.dart';
import '../../models/partner_models.dart';

class PartnerSettingsScreen extends StatefulWidget {
  const PartnerSettingsScreen({super.key});

  @override
  State<PartnerSettingsScreen> createState() => _PartnerSettingsScreenState();
}

class _PartnerSettingsScreenState extends State<PartnerSettingsScreen> {
  bool _autoShareEnabled = true;
  bool _notificationsEnabled = true;
  bool _allowComments = true;
  bool _allowPartnerInvitations = true;
  Duration _autoShareFrequency = const Duration(hours: 24);

  final List<DataType> _defaultSharedDataTypes = [
    DataType.cycleLength,
    DataType.periodDates,
    DataType.symptoms,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Sharing Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('General Settings'),
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildSectionHeader('Default Sharing Preferences'),
            _buildDefaultSharingSettings(),
            const SizedBox(height: 24),
            _buildSectionHeader('Auto-Sharing'),
            _buildAutoSharingSettings(),
            const SizedBox(height: 24),
            _buildSectionHeader('Privacy & Security'),
            _buildPrivacySettings(),
            const SizedBox(height: 24),
            _buildSectionHeader('Sharing Templates'),
            _buildSharingTemplates(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Allow Partner Invitations'),
            subtitle: const Text('Others can invite you to share cycle data'),
            value: _allowPartnerInvitations,
            onChanged: (value) {
              setState(() {
                _allowPartnerInvitations = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text(
              'Receive notifications about partner activity',
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Allow Comments'),
            subtitle: const Text('Partners can comment on your shared data'),
            value: _allowComments,
            onChanged: (value) {
              setState(() {
                _allowComments = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSharingSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Default Data Types',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'These data types will be pre-selected when inviting new partners',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...DataType.values.map((dataType) {
              return CheckboxListTile(
                title: Text(_getDataTypeTitle(dataType)),
                subtitle: Text(_getDataTypeDescription(dataType)),
                value: _defaultSharedDataTypes.contains(dataType),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _defaultSharedDataTypes.add(dataType);
                    } else {
                      _defaultSharedDataTypes.remove(dataType);
                    }
                  });
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoSharingSettings() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Auto-Share Data'),
            subtitle: const Text(
              'Automatically share new cycle data with partners',
            ),
            value: _autoShareEnabled,
            onChanged: (value) {
              setState(() {
                _autoShareEnabled = value;
              });
            },
          ),
          if (_autoShareEnabled) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Sharing Frequency'),
              subtitle: Text(_getFrequencyText(_autoShareFrequency)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showFrequencySelector,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Data Retention Policy'),
            subtitle: const Text('Manage how long shared data is kept'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDataRetentionSettings,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Visibility Settings'),
            subtitle: const Text('Control who can see your sharing activity'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showVisibilitySettings,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Shared Data'),
            subtitle: const Text('Download a copy of all shared data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportSharedData,
          ),
        ],
      ),
    );
  }

  Widget _buildSharingTemplates() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Quick Share Templates'),
            subtitle: const Text(
              'Create templates for common sharing scenarios',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _manageSharingTemplates,
          ),
          const Divider(height: 1),
          // Sharing templates would be loaded from a service
          // For now, show placeholder templates
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                _getTemplateIcon('Basic Sharing Template'),
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            title: const Text('Basic Sharing Template'),
            subtitle: const Text('Core cycle data'),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleTemplateAction(action, 'basic'),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Duplicate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                // Show delete option for custom templates
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetToDefaults,
            child: const Text('Reset to Defaults'),
          ),
        ),
      ],
    );
  }

  String _getDataTypeTitle(DataType dataType) {
    switch (dataType) {
      case DataType.cycleLength:
        return 'Cycle Length';
      case DataType.periodDates:
        return 'Period Dates';
      case DataType.symptoms:
        return 'Symptoms';
      case DataType.moods:
        return 'Moods';
      case DataType.flowIntensity:
        return 'Flow Intensity';
      case DataType.medications:
        return 'Medications';
      case DataType.temperature:
        return 'Temperature';
      case DataType.cervicalMucus:
        return 'Cervical Mucus';
      case DataType.sexualActivity:
        return 'Sexual Activity';
      case DataType.notes:
        return 'Personal Notes';
      case DataType.predictions:
        return 'Cycle Predictions';
      default:
        return 'Unknown';
    }
  }

  String _getDataTypeDescription(DataType dataType) {
    switch (dataType) {
      case DataType.cycleLength:
        return 'Average cycle length and variations';
      case DataType.periodDates:
        return 'Period start and end dates';
      case DataType.symptoms:
        return 'Physical and emotional symptoms';
      case DataType.moods:
        return 'Daily mood tracking';
      case DataType.flowIntensity:
        return 'Menstrual flow intensity levels';
      case DataType.medications:
        return 'Medications and supplements';
      case DataType.temperature:
        return 'Basal body temperature';
      case DataType.cervicalMucus:
        return 'Cervical mucus observations';
      case DataType.sexualActivity:
        return 'Sexual activity tracking';
      case DataType.notes:
        return 'Personal notes and observations';
      case DataType.predictions:
        return 'AI-generated cycle predictions';
      default:
        return 'Data type';
    }
  }

  String _getFrequencyText(Duration frequency) {
    if (frequency.inHours == 1) {
      return 'Every hour';
    } else if (frequency.inHours == 24) {
      return 'Daily';
    } else if (frequency.inDays == 7) {
      return 'Weekly';
    } else if (frequency.inHours < 24) {
      return 'Every ${frequency.inHours} hours';
    } else {
      return 'Every ${frequency.inDays} days';
    }
  }

  IconData _getTemplateIcon(String templateName) {
    switch (templateName.toLowerCase()) {
      case 'basic sharing':
        return Icons.share;
      case 'ttc support':
        return Icons.favorite;
      case 'health monitoring':
        return Icons.health_and_safety;
      case 'full transparency':
        return Icons.visibility;
      default:
        return Icons.article_outlined;
    }
  }

  void _loadSettings() async {
    // Load settings from service or shared preferences
    // This would typically load user's saved preferences
  }

  void _showFrequencySelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Auto-Share Frequency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                [
                  const Duration(hours: 1),
                  const Duration(hours: 6),
                  const Duration(hours: 12),
                  const Duration(hours: 24),
                  const Duration(days: 7),
                ].map((duration) {
                  return RadioListTile<Duration>(
                    title: Text(_getFrequencyText(duration)),
                    value: duration,
                    groupValue: _autoShareFrequency,
                    onChanged: (value) {
                      setState(() {
                        _autoShareFrequency = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  void _showDataRetentionSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Data Retention Policy'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose how long shared data should be kept:'),
              SizedBox(height: 16),
              Text('• 30 days: Shared data is deleted after 30 days'),
              Text('• 90 days: Shared data is deleted after 90 days'),
              Text('• 1 year: Shared data is deleted after 1 year'),
              Text('• Forever: Shared data is kept indefinitely'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showVisibilitySettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Visibility Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Control who can see your sharing activity:'),
              SizedBox(height: 16),
              Text('• Private: Only you can see your sharing activity'),
              Text('• Partners: Only your partners can see activity'),
              Text('• Public: Anyone in your network can see activity'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _exportSharedData() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preparing data export...')));

      // In a real implementation, this would:
      // 1. Collect all shared data
      // 2. Generate a downloadable file
      // 3. Share it with the user

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data export complete! Check your downloads.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  void _manageSharingTemplates() {
    // Navigate to template management screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Template management coming soon!')),
    );
  }

  void _handleTemplateAction(String action, String templateId) {
    switch (action) {
      case 'edit':
        _editTemplate(templateId);
        break;
      case 'duplicate':
        _duplicateTemplate(templateId);
        break;
      case 'delete':
        _deleteTemplate(templateId);
        break;
    }
  }

  void _editTemplate(String templateId) {
    // Navigate to template editor
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editing template: $templateId')));
  }

  void _duplicateTemplate(String templateId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Template "$templateId" duplicated')),
    );
  }

  void _deleteTemplate(String templateId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "$templateId"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template "$templateId" deleted'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      // Save settings to service
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
      }
    }
  }

  void _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will reset all your partner sharing settings to their default values. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _autoShareEnabled = true;
        _notificationsEnabled = true;
        _allowComments = true;
        _allowPartnerInvitations = true;
        _autoShareFrequency = const Duration(hours: 24);
        _defaultSharedDataTypes.clear();
        _defaultSharedDataTypes.addAll([
          DataType.cycleLength,
          DataType.periodDates,
          DataType.symptoms,
        ]);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
