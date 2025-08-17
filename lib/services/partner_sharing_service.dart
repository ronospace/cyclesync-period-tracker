import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/partner_models.dart';
import '../models/cycle_models.dart';
import 'firebase_service.dart';
import 'user_service.dart';
import 'error_service.dart';
import 'notification_service.dart';

/// Service for managing partner relationships and data sharing
class PartnerSharingService {
  static PartnerSharingService? _instance;
  static PartnerSharingService get instance => _instance ??= PartnerSharingService._();
  
  PartnerSharingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _relationshipsCollection => _firestore.collection('partner_relationships');
  CollectionReference get _invitationsCollection => _firestore.collection('partner_invitations');
  CollectionReference get _sharedDataCollection => _firestore.collection('shared_data');
  CollectionReference get _partnerNotificationsCollection => _firestore.collection('partner_notifications');

  /// Send partner invitation
  Future<String?> sendPartnerInvitation({
    required String partnerEmail,
    required PartnerType relationshipType,
    String? customMessage,
    Map<SharedDataType, SharingPermissionLevel>? customPermissions,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if invitation already exists
      final existingInvitation = await _findExistingInvitation(user.email!, partnerEmail);
      if (existingInvitation != null && existingInvitation.status == InvitationStatus.pending) {
        throw Exception('Invitation already sent to this email');
      }

      // Check if relationship already exists
      final existingRelationship = await _findExistingRelationship(user.uid, partnerEmail);
      if (existingRelationship != null) {
        throw Exception('Relationship already exists with this partner');
      }

      final invitationId = _invitationsCollection.doc().id;
      final permissions = customPermissions ?? SharingTemplates.getDefaultPermissions(relationshipType);
      
      final invitation = PartnerInvitation(
        id: invitationId,
        fromUserId: user.uid,
        fromUserName: user.displayName ?? 'CycleSync User',
        fromUserEmail: user.email!,
        toEmail: partnerEmail,
        relationshipType: relationshipType,
        customMessage: customMessage,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)), // 7 days expiry
        proposedPermissions: permissions,
      );

      await _invitationsCollection.doc(invitationId).set(invitation.toMap());
      
      // Send email notification (if email service is available)
      await _sendInvitationEmail(invitation);
      
