import 'package:flutter/foundation.dart';

/// Types of partner relationships
enum PartnerType {
  romanticPartner,
  spouse,
  friend,
  familyMember,
  doctor,
  coach,
  custom,
}

/// Partner relationship status
enum PartnerStatus {
  invited,
  accepted,
  blocked,
  removed,
}

/// Types of data that can be shared with partners
enum SharedDataType {
  cycleStart,           // Period start dates
  cycleLength,          // Cycle duration
  symptoms,             // Daily symptoms
  mood,                 // Mood tracking
  fertility,            // Fertility window
  intimacy,             // Intimacy tracking
  medications,          // Birth control, supplements
  appointments,         // Doctor appointments
  predictions,          // AI predictions
  analytics,            // Cycle analytics
  reminders,            // Shared reminders
  notes,                // Personal notes
}

/// Permission levels for shared data
enum SharingPermissionLevel {
  view,                 // Can only view
  comment,              // Can view and add comments
  remind,               // Can view, comment, and send reminders
  edit,                 // Full access (rare, mainly for healthcare providers)
}

/// Main partner relationship model
class PartnerRelationship {
  final String id;
  final String userId;              // User who initiated the relationship
  final String partnerId;          // Partner's user ID
  final String partnerEmail;       // Partner's email for invitation
  final String? partnerName;       // Partner's display name
  final String? partnerPhotoUrl;   // Partner's profile photo
  final PartnerType type;
  final PartnerStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? lastActiveAt;
  
  // Sharing configuration
  final Map<SharedDataType, SharingPermissionLevel> sharingPermissions;
  final bool isNotificationsEnabled;
  final bool isLocationSharingEnabled;
  final bool isEmergencyContactEnabled;
  
  // Custom settings
  final String? customTitle;        // Custom relationship title
  final String? nickname;          // Nickname for partner
  final Map<String, dynamic>? metadata;

  const PartnerRelationship({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.partnerEmail,
    this.partnerName,
    this.partnerPhotoUrl,
    required this.type,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.lastActiveAt,
    this.sharingPermissions = const {},
    this.isNotificationsEnabled = true,
    this.isLocationSharingEnabled = false,
    this.isEmergencyContactEnabled = false,
    this.customTitle,
    this.nickname,
    this.metadata,
  });

  /// Create a copy with updated fields
  PartnerRelationship copyWith({
    String? id,
    String? userId,
    String? partnerId,
    String? partnerEmail,
    String? partnerName,
    String? partnerPhotoUrl,
    PartnerType? type,
    PartnerStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? lastActiveAt,
    Map<SharedDataType, SharingPermissionLevel>? sharingPermissions,
    bool? isNotificationsEnabled,
    bool? isLocationSharingEnabled,
    bool? isEmergencyContactEnabled,
    String? customTitle,
    String? nickname,
    Map<String, dynamic>? metadata,
  }) {
    return PartnerRelationship(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      partnerEmail: partnerEmail ?? this.partnerEmail,
      partnerName: partnerName ?? this.partnerName,
      partnerPhotoUrl: partnerPhotoUrl ?? this.partnerPhotoUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      sharingPermissions: sharingPermissions ?? this.sharingPermissions,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      isLocationSharingEnabled: isLocationSharingEnabled ?? this.isLocationSharingEnabled,
      isEmergencyContactEnabled: isEmergencyContactEnabled ?? this.isEmergencyContactEnabled,
      customTitle: customTitle ?? this.customTitle,
      nickname: nickname ?? this.nickname,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'partnerEmail': partnerEmail,
      'partnerName': partnerName,
      'partnerPhotoUrl': partnerPhotoUrl,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'sharingPermissions': sharingPermissions.map(
        (key, value) => MapEntry(key.name, value.name),
      ),
      'isNotificationsEnabled': isNotificationsEnabled,
      'isLocationSharingEnabled': isLocationSharingEnabled,
      'isEmergencyContactEnabled': isEmergencyContactEnabled,
      'customTitle': customTitle,
      'nickname': nickname,
      'metadata': metadata,
    };
  }

