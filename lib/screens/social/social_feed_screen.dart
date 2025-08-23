import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/social_models.dart';
import '../../services/social_feed_service.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<FeedPost> _posts = [];
  List<String> _trendingTopics = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFeed();
    _loadTrendingTopics();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final posts = await SocialFeedService.getFeedPosts(
        category: _getSelectedCategory(),
        limit: 20,
      );

      setState(() {
        _posts = posts;
        _hasMore = posts.length == 20;
      });
    } catch (e) {
      debugPrint('Error loading feed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final posts = await SocialFeedService.getFeedPosts(
        category: _getSelectedCategory(),
        offset: _posts.length,
        limit: 10,
      );

      setState(() {
        _posts.addAll(posts);
        _hasMore = posts.length == 10;
      });
    } catch (e) {
      debugPrint('Error loading more posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTrendingTopics() async {
    try {
      final topics = await SocialFeedService.getTrendingTopics();
      setState(() {
        _trendingTopics = topics;
      });
    } catch (e) {
      debugPrint('Error loading trending topics: $e');
    }
  }

  FeedCategory _getSelectedCategory() {
    switch (_tabController.index) {
      case 0:
        return FeedCategory.forYou;
      case 1:
        return FeedCategory.stories;
      case 2:
        return FeedCategory.tips;
      case 3:
        return FeedCategory.support;
      default:
        return FeedCategory.forYou;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text(
              '💫 CycleSync',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.pink, Colors.purple]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreatePostDialog(),
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
          ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: Stack(
              children: [
                Icon(Icons.favorite_border, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _loadFeed(),
          indicatorColor: Colors.pink,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'For You ✨'),
            Tab(text: 'Stories 📖'),
            Tab(text: 'Tips 💡'),
            Tab(text: 'Support 🤗'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Trending Topics Bar
          if (_trendingTopics.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _trendingTopics.length,
                itemBuilder: (context, index) {
                  final topic = _trendingTopics[index];
                  return Container(
                    margin: EdgeInsets.only(
                      left: index == 0 ? 16 : 8,
                      right: 8,
                    ),
                    child: InkWell(
                      onTap: () => _searchTopic(topic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink.withValues(alpha: 0.3),
                              Colors.purple.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.pink.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '#$topic',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Feed Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedContent(),
                _buildFeedContent(),
                _buildFeedContent(),
                _buildFeedContent(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        backgroundColor: Colors.pink,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeedContent() {
    if (_isLoading && _posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.pink),
            const SizedBox(height: 16),
            Text(
              'Loading amazing stories... ✨',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      color: Colors.pink,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.pink),
              ),
            );
          }

          return _buildPostCard(_posts[index]);
        },
      ),
    );
  }

  Widget _buildPostCard(FeedPost post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[900]!, Colors.grey[800]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getAvatarColor(post.userId),
                  child: Text(
                    post.anonymousName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.anonymousName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_formatTimeAgo(post.createdAt)} • ${post.location}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildCategoryChip(post.category),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ),

          // Tags
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags.map((tag) {
                  return Text(
                    '#$tag',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  count: post.likes,
                  color: post.isLiked ? Colors.red : Colors.grey,
                  onTap: () => _toggleLike(post),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  count: post.comments,
                  color: Colors.grey,
                  onTap: () => _showComments(post),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  count: post.shares,
                  color: Colors.grey,
                  onTap: () => _sharePost(post),
                ),
                const Spacer(),
                _buildActionButton(
                  icon: Icons.bookmark_border,
                  count: 0,
                  color: Colors.grey,
                  onTap: () => _bookmarkPost(post),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(FeedCategory category) {
    final colors = {
      FeedCategory.forYou: [Colors.purple, Colors.pink],
      FeedCategory.stories: [Colors.blue, Colors.cyan],
      FeedCategory.tips: [Colors.orange, Colors.yellow],
      FeedCategory.support: [Colors.green, Colors.teal],
    };

    final labels = {
      FeedCategory.forYou: 'For You',
      FeedCategory.stories: 'Story',
      FeedCategory.tips: 'Tip',
      FeedCategory.support: 'Support',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors[category]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        labels[category]!,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Color _getAvatarColor(String userId) {
    final colors = [
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.cyan,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.indigo,
    ];
    return colors[userId.hashCode % colors.length];
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${difference.inDays ~/ 7}w';
    }
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  void _showCreatePostDialog() {
    // Implementation for creating posts
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostSheet(),
    );
  }

  void _searchTopic(String topic) {
    // Implementation for topic search
  }

  void _toggleLike(FeedPost post) async {
    // Implementation for like/unlike
    await SocialFeedService.toggleLike(post.id);
    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
    });
  }

  void _showComments(FeedPost post) {
    // Implementation for comments
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(postId: post.id),
    );
  }

  void _sharePost(FeedPost post) {
    // Implementation for sharing
  }

  void _bookmarkPost(FeedPost post) {
    // Implementation for bookmarking
  }
}

// Supporting widgets and models would be implemented separately
class CreatePostSheet extends StatelessWidget {
  const CreatePostSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Text(
          '✨ Create Post Coming Soon ✨',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class CommentsSheet extends StatelessWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Text(
          '💬 Comments Coming Soon 💬',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
