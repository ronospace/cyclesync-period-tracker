import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';
import 'navigation_service.dart';

/// Message types for the AI Assistant
enum AIMessageType {
  user,
  assistant,
  system,
  contextual,
  suggestion
}

/// AI Message with metadata
class AIMessage {
  final String id;
  final String content;
  final AIMessageType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? context;
  final bool isTyping;

  const AIMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.metadata = const {},
    this.context,
    this.isTyping = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'context': context,
      'isTyping': isTyping,
    };
  }

  factory AIMessage.fromMap(Map<String, dynamic> map) {
    return AIMessage(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      type: AIMessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AIMessageType.assistant,
      ),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      context: map['context'],
      isTyping: map['isTyping'] ?? false,
    );
  }

  AIMessage copyWith({
    String? id,
    String? content,
    AIMessageType? type,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? context,
    bool? isTyping,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      context: context ?? this.context,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

/// AI Assistant context from current app state
class AIContext {
  final String? currentRoute;
  final Map<String, dynamic> routeArguments;
  final Map<String, dynamic> userPreferences;
  final List<String> recentActions;
  final Map<String, dynamic> appState;
  final DateTime timestamp;

  const AIContext({
    this.currentRoute,
    this.routeArguments = const {},
    this.userPreferences = const {},
    this.recentActions = const [],
    this.appState = const {},
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'currentRoute': currentRoute,
      'routeArguments': routeArguments,
      'userPreferences': userPreferences,
      'recentActions': recentActions,
      'appState': appState,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AIContext.fromMap(Map<String, dynamic> map) {
    return AIContext(
      currentRoute: map['currentRoute'],
      routeArguments: Map<String, dynamic>.from(map['routeArguments'] ?? {}),
      userPreferences: Map<String, dynamic>.from(map['userPreferences'] ?? {}),
      recentActions: List<String>.from(map['recentActions'] ?? []),
      appState: Map<String, dynamic>.from(map['appState'] ?? {}),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// AI Assistant suggestions and insights
class AISuggestion {
  final String id;
  final String title;
  final String description;
  final String actionText;
  final VoidCallback? action;
  final IconData icon;
  final Color color;
  final int priority;

  const AISuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.actionText,
    this.action,
    required this.icon,
    required this.color,
    this.priority = 0,
  });
}

/// Conversation session with metadata
class AIConversationSession {
  final String id;
  final List<AIMessage> messages;
  final DateTime startedAt;
  final DateTime lastActivityAt;
  final String title;
  final Map<String, dynamic> metadata;

  const AIConversationSession({
    required this.id,
    required this.messages,
    required this.startedAt,
    required this.lastActivityAt,
    required this.title,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messages': messages.map((m) => m.toMap()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'title': title,
      'metadata': metadata,
    };
  }

  factory AIConversationSession.fromMap(Map<String, dynamic> map) {
    return AIConversationSession(
      id: map['id'] ?? '',
      messages: (map['messages'] as List?)
          ?.map((m) => AIMessage.fromMap(m))
          .toList() ?? [],
      startedAt: DateTime.parse(map['startedAt'] ?? DateTime.now().toIso8601String()),
      lastActivityAt: DateTime.parse(map['lastActivityAt'] ?? DateTime.now().toIso8601String()),
      title: map['title'] ?? 'Conversation',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

/// AI Assistant Service with contextual intelligence
class AIAssistantService extends ChangeNotifier {
  static final AIAssistantService _instance = AIAssistantService._internal();
  factory AIAssistantService() => _instance;
  AIAssistantService._internal();

  SharedPreferences? _prefs;
  AIConversationSession? _currentSession;
  final List<AIConversationSession> _conversationHistory = [];
  final List<AISuggestion> _currentSuggestions = [];
  
  bool _isVisible = false;
  bool _isLoading = false;
  bool _hasNewSuggestions = false;
  bool _initialized = false;

  // Cache keys
  static const String _conversationHistoryKey = 'ai_conversation_history';
  static const String _currentSessionKey = 'ai_current_session';
  static const String _preferencesKey = 'ai_user_preferences';

  // Getters
  bool get isVisible => _isVisible;
  bool get isLoading => _isLoading;
  bool get hasNewSuggestions => _hasNewSuggestions;
  AIConversationSession? get currentSession => _currentSession;
  List<AISuggestion> get currentSuggestions => List.unmodifiable(_currentSuggestions);
  List<AIConversationSession> get conversationHistory => List.unmodifiable(_conversationHistory);

  /// Initialize the AI Assistant Service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadConversationHistory();
      await _loadCurrentSession();
      await _generateContextualSuggestions();
      
      _initialized = true;
      debugPrint('✅ AIAssistantService initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize AIAssistantService: $e');
    }
  }

  /// Show/hide the AI assistant
  void toggleVisibility() {
    _isVisible = !_isVisible;
    if (_isVisible) {
      _hasNewSuggestions = false;
      _generateContextualSuggestions();
    }
    notifyListeners();
  }

  void show() {
    _isVisible = true;
    _hasNewSuggestions = false;
    _generateContextualSuggestions();
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }

  /// Start a new conversation
  Future<void> startNewConversation({String? title}) async {
    if (_currentSession != null && _currentSession!.messages.isNotEmpty) {
      await _saveCurrentSessionToHistory();
    }

    _currentSession = AIConversationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messages: [],
      startedAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      title: title ?? 'New Conversation',
    );

    await _saveCurrentSession();
    
    // Add welcome message
    await _addWelcomeMessage();
    
    notifyListeners();
  }

  /// Send a message to the AI
  Future<void> sendMessage(String content, {Map<String, dynamic>? metadata}) async {
    if (!_initialized) await initialize();
    
    if (_currentSession == null) {
      await startNewConversation();
    }

    // Add user message
    final userMessage = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: AIMessageType.user,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, userMessage],
      lastActivityAt: DateTime.now(),
    );

    notifyListeners();

    // Add typing indicator
    final typingMessage = AIMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_typing',
      content: '',
      type: AIMessageType.assistant,
      timestamp: DateTime.now(),
      isTyping: true,
    );

    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, typingMessage],
    );

    _isLoading = true;
    notifyListeners();

    try {
      // Generate AI response
      final response = await _generateAIResponse(content, userMessage.metadata);
      
      // Remove typing indicator
      _currentSession = _currentSession!.copyWith(
        messages: _currentSession!.messages.where((m) => !m.isTyping).toList(),
      );

      // Add AI response
      final aiMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        type: AIMessageType.assistant,
        timestamp: DateTime.now(),
        context: await _getCurrentContext(),
      );

      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, aiMessage],
        lastActivityAt: DateTime.now(),
      );

      await _saveCurrentSession();
      await _generateContextualSuggestions();

    } catch (e) {
      debugPrint('Error generating AI response: $e');
      
      // Remove typing indicator and add error message
      _currentSession = _currentSession!.copyWith(
        messages: _currentSession!.messages.where((m) => !m.isTyping).toList(),
      );

      final errorMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'I apologize, but I encountered an error. Please try again.',
        type: AIMessageType.system,
        timestamp: DateTime.now(),
      );

      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, errorMessage],
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get contextual suggestions based on current app state
  Future<void> generateContextualInsights() async {
    if (!_initialized) await initialize();

    final context = await _buildCurrentContext();
    await _generateContextualSuggestions(context: context);
    
    _hasNewSuggestions = true;
    notifyListeners();
  }

  /// Clear conversation history
  Future<void> clearConversationHistory() async {
    _conversationHistory.clear();
    _currentSession = null;
    await _prefs?.remove(_conversationHistoryKey);
    await _prefs?.remove(_currentSessionKey);
    notifyListeners();
  }

  /// Export conversation history
  Future<Map<String, dynamic>> exportConversationHistory() async {
    return {
      'conversations': _conversationHistory.map((c) => c.toMap()).toList(),
      'currentSession': _currentSession?.toMap(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // Private helper methods

  Future<void> _addWelcomeMessage() async {
    final context = await _buildCurrentContext();
    final welcomeContent = _generateWelcomeMessage(context);

    final welcomeMessage = AIMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      content: welcomeContent,
      type: AIMessageType.assistant,
      timestamp: DateTime.now(),
      context: await _getCurrentContext(),
    );

    _currentSession = _currentSession!.copyWith(
      messages: [welcomeMessage],
    );

    await _saveCurrentSession();
  }

  String _generateWelcomeMessage(AIContext context) {
    final currentRoute = context.currentRoute;
    final timeOfDay = DateTime.now().hour;
    
    String greeting;
    if (timeOfDay < 12) {
      greeting = 'Good morning! ☀️';
    } else if (timeOfDay < 17) {
      greeting = 'Good afternoon! 🌤️';
    } else {
      greeting = 'Good evening! 🌙';
    }

    String contextualMessage = '';
    if (currentRoute != null) {
      switch (currentRoute) {
        case '/profile':
          contextualMessage = ' I see you\'re on your profile page. Need help updating your information?';
          break;
        case '/calendar':
          contextualMessage = ' You\'re viewing your calendar. Would you like insights on your cycle patterns?';
          break;
        case '/tracking':
          contextualMessage = ' Ready to log some cycle data? I can guide you through the process.';
          break;
        default:
          contextualMessage = ' How can I assist you with CycleSync today?';
      }
    }

    return '$greeting I\'m your AI assistant, here to help you navigate CycleSync and provide personalized insights.$contextualMessage';
  }

  Future<String> _generateAIResponse(String userMessage, Map<String, dynamic> metadata) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 1500 + (500 * (DateTime.now().millisecond % 3))));

    final context = await _buildCurrentContext();
    final lowerMessage = userMessage.toLowerCase();

    // Context-aware responses
    if (lowerMessage.contains('cycle') || lowerMessage.contains('period')) {
      return _generateCycleResponse(userMessage, context);
    } else if (lowerMessage.contains('calendar') || lowerMessage.contains('schedule')) {
      return _generateCalendarResponse(userMessage, context);
    } else if (lowerMessage.contains('symptoms') || lowerMessage.contains('mood')) {
      return _generateSymptomsResponse(userMessage, context);
    } else if (lowerMessage.contains('help') || lowerMessage.contains('how')) {
      return _generateHelpResponse(userMessage, context);
    } else if (lowerMessage.contains('settings') || lowerMessage.contains('profile')) {
      return _generateSettingsResponse(userMessage, context);
    } else {
      return _generateGeneralResponse(userMessage, context);
    }
  }

  String _generateCycleResponse(String message, AIContext context) {
    final responses = [
      'I can help you track your cycle patterns! Based on your current data, I notice some interesting trends. Would you like me to show you insights about your cycle length and predictions?',
      'Cycle tracking is one of my specialties! I can help you understand your patterns, predict upcoming periods, and identify any irregularities. What specific aspect would you like to explore?',
      'Your cycle data shows some valuable patterns. I can provide personalized insights about your average cycle length, symptom patterns, and fertility windows. What would be most helpful?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _generateCalendarResponse(String message, AIContext context) {
    final responses = [
      'Your calendar view shows upcoming predictions and logged data. I can help you understand the color coding, add reminders, or export your data. What would you like to know?',
      'The calendar is a great way to visualize your cycle! I notice you have some upcoming predictions. Would you like me to explain what the different colors mean or help you plan around your cycle?',
      'Looking at your calendar, I can provide insights about your patterns and help you set up custom reminders. What specific calendar feature can I help you with?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _generateSymptomsResponse(String message, AIContext context) {
    final responses = [
      'Symptom tracking is crucial for understanding your cycle! I can help you identify patterns in your mood, physical symptoms, and energy levels. What symptoms have you been experiencing?',
      'I can provide insights about how your symptoms correlate with your cycle phases. This can help predict and manage symptoms better. Would you like to see your symptom trends?',
      'Understanding your symptom patterns can be really empowering! I can show you correlations between different symptoms and cycle phases. What would be most helpful to track?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _generateHelpResponse(String message, AIContext context) {
    final route = context.currentRoute;
    if (route != null) {
      switch (route) {
        case '/tracking':
          return 'I can help you log cycle data! You can track your period days, symptoms, mood, flow intensity, and notes. Just tap the tracking buttons and I\'ll guide you through each step.';
        case '/calendar':
          return 'The calendar shows your cycle history and predictions. Red dots are period days, blue shows fertile windows, and gray are logged symptoms. Tap any day to add or edit data!';
        case '/profile':
          return 'In your profile, you can update personal information, cycle settings, notification preferences, and data export options. What would you like to modify?';
        default:
          return 'I\'m here to help with any aspect of CycleSync! I can assist with cycle tracking, calendar navigation, symptom logging, data insights, and personalized recommendations. What would you like to know?';
      }
    }
    
    return 'I\'m your personal CycleSync assistant! I can help with cycle tracking, provide insights, explain features, and answer questions about your reproductive health. What can I do for you?';
  }

  String _generateSettingsResponse(String message, AIContext context) {
    final responses = [
      'I can help you customize your CycleSync experience! You can adjust cycle length settings, notification preferences, privacy options, and data export features. What would you like to configure?',
      'Your profile settings allow you to personalize CycleSync for your needs. I can guide you through notification setup, cycle parameters, or privacy settings. What needs adjusting?',
      'Settings and profile customization can really improve your experience! I can help with cycle length adjustments, reminder schedules, or data management options. Where should we start?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _generateGeneralResponse(String message, AIContext context) {
    final responses = [
      'That\'s a great question! I\'m here to help you get the most out of CycleSync. Whether you need cycle insights, feature explanations, or personalized recommendations, I\'ve got you covered. What would you like to explore?',
      'I understand you\'re looking for assistance! As your CycleSync AI, I can provide cycle insights, help with tracking, explain predictions, and offer personalized advice. How can I support your health journey?',
      'Thanks for reaching out! I\'m designed to help you navigate CycleSync and understand your cycle better. I can provide insights, answer questions, and offer personalized recommendations. What interests you most?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  Future<void> _generateContextualSuggestions({AIContext? context}) async {
    context ??= await _buildCurrentContext();
    
    _currentSuggestions.clear();

    // Generate suggestions based on current context
    final route = context.currentRoute;
    
    if (route == '/calendar') {
      _currentSuggestions.addAll([
        AISuggestion(
          id: 'export_data',
          title: 'Export Your Data',
          description: 'Download your cycle data for backup or sharing with healthcare providers',
          actionText: 'Export',
          icon: Icons.download,
          color: Colors.blue,
          priority: 1,
        ),
        AISuggestion(
          id: 'cycle_insights',
          title: 'Cycle Insights',
          description: 'View personalized insights about your cycle patterns and trends',
          actionText: 'View Insights',
          icon: Icons.analytics,
          color: Colors.purple,
          priority: 2,
        ),
      ]);
    }

    if (route == '/tracking') {
      _currentSuggestions.addAll([
        AISuggestion(
          id: 'quick_log',
          title: 'Quick Symptom Log',
          description: 'Quickly log common symptoms and mood for today',
          actionText: 'Quick Log',
          icon: Icons.flash_on,
          color: Colors.orange,
          priority: 1,
        ),
        AISuggestion(
          id: 'remind_tracking',
          title: 'Set Tracking Reminder',
          description: 'Never forget to log your data with daily reminders',
          actionText: 'Set Reminder',
          icon: Icons.notifications,
          color: Colors.green,
          priority: 2,
        ),
      ]);
    }

    // General suggestions
    _currentSuggestions.addAll([
      AISuggestion(
        id: 'health_tips',
        title: 'Daily Health Tip',
        description: 'Get personalized health recommendations based on your cycle phase',
        actionText: 'Get Tips',
        icon: Icons.lightbulb,
        color: Colors.amber,
        priority: 3,
      ),
      AISuggestion(
        id: 'prediction_accuracy',
        title: 'Improve Predictions',
        description: 'Help improve cycle predictions by logging more data points',
        actionText: 'Learn How',
        icon: Icons.trending_up,
        color: Colors.teal,
        priority: 4,
      ),
    ]);

    // Sort by priority
    _currentSuggestions.sort((a, b) => a.priority.compareTo(b.priority));
  }

  Future<AIContext> _buildCurrentContext() async {
    final navigationService = NavigationService();
    final currentRoute = navigationService.currentRouteName;
    
    return AIContext(
      currentRoute: currentRoute,
      routeArguments: {},
      userPreferences: await _loadUserPreferences(),
      recentActions: await _getRecentActions(),
      appState: await _getAppState(),
      timestamp: DateTime.now(),
    );
  }

  Future<String> _getCurrentContext() async {
    final context = await _buildCurrentContext();
    return jsonEncode(context.toMap());
  }

  Future<Map<String, dynamic>> _loadUserPreferences() async {
    final prefsJson = _prefs?.getString(_preferencesKey);
    if (prefsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(prefsJson));
    }
    return {};
  }

  Future<List<String>> _getRecentActions() async {
    // This would integrate with app analytics to get recent user actions
    return ['opened_calendar', 'logged_symptoms', 'viewed_insights'];
  }

  Future<Map<String, dynamic>> _getAppState() async {
    return {
      'isFirstLaunch': _prefs?.getBool('is_first_launch') ?? true,
      'hasCompletedOnboarding': _prefs?.getBool('has_completed_onboarding') ?? false,
      'notificationsEnabled': _prefs?.getBool('notifications_enabled') ?? true,
    };
  }

  Future<void> _loadConversationHistory() async {
    try {
      final historyJson = _prefs?.getString(_conversationHistoryKey);
      if (historyJson != null) {
        final List<dynamic> historyData = jsonDecode(historyJson);
        _conversationHistory.clear();
        _conversationHistory.addAll(
          historyData.map((data) => AIConversationSession.fromMap(data)),
        );
      }
    } catch (e) {
      debugPrint('Error loading conversation history: $e');
    }
  }

  Future<void> _saveConversationHistory() async {
    try {
      await _prefs?.setString(
        _conversationHistoryKey,
        jsonEncode(_conversationHistory.map((c) => c.toMap()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving conversation history: $e');
    }
  }

  Future<void> _loadCurrentSession() async {
    try {
      final sessionJson = _prefs?.getString(_currentSessionKey);
      if (sessionJson != null) {
        _currentSession = AIConversationSession.fromMap(jsonDecode(sessionJson));
      }
    } catch (e) {
      debugPrint('Error loading current session: $e');
    }
  }

  Future<void> _saveCurrentSession() async {
    try {
      if (_currentSession != null) {
        await _prefs?.setString(
          _currentSessionKey,
          jsonEncode(_currentSession!.toMap()),
        );
      }
    } catch (e) {
      debugPrint('Error saving current session: $e');
    }
  }

  Future<void> _saveCurrentSessionToHistory() async {
    if (_currentSession != null) {
      _conversationHistory.add(_currentSession!);
      
      // Keep only recent conversations
      if (_conversationHistory.length > 50) {
        _conversationHistory.removeAt(0);
      }
      
      await _saveConversationHistory();
    }
  }

  AIConversationSession copyWith({
    String? id,
    List<AIMessage>? messages,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    String? title,
    Map<String, dynamic>? metadata,
  }) {
    return AIConversationSession(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      startedAt: startedAt ?? this.startedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      title: title ?? this.title,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Extension methods for AIConversationSession
extension AIConversationSessionExtensions on AIConversationSession {
  AIConversationSession copyWith({
    String? id,
    List<AIMessage>? messages,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    String? title,
    Map<String, dynamic>? metadata,
  }) {
    return AIConversationSession(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      startedAt: startedAt ?? this.startedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      title: title ?? this.title,
      metadata: metadata ?? this.metadata,
    );
  }
}
