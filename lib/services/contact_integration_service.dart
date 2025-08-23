import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// import 'package:contacts_service/contacts_service.dart'; // Removed dependency
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Contact integration models
class ContactInfo {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final ContactPlatform platform;
  final bool isAppUser;
  final String? userId;
  final DateTime? lastSynced;

  const ContactInfo({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    required this.platform,
    this.isAppUser = false,
    this.userId,
    this.lastSynced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'platform': platform.name,
      'isAppUser': isAppUser,
      'userId': userId,
      'lastSynced': lastSynced?.toIso8601String(),
    };
  }

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      platform: ContactPlatform.values.firstWhere(
        (p) => p.name == map['platform'],
        orElse: () => ContactPlatform.phone,
      ),
      isAppUser: map['isAppUser'] ?? false,
      userId: map['userId'],
      lastSynced: map['lastSynced'] != null
          ? DateTime.parse(map['lastSynced'])
          : null,
    );
  }

  ContactInfo copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    ContactPlatform? platform,
    bool? isAppUser,
    String? userId,
    DateTime? lastSynced,
  }) {
    return ContactInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      platform: platform ?? this.platform,
      isAppUser: isAppUser ?? this.isAppUser,
      userId: userId ?? this.userId,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }
}

enum ContactPlatform { phone, whatsapp, telegram }

class ShareMessage {
  final String title;
  final String content;
  final ShareType type;
  final Map<String, dynamic>? data;

  const ShareMessage({
    required this.title,
    required this.content,
    required this.type,
    this.data,
  });
}

enum ShareType { cycleUpdate, symptoms, reminder, insights, custom }

/// Contact Integration Service for WhatsApp and Telegram
class ContactIntegrationService {
  static final ContactIntegrationService _instance =
      ContactIntegrationService._internal();
  factory ContactIntegrationService() => _instance;
  ContactIntegrationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  static const String _contactsCollection = 'user_contacts';
  static const String _shareHistoryCollection = 'share_history';

  // Platform method channels (would need native implementation)
  static const MethodChannel _whatsappChannel = MethodChannel(
    'cyclesync/whatsapp',
  );
  static const MethodChannel _telegramChannel = MethodChannel(
    'cyclesync/telegram',
  );

