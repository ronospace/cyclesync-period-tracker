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
                            onPressed: () => _showHealthcareProviderDialog(context),
                            icon: const Icon(Icons.local_hospital),
                            label: const Text('Healthcare\nProvider'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showPartnerDialog(context),
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
                        onPressed: () => _showProviderAccessDialog(context),
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
                        onPressed: () => _showCommunityDialog(context),
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

  void _showHealthcareProviderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _HealthcareProviderDialog(),
    );
  }

  void _showPartnerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _PartnerSharingDialog(),
    );
  }

  void _showProviderAccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ProviderAccessDialog(),
    );
  }

  void _showCommunityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CommunityResearchDialog(),
    );
  }
}

// Healthcare Provider Dialog
class _HealthcareProviderDialog extends StatefulWidget {
  @override
  _HealthcareProviderDialogState createState() => _HealthcareProviderDialogState();
}

class _HealthcareProviderDialogState extends State<_HealthcareProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _providerNameController = TextEditingController();
  final _providerEmailController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedDuration = '30 days';
  final Set<String> _selectedData = {'Cycle patterns', 'Symptoms', 'Daily logs'};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Share with Healthcare Provider', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _providerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Provider Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _providerEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Provider Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (!value!.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Access Duration',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: ['7 days', '30 days', '90 days', '1 year']
                        .map((duration) => DropdownMenuItem(
                              value: duration,
                              child: Text(duration),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedDuration = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Data to Share:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...['Cycle patterns', 'Symptoms', 'Daily logs', 'Analytics'].map(
                    (dataType) => CheckboxListTile(
                      title: Text(dataType),
                      value: _selectedData.contains(dataType),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedData.add(dataType);
                          } else {
                            _selectedData.remove(dataType);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _shareWithProvider(context);
                    }
                  },
                  child: const Text('Share Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareWithProvider(BuildContext context) {
    // Simulate API call
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully shared data with ${_providerNameController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}

// Partner Sharing Dialog
class _PartnerSharingDialog extends StatefulWidget {
  @override
  _PartnerSharingDialogState createState() => _PartnerSharingDialogState();
}

class _PartnerSharingDialogState extends State<_PartnerSharingDialog> {
  final _emailController = TextEditingController();
  final Set<String> _selectedData = {'Cycle predictions', 'Mood tracking'};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.pink),
                const SizedBox(width: 8),
                const Text('Share with Partner', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Partner Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('What to Share:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...['Cycle predictions', 'Mood tracking', 'Symptoms', 'Fertility window']
                .map(
              (dataType) => CheckboxListTile(
                title: Text(dataType),
                value: _selectedData.contains(dataType),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedData.add(dataType);
                    } else {
                      _selectedData.remove(dataType);
                    }
                  });
                },
              ),
            ),
            
            const SizedBox(height: 16),
            Card(
              color: Colors.pink.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.pink.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your partner will receive updates and can view shared information.',
                        style: TextStyle(color: Colors.pink.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _shareWithPartner(context),
                  child: const Text('Send Invitation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareWithPartner(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation sent to partner!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Provider Access Dialog
class _ProviderAccessDialog extends StatefulWidget {
  @override
  _ProviderAccessDialogState createState() => _ProviderAccessDialogState();
}

class _ProviderAccessDialogState extends State<_ProviderAccessDialog> {
  final _formKey = GlobalKey<FormState>();
  final _providerNameController = TextEditingController();
  final _clinicController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _accessType = 'Read-only';
  final Set<String> _permissions = {'View cycle data', 'Generate reports'};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Create Provider Access', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _providerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Provider Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _clinicController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic/Hospital',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Professional Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (!value!.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _accessType,
                    decoration: const InputDecoration(
                      labelText: 'Access Level',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Read-only', 'Limited write', 'Full access']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _accessType = value!),
                  ),
                  const SizedBox(height: 16),
                  
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...['View cycle data', 'Generate reports', 'Add notes', 'Export data']
                      .map(
                    (permission) => CheckboxListTile(
                      title: Text(permission),
                      value: _permissions.contains(permission),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _permissions.add(permission);
                          } else {
                            _permissions.remove(permission);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _createProviderAccess(context);
                    }
                  },
                  child: const Text('Create Access'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createProviderAccess(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Provider access created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Community Research Dialog
class _CommunityResearchDialog extends StatefulWidget {
  @override
  _CommunityResearchDialogState createState() => _CommunityResearchDialogState();
}

class _CommunityResearchDialogState extends State<_CommunityResearchDialog> {
  bool _agreedToTerms = false;
  final Set<String> _researchAreas = {'Cycle patterns', 'Symptom research'};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Join Community Research', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            const Text(
              'Help improve menstrual health understanding by contributing anonymous data to research.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            const Text('Research Areas:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...['Cycle patterns', 'Symptom research', 'Health correlations', 'Treatment outcomes']
                .map(
              (area) => CheckboxListTile(
                title: Text(area),
                value: _researchAreas.contains(area),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _researchAreas.add(area);
                    } else {
                      _researchAreas.remove(area);
                    }
                  });
                },
              ),
            ),
            
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Protection',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• All data is completely anonymous\n'
                      '• No personal identifiers are shared\n'
                      '• You can opt out at any time\n'
                      '• Data is used only for approved research',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            CheckboxListTile(
              title: const Text('I agree to the privacy terms and conditions'),
              value: _agreedToTerms,
              onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _agreedToTerms ? () => _joinCommunity(context) : null,
                  child: const Text('Join Community'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _joinCommunity(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully joined the research community!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