  /// Create from Firebase map
  factory PartnerRelationship.fromMap(Map<String, dynamic> map) {
    return PartnerRelationship(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      partnerEmail: map['partnerEmail'] ?? '',
      partnerName: map['partnerName'],
      partnerPhotoUrl: map['partnerPhotoUrl'],
      type: PartnerType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PartnerType.custom,
      ),
      status: PartnerStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PartnerStatus.invited,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt']) : null,
      lastActiveAt: map['lastActiveAt'] != null ? DateTime.parse(map['lastActiveAt']) : null,
      sharingPermissions: _parseSharedPermissions(map['sharingPermissions']),
      isNotificationsEnabled: map['isNotificationsEnabled'] ?? true,
      isLocationSharingEnabled: map['isLocationSharingEnabled'] ?? false,
      isEmergencyContactEnabled: map['isEmergencyContactEnabled'] ?? false,
      customTitle: map['customTitle'],
      nickname: map['nickname'],
      metadata: map['metadata'],
    );
  }

  static Map<SharedDataType, SharingPermissionLevel> _parseSharedPermissions(
    dynamic permissions,
  ) {
    if (permissions is! Map) return {};
    
    final result = <SharedDataType, SharingPermissionLevel>{};
    permissions.forEach((key, value) {
      try {
        final dataType = SharedDataType.values.firstWhere((e) => e.name == key);
        final permLevel = SharingPermissionLevel.values.firstWhere((e) => e.name == value);
        result[dataType] = permLevel;
      } catch (e) {
        debugPrint('Error parsing permission: $key -> $value');
      }
    });
    
    return result;
  }

  /// Check if partner has access to specific data type
  bool hasAccessTo(SharedDataType dataType) {
    return sharingPermissions.containsKey(dataType);
  }

  /// Get permission level for specific data type
  SharingPermissionLevel? getPermissionLevel(SharedDataType dataType) {
    return sharingPermissions[dataType];
  }

  /// Check if partner can perform specific action
  bool canPerformAction(SharedDataType dataType, PartnerAction action) {
    final permission = getPermissionLevel(dataType);
    if (permission == null) return false;

    switch (action) {
      case PartnerAction.view:
        return true; // All permission levels allow viewing
      case PartnerAction.comment:
        return permission.index >= SharingPermissionLevel.comment.index;
      case PartnerAction.remind:
        return permission.index >= SharingPermissionLevel.remind.index;
      case PartnerAction.edit:
        return permission.index >= SharingPermissionLevel.edit.index;
    }
  }

  /// Get display name for partner
  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) return nickname!;
    if (partnerName != null && partnerName!.isNotEmpty) return partnerName!;
    return partnerEmail.split('@').first;
  }

  /// Get relationship display text
  String get relationshipDisplayText {
    if (customTitle != null && customTitle!.isNotEmpty) return customTitle!;
    return _getPartnerTypeDisplayName(type);
  }

  String _getPartnerTypeDisplayName(PartnerType type) {
    switch (type) {
      case PartnerType.romanticPartner: return 'Partner';
      case PartnerType.spouse: return 'Spouse';
      case PartnerType.friend: return 'Friend';
      case PartnerType.familyMember: return 'Family';
      case PartnerType.doctor: return 'Doctor';
      case PartnerType.coach: return 'Coach';
      case PartnerType.custom: return 'Contact';
    }
  }
}

/// Actions that partners can perform
enum PartnerAction {
  view,
  comment,
  remind,
  edit,
}

/// Partner invitation model
class PartnerInvitation {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserEmail;
  final String toEmail;
  final PartnerType relationshipType;
  final String? customMessage;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final InvitationStatus status;
  final Map<SharedDataType, SharingPermissionLevel> proposedPermissions;

  const PartnerInvitation({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserEmail,
    required this.toEmail,
    required this.relationshipType,
    this.customMessage,
    required this.createdAt,
    this.expiresAt,
    this.status = InvitationStatus.pending,
    this.proposedPermissions = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserEmail': fromUserEmail,
      'toEmail': toEmail,
      'relationshipType': relationshipType.name,
      'customMessage': customMessage,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status.name,
      'proposedPermissions': proposedPermissions.map(
        (key, value) => MapEntry(key.name, value.name),
      ),
    };
  }

  factory PartnerInvitation.fromMap(Map<String, dynamic> map) {
    return PartnerInvitation(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      fromUserName: map['fromUserName'] ?? '',
      fromUserEmail: map['fromUserEmail'] ?? '',
      toEmail: map['toEmail'] ?? '',
      relationshipType: PartnerType.values.firstWhere(
        (e) => e.name == map['relationshipType'],
        orElse: () => PartnerType.custom,
      ),
      customMessage: map['customMessage'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      status: InvitationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => InvitationStatus.pending,
      ),
      proposedPermissions: PartnerRelationship._parseSharedPermissions(map['proposedPermissions']),
    );
  }
}

enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
  cancelled,
}

/// Shared data entry between partners
class SharedDataEntry {
  final String id;
  final String relationshipId;
  final String fromUserId;
  final SharedDataType dataType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final List<PartnerComment> comments;
  final bool isPrivate;

  const SharedDataEntry({
    required this.id,
    required this.relationshipId,
    required this.fromUserId,
    required this.dataType,
    required this.data,
    required this.timestamp,
    this.comments = const [],
    this.isPrivate = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'relationshipId': relationshipId,
      'fromUserId': fromUserId,
      'dataType': dataType.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'comments': comments.map((c) => c.toMap()).toList(),
      'isPrivate': isPrivate,
    };
  }

  factory SharedDataEntry.fromMap(Map<String, dynamic> map) {
    return SharedDataEntry(
      id: map['id'] ?? '',
      relationshipId: map['relationshipId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      dataType: SharedDataType.values.firstWhere(
        (e) => e.name == map['dataType'],
        orElse: () => SharedDataType.notes,
      ),
      data: map['data'] ?? {},
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((c) => PartnerComment.fromMap(c))
          .toList(),
      isPrivate: map['isPrivate'] ?? false,
    );
  }
}