  // Predefined important contacts
  static const List<ContactInfo> _predefinedContacts = [
    ContactInfo(
      id: 'whatsapp_support',
      name: 'CycleSync Support',
      phoneNumber: '+4917627702411',
      platform: ContactPlatform.whatsapp,
    ),
  ];

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    try {
      final contactsPermission = await Permission.contacts.request();

      if (contactsPermission != PermissionStatus.granted) {
        debugPrint('Contacts permission denied');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Get device contacts
  Future<List<ContactInfo>> getDeviceContacts() async {
    try {
      final hasPermission = await Permission.contacts.isGranted;
      if (!hasPermission) {
        final granted = await requestPermissions();
        if (!granted) return [];
      }

      // final contacts = await ContactsService.getContacts();
      // Return empty list since contacts_service dependency was removed
      return [];
    } catch (e) {
      debugPrint('Error getting device contacts: $e');
      return [];
    }
  }

  /// Get WhatsApp contacts (requires WhatsApp Business API or native integration)
  Future<List<ContactInfo>> getWhatsAppContacts() async {
    try {
      // This would require native Android/iOS implementation
      // to access WhatsApp contacts or use WhatsApp Business API
      final result = await _whatsappChannel.invokeMethod('getContacts');

      if (result is List) {
        return result.map<ContactInfo>((contact) {
          return ContactInfo(
            id: contact['id'] ?? '',
            name: contact['name'] ?? 'Unknown',
            phoneNumber: _cleanPhoneNumber(contact['phoneNumber']),
            platform: ContactPlatform.whatsapp,
          );
        }).toList();
      }

      return [];
    } on PlatformException catch (e) {
      debugPrint('Error getting WhatsApp contacts: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting WhatsApp contacts: $e');
      return [];
    }
  }

  /// Get Telegram contacts (requires Telegram API integration)
  Future<List<ContactInfo>> getTelegramContacts() async {
    try {
      // This would require Telegram API integration
      final result = await _telegramChannel.invokeMethod('getContacts');

      if (result is List) {
        return result.map<ContactInfo>((contact) {
          return ContactInfo(
            id: contact['id'] ?? '',
            name: contact['name'] ?? 'Unknown',
            phoneNumber: _cleanPhoneNumber(contact['phoneNumber']),
            platform: ContactPlatform.telegram,
          );
        }).toList();
      }

      return [];
    } on PlatformException catch (e) {
      debugPrint('Error getting Telegram contacts: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting Telegram contacts: $e');
      return [];
    }
  }

  /// Get predefined important contacts
  List<ContactInfo> getPredefinedContacts() {
    return List.from(_predefinedContacts);
  }

  /// Add predefined contact to user's contacts
  Future<bool> addPredefinedContact(String contactId) async {
    if (currentUserId == null) return false;

    try {
      final contact = _predefinedContacts.firstWhere(
        (c) => c.id == contactId,
        orElse: () => throw Exception('Predefined contact not found'),
      );

      await _saveContactToFirestore(contact);
      return true;
    } catch (e) {
      debugPrint('Error adding predefined contact: $e');
      return false;
    }
  }

  /// Sync all contacts from all platforms
  Future<List<ContactInfo>> syncAllContacts({bool forceRefresh = false}) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final List<ContactInfo> allContacts = [];

      // Add predefined important contacts first
      allContacts.addAll(_predefinedContacts);

      // Get contacts from all platforms
      final deviceContacts = await getDeviceContacts();
      final whatsappContacts = await getWhatsAppContacts();
      final telegramContacts = await getTelegramContacts();

      allContacts.addAll(deviceContacts);
      allContacts.addAll(whatsappContacts);
      allContacts.addAll(telegramContacts);

      // Remove duplicates based on phone number
      final Map<String, ContactInfo> uniqueContacts = {};
      for (final contact in allContacts) {
        final key = contact.phoneNumber ?? contact.email ?? contact.id;
        if (!uniqueContacts.containsKey(key)) {
          uniqueContacts[key] = contact;
        }
      }

      // Check which contacts are app users
      final updatedContacts = await _checkAppUsers(
        uniqueContacts.values.toList(),
      );

      // Save to Firestore
      await _saveContactsToFirestore(updatedContacts, forceRefresh);

      return updatedContacts;
    } catch (e) {
      debugPrint('Error syncing contacts: $e');
      return [];
    }
  }

  /// Get synced contacts from Firestore
  Future<List<ContactInfo>> getSyncedContacts({
    ContactPlatform? platform,
    bool appUsersOnly = false,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      Query query = _firestore
          .collection(_contactsCollection)
          .doc(currentUserId)
          .collection('contacts');

      if (platform != null) {
        query = query.where('platform', isEqualTo: platform.name);
      }

      if (appUsersOnly) {
        query = query.where('isAppUser', isEqualTo: true);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ContactInfo.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting synced contacts: $e');
      return [];
    }
  }

  /// Quick share to CycleSync support via WhatsApp
  Future<bool> shareToSupport(ShareMessage message) async {
    const supportContact = '+4917627702411';
    return await shareViaWhatsApp(
      phoneNumber: supportContact,
      message: message,
    );
  }

  /// Share cycle data via WhatsApp
  Future<bool> shareViaWhatsApp({
    required String phoneNumber,
    required ShareMessage message,
  }) async {
    try {
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      if (cleanNumber == null) return false;

      final shareText = _formatShareMessage(message);
      final whatsappUrl =
          'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(shareText)}';

      final canLaunch = await canLaunchUrl(Uri.parse(whatsappUrl));
      if (canLaunch) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );

        // Log share activity
        await _logShareActivity(
          platform: ContactPlatform.whatsapp,
          recipient: phoneNumber,
          shareType: message.type,
        );

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error sharing via WhatsApp: $e');
      return false;
    }
  }

