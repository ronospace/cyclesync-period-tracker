import 'package:flutter/foundation.dart';

/// Types of social communities/chatrooms
enum CommunityType {
  general,              // General cycle discussion
  ttc,                 // Trying to conceive
  pcos,                // PCOS support
  endometriosis,       // Endometriosis support
  teenagers,           // Teen support
  postpartum,          // Postpartum cycles
  menopause,           // Menopause transition
  birthControl,        // Birth control discussion
  nutrition,           // Diet and nutrition
  fitness,             // Exercise and fitness
  wellness,            // Mental health and wellness
  custom,              // Custom communities
}

/// Community/Chatroom model
class Community {
  final String id;
  final String name;
  final String description;
  final CommunityType type;
  final String? imageUrl;
  final DateTime createdAt;
  final String createdBy;
  final List<String> moderators;
  final int memberCount;
  final bool isPrivate;
  final bool requiresApproval;
  final List<String> tags;
  final Map<String, dynamic>? settings;
  final CommunityStats stats;

  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    required this.createdBy,
    this.moderators = const [],
    this.memberCount = 0,
    this.isPrivate = false,
    this.requiresApproval = false,
    this.tags = const [],
    this.settings,
    this.stats = const CommunityStats(),
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'moderators': moderators,
      'memberCount': memberCount,
      'isPrivate': isPrivate,
      'requiresApproval': requiresApproval,
      'tags': tags,
      'settings': settings,
      'stats': stats.toMap(),
    };
  }

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: CommunityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CommunityType.general,
      ),
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: map['createdBy'] ?? '',
      moderators: List<String>.from(map['moderators'] ?? []),
      memberCount: map['memberCount'] ?? 0,
      isPrivate: map['isPrivate'] ?? false,
      requiresApproval: map['requiresApproval'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      settings: map['settings'],
      stats: CommunityStats.fromMap(map['stats'] ?? {}),
    );
  }

  Community copyWith({
    String? id,
    String? name,
    String? description,
    CommunityType? type,
    String? imageUrl,
    DateTime? createdAt,
    String? createdBy,
    List<String>? moderators,
    int? memberCount,
    bool? isPrivate,
    bool? requiresApproval,
    List<String>? tags,
    Map<String, dynamic>? settings,
    CommunityStats? stats,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      moderators: moderators ?? this.moderators,
      memberCount: memberCount ?? this.memberCount,
      isPrivate: isPrivate ?? this.isPrivate,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      tags: tags ?? this.tags,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
    );
  }
}

/// Community statistics
class CommunityStats {
  final int totalMessages;
  final int activeMembers;
  final DateTime lastActivity;
  final int dailyMessages;
  final double engagementRate;

  const CommunityStats({
    this.totalMessages = 0,
    this.activeMembers = 0,
    DateTime? lastActivity,
    this.dailyMessages = 0,
    this.engagementRate = 0.0,
  }) : lastActivity = lastActivity ?? const DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, dynamic> toMap() {
    return {
      'totalMessages': totalMessages,
      'activeMembers': activeMembers,
      'lastActivity': lastActivity.toIso8601String(),
      'dailyMessages': dailyMessages,
      'engagementRate': engagementRate,
    };
  }

  factory CommunityStats.fromMap(Map<String, dynamic> map) {
    return CommunityStats(
      totalMessages: map['totalMessages'] ?? 0,
      activeMembers: map['activeMembers'] ?? 0,
      lastActivity: map['lastActivity'] != null 
          ? DateTime.parse(map['lastActivity'])
          : DateTime.now(),
      dailyMessages: map['dailyMessages'] ?? 0,
      engagementRate: map['engagementRate']?.toDouble() ?? 0.0,
    );
  }
}

/// Community message model
class CommunityMessage {
  final String id;
  final String communityId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final DateTime? editedAt;
  final List<MessageReaction> reactions;
  final List<String> mentions;
  final String? replyToMessageId;
  final List<MessageAttachment> attachments;
  final bool isDeleted;
  final bool isPinned;
  final Map<String, dynamic>? metadata;