      debugPrint('Partner invitation sent: $invitationId');
      return invitationId;
    } catch (e) {
      ErrorService.logError(e, context: 'Send partner invitation');
      return null;
    }
  }

  /// Get pending invitations for current user
  Stream<List<PartnerInvitation>> getPendingInvitations() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _invitationsCollection
        .where('toEmail', isEqualTo: user.email)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PartnerInvitation.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get sent invitations by current user
  Stream<List<PartnerInvitation>> getSentInvitations() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _invitationsCollection
        .where('fromUserId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PartnerInvitation.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Accept partner invitation
  Future<bool> acceptPartnerInvitation(String invitationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final invitationDoc = await _invitationsCollection.doc(invitationId).get();
      if (!invitationDoc.exists) throw Exception('Invitation not found');

      final invitation = PartnerInvitation.fromMap(invitationDoc.data() as Map<String, dynamic>);
      
      // Check if invitation is still valid
      if (invitation.status != InvitationStatus.pending) {
        throw Exception('Invitation is no longer valid');
      }
      if (invitation.expiresAt != null && invitation.expiresAt!.isBefore(DateTime.now())) {
        throw Exception('Invitation has expired');
      }

      // Create relationship for both users
      final relationshipId = _relationshipsCollection.doc().id;
      final now = DateTime.now();

      // Primary relationship (from inviter to invitee)
      final primaryRelationship = PartnerRelationship(
        id: relationshipId,
        userId: invitation.fromUserId,
        partnerId: user.uid,
        partnerEmail: user.email!,
        partnerName: user.displayName,
        partnerPhotoUrl: user.photoURL,
        type: invitation.relationshipType,
        status: PartnerStatus.accepted,
        createdAt: invitation.createdAt,
        acceptedAt: now,
        sharingPermissions: invitation.proposedPermissions,
      );

      // Reciprocal relationship (from invitee to inviter)
      final reciprocalRelationshipId = _relationshipsCollection.doc().id;
      final reciprocalPermissions = _getReciprocalPermissions(invitation.proposedPermissions);
      
      final reciprocalRelationship = PartnerRelationship(
        id: reciprocalRelationshipId,
        userId: user.uid,
        partnerId: invitation.fromUserId,
        partnerEmail: invitation.fromUserEmail,
        partnerName: invitation.fromUserName,
        type: invitation.relationshipType,
        status: PartnerStatus.accepted,
        createdAt: invitation.createdAt,
        acceptedAt: now,
        sharingPermissions: reciprocalPermissions,
      );

      // Batch write to ensure atomicity
      final batch = _firestore.batch();
      
      // Create relationships
      batch.set(_relationshipsCollection.doc(relationshipId), primaryRelationship.toMap());
      batch.set(_relationshipsCollection.doc(reciprocalRelationshipId), reciprocalRelationship.toMap());
      
      // Update invitation status
      batch.update(_invitationsCollection.doc(invitationId), {
        'status': InvitationStatus.accepted.name,
      });

      await batch.commit();

      // Send notifications
      await _sendPartnerNotification(
        reciprocalRelationship.id,
        invitation.fromUserId,
        user.uid,
        PartnerNotificationType.general,
        'Partner Connected',
        '${user.displayName ?? user.email} accepted your partner invitation!',
      );

      debugPrint('Partner invitation accepted: $invitationId');
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Accept partner invitation');
      return false;
    }
  }

  /// Decline partner invitation
  Future<bool> declinePartnerInvitation(String invitationId) async {
    try {
      await _invitationsCollection.doc(invitationId).update({
        'status': InvitationStatus.declined.name,
      });
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Decline partner invitation');
      return false;
    }
  }

  /// Get user's partner relationships
  Stream<List<PartnerRelationship>> getPartnerRelationships() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _relationshipsCollection
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: PartnerStatus.accepted.name)
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PartnerRelationship.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Update sharing permissions for a relationship
  Future<bool> updateSharingPermissions(
    String relationshipId,
    Map<SharedDataType, SharingPermissionLevel> permissions,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _relationshipsCollection.doc(relationshipId).update({
        'sharingPermissions': permissions.map((key, value) => MapEntry(key.name, value.name)),
      });

      debugPrint('Sharing permissions updated for relationship: $relationshipId');
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Update sharing permissions');
      return false;
    }
  }

  /// Share cycle data with partner
  Future<bool> shareCycleData(
    String relationshipId,
    SharedDataType dataType,
    Map<String, dynamic> data,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user has permission to share this data
      final relationship = await _getRelationship(relationshipId);
      if (relationship == null || !relationship.hasAccessTo(dataType)) {
        throw Exception('No permission to share this data type');
      }

      final sharedDataId = _sharedDataCollection.doc().id;
      final sharedData = SharedDataEntry(
        id: sharedDataId,
        relationshipId: relationshipId,
        fromUserId: user.uid,
        dataType: dataType,
        data: data,
        timestamp: DateTime.now(),
      );

      await _sharedDataCollection.doc(sharedDataId).set(sharedData.toMap());

      // Notify partner
      await _sendPartnerNotification(
        relationshipId,
        user.uid,
        relationship.partnerId,
        PartnerNotificationType.dataShared,
        'New Data Shared',
        '${user.displayName ?? 'Your partner'} shared ${_getDataTypeDisplayName(dataType)} with you',
        data: {'sharedDataId': sharedDataId, 'dataType': dataType.name},
      );

      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Share cycle data');
      return false;
    }
  }

  /// Get shared data for a relationship
  Stream<List<SharedDataEntry>> getSharedData(String relationshipId) {
    return _sharedDataCollection
        .where('relationshipId', isEqualTo: relationshipId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SharedDataEntry.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Add comment to shared data
  Future<bool> addCommentToSharedData(
    String sharedDataId,
    String content,
    {CommentType type = CommentType.comment}
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final comment = PartnerComment(
        id: _firestore.collection('temp').doc().id,
        userId: user.uid,
        userName: user.displayName ?? user.email!,
        content: content,
        timestamp: DateTime.now(),
        type: type,
      );

      await _sharedDataCollection.doc(sharedDataId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });

      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Add comment to shared data');
      return false;
    }
  }

  /// Send partner notification
  Future<bool> _sendPartnerNotification(
    String relationshipId,
    String fromUserId,
    String toUserId,
    PartnerNotificationType type,
    String title,
    String message, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = _partnerNotificationsCollection.doc().id;
      final notification = PartnerNotification(
        id: notificationId,
        relationshipId: relationshipId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: type,
        title: title,
        message: message,
        data: data,
        timestamp: DateTime.now(),
      );

      await _partnerNotificationsCollection.doc(notificationId).set(notification.toMap());
      
      // Also send local notification if service is available
      // NotificationService.instance.sendLocalNotification(title, message);
      
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Send partner notification');
      return false;
    }
  }

  /// Get partner notifications
  Stream<List<PartnerNotification>> getPartnerNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _partnerNotificationsCollection
        .where('toUserId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PartnerNotification.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _partnerNotificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Mark notification as read');
      return false;
    }
  }

  /// Remove partner relationship
  Future<bool> removePartnerRelationship(String relationshipId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get the relationship to find the reciprocal one
      final relationship = await _getRelationship(relationshipId);
      if (relationship == null) throw Exception('Relationship not found');

      // Find and remove reciprocal relationship
      final reciprocalQuery = await _relationshipsCollection
          .where('userId', isEqualTo: relationship.partnerId)
          .where('partnerId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      
      // Remove primary relationship
      batch.update(_relationshipsCollection.doc(relationshipId), {
        'status': PartnerStatus.removed.name,
      });

      // Remove reciprocal relationship
      for (final doc in reciprocalQuery.docs) {
        batch.update(doc.reference, {
          'status': PartnerStatus.removed.name,
        });
      }

      await batch.commit();

      debugPrint('Partner relationship removed: $relationshipId');
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Remove partner relationship');
      return false;
    }
  }

  /// Auto-share cycle data based on permissions
  Future<void> autoShareCycleData(CycleEntry cycleData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final relationshipsSnapshot = await _relationshipsCollection
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: PartnerStatus.accepted.name)
          .get();

      for (final doc in relationshipsSnapshot.docs) {
        final relationship = PartnerRelationship.fromMap(doc.data() as Map<String, dynamic>);
        
        // Check what data types this partner has access to and auto-share
        if (relationship.hasAccessTo(SharedDataType.cycleStart) && cycleData.startDate != null) {
          await shareCycleData(
            relationship.id,
            SharedDataType.cycleStart,
            {
              'date': cycleData.startDate!.toIso8601String(),
              'flow': cycleData.flowLevel,
              'autoShared': true,
            },
          );
        }

        if (relationship.hasAccessTo(SharedDataType.symptoms) && cycleData.symptoms != null) {
          await shareCycleData(
            relationship.id,
            SharedDataType.symptoms,
            {
              'symptoms': cycleData.symptoms,
              'date': DateTime.now().toIso8601String(),
              'autoShared': true,
            },
          );
        }

        if (relationship.hasAccessTo(SharedDataType.mood) && cycleData.moodLevel != null) {
          await shareCycleData(
            relationship.id,
            SharedDataType.mood,
            {
              'level': cycleData.moodLevel,
              'date': DateTime.now().toIso8601String(),
              'autoShared': true,
            },
          );
        }
      }
    } catch (e) {
      ErrorService.logError(e, context: 'Auto-share cycle data');
    }
  }

  /// Send period starting notification to partners
  Future<void> notifyPartnersOfPeriodStart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final relationshipsSnapshot = await _relationshipsCollection
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: PartnerStatus.accepted.name)
          .get();

      for (final doc in relationshipsSnapshot.docs) {
        final relationship = PartnerRelationship.fromMap(doc.data() as Map<String, dynamic>);
        
        if (relationship.hasAccessTo(SharedDataType.cycleStart) && relationship.isNotificationsEnabled) {
          await _sendPartnerNotification(
            relationship.id,
            user.uid,
            relationship.partnerId,
            PartnerNotificationType.periodStarted,
            'Period Started',
            '${user.displayName ?? 'Your partner'}\'s period has started today.',
          );
        }
      }
    } catch (e) {
      ErrorService.logError(e, context: 'Notify partners of period start');
    }
  }

  /// Get emergency contacts from partners
  Future<List<PartnerRelationship>> getEmergencyContacts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _relationshipsCollection
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: PartnerStatus.accepted.name)
          .where('isEmergencyContactEnabled', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => PartnerRelationship.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ErrorService.logError(e, context: 'Get emergency contacts');
      return [];
    }
  }

  /// Helper methods

  Future<PartnerInvitation?> _findExistingInvitation(String fromEmail, String toEmail) async {
    try {
      final snapshot = await _invitationsCollection
          .where('fromUserEmail', isEqualTo: fromEmail)
          .where('toEmail', isEqualTo: toEmail)
          .where('status', isEqualTo: InvitationStatus.pending.name)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return PartnerInvitation.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<PartnerRelationship?> _findExistingRelationship(String userId, String partnerEmail) async {
    try {
      final snapshot = await _relationshipsCollection
          .where('userId', isEqualTo: userId)
          .where('partnerEmail', isEqualTo: partnerEmail)
          .where('status', isEqualTo: PartnerStatus.accepted.name)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return PartnerRelationship.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<PartnerRelationship?> _getRelationship(String relationshipId) async {
    try {
      final doc = await _relationshipsCollection.doc(relationshipId).get();
      if (doc.exists) {
        return PartnerRelationship.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<SharedDataType, SharingPermissionLevel> _getReciprocalPermissions(
    Map<SharedDataType, SharingPermissionLevel> originalPermissions,
  ) {
    // For now, return same permissions, but in a real app you might want different logic
    // For example, doctors might have edit permissions on patient data, but patients only view on doctor's notes
    return Map.from(originalPermissions);
  }

  String _getDataTypeDisplayName(SharedDataType dataType) {
    switch (dataType) {
      case SharedDataType.cycleStart: return 'period start';
      case SharedDataType.cycleLength: return 'cycle length';
      case SharedDataType.symptoms: return 'symptoms';
      case SharedDataType.mood: return 'mood';
      case SharedDataType.fertility: return 'fertility data';
      case SharedDataType.intimacy: return 'intimacy';
      case SharedDataType.medications: return 'medications';
      case SharedDataType.appointments: return 'appointments';
      case SharedDataType.predictions: return 'predictions';
      case SharedDataType.analytics: return 'analytics';
      case SharedDataType.reminders: return 'reminders';
      case SharedDataType.notes: return 'notes';
    }
  }

  Future<void> _sendInvitationEmail(PartnerInvitation invitation) async {
    // This would integrate with an email service
    // For now, we'll just log it
    debugPrint('Email invitation would be sent to: ${invitation.toEmail}');
    // Implementation would depend on email service (SendGrid, AWS SES, etc.)
  }

  /// Cleanup expired invitations
  Future<void> cleanupExpiredInvitations() async {
    try {
      final now = DateTime.now();
      final expiredQuery = await _invitationsCollection
          .where('expiresAt', isLessThan: now)
          .where('status', isEqualTo: InvitationStatus.pending.name)
          .get();

      final batch = _firestore.batch();
      for (final doc in expiredQuery.docs) {
        batch.update(doc.reference, {'status': InvitationStatus.expired.name});
      }

      if (expiredQuery.docs.isNotEmpty) {
        await batch.commit();
        debugPrint('Cleaned up ${expiredQuery.docs.length} expired invitations');
      }
    } catch (e) {
      ErrorService.logError(e, context: 'Cleanup expired invitations');
    }
  }
}