  /// Share cycle data via Telegram
  Future<bool> shareViaTelegram({
    required String phoneNumber,
    required ShareMessage message,
  }) async {
    try {
      final shareText = _formatShareMessage(message);
      final telegramUrl =
          'https://t.me/share/url?url=${Uri.encodeComponent(shareText)}';

      final canLaunch = await canLaunchUrl(Uri.parse(telegramUrl));
      if (canLaunch) {
        await launchUrl(
          Uri.parse(telegramUrl),
          mode: LaunchMode.externalApplication,
        );

        // Log share activity
        await _logShareActivity(
          platform: ContactPlatform.telegram,
          recipient: phoneNumber,
          shareType: message.type,
        );

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error sharing via Telegram: $e');
      return false;
    }
  }

  /// Share via SMS as fallback
  Future<bool> shareViaSMS({
    required String phoneNumber,
    required ShareMessage message,
  }) async {
    try {
      final shareText = _formatShareMessage(message);
      final smsUrl = 'sms:$phoneNumber?body=${Uri.encodeComponent(shareText)}';

      final canLaunch = await canLaunchUrl(Uri.parse(smsUrl));
      if (canLaunch) {
        await launchUrl(Uri.parse(smsUrl));

        // Log share activity
        await _logShareActivity(
          platform: ContactPlatform.phone,
          recipient: phoneNumber,
          shareType: message.type,
        );

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error sharing via SMS: $e');
      return false;
    }
  }

  /// Get share history
  Future<List<Map<String, dynamic>>> getShareHistory({
    int limit = 50,
    ContactPlatform? platform,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      Query query = _firestore
          .collection(_shareHistoryCollection)
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (platform != null) {
        query = query.where('platform', isEqualTo: platform.name);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting share history: $e');
      return [];
    }
  }

  /// Search contacts
  List<ContactInfo> searchContacts(List<ContactInfo> contacts, String query) {
    if (query.trim().isEmpty) return contacts;

    final queryLower = query.toLowerCase();

    return contacts.where((contact) {
      return contact.name.toLowerCase().contains(queryLower) ||
          (contact.phoneNumber?.contains(query) ?? false) ||
          (contact.email?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  /// Create support/help message
  static ShareMessage createSupportMessage({
    required String subject,
    required String message,
    Map<String, dynamic>? diagnosticInfo,
  }) {
    final content =
        '''
🆘 Support Request

Subject: $subject

Message: $message

${diagnosticInfo != null ? 'Diagnostic Info: ${diagnosticInfo.toString()}' : ''}

Sent from CycleSync App 💜
''';

    return ShareMessage(
      title: 'Support Request',
      content: content.trim(),
      type: ShareType.custom,
      data: {
        'subject': subject,
        'message': message,
        'diagnosticInfo': diagnosticInfo,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Create quick share messages
  static ShareMessage createCycleUpdateMessage({
    required String phase,
    required int dayOfCycle,
    String? additionalInfo,
  }) {
    final content =
        '''
🌙 Cycle Update

Current Phase: $phase
Day of Cycle: $dayOfCycle
${additionalInfo != null ? '\nNote: $additionalInfo' : ''}

Shared from CycleSync 💜
''';

    return ShareMessage(
      title: 'Cycle Update',
      content: content.trim(),
      type: ShareType.cycleUpdate,
      data: {
        'phase': phase,
        'dayOfCycle': dayOfCycle,
        'additionalInfo': additionalInfo,
      },
    );
  }

  static ShareMessage createSymptomsMessage({
    required List<String> symptoms,
    required String severity,
    String? notes,
  }) {
    final symptomsText = symptoms.join(', ');
    final content =
        '''
🩺 Symptoms Update

Symptoms: $symptomsText
Severity: $severity
${notes != null ? '\nNotes: $notes' : ''}

Shared from CycleSync 💜
''';

    return ShareMessage(
      title: 'Symptoms Update',
      content: content.trim(),
      type: ShareType.symptoms,
      data: {'symptoms': symptoms, 'severity': severity, 'notes': notes},
    );
  }

  static ShareMessage createReminderMessage({
    required String reminderType,
    required String message,
  }) {
    final content =
        '''
⏰ Reminder

Type: $reminderType
Message: $message

Shared from CycleSync 💜
''';

    return ShareMessage(
      title: 'Cycle Reminder',
      content: content.trim(),
      type: ShareType.reminder,
      data: {'reminderType': reminderType, 'message': message},
    );
  }

  // Private helper methods

  String? _cleanPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null) return null;

    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with + or add it
    if (!cleaned.startsWith('+') && cleaned.isNotEmpty) {
      cleaned = '+$cleaned';
    }

    return cleaned.isEmpty ? null : cleaned;
  }

  Future<List<ContactInfo>> _checkAppUsers(List<ContactInfo> contacts) async {
    try {
      final phoneNumbers = contacts
          .where((c) => c.phoneNumber != null)
          .map((c) => c.phoneNumber!)
          .toList();

      if (phoneNumbers.isEmpty) return contacts;

      // Query users collection for matching phone numbers
      final userSnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', whereIn: phoneNumbers)
          .get();

      final appUserPhones = <String, String>{};
      for (final doc in userSnapshot.docs) {
        final data = doc.data();
        final phone = data['phoneNumber'] as String?;
        if (phone != null) {
          appUserPhones[phone] = doc.id;
        }
      }

      return contacts.map((contact) {
        if (contact.phoneNumber != null &&
            appUserPhones.containsKey(contact.phoneNumber)) {
          return contact.copyWith(
            isAppUser: true,
            userId: appUserPhones[contact.phoneNumber],
          );
        }
        return contact;
      }).toList();
    } catch (e) {
      debugPrint('Error checking app users: $e');
      return contacts;
    }
  }

  Future<void> _saveContactToFirestore(ContactInfo contact) async {
    if (currentUserId == null) return;

    try {
      final userContactsRef = _firestore
          .collection(_contactsCollection)
          .doc(currentUserId)
          .collection('contacts');

      final contactWithTimestamp = contact.copyWith(lastSynced: DateTime.now());

      await userContactsRef.doc(contact.id).set(contactWithTimestamp.toMap());
    } catch (e) {
      debugPrint('Error saving contact to Firestore: $e');
    }
  }

  Future<void> _saveContactsToFirestore(
    List<ContactInfo> contacts,
    bool forceRefresh,
  ) async {
    if (currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final userContactsRef = _firestore
          .collection(_contactsCollection)
          .doc(currentUserId)
          .collection('contacts');

      // Clear existing contacts if force refresh
      if (forceRefresh) {
        final existingContacts = await userContactsRef.get();
        for (final doc in existingContacts.docs) {
          batch.delete(doc.reference);
        }
      }

      // Add updated contacts
      for (final contact in contacts) {
        final contactWithTimestamp = contact.copyWith(
          lastSynced: DateTime.now(),
        );

        batch.set(
          userContactsRef.doc(contact.id),
          contactWithTimestamp.toMap(),
        );
      }

      await batch.commit();

      // Update sync metadata
      await _firestore.collection(_contactsCollection).doc(currentUserId).set({
        'lastSynced': DateTime.now().toIso8601String(),
        'totalContacts': contacts.length,
        'appUsers': contacts.where((c) => c.isAppUser).length,
        'predefinedContacts': _predefinedContacts.length,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving contacts to Firestore: $e');
    }
  }

  String _formatShareMessage(ShareMessage message) {
    return message.content;
  }

  Future<void> _logShareActivity({
    required ContactPlatform platform,
    required String recipient,
    required ShareType shareType,
  }) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection(_shareHistoryCollection).add({
        'userId': currentUserId,
        'platform': platform.name,
        'recipient': recipient,
        'shareType': shareType.name,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error logging share activity: $e');
    }
  }

  /// Check if WhatsApp is installed
  Future<bool> isWhatsAppInstalled() async {
    try {
      final canLaunch = await canLaunchUrl(Uri.parse('whatsapp://'));
      return canLaunch;
    } catch (e) {
      return false;
    }
  }

  /// Check if Telegram is installed
  Future<bool> isTelegramInstalled() async {
    try {
      final canLaunch = await canLaunchUrl(Uri.parse('tg://'));
      return canLaunch;
    } catch (e) {
      return false;
    }
  }

  /// Get available sharing platforms
  Future<List<ContactPlatform>> getAvailablePlatforms() async {
    final platforms = <ContactPlatform>[
      ContactPlatform.phone,
    ]; // SMS always available

    if (await isWhatsAppInstalled()) {
      platforms.add(ContactPlatform.whatsapp);
    }

    if (await isTelegramInstalled()) {
      platforms.add(ContactPlatform.telegram);
    }

    return platforms;
  }
}
