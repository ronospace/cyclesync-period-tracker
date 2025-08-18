import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/social_service.dart';
import '../../models/social_models.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_overlay.dart';

// Import dialog files
import 'dialogs/share_data_dialog.dart';
import 'dialogs/create_provider_access_dialog.dart';
import 'dialogs/join_community_dialog.dart';
import 'dialogs/additional_dialogs.dart';

class SocialSharingScreen extends StatefulWidget {
  const SocialSharingScreen({super.key});

  @override
  State<SocialSharingScreen> createState() => _SocialSharingScreenState();
}

class _SocialSharingScreenState extends State<SocialSharingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  MySharedDataResult? _mySharedData;
  CommunityInsightResult? _communityInsights;
  bool _isLoading = true;
  bool _communityParticipant = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final [sharedData, insights] = await Future.wait([
        SocialService.getMySharedData(),
        SocialService.generateCommunityInsights(),
      ]);

      setState(() {
        _mySharedData = sharedData as MySharedDataResult;
        _communityInsights = insights as CommunityInsightResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Social & Sharing',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.share), text: 'My Shares'),
            Tab(icon: Icon(Icons.add_circle), text: 'Share Data'),
            Tab(icon: Icon(Icons.insights), text: 'Community'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMySharesTab(),
            _buildShareDataTab(),
            _buildCommunityTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMySharesTab() {
    if (_mySharedData == null || !_mySharedData!.success) {
      return const Center(
        child: Text('Unable to load shared data'),
      );
    }

    final activeShares = _mySharedData!.activeShares ?? [];
    final expiredShares = _mySharedData!.expiredShares ?? [];
    final providerAccess = _mySharedData!.providerAccess ?? [];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCard(),
          const SizedBox(height: 16),
          
          if (activeShares.isNotEmpty) ...[
            _buildSectionHeader('Active Shares', Icons.share, activeShares.length),
            ...activeShares.map((share) => _buildShareCard(share)),
            const SizedBox(height: 16),
          ],
          
          if (providerAccess.isNotEmpty) ...[
            _buildSectionHeader('Provider Access', Icons.local_hospital, providerAccess.length),
            ...providerAccess.map((access) => _buildProviderAccessCard(access)),
            const SizedBox(height: 16),
          ],
          
          if (expiredShares.isNotEmpty) ...[
            _buildSectionHeader('Expired Shares', Icons.history, expiredShares.length),
            ...expiredShares.map((share) => _buildShareCard(share, isExpired: true)),
          ],
          
          if (activeShares.isEmpty && expiredShares.isEmpty && providerAccess.isEmpty)
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalShares = _mySharedData?.totalShares ?? 0;
    final activeCount = _mySharedData?.activeShares?.length ?? 0;
    final providerCount = _mySharedData?.providerAccess?.length ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Sharing Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(totalShares.toString(), 'Total Shares', Icons.share),
                _buildStatItem(activeCount.toString(), 'Active', Icons.check_circle),
                _buildStatItem(providerCount.toString(), 'Providers', Icons.local_hospital),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Chip(
            label: Text('$count'),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard(ShareSummary share, {bool isExpired = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpired 
              ? Colors.grey 
              : Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            isExpired ? Icons.history : Icons.share,
            color: isExpired ? Colors.grey : Theme.of(context).primaryColor,
          ),
        ),
        title: Text(share.providerEmail),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${share.dataTypes.join(', ')}'),
            Text(
              '${share.timeRemaining} • Accessed ${share.accessCount} times',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (share.isActive)
              const PopupMenuItem(
                value: 'revoke',
                child: ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Revoke Access'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'details',
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('View Details'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) => _handleShareAction(value.toString(), share),
        ),
      ),
    );
  }

  Widget _buildProviderAccessCard(ProviderAccessSummary access) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.local_hospital,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(access.providerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(access.providerTypeDisplayName),
            Text(
              'Granted ${_formatDate(access.grantedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Chip(
          label: Text(access.status.toUpperCase()),
          backgroundColor: access.isActive 
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildShareDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickShareOptions(),
          const SizedBox(height: 24),
          _buildProviderAccessSection(),
          const SizedBox(height: 24),
          _buildShareWithPartnerSection(),
        ],
      ),
    );
  }

  Widget _buildQuickShareOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Quick Share',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showShareDialog(ShareType.healthcare),
                    icon: const Icon(Icons.local_hospital),
                    label: const Text('Healthcare\nProvider'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showShareDialog(ShareType.partner),
                    icon: const Icon(Icons.favorite),
                    label: const Text('Partner'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderAccessSection() {
    return Card(
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
              onPressed: () => _showProviderAccessDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create Provider Access'),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareWithPartnerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Partner Sharing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          const SizedBox(height: 12),
          const Text(
            'Share your cycle information with your partner for better understanding and support.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showPartnerSharingDialog(),
              icon: const Icon(Icons.share),
              label: const Text('Share with Partner'),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommunityParticipationCard(),
          const SizedBox(height: 16),
          if (_communityInsights?.success == true) ...[
            _buildCommunityInsightsCard(),
            const SizedBox(height: 16),
          ],
          _buildPrivacyInfoCard(),
        ],
      ),
    );
  }

  Widget _buildCommunityParticipationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Community Participation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            _communityParticipant
                ? 'You are contributing to community insights. Thank you!'
                : 'Join thousands of users contributing anonymous data to help improve menstrual health understanding.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _communityParticipant
                    ? OutlinedButton.icon(
                        onPressed: () => _showCommunityPreferencesDialog(),
                        icon: const Icon(Icons.settings),
                        label: const Text('Manage Preferences'),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _showJoinCommunityDialog(),
                        icon: const Icon(Icons.add_circle),
                        label: const Text('Join Community'),
                      ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityInsightsCard() {
    final insights = _communityInsights!.insights!;
    final participantCount = (_communityInsights as dynamic)?.participantCount ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Community Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            'Based on $participantCount anonymous participants',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => _buildInsightItem(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(CommunityInsight insight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            (insight as dynamic).value ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            insight.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyInfoCard() {
    return Card(
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.share,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Shared Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by sharing your cycle data with a healthcare provider or partner.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.add),
              label: const Text('Share Data'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog methods
  void _showShareDialog(ShareType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareDataDialog(type: type),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadData());
  }

  void _showProviderAccessDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateProviderAccessDialog(),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadData());
  }

  void _showPartnerSharingDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PartnerSharingDialog(),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadData());
  }

  void _showJoinCommunityDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JoinCommunityDialog(),
        fullscreenDialog: true,
      ),
    ).then((result) {
      if (result == true) {
        setState(() => _communityParticipant = true);
        _loadData();
      }
    });
  }

  void _showCommunityPreferencesDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommunityPreferencesDialog(),
        fullscreenDialog: true,
      ),
    );
  }

  void _handleShareAction(String action, ShareSummary share) async {
    switch (action) {
      case 'revoke':
        final confirmed = await _showRevokeConfirmation(share.providerEmail);
        if (confirmed == true) {
          final success = await SocialService.revokeAccess(share.shareId);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access revoked successfully')),
            );
            _loadData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to revoke access')),
            );
          }
        }
        break;
      case 'details':
        _showShareDetails(share);
        break;
    }
  }

  Future<bool?> _showRevokeConfirmation(String providerEmail) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Access'),
        content: Text(
          'Are you sure you want to revoke access for $providerEmail? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke Access'),
          ),
        ],
      ),
    );
  }

  void _showShareDetails(ShareSummary share) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ShareDetailsSheet(share: share),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

