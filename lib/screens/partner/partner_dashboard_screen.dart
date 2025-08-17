import 'package:flutter/material.dart';
import '../../models/partner_models.dart';
import '../../services/partner_sharing_service.dart';
import 'partner_invitation_screen.dart';
import 'partner_settings_screen.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Sharing'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PartnerSettingsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Partners', icon: Icon(Icons.people)),
            Tab(text: 'Invitations', icon: Icon(Icons.mail)),
            Tab(text: 'Shared Data', icon: Icon(Icons.share)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPartnersTab(),
          _buildInvitationsTab(),
          _buildSharedDataTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PartnerInvitationScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Invite Partner'),
      ),
    );
  }

  Widget _buildPartnersTab() {
    return StreamBuilder<List<PartnerRelationship>>(
      stream: PartnerSharingService().getPartnersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyPartnersState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final partner = snapshot.data![index];
            return _buildPartnerCard(partner);
          },
        );
      },
    );
  }

  Widget _buildEmptyPartnersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Partners Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite your partner to share your cycle journey together',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PartnerInvitationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Invite Your First Partner'),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(PartnerRelationship partner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    partner.partnerName.isNotEmpty 
                        ? partner.partnerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.partnerName.isEmpty 
                            ? partner.partnerEmail
                            : partner.partnerName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (partner.partnerName.isNotEmpty)
                        Text(
                          partner.partnerEmail,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        'Connected ${_getTimeAgo(partner.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPermissionText(partner.permission),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataTypeChips(partner.sharedDataTypes),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last activity: ${_getTimeAgo(partner.lastActivity)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _viewSharedData(partner),
                      child: const Text('View Data'),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handlePartnerAction(value, partner),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit Permissions'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: ListTile(
                            leading: Icon(Icons.remove_circle, color: Colors.red),
                            title: Text('Remove Partner'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeChips(List<DataType> dataTypes) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: dataTypes.take(3).map((dataType) {
        return Chip(
          label: Text(
            _getDataTypeTitle(dataType),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        );
      }).toList()
        ..add(
          if (dataTypes.length > 3)
            Chip(
              label: Text(
                '+${dataTypes.length - 3} more',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
        ),
    );
  }

  Widget _buildInvitationsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Sent'),
              Tab(text: 'Received'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSentInvitations(),
                _buildReceivedInvitations(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentInvitations() {
    return StreamBuilder<List<PartnerInvitation>>(
      stream: PartnerSharingService().getSentInvitationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyInvitationsState('sent');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final invitation = snapshot.data![index];
            return _buildInvitationCard(invitation, isSent: true);
          },
        );
      },
    );
  }

  Widget _buildReceivedInvitations() {
    return StreamBuilder<List<PartnerInvitation>>(
      stream: PartnerSharingService().getReceivedInvitationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyInvitationsState('received');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final invitation = snapshot.data![index];
            return _buildInvitationCard(invitation, isSent: false);
          },
        );
      },
    );
  }

  Widget _buildEmptyInvitationsState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'sent' ? Icons.send : Icons.inbox,
            size: 60,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            type == 'sent' ? 'No Sent Invitations' : 'No Received Invitations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            type == 'sent'
                ? 'Invite someone to start sharing your cycle data'
                : 'You haven\\'t received any partner invitations yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(PartnerInvitation invitation, {required bool isSent}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(invitation.status),
                  child: Icon(
                    _getStatusIcon(invitation.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSent ? invitation.inviteeEmail : invitation.inviterEmail,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getStatusText(invitation.status),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(invitation.status),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPermissionText(invitation.permission),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (invitation.personalMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  invitation.personalMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildDataTypeChips(invitation.dataTypes),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sent ${_getTimeAgo(invitation.sentAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (invitation.status == InvitationStatus.pending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSent)
                        TextButton(
                          onPressed: () => _cancelInvitation(invitation.id),
                          child: const Text('Cancel'),
                        )
                      else ...[
                        TextButton(
                          onPressed: () => _declineInvitation(invitation.id),
                          child: const Text('Decline'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _acceptInvitation(invitation.id),
                          child: const Text('Accept'),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedDataTab() {
    return StreamBuilder<List<SharedDataEntry>>(
      stream: PartnerSharingService().getSharedDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySharedDataState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final dataEntry = snapshot.data![index];
            return _buildSharedDataCard(dataEntry);
          },
        );
      },
    );
  }

  Widget _buildEmptySharedDataState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.share_outlined,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Shared Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start sharing data with your partners to see it here',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSharedDataCard(SharedDataEntry dataEntry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _getDataTypeIcon(dataEntry.dataType),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(_getDataTypeTitle(dataEntry.dataType)),
        subtitle: Text('Shared with ${dataEntry.sharedWithEmails.join(", ")}'),
        trailing: Text(_getTimeAgo(dataEntry.sharedAt)),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _getPermissionText(SharedDataPermission permission) {
    switch (permission) {
      case SharedDataPermission.viewOnly:
        return 'View Only';
      case SharedDataPermission.comment:
        return 'Comment';
      case SharedDataPermission.edit:
        return 'Edit';
    }
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
    }
  }

  IconData _getDataTypeIcon(DataType dataType) {
    switch (dataType) {
      case DataType.cycleLength:
        return Icons.timeline;
      case DataType.periodDates:
        return Icons.calendar_today;
      case DataType.symptoms:
        return Icons.healing;
      case DataType.moods:
        return Icons.mood;
      case DataType.flowIntensity:
        return Icons.opacity;
      case DataType.medications:
        return Icons.medication;
      case DataType.temperature:
        return Icons.thermostat;
      case DataType.cervicalMucus:
        return Icons.water_drop;
      case DataType.sexualActivity:
        return Icons.favorite;
      case DataType.notes:
        return Icons.note;
      case DataType.predictions:
        return Icons.insights;
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
    }
  }

  void _viewSharedData(PartnerRelationship partner) {
    // Navigate to shared data detail view
    // Implementation would show detailed shared data for this partner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing shared data with ${partner.partnerName}'),
      ),
    );
  }

  void _handlePartnerAction(String action, PartnerRelationship partner) async {
    switch (action) {
      case 'edit':
        // Navigate to edit permissions screen
        break;
      case 'remove':
        await _confirmRemovePartner(partner);
        break;
    }
  }

  Future<void> _confirmRemovePartner(PartnerRelationship partner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Partner'),
        content: Text(
          'Are you sure you want to remove ${partner.partnerName}? '
          'They will no longer have access to your shared data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await PartnerSharingService().removePartner(partner.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partner removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing partner: $e'),
            ),
          );
        }
      }
    }
  }

  Future<void> _acceptInvitation(String invitationId) async {
    try {
      final success = await PartnerSharingService().acceptInvitation(invitationId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation accepted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting invitation: $e'),
          ),
        );
      }
    }
  }

  Future<void> _declineInvitation(String invitationId) async {
    try {
      final success = await PartnerSharingService().declineInvitation(invitationId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation declined'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining invitation: $e'),
          ),
        );
      }
    }
  }

  Future<void> _cancelInvitation(String invitationId) async {
    try {
      final success = await PartnerSharingService().cancelInvitation(invitationId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling invitation: $e'),
          ),
        );
      }
    }
  }
}
