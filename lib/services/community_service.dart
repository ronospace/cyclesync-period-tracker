import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../models/community_models.dart';
import 'notification_service.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Collections
  static const String _communitiesCollection = 'communities';
  static const String _messagesCollection = 'messages';
  static const String _membershipsCollection = 'memberships';
  static const String _reviewsCollection = 'reviews';
  static const String _profilesCollection = 'social_profiles';
  static const String _pollsCollection = 'polls';

  /// Initialize default communities
  Future<void> initializeDefaultCommunities() async {
    try {
      for (final community in CommunityTemplates.defaultCommunities) {
        final doc = await _firestore
            .collection(_communitiesCollection)
            .doc(community.id)
            .get();

        if (!doc.exists) {
          await _firestore
              .collection(_communitiesCollection)
              .doc(community.id)
              .set(community.toMap());
        }
      }
    } catch (e) {
      debugPrint('Error initializing default communities: $e');
      rethrow;
    }
  }

  /// Get all available communities
  Stream<List<Community>> getCommunitiesStream() {
    return _firestore
        .collection(_communitiesCollection)
        .orderBy('memberCount', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Community.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Get user's joined communities
  Stream<List<Community>> getUserCommunitiesStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_membershipsCollection)
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: MembershipStatus.active.name)
        .snapshots()
        .asyncMap((snapshot) async {
          final communityIds = snapshot.docs
              .map((doc) => doc.data()['communityId'] as String)
              .toList();

          if (communityIds.isEmpty) return <Community>[];

          final communitiesSnapshot = await _firestore
              .collection(_communitiesCollection)
              .where(FieldPath.documentId, whereIn: communityIds)
              .get();

          return communitiesSnapshot.docs
              .map((doc) => Community.fromMap(doc.data()))
              .toList();
        });
  }

  /// Join a community
  Future<bool> joinCommunity(String communityId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      // Check if already a member
      final existingMembership = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: currentUserId)
          .where('communityId', isEqualTo: communityId)
          .get();

      if (existingMembership.docs.isNotEmpty) {
        final membership = CommunityMembership.fromMap(
          existingMembership.docs.first.data(),
        );

        if (membership.status == MembershipStatus.active) {
          return true; // Already a member
        }

        // Reactivate membership
        await _firestore
            .collection(_membershipsCollection)
            .doc(existingMembership.docs.first.id)
            .update({
              'status': MembershipStatus.active.name,
              'joinedAt': DateTime.now().toIso8601String(),
            });
      } else {
        // Create new membership
        final user = _auth.currentUser!;
        final membership = CommunityMembership(
          id: '',
          communityId: communityId,
          userId: currentUserId!,
          userName: user.displayName ?? 'Anonymous',
          userPhotoUrl: user.photoURL,
          joinedAt: DateTime.now(),
        );

        await _firestore
            .collection(_membershipsCollection)
            .add(membership.toMap());
      }

      // Update community member count
      await _firestore
          .collection(_communitiesCollection)
          .doc(communityId)
          .update({'memberCount': FieldValue.increment(1)});

      return true;
    } catch (e) {
      debugPrint('Error joining community: $e');
      return false;
    }
  }

  /// Leave a community
  Future<bool> leaveCommunity(String communityId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final membership = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: currentUserId)
          .where('communityId', isEqualTo: communityId)
          .get();

      if (membership.docs.isEmpty) return false;

      await _firestore
          .collection(_membershipsCollection)
          .doc(membership.docs.first.id)
          .update({'status': MembershipStatus.left.name});

      // Update community member count
      await _firestore
          .collection(_communitiesCollection)
          .doc(communityId)
          .update({'memberCount': FieldValue.increment(-1)});

      return true;
    } catch (e) {
      debugPrint('Error leaving community: $e');
      return false;
    }
  }

  /// Get messages from a community
  Stream<List<CommunityMessage>> getMessagesStream(
    String communityId, {
    int limit = 50,
  }) {
    return _firestore
        .collection(_messagesCollection)
        .where('communityId', isEqualTo: communityId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityMessage.fromMap(doc.data()))
              .toList()
              .reversed
              .toList(),
        );
  }

  /// Send a message to a community
  Future<bool> sendMessage({
    required String communityId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    List<File>? attachments,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (content.trim().isEmpty && (attachments?.isEmpty ?? true)) return false;

    try {
      final user = _auth.currentUser!;
      final messageId = _firestore.collection(_messagesCollection).doc().id;

      // Upload attachments if any
      final List<MessageAttachment> uploadedAttachments = [];
      if (attachments != null && attachments.isNotEmpty) {
        for (int i = 0; i < attachments.length; i++) {
          final file = attachments[i];
          final fileName = '${messageId}_attachment_$i';
          final ref = _storage
              .ref()
              .child('message_attachments')
              .child(communityId)
              .child(fileName);

          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          uploadedAttachments.add(
            MessageAttachment(
              id: fileName,
              type: _getAttachmentTypeFromPath(file.path),
              url: downloadUrl,
              fileName: file.path.split('/').last,
              fileSize: await file.length(),
            ),
          );
        }
      }

      final message = CommunityMessage(
        id: messageId,
        communityId: communityId,
        userId: currentUserId!,
        userName: user.displayName ?? 'Anonymous',
        userPhotoUrl: user.photoURL,
        content: content.trim(),
        type: type,
        timestamp: DateTime.now(),
        replyToMessageId: replyToMessageId,
        attachments: uploadedAttachments,
      );

      await _firestore
          .collection(_messagesCollection)
          .doc(messageId)
          .set(message.toMap());

      // Update community stats
      await _firestore
          .collection(_communitiesCollection)
          .doc(communityId)
          .update({
            'stats.totalMessages': FieldValue.increment(1),
            'stats.dailyMessages': FieldValue.increment(1),
            'stats.lastActivity': DateTime.now().toIso8601String(),
          });

      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  /// React to a message
  Future<bool> reactToMessage(String messageId, String emoji) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final messageDoc = await _firestore
          .collection(_messagesCollection)
          .doc(messageId)
          .get();

      if (!messageDoc.exists) return false;

      final message = CommunityMessage.fromMap(messageDoc.data()!);
      final reactions = List<MessageReaction>.from(message.reactions);

      // Find existing reaction with same emoji
      final existingReactionIndex = reactions.indexWhere(
        (reaction) => reaction.emoji == emoji,
      );

      if (existingReactionIndex != -1) {
        final existingReaction = reactions[existingReactionIndex];
        final userIds = List<String>.from(existingReaction.userIds);

        if (userIds.contains(currentUserId)) {
          // Remove user's reaction
          userIds.remove(currentUserId);
          if (userIds.isEmpty) {
            reactions.removeAt(existingReactionIndex);
          } else {
            reactions[existingReactionIndex] = MessageReaction(
              emoji: emoji,
              userIds: userIds,
              count: userIds.length,
            );
          }
        } else {
          // Add user's reaction
          userIds.add(currentUserId!);
          reactions[existingReactionIndex] = MessageReaction(
            emoji: emoji,
            userIds: userIds,
            count: userIds.length,
          );
        }
      } else {
        // Create new reaction
        reactions.add(
          MessageReaction(emoji: emoji, userIds: [currentUserId!], count: 1),
        );
      }

      await _firestore.collection(_messagesCollection).doc(messageId).update({
        'reactions': reactions.map((r) => r.toMap()).toList(),
      });

      return true;
    } catch (e) {
      debugPrint('Error reacting to message: $e');
      return false;
    }
  }

  /// Create a custom community
  Future<String?> createCommunity({
    required String name,
    required String description,
    required CommunityType type,
    bool isPrivate = false,
    bool requiresApproval = false,
    List<String> tags = const [],
    File? imageFile,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final communityId = _firestore
          .collection(_communitiesCollection)
          .doc()
          .id;
      String? imageUrl;

      // Upload community image if provided
      if (imageFile != null) {
        final ref = _storage.ref().child('community_images').child(communityId);

        final uploadTask = ref.putFile(imageFile);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final community = Community(
        id: communityId,
        name: name,
        description: description,
        type: type,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        createdBy: currentUserId!,
        moderators: [currentUserId!],
        isPrivate: isPrivate,
        requiresApproval: requiresApproval,
        tags: tags,
      );

      await _firestore
          .collection(_communitiesCollection)
          .doc(communityId)
          .set(community.toMap());

      // Auto-join creator as founder
      final user = _auth.currentUser!;
      final membership = CommunityMembership(
        id: '',
        communityId: communityId,
        userId: currentUserId!,
        userName: user.displayName ?? 'Anonymous',
        userPhotoUrl: user.photoURL,
        role: MembershipRole.founder,
        joinedAt: DateTime.now(),
      );

      await _firestore
          .collection(_membershipsCollection)
          .add(membership.toMap());

      return communityId;
    } catch (e) {
      debugPrint('Error creating community: $e');
      return null;
    }
  }

  /// Submit an app review
  Future<bool> submitReview({
    required int rating,
    String? title,
    String? comment,
    ReviewCategory? category,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (rating < 1 || rating > 5) throw Exception('Rating must be 1-5');

    try {
      // Check if user already has a review
      final existingReview = await _firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: currentUserId)
          .get();

      final user = _auth.currentUser!;

      if (existingReview.docs.isNotEmpty) {
        // Update existing review
        final reviewId = existingReview.docs.first.id;
        await _firestore.collection(_reviewsCollection).doc(reviewId).update({
          'rating': rating,
          'title': title,
          'comment': comment,
          'category': category?.name,
          'updatedAt': DateTime.now().toIso8601String(),
          'status': ReviewStatus.pending.name,
        });
      } else {
        // Create new review
        final review = AppReview(
          id: '',
          userId: currentUserId!,
          userName: user.displayName ?? 'Anonymous',
          userPhotoUrl: user.photoURL,
          rating: rating,
          title: title,
          comment: comment,
          category: category,
          createdAt: DateTime.now(),
        );

        await _firestore.collection(_reviewsCollection).add(review.toMap());
      }

      return true;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return false;
    }
  }

  /// Get app reviews
  Stream<List<AppReview>> getReviewsStream({
    ReviewStatus? status,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_reviewsCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => AppReview.fromMap(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Mark review as helpful
  Future<bool> markReviewHelpful(String reviewId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final reviewDoc = await _firestore
          .collection(_reviewsCollection)
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) return false;

      final review = AppReview.fromMap(reviewDoc.data()!);
      final helpfulVotes = List<String>.from(review.helpfulVotes);

      if (helpfulVotes.contains(currentUserId)) {
        helpfulVotes.remove(currentUserId);
      } else {
        helpfulVotes.add(currentUserId!);
      }

      await _firestore.collection(_reviewsCollection).doc(reviewId).update({
        'helpfulVotes': helpfulVotes,
      });

      return true;
    } catch (e) {
      debugPrint('Error marking review as helpful: $e');
      return false;
    }
  }

  /// Get or create user social profile
  Future<SocialProfile> getUserProfile([String? userId]) async {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) throw Exception('No user ID provided');

    try {
      final profileDoc = await _firestore
          .collection(_profilesCollection)
          .doc(targetUserId)
          .get();

      if (profileDoc.exists) {
        return SocialProfile.fromMap(profileDoc.data()!);
      }

      // Create default profile
      final user = userId == null ? _auth.currentUser : null;
      final profile = SocialProfile(
        userId: targetUserId,
        displayName: user?.displayName ?? 'Anonymous',
        photoUrl: user?.photoURL,
        joinedDate: DateTime.now(),
      );

      await _firestore
          .collection(_profilesCollection)
          .doc(targetUserId)
          .set(profile.toMap());

      return profile;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Update user social profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? bio,
    bool? isPublic,
    PrivacySettings? privacySettings,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (isPublic != null) updates['isPublic'] = isPublic;
      if (privacySettings != null) {
        updates['privacySettings'] = privacySettings.toMap();
      }

      if (updates.isEmpty) return false;

      await _firestore
          .collection(_profilesCollection)
          .doc(currentUserId)
          .update(updates);

      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  /// Create a poll in a community
  Future<String?> createPoll({
    required String communityId,
    required String question,
    required List<String> options,
    DateTime? expiresAt,
    bool allowMultipleChoice = false,
    bool isAnonymous = false,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (options.length < 2)
      throw Exception('Poll must have at least 2 options');

    try {
      final pollId = _firestore.collection(_pollsCollection).doc().id;

      final pollOptions = options
          .asMap()
          .entries
          .map(
            (entry) => PollOption(id: entry.key.toString(), text: entry.value),
          )
          .toList();

      final poll = CommunityPoll(
        id: pollId,
        communityId: communityId,
        createdBy: currentUserId!,
        question: question,
        options: pollOptions,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        allowMultipleChoice: allowMultipleChoice,
        isAnonymous: isAnonymous,
      );

      await _firestore
          .collection(_pollsCollection)
          .doc(pollId)
          .set(poll.toMap());

      // Send poll as message
      await sendMessage(
        communityId: communityId,
        content: '📊 $question',
        type: MessageType.poll,
      );

      return pollId;
    } catch (e) {
      debugPrint('Error creating poll: $e');
      return null;
    }
  }

  /// Vote in a poll
  Future<bool> voteInPoll(String pollId, List<String> optionIds) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final pollDoc = await _firestore
          .collection(_pollsCollection)
          .doc(pollId)
          .get();

      if (!pollDoc.exists) return false;

      final poll = CommunityPoll.fromMap(pollDoc.data()!);

      if (!poll.isActive) return false;
      if (poll.expiresAt != null && DateTime.now().isAfter(poll.expiresAt!)) {
        return false;
      }

      final updatedOptions = List<PollOption>.from(poll.options);

      // Remove user's previous votes
      for (int i = 0; i < updatedOptions.length; i++) {
        final voters = List<String>.from(updatedOptions[i].voters);
        if (voters.contains(currentUserId)) {
          voters.remove(currentUserId);
          updatedOptions[i] = PollOption(
            id: updatedOptions[i].id,
            text: updatedOptions[i].text,
            voters: voters,
            voteCount: voters.length,
          );
        }
      }

      // Add new votes
      for (final optionId in optionIds) {
        final optionIndex = updatedOptions.indexWhere((o) => o.id == optionId);
        if (optionIndex != -1) {
          final voters = List<String>.from(updatedOptions[optionIndex].voters);
          voters.add(currentUserId!);
          updatedOptions[optionIndex] = PollOption(
            id: updatedOptions[optionIndex].id,
            text: updatedOptions[optionIndex].text,
            voters: voters,
            voteCount: voters.length,
          );
        }

        if (!poll.allowMultipleChoice) break;
      }

      final totalVotes = updatedOptions.fold<int>(
        0,
        (sum, option) => sum + option.voteCount,
      );

      await _firestore.collection(_pollsCollection).doc(pollId).update({
        'options': updatedOptions.map((o) => o.toMap()).toList(),
        'totalVotes': totalVotes,
      });

      return true;
    } catch (e) {
      debugPrint('Error voting in poll: $e');
      return false;
    }
  }

  /// Search communities
  Future<List<Community>> searchCommunities(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final queryLower = query.toLowerCase();

      // Search by name (Firestore text search is limited)
      final nameResults = await _firestore
          .collection(_communitiesCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .get();

      // Search by tags
      final tagResults = await _firestore
          .collection(_communitiesCollection)
          .where('tags', arrayContains: queryLower)
          .get();

      final communities = <String, Community>{};

      for (final doc in [...nameResults.docs, ...tagResults.docs]) {
        final community = Community.fromMap(doc.data());
        communities[community.id] = community;
      }

      return communities.values.toList();
    } catch (e) {
      debugPrint('Error searching communities: $e');
      return [];
    }
  }

  /// Clean up expired content
  Future<void> cleanupExpiredContent() async {
    try {
      final now = DateTime.now();

      // Expire old polls
      final expiredPolls = await _firestore
          .collection(_pollsCollection)
          .where('expiresAt', isLessThan: now.toIso8601String())
          .where('isActive', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in expiredPolls.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error cleaning up expired content: $e');
    }
  }

  /// Helper method to determine attachment type from file path
  AttachmentType _getAttachmentTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return AttachmentType.image;
    } else if (['mp4', 'avi', 'mov', 'wmv', 'mkv'].contains(extension)) {
      return AttachmentType.video;
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(extension)) {
      return AttachmentType.audio;
    } else {
      return AttachmentType.document;
    }
  }
}
