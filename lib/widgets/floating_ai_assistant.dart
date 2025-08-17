import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_assistant_service.dart';
import 'ai_assistant_avatar.dart';
import 'ai_assistant_chat.dart';

/// Floating AI Assistant Button with contextual intelligence
class FloatingAIAssistant extends StatefulWidget {
  final AIAssistantService? assistantService;
  
  const FloatingAIAssistant({
    super.key,
    this.assistantService,
  });

  @override
  State<FloatingAIAssistant> createState() => _FloatingAIAssistantState();
}

class _FloatingAIAssistantState extends State<FloatingAIAssistant>
    with TickerProviderStateMixin {
  late AIAssistantService _assistantService;
  late AnimationController _fabController;
  late AnimationController _overlayController;
  late AnimationController _quickActionsController;
  
  late Animation<double> _fabAnimation;
  late Animation<double> _overlayAnimation;
  late Animation<double> _quickActionsAnimation;

  bool _showQuickActions = false;
  OverlayEntry? _overlayEntry;
  OverlayEntry? _chatOverlayEntry;

  @override
  void initState() {
    super.initState();
    
    _assistantService = widget.assistantService ?? AIAssistantService();
    
    // Animation controllers
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _quickActionsController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Animations
    _fabAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    ));

    _overlayAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOutCubic,
    ));

    _quickActionsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _quickActionsController,
      curve: Curves.easeOutQuart,
    ));

    // Initialize service and start animation
    _initializeService();
    _fabController.forward();

    // Listen to assistant service changes
    _assistantService.addListener(_onAssistantServiceChanged);
  }

  Future<void> _initializeService() async {
    await _assistantService.initialize();
    
    // Generate contextual insights periodically
    _generatePeriodicInsights();
  }

  void _generatePeriodicInsights() {
    // Generate insights every 30 seconds when the assistant is not visible
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_assistantService.isVisible && mounted) {
        _assistantService.generateContextualInsights();
      }
    });
  }

  void _onAssistantServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _assistantService.removeListener(_onAssistantServiceChanged);
    _fabController.dispose();
    _overlayController.dispose();
    _quickActionsController.dispose();
    _removeOverlay();
    _removeChatOverlay();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    
    if (_assistantService.isVisible) {
      _hideAssistant();
    } else {
      _showAssistant();
    }
  }

  void _onLongPress() {
    HapticFeedback.heavyImpact();
    _toggleQuickActions();
  }

  void _showAssistant() {
    _assistantService.show();
    _showChatOverlay();
  }

  void _hideAssistant() {
    _assistantService.hide();
    _removeChatOverlay();
  }

  void _toggleQuickActions() {
    setState(() {
      _showQuickActions = !_showQuickActions;
    });

    if (_showQuickActions) {
      _quickActionsController.forward();
      _showQuickActionsOverlay();
    } else {
      _quickActionsController.reverse();
      _removeOverlay();
    }
  }

  void _showQuickActionsOverlay() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildQuickActionsOverlay(),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    _overlayController.forward();
  }

  void _showChatOverlay() {
    _removeChatOverlay();
    
    _chatOverlayEntry = OverlayEntry(
      builder: (context) => _buildChatOverlay(),
    );
    
    Overlay.of(context).insert(_chatOverlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  void _removeChatOverlay() {
    _chatOverlayEntry?.remove();
    _chatOverlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fabAnimation, _assistantService]),
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: GestureDetector(
            onTap: _onTap,
            onLongPress: _onLongPress,
            child: AIAssistantAvatar(
              onTap: _onTap,
              isActive: _assistantService.isVisible || _assistantService.isLoading,
              hasNotification: _assistantService.hasNewSuggestions,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsOverlay() {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              _toggleQuickActions();
            },
            child: Container(
              color: Colors.black.withOpacity(0.3 * _overlayAnimation.value),
              child: Stack(
                children: [
                  // Position quick actions near the FAB
                  Positioned(
                    right: 16,
                    bottom: 140, // Above the FAB
                    child: Transform.scale(
                      scale: _overlayAnimation.value,
                      child: _buildQuickActionsList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsList() {
    final suggestions = _assistantService.currentSuggestions.take(4).toList();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Quick actions title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Quick action buttons
        ...suggestions.asMap().entries.map((entry) {
          final index = entry.key;
          final suggestion = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(bottom: index < suggestions.length - 1 ? 8 : 0),
            child: _buildQuickActionButton(suggestion),
          );
        }),
        
        const SizedBox(height: 8),
        
        // Open chat action
        _buildQuickActionButton(
          AISuggestion(
            id: 'open_chat',
            title: 'Open Chat',
            description: 'Start a conversation with AI Assistant',
            actionText: 'Chat',
            icon: Icons.chat,
            color: Colors.blue,
          ),
          onTap: () {
            _toggleQuickActions();
            _showAssistant();
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(AISuggestion suggestion, {VoidCallback? onTap}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        child: InkWell(
          onTap: onTap ?? () {
            HapticFeedback.lightImpact();
            if (suggestion.action != null) {
              suggestion.action!();
            } else {
              _assistantService.sendMessage('${suggestion.actionText}: ${suggestion.title}');
              _showAssistant();
            }
            _toggleQuickActions();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: suggestion.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    suggestion.icon,
                    size: 20,
                    color: suggestion.color,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        suggestion.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (suggestion.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          suggestion.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatOverlay() {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          // Tap outside to close
          _hideAssistant();
        },
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping on chat
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AIAssistantChat(
                assistantService: _assistantService,
                onClose: _hideAssistant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Positioned Floating AI Assistant that can be placed anywhere in the widget tree
class PositionedFloatingAIAssistant extends StatelessWidget {
  final AIAssistantService? assistantService;
  final Alignment alignment;
  final EdgeInsets margin;

  const PositionedFloatingAIAssistant({
    super.key,
    this.assistantService,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        child: FloatingAIAssistant(
          assistantService: assistantService,
        ),
      ),
    );
  }
}

/// Floating AI Assistant Wrapper for easy integration
class AIAssistantWrapper extends StatefulWidget {
  final Widget child;
  final AIAssistantService? assistantService;
  final bool enabled;
  final Alignment alignment;
  final EdgeInsets margin;

  const AIAssistantWrapper({
    super.key,
    required this.child,
    this.assistantService,
    this.enabled = true,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(16),
  });

  @override
  State<AIAssistantWrapper> createState() => _AIAssistantWrapperState();
}

class _AIAssistantWrapperState extends State<AIAssistantWrapper> {
  late AIAssistantService _assistantService;

  @override
  void initState() {
    super.initState();
    _assistantService = widget.assistantService ?? AIAssistantService();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        if (widget.enabled)
          PositionedFloatingAIAssistant(
            assistantService: _assistantService,
            alignment: widget.alignment,
            margin: widget.margin,
          ),
      ],
    );
  }
}

// Timer import
import 'dart:async';
