import 'dart:math';
import '../models/social_models.dart';

/// Service for managing Gen Z/Millennial social feed functionality
class SocialFeedService {
  static const List<String> _anonymousNames = [
    'CycleQueen',
    'FlowGuru',
    'PeriodPower',
    'MoonChild',
    'WellnessWave',
    'CycleSync',
    'FlowFree',
    'PinkPower',
    'MoonMagic',
    'FlowVibes',
    'CycleStar',
    'PeriodPro',
    'FlowFriend',
    'MoonBeam',
    'WellnessWin',
    'CycleSage',
    'FlowFab',
    'PeriodPal',
    'MoonGlow',
    'WellnessWiz',
    'CycleChamp',
    'FlowFinesse',
    'PeriodPrincess',
    'MoonRise',
    'WellnessWin',
  ];

  static const List<String> _globalLocations = [
    'Global',
    'North America',
    'Europe',
    'Asia',
    'Australia',
    'Africa',
    'South America',
    'Anonymous',
    'Worldwide',
  ];

  static const List<String> _trendingTopics = [
    'periodflu',
    'cyclehacks',
    'pms',
    'periodpositivity',
    'flowfriendly',
    'cyclescience',
    'periodpower',
    'menstrualtips',
    'cyclecare',
    'periodlife',
    'flowvibes',
    'cyclefacts',
    'periodstories',
    'menstrualhealth',
    'cyclewise',
    'periodproblems',
    'flowsupport',
    'cyclecommunity',
    'periodboss',
    'flowstrong',
  ];

  static final Map<FeedCategory, List<Map<String, dynamic>>> _samplePosts = {
    FeedCategory.forYou: [
      {
        'content':
            'Just discovered that dark chocolate actually helps with cramps! 🍫 My period pain went from a 7 to a 3 after eating some. Anyone else experience this magic?',
        'tags': ['chocolate', 'cramps', 'periodpain', 'lifehack'],
        'likes': 247,
        'comments': 42,
        'shares': 18,
      },
      {
        'content':
            'PSA: Your period coming early when you\'re stressed is completely normal! Your body is just responding to cortisol levels. Be kind to yourself ❤️',
        'tags': ['stress', 'periodfacts', 'selfcare', 'mentalhealth'],
        'likes': 189,
        'comments': 28,
        'shares': 35,
      },
      {
        'content':
            'Anyone else get super emotional the day before their period starts? Like I literally cried watching a dog video yesterday 😅',
        'tags': ['pms', 'emotions', 'relatable', 'periodlife'],
        'likes': 156,
        'comments': 67,
        'shares': 12,
      },
    ],
    FeedCategory.stories: [
      {
        'content':
            'Story time: I got my first period at a friend\'s sleepover and was mortified. Now I realize how normal and beautiful it is. Sharing for anyone feeling embarrassed ✨',
        'tags': ['firstperiod', 'periodstories', 'confidence', 'growth'],
        'likes': 312,
        'comments': 89,
        'shares': 45,
      },
      {
        'content':
            'My mom never talked to me about periods, so I\'m breaking the cycle. Had the most beautiful conversation with my little sister about menstruation today 💕',
        'tags': ['periodsupport', 'family', 'education', 'breaking cycles'],
        'likes': 428,
        'comments': 156,
        'shares': 78,
      },
    ],
    FeedCategory.tips: [
      {
        'content':
            'Period hack: Track your mood alongside your cycle! I noticed I\'m most creative during ovulation and most introspective during my period 🎨',
        'tags': ['tracking', 'cyclehacks', 'productivity', 'selfawareness'],
        'likes': 203,
        'comments': 34,
        'shares': 56,
      },
      {
        'content':
            'Heat pad alternative: Fill a clean sock with rice, tie it off, and microwave for 1-2 minutes. Instant heat therapy! 🧦',
        'tags': ['diy', 'cramprelief', 'budgetfriendly', 'lifehack'],
        'likes': 178,
        'comments': 23,
        'shares': 41,
      },
    ],
    FeedCategory.support: [
      {
        'content':
            'To anyone struggling with irregular periods: you\'re not alone. It took me 2 years to find the right doctor who listened. Keep advocating for yourself 💪',
        'tags': ['irregularperiods', 'healthcare', 'advocacy', 'support'],
        'likes': 267,
        'comments': 45,
        'shares': 33,
      },
      {
        'content':
            'Reminder: Period poverty is real. If you can afford to, donate pads/tampons to local shelters. Let\'s support each other 🤝',
        'tags': ['periodpoverty', 'community', 'donation', 'activism'],
        'likes': 145,
        'comments': 19,
        'shares': 28,
      },
    ],
  };

  /// Get trending topics for the current period
  static Future<List<String>> getTrendingTopics() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call

    final random = Random();
    final topics = <String>[];
    final shuffledTopics = List.from(_trendingTopics)..shuffle(random);

    // Return 5-8 trending topics
    final count = 5 + random.nextInt(4);
    for (int i = 0; i < count && i < shuffledTopics.length; i++) {
      topics.add(shuffledTopics[i]);
    }

