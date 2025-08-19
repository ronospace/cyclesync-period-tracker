import 'package:flutter/material.dart';
import '../../models/partner_models.dart';
import '../../services/partner_sharing_service.dart';

class PartnerInvitationScreen extends StatefulWidget {
  const PartnerInvitationScreen({super.key});

  @override
  State<PartnerInvitationScreen> createState() => _PartnerInvitationScreenState();
}

class _PartnerInvitationScreenState extends State<PartnerInvitationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isLoading = false;
  SharingPermissionLevel _selectedPermission = SharingPermissionLevel.view;
  final Set<SharedDataType> _selectedDataTypes = {
    SharedDataType.cycleLength,
    SharedDataType.periodDates,
    SharedDataType.symptoms,
  };

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Partner'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPermissionSelector(),
              const SizedBox(height: 20),
              _buildDataTypeSelector(),
              const SizedBox(height: 20),
              _buildMessageField(),
              const SizedBox(height: 32),
              _buildInviteButton(),
              const SizedBox(height: 16),
              _buildExistingInvitations(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Share Your Cycle Journey',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Invite your partner to share in your menstrual health journey. Choose what data to share and set permissions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partner\'s Email',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your partner\'s email address',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPermissionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permission Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...SharingPermissionLevel.values.map((permission) {
          return RadioListTile<SharingPermissionLevel>(
            title: Text(_getPermissionTitle(permission)),
            subtitle: Text(_getPermissionDescription(permission)),
            value: permission,
            groupValue: _selectedPermission,
            onChanged: (value) {
              setState(() {
                _selectedPermission = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildDataTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data to Share',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select which types of data your partner can access',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...SharedDataType.values.map((dataType) {
          return CheckboxListTile(
            title: Text(_getDataTypeTitle(dataType)),
            subtitle: Text(_getDataTypeDescription(dataType)),
            value: _selectedDataTypes.contains(dataType),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedDataTypes.add(dataType);
                } else {
                  _selectedDataTypes.remove(dataType);
                }
              });
            },
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Message (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a personal message to your invitation...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendInvitation,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                'Send Invitation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildExistingInvitations() {
    return StreamBuilder<List<PartnerInvitation>>(
      stream: PartnerSharingService.instance.getSentInvitationsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Sent Invitations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...snapshot.data!.map((invitation) => _buildInvitationCard(invitation)),
          ],
        );
      },
    );
  }

  Widget _buildInvitationCard(PartnerInvitation invitation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(invitation.status),
          child: Icon(
            _getStatusIcon(invitation.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(invitation.inviteeEmail),
        subtitle: Text(_getStatusText(invitation.status)),
        trailing: invitation.status == InvitationStatus.pending
            ? TextButton(
                onPressed: () => _cancelInvitation(invitation.id),
                child: const Text('Cancel'),
              )
            : null,
      ),
    );
  }

  String _getPermissionTitle(SharingPermissionLevel permission) {
    switch (permission) {
      case SharingPermissionLevel.view:
      case SharingPermissionLevel.viewOnly:
        return 'View Only';
      case SharingPermissionLevel.comment:
        return 'View  Comment';
      case SharingPermissionLevel.remind:
        return 'View, Comment  Remind';
      case SharingPermissionLevel.edit:
        return 'View, Comment  Edit';
    }
  }

  String _getPermissionDescription(SharingPermissionLevel permission) {
    switch (permission) {
      case SharingPermissionLevel.view:
      case SharingPermissionLevel.viewOnly:
        return 'Partner can only view shared data';
      case SharingPermissionLevel.comment:
        return 'Partner can view and add comments';
      case SharingPermissionLevel.remind:
        return 'Partner can view, comment, and send reminders';
      case SharingPermissionLevel.edit:
        return 'Partner can view, comment, and make edits';
    }
  }

  String _getDataTypeTitle(SharedDataType dataType) {
    switch (dataType) {
      case SharedDataType.cycleLength:
        return 'Cycle Length';
      case SharedDataType.periodDates:
        return 'Period Dates';
      case SharedDataType.symptoms:
        return 'Symptoms';
      case SharedDataType.moods:
        return 'Moods';
      case SharedDataType.flowIntensity:
        return 'Flow Intensity';
      case SharedDataType.medications:
        return 'Medications';
      case SharedDataType.temperature:
        return 'Temperature';
      case SharedDataType.cervicalMucus:
        return 'Cervical Mucus';
      case SharedDataType.sexualActivity:
        return 'Sexual Activity';
      case SharedDataType.notes:
        return 'Personal Notes';
      case SharedDataType.predictions:
        return 'Cycle Predictions';
      case SharedDataType.cycleStart:
        return 'Cycle Start';
      case SharedDataType.mood:
        return 'Mood';
      case SharedDataType.fertility:
        return 'Fertility';
      case SharedDataType.intimacy:
        return 'Intimacy';
      case SharedDataType.appointments:
        return 'Appointments';
      case SharedDataType.analytics:
        return 'Analytics';
      case SharedDataType.reminders:
        return 'Reminders';
    }
  }

  String _getDataTypeDescription(SharedDataType dataType) {
    switch (dataType) {
      case SharedDataType.cycleLength:
        return 'Average cycle length and variations';
      case SharedDataType.periodDates:
        return 'Period start and end dates';
      case SharedDataType.symptoms:
        return 'Physical and emotional symptoms';
      case SharedDataType.moods:
        return 'Daily mood tracking';
      case SharedDataType.flowIntensity:
        return 'Menstrual flow intensity levels';
      case SharedDataType.medications:
        return 'Medications and supplements';
      case SharedDataType.temperature:
        return 'Basal body temperature';
      case SharedDataType.cervicalMucus:
        return 'Cervical mucus observations';
      case SharedDataType.sexualActivity:
        return 'Sexual activity tracking';
      case SharedDataType.notes:
        return 'Personal notes and observations';
      case SharedDataType.predictions:
        return 'AI-generated cycle predictions';
      case SharedDataType.cycleStart:
        return 'Period start dates';
      case SharedDataType.mood:
        return 'Mood tracking';
      case SharedDataType.fertility:
        return 'Fertility window';
      case SharedDataType.intimacy:
        return 'Intimacy events';
      case SharedDataType.appointments:
        return 'Doctor appointments';
      case SharedDataType.analytics:
        return 'Cycle analytics';
      case SharedDataType.reminders:
        return 'Shared reminders';
    }
  }

  Color _getStatusColor(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return Colors.orange;
      case InvitationStatus.accepted:
        return Colors.green;
      case InvitationStatus.declined:
        return Colors.red;
      case InvitationStatus.expired:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return Icons.schedule;
      case InvitationStatus.accepted:
        return Icons.check;
      case InvitationStatus.declined:
        return Icons.close;
      case InvitationStatus.expired:
        return Icons.timer_off;
      default:
        return Icons.schedule;
    }
  }

  String _getStatusText(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return 'Pending response';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDataTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one data type to share'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final invitationId = await PartnerSharingService.instance.sendPartnerInvitation(
        partnerEmail: _emailController.text.trim(),
        relationshipType: PartnerType.romanticPartner, // Default type
        customMessage: _messageController.text.trim().isEmpty 
            ? null 
            : _messageController.text.trim(),
        customPermissions: {
          for (final dt in _selectedDataTypes) dt: _selectedPermission,
        },
      );
      final success = invitationId != null;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send invitation. Please try again.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _emailController.clear();
    _messageController.clear();
    setState(() {
      _selectedPermission = SharingPermissionLevel.view;
      _selectedDataTypes.clear();
      _selectedDataTypes.addAll([
        SharedDataType.cycleLength,
        SharedDataType.periodDates,
        SharedDataType.symptoms,
      ]);
    });
  }

  Future<void> _cancelInvitation(String invitationId) async {
    try {
      final success = await PartnerSharingService.instance.cancelPartnerInvitation(invitationId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling invitation: $e'),
        ),
      );
    }
  }
}