  const CommunityMessage({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.editedAt,
    this.reactions = const [],
    this.mentions = const [],
    this.replyToMessageId,
    this.attachments = const [],
    this.isDeleted = false,
    this.isPinned = false,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'communityId': communityId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'reactions': reactions.map((r) => r.toMap()).toList(),
      'mentions': mentions,
      'replyToMessageId': replyToMessageId,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'metadata': metadata,
    };
  }

  factory CommunityMessage.fromMap(Map<String, dynamic> map) {
    return CommunityMessage(
      id: map['id'] ?? '',
      communityId: map['communityId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      editedAt: map['editedAt'] != null ? DateTime.parse(map['editedAt']) : null,
      reactions: (map['reactions'] as List<dynamic>? ?? [])
          .map((r) => MessageReaction.fromMap(r))
          .toList(),
      mentions: List<String>.from(map['mentions'] ?? []),
      replyToMessageId: map['replyToMessageId'],
      attachments: (map['attachments'] as List<dynamic>? ?? [])
          .map((a) => MessageAttachment.fromMap(a))
          .toList(),
      isDeleted: map['isDeleted'] ?? false,
      isPinned: map['isPinned'] ?? false,
      metadata: map['metadata'],
    );
  }
}

enum MessageType {
  text,
  image,
  poll,
  announcement,
  question,
  celebration,
  support,
}

/// Message reaction (emoji reactions)
class MessageReaction {
  final String emoji;
  final List<String> userIds;
  final int count;

  const MessageReaction({
    required this.emoji,
    required this.userIds,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'emoji': emoji,
      'userIds': userIds,
      'count': count,
    };
  }

  factory MessageReaction.fromMap(Map<String, dynamic> map) {
    return MessageReaction(
      emoji: map['emoji'] ?? '',
      userIds: List<String>.from(map['userIds'] ?? []),
      count: map['count'] ?? 0,
    );
  }
}

/// Message attachment
class MessageAttachment {
  final String id;
  final AttachmentType type;
  final String url;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;

  const MessageAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.fileName,
    this.fileSize,
    this.mimeType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
    };
  }

  factory MessageAttachment.fromMap(Map<String, dynamic> map) {
    return MessageAttachment(
      id: map['id'] ?? '',
      type: AttachmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AttachmentType.image,
      ),
      url: map['url'] ?? '',
      fileName: map['fileName'],
      fileSize: map['fileSize'],
      mimeType: map['mimeType'],
    );
  }
}

enum AttachmentType {
  image,
  video,
  document,
  audio,
}

/// Community membership model
class CommunityMembership {
  final String id;
  final String communityId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final MembershipRole role;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final MembershipStatus status;
  final bool isNotificationsEnabled;
  final Map<String, dynamic>? preferences;

  const CommunityMembership({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.role = MembershipRole.member,
    required this.joinedAt,
    this.lastActiveAt,
    this.status = MembershipStatus.active,
    this.isNotificationsEnabled = true,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'communityId': communityId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'status': status.name,
      'isNotificationsEnabled': isNotificationsEnabled,
      'preferences': preferences,
    };
  }

  factory CommunityMembership.fromMap(Map<String, dynamic> map) {
    return CommunityMembership(
      id: map['id'] ?? '',
      communityId: map['communityId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      role: MembershipRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => MembershipRole.member,
      ),
      joinedAt: DateTime.parse(map['joinedAt'] ?? DateTime.now().toIso8601String()),
      lastActiveAt: map['lastActiveAt'] != null 
          ? DateTime.parse(map['lastActiveAt']) 
          : null,
      status: MembershipStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MembershipStatus.active,
      ),
      isNotificationsEnabled: map['isNotificationsEnabled'] ?? true,
      preferences: map['preferences'],
    );
  }
}

enum MembershipRole {
  member,
  moderator,
  admin,
  founder,
}

enum MembershipStatus {
  active,
  inactive,
  banned,
  left,
  pending,
}

/// App review model
class AppReview {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int rating; // 1-5 stars
  final String? title;
  final String? comment;
  final ReviewCategory? category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final bool isPublic;
  final List<String> helpfulVotes;
  final ReviewStatus status;
  final String? moderatorNote;