    return topics;
  }

  /// Get feed posts based on category
  static Future<List<FeedPost>> getFeedPosts({
    required FeedCategory category,
    int limit = 20,
    int offset = 0,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulate API call

    final random = Random();
    final posts = <FeedPost>[];
    final categoryPosts =
        _samplePosts[category] ?? _samplePosts[FeedCategory.forYou]!;

    // Generate posts with some randomization
    for (int i = offset; i < offset + limit && posts.length < limit; i++) {
      final postIndex = i % categoryPosts.length;
      final postData = categoryPosts[postIndex];

      final post = FeedPost(
        id: 'post_${category.name}_$i',
        userId: 'user_${random.nextInt(1000)}',
        anonymousName: _anonymousNames[random.nextInt(_anonymousNames.length)],
        content: postData['content'] as String,
        category: category,
        tags: List<String>.from(postData['tags']),
        location: _globalLocations[random.nextInt(_globalLocations.length)],
        createdAt: DateTime.now().subtract(
          Duration(
            hours: random.nextInt(72), // Posts from last 3 days
            minutes: random.nextInt(60),
          ),
        ),
        likes: (postData['likes'] as int) + random.nextInt(50) - 25,
        comments: (postData['comments'] as int) + random.nextInt(20) - 10,
        shares: (postData['shares'] as int) + random.nextInt(10) - 5,
        isLiked: random.nextBool(),
      );

      posts.add(post);
    }

    return posts;
  }

  /// Toggle like on a post
  static Future<void> toggleLike(String postId) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate API call
    // In real implementation, this would update the database
  }

  /// Get comments for a post
  static Future<List<Comment>> getComments(
    String postId, {
    int limit = 50,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // Simulate API call

    final random = Random();
    final comments = <Comment>[];

    final sampleComments = [
      'This is so helpful! Thank you for sharing 💕',
      'OMG yes! I thought I was the only one',
      'Adding this to my period toolkit 🛠️',
      'Thank you for normalizing this conversation',
      'Sending virtual hugs! 🤗',
      'This needs more visibility!',
      'Bookmarking this for later ⭐',
      'You\'re amazing for sharing this',
      'This made my day better ❤️',
      'So relatable! Thanks for posting',
    ];

    final commentCount = random.nextInt(8) + 2; // 2-10 comments
    for (int i = 0; i < commentCount; i++) {
      final comment = Comment(
        id: 'comment_${postId}_$i',
        postId: postId,
        userId: 'user_${random.nextInt(1000)}',
        anonymousName: _anonymousNames[random.nextInt(_anonymousNames.length)],
        content: sampleComments[random.nextInt(sampleComments.length)],
        createdAt: DateTime.now().subtract(
          Duration(
            minutes: random.nextInt(1440), // Comments from last 24 hours
          ),
        ),
        likes: random.nextInt(15),
        isLiked: random.nextBool(),
      );
      comments.add(comment);
    }

    // Sort by creation time (newest first)
    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return comments;
  }

  /// Create a new post
  static Future<FeedPost?> createPost({
    required String content,
    required FeedCategory category,
    required List<String> tags,
    bool isAnonymous = true,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 1000),
    ); // Simulate API call

    if (content.trim().isEmpty) {
      throw Exception('Post content cannot be empty');
    }

    final random = Random();

    final post = FeedPost(
      id: 'post_new_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      anonymousName: isAnonymous
          ? _anonymousNames[random.nextInt(_anonymousNames.length)]
          : 'You',
      content: content,
      category: category,
      tags: tags,
      location: 'Your Location',
      createdAt: DateTime.now(),
      likes: 0,
      comments: 0,
      shares: 0,
      isLiked: false,
    );

    return post;
  }

  /// Report a post
  static Future<void> reportPost(String postId, String reason) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call
    // In real implementation, this would flag the post for review
  }

  /// Block a user
  static Future<void> blockUser(String userId) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate API call
    // In real implementation, this would add user to blocked list
  }

  /// Get user's own posts
  static Future<List<FeedPost>> getMyPosts({int limit = 20}) async {
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // Simulate API call

    // Return empty list for now - in real implementation would fetch user's posts
    return [];
  }

  /// Search posts by hashtag or content
  static Future<List<FeedPost>> searchPosts(
    String query, {
    int limit = 20,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 900),
    ); // Simulate API call

    // Simple simulation - return some matching posts
    final allPosts = <FeedPost>[];

    for (final category in FeedCategory.values) {
      final posts = await getFeedPosts(category: category, limit: 5);
      allPosts.addAll(posts);
    }

    // Filter posts that match the query
    final matchingPosts = allPosts.where((post) {
      return post.content.toLowerCase().contains(query.toLowerCase()) ||
          post.tags.any(
            (tag) => tag.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();

    return matchingPosts.take(limit).toList();
  }
}

/// Comment model for posts
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String anonymousName;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.anonymousName,
    required this.content,
    required this.createdAt,
    required this.likes,
    this.isLiked = false,
  });
}
