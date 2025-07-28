import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/ai_chat_service.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/services/logger_service.dart';

class ProfileBuildingScreen extends ConsumerStatefulWidget {
  const ProfileBuildingScreen({super.key});

  @override
  ConsumerState<ProfileBuildingScreen> createState() => _ProfileBuildingScreenState();
}

class _ProfileBuildingScreenState extends ConsumerState<ProfileBuildingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  
  ConversationContext? _context;
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        LoggerService.error('ProfileBuildingScreen', '_initializeChat', 'User ID is null');
        return;
      }

      // Check if there's an existing context
      ConversationContext? existingContext = await AIChatService.getConversationContext(userId);
      
      if (existingContext != null) {
        _context = existingContext;
        _messages = existingContext.conversationHistory;
      } else {
        // Start new session
        _context = await AIChatService.startProfileBuildingSession(userId);
        _messages = _context!.conversationHistory;
      }

      // Check if profile building is complete
      _isProfileComplete = await AIChatService.isProfileBuildingComplete(userId);

      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      LoggerService.error('ProfileBuildingScreen', '_initializeChat', 'Failed to initialize: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null || _context == null) return;

      // Clear input immediately
      _messageController.clear();

      // Add user message to UI
      final userMessage = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: userId,
        content: message,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
        emojis: [],
        isRead: true,
      );

      setState(() {
        _messages.add(userMessage);
      });

      _scrollToBottom();

      // Get AI response
      String aiResponse = await AIChatService.processUserMessage(userId, message, _context!);

      // Add AI response to UI
      final aiMessage = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'ai_assistant',
        content: aiResponse,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
        emojis: [],
        isRead: true,
      );

      setState(() {
        _messages.add(aiMessage);
      });

      _scrollToBottom();

      // Check if profile is now complete
      _isProfileComplete = await AIChatService.isProfileBuildingComplete(userId);
      
      if (_isProfileComplete) {
        _showProfileCompleteDialog();
      }

    } catch (e) {
      LoggerService.error('ProfileBuildingScreen', '_sendMessage', 'Failed to send message: $e');
      _showErrorSnackBar('Failed to send message. Please try again.');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.normalAnimation,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showProfileCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Profile Complete! 🎉'),
        content: const Text(
          'Great job! Your profile is now complete and ready for matching. Let\'s find your perfect match!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Start Matching'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Build Your Profile'),
        actions: [
          if (_isProfileComplete)
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Continue'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(theme),

          // Chat messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessageList(theme),
          ),

          // Message input
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Profile Assistant',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isProfileComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Complete',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _isProfileComplete ? 1.0 : 0.7, // Simplified progress
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            _isProfileComplete 
                ? 'Profile building complete!' 
                : 'Building your profile...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme) {
    if (_messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isAI = message.senderId == 'ai_assistant';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAI) ...[
                // AI Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              Expanded(
                child: Column(
                  crossAxisAlignment: isAI 
                      ? CrossAxisAlignment.start 
                      : CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAI 
                            ? theme.colorScheme.surface
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomLeft: isAI ? const Radius.circular(4) : null,
                          bottomRight: isAI ? null : const Radius.circular(4),
                        ),
                        border: isAI 
                            ? Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.2),
                              )
                            : null,
                      ),
                      child: Text(
                        message.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isAI 
                              ? theme.colorScheme.onSurface
                              : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (!isAI) ...[
                const SizedBox(width: 12),
                // User Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}