  const AppReview({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    this.title,
    this.comment,
    this.category,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.isPublic = true,
    this.helpfulVotes = const [],
    this.status = ReviewStatus.pending,
    this.moderatorNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'title': title,
      'comment': comment,
      'category': category?.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerified': isVerified,
      'isPublic': isPublic,
      'helpfulVotes': helpfulVotes,
      'status': status.name,
      'moderatorNote': moderatorNote,
    };
  }

  factory AppReview.fromMap(Map<String, dynamic> map) {
    return AppReview(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      rating: map['rating'] ?? 0,
      title: map['title'],
      comment: map['comment'],
      category: map['category'] != null 
          ? ReviewCategory.values.firstWhere(
              (e) => e.name == map['category'],
              orElse: () => ReviewCategory.general,
            )
          : null,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isVerified: map['isVerified'] ?? false,
      isPublic: map['isPublic'] ?? true,
      helpfulVotes: List<String>.from(map['helpfulVotes'] ?? []),
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReviewStatus.pending,
      ),
      moderatorNote: map['moderatorNote'],
    );
  }
}

enum ReviewCategory {
  general,
  tracking,
  predictions,
  ui,
  performance,
  support,
  features,
}

enum ReviewStatus {
  pending,
  approved,
  rejected,
  flagged,
}

/// User social profile
class SocialProfile {
  final String userId;
  final String displayName;
  final String? bio;
  final String? photoUrl;
  final DateTime joinedDate;
  final bool isPublic;
  final SocialStats stats;
  final List<String> badges;
  final Map<String, dynamic>? preferences;
  final PrivacySettings privacySettings;

  const SocialProfile({
    required this.userId,
    required this.displayName,
    this.bio,
    this.photoUrl,
    required this.joinedDate,
    this.isPublic = true,
    this.stats = const SocialStats(),
    this.badges = const [],
    this.preferences,
    this.privacySettings = const PrivacySettings(),
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'bio': bio,
      'photoUrl': photoUrl,
      'joinedDate': joinedDate.toIso8601String(),
      'isPublic': isPublic,
      'stats': stats.toMap(),
      'badges': badges,
      'preferences': preferences,
      'privacySettings': privacySettings.toMap(),
    };
  }

  factory SocialProfile.fromMap(Map<String, dynamic> map) {
    return SocialProfile(
      userId: map['userId'] ?? '',
      displayName: map['displayName'] ?? '',
      bio: map['bio'],
      photoUrl: map['photoUrl'],
      joinedDate: DateTime.parse(map['joinedDate'] ?? DateTime.now().toIso8601String()),
      isPublic: map['isPublic'] ?? true,
      stats: SocialStats.fromMap(map['stats'] ?? {}),
      badges: List<String>.from(map['badges'] ?? []),
      preferences: map['preferences'],
      privacySettings: PrivacySettings.fromMap(map['privacySettings'] ?? {}),
    );
  }
}

/// Social statistics for users
class SocialStats {
  final int messagesPosted;
  final int communitiesJoined;
  final int helpfulVotes;
  final int reviewsWritten;
  final double averageRating;
  final DateTime lastActive;

  const SocialStats({
    this.messagesPosted = 0,
    this.communitiesJoined = 0,
    this.helpfulVotes = 0,
    this.reviewsWritten = 0,
    this.averageRating = 0.0,
    DateTime? lastActive,
  }) : lastActive = lastActive ?? const DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, dynamic> toMap() {
    return {
      'messagesPosted': messagesPosted,
      'communitiesJoined': communitiesJoined,
      'helpfulVotes': helpfulVotes,
      'reviewsWritten': reviewsWritten,
      'averageRating': averageRating,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory SocialStats.fromMap(Map<String, dynamic> map) {
    return SocialStats(
      messagesPosted: map['messagesPosted'] ?? 0,
      communitiesJoined: map['communitiesJoined'] ?? 0,
      helpfulVotes: map['helpfulVotes'] ?? 0,
      reviewsWritten: map['reviewsWritten'] ?? 0,
      averageRating: map['averageRating']?.toDouble() ?? 0.0,
      lastActive: map['lastActive'] != null 
          ? DateTime.parse(map['lastActive'])
          : DateTime.now(),
    );
  }
}

/// Privacy settings for social features
class PrivacySettings {
  final bool showProfile;
  final bool showStats;
  final bool allowDirectMessages;
  final bool showOnlineStatus;
  final bool allowMentions;

  const PrivacySettings({
    this.showProfile = true,
    this.showStats = true,
    this.allowDirectMessages = true,
    this.showOnlineStatus = true,
    this.allowMentions = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'showProfile': showProfile,
      'showStats': showStats,
      'allowDirectMessages': allowDirectMessages,
      'showOnlineStatus': showOnlineStatus,
      'allowMentions': allowMentions,
    };
  }

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      showProfile: map['showProfile'] ?? true,
      showStats: map['showStats'] ?? true,
      allowDirectMessages: map['allowDirectMessages'] ?? true,
      showOnlineStatus: map['showOnlineStatus'] ?? true,
      allowMentions: map['allowMentions'] ?? true,
    );
  }
}

