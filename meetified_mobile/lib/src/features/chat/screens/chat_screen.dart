import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String matchId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.matchId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'content': 'Hey! Thanks for the match 😊',
      'isMe': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': true,
    },
    {
      'id': '2',
      'content': 'Hi there! I\'m excited to get to know you better!',
      'isMe': true,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      'isRead': true,
    },
    {
      'id': '3',
      'content': 'I saw that we both love hiking. Do you have any favorite trails?',
      'isMe': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      'isRead': true,
    },
    {
      'id': '4',
      'content': 'Yes! I love the trails in the mountains. There\'s this one spot with an amazing waterfall view.',
      'isMe': true,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      'isRead': true,
    },
    {
      'id': '5',
      'content': 'That sounds incredible! I\'d love to hear more about it 🏔️',
      'isMe': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': true,
    },
  ];

  bool _isTyping = false;
  bool _isAnonymous = true; // Start with anonymous chat

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'isMe': true,
        'timestamp': DateTime.now(),
        'isRead': false,
      });
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate typing indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate response after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': _getSimulatedResponse(content),
            'isMe': false,
            'timestamp': DateTime.now(),
            'isRead': true,
          });
        });
        _scrollToBottom();
      }
    });
  }

  String _getSimulatedResponse(String userMessage) {
    final responses = [
      'That\'s really interesting!',
      'Tell me more about that 😊',
      'I totally agree with you!',
      'That sounds amazing!',
      'I\'d love to hear your thoughts on that',
      'Wow, that\'s so cool!',
      'I can relate to that so much',
    ];
    return responses[DateTime.now().millisecond % responses.length];
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

  void _showRevealIdentityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reveal Identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ready to reveal your identity? This will show your name and photos to your match.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Premium feature - Upgrade for instant identity reveals',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to premium screen
            },
            child: const Text('Upgrade to Premium'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isAnonymous = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Identity revealed! Your match can now see your profile.'),
                ),
              );
            },
            child: const Text('Reveal Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _isAnonymous ? Icons.person_outline : Icons.person,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isAnonymous ? 'Anonymous Match' : 'Sarah Johnson',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isAnonymous 
                        ? 'Identities hidden' 
                        : 'Last seen 5 minutes ago',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_isAnonymous)
            IconButton(
              onPressed: _showRevealIdentityDialog,
              icon: Icon(
                Icons.visibility,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Reveal Identity',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'report':
                  // Handle report
                  break;
                case 'block':
                  // Handle block
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report_outlined),
                    SizedBox(width: 12),
                    Text('Report'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_outlined),
                    SizedBox(width: 12),
                    Text('Block'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Anonymous chat notice
          if (_isAnonymous)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anonymous chat - Identities are hidden until revealed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(theme);
                }

                final message = _messages[index];
                return _buildMessage(theme, message);
              },
            ),
          ),

          // Message input
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessage(ThemeData theme, Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    final content = message['content'] as String;
    final timestamp = message['timestamp'] as DateTime;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _isAnonymous ? Icons.person_outline : Icons.person,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: isMe ? null : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : null,
                    ),
                    border: isMe 
                        ? null 
                        : Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                  ),
                  child: Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe 
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _isAnonymous ? Icons.person_outline : Icons.person,
              color: theme.colorScheme.secondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'typing...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            IconButton(
              onPressed: () {
                // Show emoji picker
              },
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
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
                onPressed: _sendMessage,
                icon: const Icon(
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
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}