import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/social_service.dart';
import '../../../models/social_models.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_overlay.dart';

class CreateProviderAccessDialog extends StatefulWidget {
  const CreateProviderAccessDialog({super.key});

  @override
  State<CreateProviderAccessDialog> createState() =>
      _CreateProviderAccessDialogState();
}

class _CreateProviderAccessDialogState
    extends State<CreateProviderAccessDialog> {
  final _formKey = GlobalKey<FormState>();
  final _providerNameController = TextEditingController();
  final _providerEmailController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _notesController = TextEditingController();

  ProviderType _selectedProviderType = ProviderType.gynecologist;
  final Set<DataType> _authorizedDataTypes = {
    DataType.cyclePattern,
    DataType.symptoms,
    DataType.wellbeing,
  };
  Duration? _accessDuration = const Duration(days: 365);
  bool _requireVerification = true;
  bool _allowDataExport = false;
  bool _sendWelcomeEmail = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _providerNameController.dispose();
    _providerEmailController.dispose();
    _clinicNameController.dispose();
    _licenseNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Provider Access'),
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
                      const SizedBox(height: 32),
                      _buildProviderInfoSection(),
                      const SizedBox(height: 24),
                      _buildDataAuthorizationSection(),
                      const SizedBox(height: 24),
                      _buildAccessOptionsSection(),
                      const SizedBox(height: 24),
                      _buildSecuritySection(),
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
        const Text(
          'Secure Healthcare Provider Access',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Create long-term, secure access for your healthcare provider with customizable permissions.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This creates a dedicated, HIPAA-compliant portal for your healthcare provider.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                const Text(
                  'Provider Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _providerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Provider Name *',
                      hintText: 'Dr. Jane Smith',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Provider name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<ProviderType>(
                    value: _selectedProviderType,
                    decoration: const InputDecoration(
                      labelText: 'Type *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    items: ProviderType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getProviderTypeDisplayName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProviderType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _providerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Professional Email Address *',
                hintText: 'doctor@clinic.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _clinicNameController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic/Hospital Name',
                      hintText: 'City Medical Center',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _licenseNumberController,
                    decoration: const InputDecoration(
                      labelText: 'License Number',
                      hintText: 'Optional',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataAuthorizationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.data_usage),
                const SizedBox(width: 8),
                const Text(
                  'Data Authorization',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select which types of data this provider can access',
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(),
            const SizedBox(height: 16),

            ...DataType.values.map((dataType) {
              final isAuthorized = _authorizedDataTypes.contains(dataType);
              final isSensitive = dataType.isSensitive;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isAuthorized
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                    : null,
                child: CheckboxListTile(
                  title: Row(
                    children: [
                      Text(
                        dataType.displayName,
                        style: TextStyle(
                          fontWeight: isAuthorized
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (isSensitive) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.warning,
                          size: 16,
                          color: Colors.orange.shade600,
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dataType.description),
                      if (isSensitive) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Contains highly sensitive personal information',
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  value: isAuthorized,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _authorizedDataTypes.add(dataType);
                      } else {
                        _authorizedDataTypes.remove(dataType);
                      }
                    });
                  },
                ),
              );
            }),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: ${_authorizedDataTypes.length} data types authorized',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildAccessOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings),
                const SizedBox(width: 8),
                const Text(
                  'Access Configuration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              'Access Duration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ...([
              (const Duration(days: 90), '3 Months', 'Short-term care'),
              (const Duration(days: 365), '1 Year', 'Standard ongoing care'),
              (const Duration(days: 730), '2 Years', 'Long-term treatment'),
              (null, 'Indefinite', 'Permanent provider relationship'),
            ].map((option) {
              return RadioListTile<Duration?>(
                title: Text(option.$2),
                subtitle: Text(option.$3),
                value: option.$1,
                groupValue: _accessDuration,
                onChanged: (value) {
                  setState(() {
                    _accessDuration = value;
                  });
                },
              );
            })),

            const SizedBox(height: 20),
            const Text(
              'Additional Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Require identity verification'),
              subtitle: const Text(
                'Provider must verify identity before first access',
              ),
              value: _requireVerification,
              onChanged: (value) {
                setState(() {
                  _requireVerification = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Allow data export'),
              subtitle: const Text(
                'Provider can export data for their records',
              ),
              value: _allowDataExport,
              onChanged: (value) {
                setState(() {
                  _allowDataExport = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Send welcome email'),
              subtitle: const Text(
                'Automatically notify provider about access',
              ),
              value: _sendWelcomeEmail,
              onChanged: (value) {
                setState(() {
                  _sendWelcomeEmail = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Security & Privacy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Security Features:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ...[
              '🔐 End-to-end encryption for all data',
              '🏥 HIPAA-compliant access controls',
              '📋 Complete audit trail of all access',
              '🔄 Real-time access monitoring',
              '⏰ Automatic session timeouts',
              '🚫 Ability to revoke access instantly',
            ].map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(feature, style: const TextStyle(fontSize: 14)),
              ),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText:
                    'Any special instructions or context for this provider...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Important: You can monitor, modify, or revoke this access at any time. The provider will be notified of any changes to their access permissions.',
                      style: TextStyle(color: Colors.red.shade700),
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
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
              onPressed: _canCreateAccess() ? _createProviderAccess : null,
              child: const Text('Create Provider Access'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canCreateAccess() {
    return _providerNameController.text.isNotEmpty &&
        _providerEmailController.text.isNotEmpty &&
        RegExp(
          r'^[^@]+@[^@]+\.[^@]+',
        ).hasMatch(_providerEmailController.text) &&
        _authorizedDataTypes.isNotEmpty;
  }

  String _getProviderTypeDisplayName(ProviderType type) {
    switch (type) {
      case ProviderType.gynecologist:
        return 'Gynecologist';
      case ProviderType.generalPractitioner:
        return 'General Practitioner';
      case ProviderType.nutritionist:
        return 'Nutritionist';
      case ProviderType.mentalHealth:
        return 'Mental Health';
      case ProviderType.fertility:
        return 'Fertility Specialist';
      case ProviderType.endocrinologist:
        return 'Endocrinologist';
      case ProviderType.other:
        return 'Other';
    }
  }

  Future<void> _createProviderAccess() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SocialService.createProviderAccess(
        providerName: _providerNameController.text.trim(),
        providerEmail: _providerEmailController.text.trim(),
        providerType: _selectedProviderType,
        authorizedDataTypes: _authorizedDataTypes.toList(),
        accessDuration: _accessDuration,
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        await _showSuccessDialog(result);
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
      await _showErrorDialog('Failed to create provider access: $e');
    }
  }

  Future<void> _showSuccessDialog(ProviderAccessResult result) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Provider Access Created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 16),

            if (result.dashboardUrl != null) ...[
              const Text(
                'Provider Dashboard URL:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.dashboardUrl!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: result.dashboardUrl!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL copied to clipboard'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      iconSize: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Steps:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _sendWelcomeEmail
                        ? '• Your provider will receive a welcome email with access instructions\n'
                              '• You can monitor access from the Social & Sharing section\n'
                              '• Access can be modified or revoked at any time'
                        : '• Share the dashboard URL with your provider\n'
                              '• Monitor access from the Social & Sharing section\n'
                              '• Access can be modified or revoked at any time',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ],
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
        title: const Text('Failed to Create Access'),
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