/// Community poll model
class CommunityPoll {
  final String id;
  final String communityId;
  final String createdBy;
  final String question;
  final List<PollOption> options;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool allowMultipleChoice;
  final bool isAnonymous;
  final bool isActive;
  final int totalVotes;

  const CommunityPoll({
    required this.id,
    required this.communityId,
    required this.createdBy,
    required this.question,
    required this.options,
    required this.createdAt,
    this.expiresAt,
    this.allowMultipleChoice = false,
    this.isAnonymous = false,
    this.isActive = true,
    this.totalVotes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'communityId': communityId,
      'createdBy': createdBy,
      'question': question,
      'options': options.map((o) => o.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'allowMultipleChoice': allowMultipleChoice,
      'isAnonymous': isAnonymous,
      'isActive': isActive,
      'totalVotes': totalVotes,
    };
  }

  factory CommunityPoll.fromMap(Map<String, dynamic> map) {
    return CommunityPoll(
      id: map['id'] ?? '',
      communityId: map['communityId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      question: map['question'] ?? '',
      options: (map['options'] as List<dynamic>? ?? [])
          .map((o) => PollOption.fromMap(o))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      allowMultipleChoice: map['allowMultipleChoice'] ?? false,
      isAnonymous: map['isAnonymous'] ?? false,
      isActive: map['isActive'] ?? true,
      totalVotes: map['totalVotes'] ?? 0,
    );
  }
}

class PollOption {
  final String id;
  final String text;
  final List<String> voters;
  final int voteCount;

  const PollOption({
    required this.id,
    required this.text,
    this.voters = const [],
    this.voteCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'voters': voters,
      'voteCount': voteCount,
    };
  }

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      voters: List<String>.from(map['voters'] ?? []),
      voteCount: map['voteCount'] ?? 0,
    );
  }
}

/// Default community templates
class CommunityTemplates {
  static final List<Community> defaultCommunities = [
    Community(
      id: 'general',
      name: 'General Discussion',
      description: 'Open discussion about menstrual health, cycles, and experiences',
      type: CommunityType.general,
      createdAt: DateTime(2024, 1, 1),
      createdBy: 'system',
      tags: const ['general', 'discussion', 'support'],
      stats: const CommunityStats(),
    ),
    Community(
      id: 'ttc',
      name: 'Trying to Conceive',
      description: 'Support and discussion for those trying to conceive',
      type: CommunityType.ttc,
      createdAt: DateTime(2024, 1, 1),
      createdBy: 'system',
      tags: const ['ttc', 'fertility', 'pregnancy'],
      stats: const CommunityStats(),
    ),
    Community(
      id: 'pcos',
      name: 'PCOS Support',
      description: 'Community for those with PCOS to share experiences and support',
      type: CommunityType.pcos,
      createdAt: DateTime(2024, 1, 1),
      createdBy: 'system',
      tags: const ['pcos', 'hormonal', 'support'],
      stats: const CommunityStats(),
    ),
    Community(
      id: 'teens',
      name: 'Teen Support',
      description: 'A safe space for teenagers to learn and discuss menstrual health',
      type: CommunityType.teenagers,
      createdAt: DateTime(2024, 1, 1),
      createdBy: 'system',
      tags: const ['teens', 'education', 'first-period'],
      stats: const CommunityStats(),
    ),
  ];
}