/// Comment on shared data
class PartnerComment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  final CommentType type;

  const PartnerComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    this.type = CommentType.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  factory PartnerComment.fromMap(Map<String, dynamic> map) {
    return PartnerComment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      type: CommentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CommentType.comment,
      ),
    );
  }
}

enum CommentType {
  comment,
  supportMessage,
  reminder,
  celebration,
}

/// Partner notification model
class PartnerNotification {
  final String id;
  final String relationshipId;
  final String fromUserId;
  final String toUserId;
  final PartnerNotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;

  const PartnerNotification({
    required this.id,
    required this.relationshipId,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'relationshipId': relationshipId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'type': type.name,
      'title': title,
      'message': message,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory PartnerNotification.fromMap(Map<String, dynamic> map) {
    return PartnerNotification(
      id: map['id'] ?? '',
      relationshipId: map['relationshipId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      type: PartnerNotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PartnerNotificationType.general,
      ),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      data: map['data'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
    );
  }
}

enum PartnerNotificationType {
  periodStarting,
  periodStarted,
  fertilityWindow,
  symptomAlert,
  medicationReminder,
  supportRequest,
  celebration,
  dataShared,
  comment,
  general,
}

/// Default sharing templates for different partner types
class SharingTemplates {
  static const Map<PartnerType, Map<SharedDataType, SharingPermissionLevel>> defaults = {
    PartnerType.romanticPartner: {
      SharedDataType.cycleStart: SharingPermissionLevel.comment,
      SharedDataType.fertility: SharingPermissionLevel.comment,
      SharedDataType.mood: SharingPermissionLevel.view,
      SharedDataType.symptoms: SharingPermissionLevel.view,
      SharedDataType.predictions: SharingPermissionLevel.view,
      SharedDataType.reminders: SharingPermissionLevel.remind,
    },
    PartnerType.spouse: {
      SharedDataType.cycleStart: SharingPermissionLevel.comment,
      SharedDataType.cycleLength: SharingPermissionLevel.view,
      SharedDataType.fertility: SharingPermissionLevel.comment,
      SharedDataType.mood: SharingPermissionLevel.comment,
      SharedDataType.symptoms: SharingPermissionLevel.view,
      SharedDataType.intimacy: SharingPermissionLevel.comment,
      SharedDataType.predictions: SharingPermissionLevel.view,
      SharedDataType.reminders: SharingPermissionLevel.remind,
    },
    PartnerType.friend: {
      SharedDataType.cycleStart: SharingPermissionLevel.comment,
      SharedDataType.mood: SharingPermissionLevel.view,
      SharedDataType.reminders: SharingPermissionLevel.view,
    },
    PartnerType.familyMember: {
      SharedDataType.cycleStart: SharingPermissionLevel.view,
      SharedDataType.mood: SharingPermissionLevel.view,
      SharedDataType.appointments: SharingPermissionLevel.remind,
    },
    PartnerType.doctor: {
      SharedDataType.cycleStart: SharingPermissionLevel.edit,
      SharedDataType.cycleLength: SharingPermissionLevel.edit,
      SharedDataType.symptoms: SharingPermissionLevel.edit,
      SharedDataType.medications: SharingPermissionLevel.edit,
      SharedDataType.appointments: SharingPermissionLevel.edit,
      SharedDataType.analytics: SharingPermissionLevel.edit,
      SharedDataType.predictions: SharingPermissionLevel.view,
    },
    PartnerType.coach: {
      SharedDataType.cycleStart: SharingPermissionLevel.comment,
      SharedDataType.symptoms: SharingPermissionLevel.comment,
      SharedDataType.mood: SharingPermissionLevel.comment,
      SharedDataType.analytics: SharingPermissionLevel.view,
      SharedDataType.reminders: SharingPermissionLevel.remind,
    },
  };

  /// Get default sharing permissions for partner type
  static Map<SharedDataType, SharingPermissionLevel> getDefaultPermissions(PartnerType type) {
    return Map.from(defaults[type] ?? {});
  }

  /// Get suggested permissions based on relationship context
  static Map<SharedDataType, SharingPermissionLevel> getSuggestedPermissions(
    PartnerType type,
    {bool isLongDistance = false, bool isTryingToConceive = false}
  ) {
    var permissions = getDefaultPermissions(type);
    
    if (isLongDistance && (type == PartnerType.romanticPartner || type == PartnerType.spouse)) {
      permissions[SharedDataType.mood] = SharingPermissionLevel.comment;
      permissions[SharedDataType.notes] = SharingPermissionLevel.comment;
    }
    
    if (isTryingToConceive && (type == PartnerType.romanticPartner || type == PartnerType.spouse)) {
      permissions[SharedDataType.fertility] = SharingPermissionLevel.comment;
      permissions[SharedDataType.intimacy] = SharingPermissionLevel.comment;
      permissions[SharedDataType.predictions] = SharingPermissionLevel.comment;
    }
    
    return permissions;
  }
}
