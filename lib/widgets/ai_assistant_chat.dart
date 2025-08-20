import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_assistant_service.dart';
import 'dart:math' as math;

/// AI Assistant Chat Interface
class AIAssistantChat extends StatefulWidget {
  final AIAssistantService assistantService;
  final VoidCallback? onClose;

  const AIAssistantChat({
    super.key,
    required this.assistantService,
    this.onClose,
  });

  @override
  State<AIAssistantChat> createState() => _AIAssistantChatState();
}

class _AIAssistantChatState extends State<AIAssistantChat>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _slideController;
  late AnimationController _suggestionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _suggestionAnimation;

  bool _showSuggestions = true;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _suggestionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _suggestionAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _suggestionController,
      curve: Curves.easeOutQuart,
    ));

    // Start animations
    _slideController.forward();
    _suggestionController.forward();

    // Listen to assistant service changes
    widget.assistantService.addListener(_onAssistantServiceChanged);

    // Initialize if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.assistantService.currentSession == null) {
        widget.assistantService.startNewConversation();
      }
    });
  }

  void _onAssistantServiceChanged() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    widget.assistantService.removeListener(_onAssistantServiceChanged);
    _slideController.dispose();
    _suggestionController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.assistantService.sendMessage(message);
      _messageController.clear();
      setState(() {
        _showSuggestions = false;
      });
      _focusNode.unfocus();
    }
  }

  void _onSuggestionTapped(AISuggestion suggestion) {
    // Execute suggestion action or send as message
    if (suggestion.action != null) {
      suggestion.action!();
    } else {
      widget.assistantService.sendMessage('${suggestion.actionText}: ${suggestion.title}');
    }
    
    setState(() {
      _showSuggestions = false;
    });

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Suggestions (if visible and available)
            if (_showSuggestions && widget.assistantService.currentSuggestions.isNotEmpty)
              _buildSuggestions(),
            
            // Chat messages
            Expanded(
              child: _buildMessageList(),
            ),
            
            // Input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withValues(alpha: 0.8),
                  Colors.blueAccent.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 22,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.assistantService.isLoading)
                  Text(
                    'Typing...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Text(
                    'Online',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
          
          // Action buttons
          IconButton(
            onPressed: () {
              widget.assistantService.startNewConversation();
              setState(() {
                _showSuggestions = true;
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'New Conversation',
          ),
          
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return AnimatedBuilder(
      animation: _suggestionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _suggestionAnimation.value,
          child: Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.assistantService.currentSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = widget.assistantService.currentSuggestions[index];
                return _buildSuggestionCard(suggestion);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionCard(AISuggestion suggestion) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _onSuggestionTapped(suggestion),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: suggestion.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        suggestion.icon,
                        size: 18,
                        color: suggestion.color,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  suggestion.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  suggestion.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    final session = widget.assistantService.currentSession;
    if (session == null || session.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: session.messages.length,
      itemBuilder: (context, index) {
        final message = session.messages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withValues(alpha: 0.1),
                  Colors.blueAccent.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.psychology,
              size: 40,
              color: Colors.blue,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'AI Assistant Ready',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Ask me anything about CycleSync\nor your cycle tracking journey!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message, int index) {
    final isUser = message.type == AIMessageType.user;
    final isSystem = message.type == AIMessageType.system;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        top: index == 0 ? 8 : 0,
      ),
      child: Row(
        mainAxisAlignment: isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && !isSystem) ...[
            // AI Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withValues(alpha: 0.8),
                    Colors.blueAccent.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getMessageBackgroundColor(message),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isTyping)
                    _buildTypingIndicator()
                  else
                    Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getMessageTextColor(message),
                      ),
                    ),
                  
                  if (!message.isTyping) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getMessageTextColor(message)?.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            // User Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTypingDot(0),
        const SizedBox(width: 4),
        _buildTypingDot(1),
        const SizedBox(width: 4),
        _buildTypingDot(2),
      ],
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: widget.assistantService,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.4, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 150)),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Message input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMessageBackgroundColor(AIMessage message) {
    switch (message.type) {
      case AIMessageType.user:
        return Theme.of(context).colorScheme.primary;
      case AIMessageType.system:
        return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1);
      default:
        return Theme.of(context).colorScheme.surface;
    }
  }

  Color? _getMessageTextColor(AIMessage message) {
    switch (message.type) {
      case AIMessageType.user:
        return Theme.of(context).colorScheme.onPrimary;
      case AIMessageType.system:
        return Theme.of(context).colorScheme.secondary;
      default:
        return Theme.of(context).textTheme.bodyMedium?.color;
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
