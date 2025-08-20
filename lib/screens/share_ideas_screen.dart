import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';

class ShareIdeasScreen extends StatefulWidget {
  const ShareIdeasScreen({super.key});

  @override
  State<ShareIdeasScreen> createState() => _ShareIdeasScreenState();
}

class _ShareIdeasScreenState extends State<ShareIdeasScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _ideaController = TextEditingController();
  final _featureController = TextEditingController();
  final _bugController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedCategory = 'Feature Request';
  int _rating = 5;
  bool _isSubmitting = false;
  bool _allowContact = true;
  
  final List<String> _categories = [
    'Feature Request',
    'Bug Report', 
    'UI/UX Improvement',
    'Performance',
    'Health Features',
    'AI Enhancement',
    'Data & Analytics',
    'Social Features',
    'General Feedback'
  ];
  
  final List<Map<String, dynamic>> _quickIdeas = [
    {
      'title': '🎯 AI Mood Predictor',
      'description': 'Predict mood patterns based on cycle phases',
      'category': 'AI Enhancement',
      'votes': 42
    },
    {
      'title': '🏃‍♀️ Exercise Recommendations',
      'description': 'Suggest workouts based on cycle phase and energy levels',
      'category': 'Health Features', 
      'votes': 38
    },
    {
      'title': '📱 Widget Support',
      'description': 'Home screen widget for quick cycle tracking',
      'category': 'Feature Request',
      'votes': 35
    },
    {
      'title': '🍎 Nutrition Tracking',
      'description': 'Track nutrition and correlate with symptoms',
      'category': 'Health Features',
      'votes': 29
    },
    {
      'title': '👥 Partner Notifications',
      'description': 'Discreet notifications to partners about mood/phase',
      'category': 'Social Features',
      'votes': 27
    },
    {
      'title': '🌙 Sleep Pattern Integration',
      'description': 'Deep sleep analysis with cycle correlation',
      'category': 'Health Features',
      'votes': 24
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ideaController.dispose();
    _featureController.dispose();
    _bugController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _emailController.text = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_email', _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.pink.shade400],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Share Your Ideas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.purple.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.purple.shade600,
          tabs: const [
            Tab(icon: Icon(Icons.create), text: 'Submit Idea'),
            Tab(icon: Icon(Icons.trending_up), text: 'Top Ideas'),
            Tab(icon: Icon(Icons.help_outline), text: 'How It Works'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmitTab(),
          _buildTopIdeasTab(),
          _buildHowItWorksTab(),
        ],
      ),
    );
  }

  Widget _buildSubmitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.withOpacity(0.1), Colors.pink.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.lightbulb, size: 48, color: Colors.purple),
                const SizedBox(height: 12),
                const Text(
                  'Got an Amazing Idea?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us make CycleSync even better! Share your ideas, report bugs, or suggest improvements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Category selection
          const Text(
            'Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        _getCategoryIcon(category),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Idea title/summary
          const Text(
            'Title or Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _featureController,
            decoration: InputDecoration(
              hintText: 'Brief description of your idea...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.shade400),
              ),
            ),
            maxLength: 100,
          ),
          
          const SizedBox(height: 16),
          
          // Detailed description
          const Text(
            'Detailed Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ideaController,
            decoration: InputDecoration(
              hintText: 'Describe your idea in detail. How would it work? What problem does it solve?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.shade400),
              ),
            ),
            maxLines: 4,
            maxLength: 500,
          ),
          
          const SizedBox(height: 20),
          
          // Priority rating
          const Text(
            'How important is this to you?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            _getRatingText(_rating),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          
          const SizedBox(height: 24),
          
          // Contact info (optional)
          const Text(
            'Contact Information (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email (for updates)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Allow us to contact you about this idea'),
            subtitle: const Text('Get updates on development progress'),
            value: _allowContact,
            onChanged: (value) => setState(() => _allowContact = value),
          ),
          
          const SizedBox(height: 32),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitIdea,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send),
                        SizedBox(width: 8),
                        Text('Submit Idea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick submit buttons
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickActionChip('🐛 Report Bug', Icons.bug_report, Colors.red),
              _buildQuickActionChip('🎨 UI Suggestion', Icons.palette, Colors.blue),
              _buildQuickActionChip('⚡ Performance', Icons.speed, Colors.orange),
              _buildQuickActionChip('🤖 AI Feature', Icons.psychology, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopIdeasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.trending_up, size: 48, color: Colors.blue),
                const SizedBox(height: 12),
                const Text(
                  'Community\'s Top Ideas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'See what the community is most excited about and vote for your favorites!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Ideas list
          ...List.generate(_quickIdeas.length, (index) {
            final idea = _quickIdeas[index];
            return _buildIdeaCard(idea, index + 1);
          }),
          
          const SizedBox(height: 20),
          
          // Submit your own idea
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.withOpacity(0.1), Colors.pink.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.add_circle, size: 32, color: Colors.purple),
                const SizedBox(height: 8),
                const Text(
                  'Don\'t see your idea?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Submit your own suggestion!',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit Idea'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.info, size: 48, color: Colors.green),
                const SizedBox(height: 12),
                const Text(
                  'How It Works',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn how your ideas help shape the future of CycleSync!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Steps
          _buildStep(1, '💡 Submit Ideas', 
              'Share your feature requests, bug reports, or general feedback through our easy form.'),
          _buildStep(2, '👥 Community Voting', 
              'Other users can vote on ideas they like. Popular ideas get prioritized for development.'),
          _buildStep(3, '🔍 Review Process', 
              'Our development team reviews all submissions and evaluates technical feasibility.'),
          _buildStep(4, '🚀 Development', 
              'Top-voted and feasible ideas get added to our development roadmap.'),
          _buildStep(5, '📱 Release', 
              'New features are released in app updates, and contributors get credited!'),
          
          const SizedBox(height: 24),
          
          // FAQ
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildFAQ('How long does development take?', 
              'Simple features can be implemented in 1-2 weeks, while complex features may take 2-3 months.'),
          _buildFAQ('Will I be notified about my idea?', 
              'Yes! If you provide your email, we\'ll send updates about your idea\'s progress.'),
          _buildFAQ('Can I submit multiple ideas?', 
              'Absolutely! We love hearing lots of creative suggestions from our users.'),
          _buildFAQ('What makes a good suggestion?', 
              'Clear description, specific use case, and explanation of how it would improve the user experience.'),
          
          const SizedBox(height: 24),
          
          // Contact info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.contact_mail, size: 32, color: Colors.blue),
                const SizedBox(height: 12),
                const Text(
                  'Need Direct Support?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'For urgent issues or detailed discussions, contact us directly:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push('/feedback'),
                  icon: const Icon(Icons.message),
                  label: const Text('Direct Feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(Map<String, dynamic> idea, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rank <= 3 ? Colors.amber : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    idea['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    idea['description'],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          idea['category'],
                          style: const TextStyle(
                            color: Colors.purple,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Votes
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      idea['votes'] = (idea['votes'] as int) + 1;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Voted for "${idea['title']}"!'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.thumb_up, color: Colors.green, size: 16),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${idea['votes']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, Color color) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      onPressed: () {
        _quickFillForm(label);
      },
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Feature Request':
        return const Icon(Icons.add_circle, color: Colors.blue);
      case 'Bug Report':
        return const Icon(Icons.bug_report, color: Colors.red);
      case 'UI/UX Improvement':
        return const Icon(Icons.palette, color: Colors.purple);
      case 'Performance':
        return const Icon(Icons.speed, color: Colors.orange);
      case 'Health Features':
        return const Icon(Icons.health_and_safety, color: Colors.green);
      case 'AI Enhancement':
        return const Icon(Icons.psychology, color: Colors.deepPurple);
      case 'Data & Analytics':
        return const Icon(Icons.analytics, color: Colors.indigo);
      case 'Social Features':
        return const Icon(Icons.people, color: Colors.pink);
      default:
        return const Icon(Icons.feedback, color: Colors.grey);
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Nice to have';
      case 2:
        return 'Would be useful';
      case 3:
        return 'Important';
      case 4:
        return 'Very important';
      case 5:
        return 'Essential!';
      default:
        return '';
    }
  }

  void _quickFillForm(String type) {
    setState(() {
      if (type.contains('Bug')) {
        _selectedCategory = 'Bug Report';
        _featureController.text = 'Bug Report: ';
        _ideaController.text = 'I found a bug when... ';
      } else if (type.contains('UI')) {
        _selectedCategory = 'UI/UX Improvement';
        _featureController.text = 'UI Improvement: ';
        _ideaController.text = 'The user interface could be improved by... ';
      } else if (type.contains('Performance')) {
        _selectedCategory = 'Performance';
        _featureController.text = 'Performance Issue: ';
        _ideaController.text = 'The app is slow when... ';
      } else if (type.contains('AI')) {
        _selectedCategory = 'AI Enhancement';
        _featureController.text = 'AI Feature: ';
        _ideaController.text = 'I would love an AI feature that... ';
      }
    });
    _tabController.animateTo(0);
  }

  Future<void> _submitIdea() async {
    if (_featureController.text.isEmpty || _ideaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Save user info for next time
    await _saveUserInfo();

    // Simulate submission
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Idea Submitted!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thank you for your suggestion! Your idea has been submitted to our development team.'),
              const SizedBox(height: 16),
              const Text('What happens next:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• Community voting period (2 weeks)'),
              const Text('• Development team review'),
              const Text('• Implementation (if approved)'),
              if (_allowContact && _emailController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'We\'ll send updates to ${_emailController.text}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _tabController.animateTo(1); // Go to top ideas tab
              },
              child: const Text('View Top Ideas'),
            ),
          ],
        ),
      );

      // Clear form
      _featureController.clear();
      _ideaController.clear();
      setState(() {
        _rating = 5;
        _selectedCategory = 'Feature Request';
      });
    }
  }
}
