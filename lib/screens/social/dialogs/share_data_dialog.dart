import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/social_service.dart';
import '../../../models/social_models.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_overlay.dart';

enum ShareType { healthcare, partner }

class ShareDataDialog extends StatefulWidget {
  final ShareType type;

  const ShareDataDialog({super.key, required this.type});

  @override
  State<ShareDataDialog> createState() => _ShareDataDialogState();
}

class _ShareDataDialogState extends State<ShareDataDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form data
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _providerNameController = TextEditingController();

  SharePermission _selectedPermission = SharePermission.viewOnly;
  ProviderType _selectedProviderType = ProviderType.gynecologist;
  Set<DataType> _selectedDataTypes = {DataType.cyclePattern};
  DateRange? _selectedDateRange;
  Duration? _selectedExpiration = const Duration(days: 30);
  bool _includePersonalMessage = false;
  bool _sendNotification = true;
  bool _agreeToPolicies = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    _providerNameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializeDefaults() {
    if (widget.type == ShareType.healthcare) {
      _selectedPermission = SharePermission.fullAccess;
      _selectedDataTypes = {
        DataType.cyclePattern,
        DataType.symptoms,
        DataType.wellbeing,
      };
    } else {
      _selectedPermission = SharePermission.viewOnly;
      _selectedDataTypes = {DataType.cyclePattern};
    }

    // Set default date range to last 6 months
    final now = DateTime.now();
    _selectedDateRange = DateRange(
      start: DateTime(now.year, now.month - 6, now.day),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.type == ShareType.healthcare
            ? 'Share with Healthcare Provider'
            : 'Share with Partner',
        actions: [
          if (_currentStep > 0)
            IconButton(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildRecipientStep(),
                  _buildPermissionsStep(),
                  _buildDataSelectionStep(),
                  _buildOptionsStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(5, (index) {
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                if (index < 4)
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

  Widget _buildRecipientStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.type == ShareType.healthcare
                ? 'Healthcare Provider Information'
                : 'Partner Information',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.type == ShareType.healthcare
                ? 'Enter your healthcare provider\'s email address and details'
                : 'Enter your partner\'s email address',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          if (widget.type == ShareType.healthcare) ...[
            TextFormField(
              controller: _providerNameController,
              decoration: const InputDecoration(
                labelText: 'Provider Name *',
                hintText: 'Dr. Smith',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<ProviderType>(
              value: _selectedProviderType,
              decoration: const InputDecoration(
                labelText: 'Provider Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              items: ProviderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type.name.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProviderType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
          ],

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: widget.type == ShareType.healthcare
                  ? 'Provider Email *'
                  : 'Partner Email *',
              hintText: 'example@email.com',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Include personal message'),
            subtitle: const Text(
              'Add a personalized note with your shared data',
            ),
            value: _includePersonalMessage,
            onChanged: (value) {
              setState(() {
                _includePersonalMessage = value;
              });
            },
          ),

          if (_includePersonalMessage) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Personal Message',
                hintText: 'Add any relevant context or notes...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],

          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Privacy & Security',
            icon: Icons.security,
            content: widget.type == ShareType.healthcare
                ? 'Your data will be shared securely with HIPAA compliance. The provider will receive a secure access link.'
                : 'Your partner will receive a secure access link. You can revoke access at any time.',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Access Permissions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose what level of access to grant',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          ...SharePermission.values.map((permission) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: RadioListTile<SharePermission>(
                title: Text(
                  permission.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(permission.description),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: permission.allowedDataTypes
                          .map(
                            (type) => Chip(
                              label: Text(type.displayName),
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                value: permission,
                groupValue: _selectedPermission,
                onChanged: (value) {
                  setState(() {
                    _selectedPermission = value!;
                    _selectedDataTypes = permission.allowedDataTypes.toSet();
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Recommended for ${widget.type.name}',
            icon: Icons.lightbulb,
            content: widget.type == ShareType.healthcare
                ? 'Full Access is recommended for healthcare providers to get complete insights for better care.'
                : 'View Only access is typically sufficient for partners to understand your cycle patterns.',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Data to Share',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose which types of data to include',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          ...DataType.values
              .where(
                (type) => _selectedPermission.allowedDataTypes.contains(type),
              )
              .map((dataType) {
                final isSelected = _selectedDataTypes.contains(dataType);
                final isSensitive = dataType.isSensitive;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CheckboxListTile(
                    title: Row(
                      children: [
                        Text(
                          dataType.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
                        const SizedBox(height: 4),
                        Text(dataType.description),
                        if (isSensitive) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Contains sensitive personal information',
                            style: TextStyle(
                              color: Colors.orange.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedDataTypes.add(dataType);
                        } else {
                          _selectedDataTypes.remove(dataType);
                        }
                      });
                    },
                  ),
                );
              }),

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
                      Icon(Icons.calendar_month, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Data will be shared from: ${_selectedDateRange?.toString() ?? 'Not selected'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _selectDateRange,
                          child: const Text('Change Range'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              final now = DateTime.now();
                              _selectedDateRange = DateRange(
                                start: DateTime(
                                  now.year,
                                  now.month - 6,
                                  now.day,
                                ),
                                end: now,
                              );
                            });
                          },
                          child: const Text('Last 6 Months'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sharing Options',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure additional sharing preferences',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: 8),
                      const Text(
                        'Access Duration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ...([
                    (const Duration(days: 7), '1 Week'),
                    (const Duration(days: 30), '1 Month'),
                    (const Duration(days: 90), '3 Months'),
                    (const Duration(days: 365), '1 Year'),
                    (null, 'No Expiration'),
                  ].map((option) {
                    return RadioListTile<Duration?>(
                      title: Text(option.$2),
                      subtitle: option.$1 != null
                          ? Text('Expires in ${option.$1!.inDays} days')
                          : const Text(
                              'Access never expires (can be revoked manually)',
                            ),
                      value: option.$1,
                      groupValue: _selectedExpiration,
                      onChanged: (value) {
                        setState(() {
                          _selectedExpiration = value;
                        });
                      },
                    );
                  })),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Send notification email'),
                  subtitle: const Text(
                    'Notify recipient about shared data access',
                  ),
                  value: _sendNotification,
                  onChanged: (value) {
                    setState(() {
                      _sendNotification = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Require access confirmation'),
                  subtitle: const Text(
                    'Recipient must confirm before accessing data',
                  ),
                  value: false,
                  onChanged: null, // Feature for future implementation
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Access Management',
            icon: Icons.info,
            content:
                'You can view all your shares, check access history, and revoke access at any time from the Social & Sharing section.',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review & Share',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please review your sharing settings before proceeding',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sharing Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  if (widget.type == ShareType.healthcare) ...[
                    _buildReviewRow(
                      'Provider Name',
                      _providerNameController.text,
                    ),
                    _buildReviewRow(
                      'Provider Type',
                      _selectedProviderType.name,
                    ),
                  ],
                  _buildReviewRow('Email', _emailController.text),
                  _buildReviewRow(
                    'Access Level',
                    _selectedPermission.displayName,
                  ),
                  _buildReviewRow(
                    'Data Types',
                    _selectedDataTypes.map((e) => e.displayName).join(', '),
                  ),
                  _buildReviewRow(
                    'Date Range',
                    _selectedDateRange?.toString() ?? 'Not selected',
                  ),
                  _buildReviewRow(
                    'Expires',
                    _selectedExpiration != null
                        ? 'In ${_selectedExpiration!.inDays} days'
                        : 'Never',
                  ),
                  if (_includePersonalMessage &&
                      _messageController.text.isNotEmpty)
                    _buildReviewRow('Message', _messageController.text),
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
                      Icon(Icons.privacy_tip, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Privacy Acknowledgment',
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
                    'By sharing your data, you acknowledge that:\n\n'
                    '• The recipient will have access to the selected personal health information\n'
                    '• You can revoke access at any time\n'
                    '• All data is transmitted securely and encrypted\n'
                    '• The recipient is responsible for maintaining confidentiality',
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text(
                      'I agree to the privacy terms and data sharing policy',
                    ),
                    value: _agreeToPolicies,
                    onChanged: (value) {
                      setState(() {
                        _agreeToPolicies = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
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
            color: Colors.black.withValues(alpha: 0.1),
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
              child: Text(_currentStep == 4 ? 'Share Data' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
        return _emailController.text.isNotEmpty &&
            RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text) &&
            (widget.type != ShareType.healthcare ||
                _providerNameController.text.isNotEmpty);
      case 1:
        return true; // Permission always selected
      case 2:
        return _selectedDataTypes.isNotEmpty && _selectedDateRange != null;
      case 3:
        return true; // Options are optional
      case 4:
        return _agreeToPolicies;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _shareData();
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start:
            _selectedDateRange?.start ??
            DateTime.now().subtract(const Duration(days: 180)),
        end: _selectedDateRange?.end ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = DateRange(start: picked.start, end: picked.end);
      });
    }
  }

  Future<void> _shareData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SocialService.shareWithProvider(
        providerEmail: _emailController.text.trim(),
        permission: _selectedPermission,
        dateRange: _selectedDateRange!,
        dataTypes: _selectedDataTypes.toList(),
        personalMessage: _includePersonalMessage
            ? _messageController.text.trim()
            : null,
        expiration: _selectedExpiration,
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
      await _showErrorDialog('Failed to share data: $e');
    }
  }

  Future<void> _showSuccessDialog(ShareResult result) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Data Shared Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 16),
            if (result.accessUrl != null) ...[
              const Text('Access URL:'),
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
                        result.accessUrl!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: result.accessUrl!),
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
            ],
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
