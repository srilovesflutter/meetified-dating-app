import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Active matches header
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Matches',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: _buildActiveMatch(theme, index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Recent chats
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildChatItem(theme, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveMatch(ThemeData theme, int index) {
    final names = ['Sarah', 'Emma', 'Jessica', 'Amanda', 'Rachel'];
    final isOnline = [true, false, true, false, true];

    return GestureDetector(
      onTap: () {
        context.go('/chat/match_$index', extra: 'match_$index');
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ),
              if (isOnline[index])
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            names[index],
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ThemeData theme, int index) {
    final names = ['Sarah Johnson', 'Emma Davis', 'Jessica Wilson', 'Amanda Brown', 'Rachel Garcia', 'Sophie Miller', 'Lisa Taylor', 'Maria Rodriguez'];
    final lastMessages = [
      'Hey! Thanks for the match 😊',
      'That\'s so interesting! Tell me more',
      'Would love to chat more about travel',
      'AI Assistant: I\'d like to know more about...',
      'Haha, that\'s funny! 😄',
      'What do you think about...',
      'AI Assistant: What are your thoughts on...',
      'Looking forward to hearing from you!'
    ];
    final times = ['2m', '1h', '3h', '5h', '1d', '2d', '3d', '1w'];
    final unreadCounts = [2, 0, 1, 0, 0, 3, 0, 1];
    final isAIMessage = [false, false, false, true, false, false, true, false];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      leading: Stack(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: isAIMessage[index]
                ? Icon(
                    Icons.psychology,
                    color: theme.colorScheme.primary,
                    size: 28,
                  )
                : Icon(
                    Icons.person,
                    size: 28,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
          ),
          if (unreadCounts[index] > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  '${unreadCounts[index]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              isAIMessage[index] ? 'AI Assistant' : names[index],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: unreadCounts[index] > 0 
                    ? FontWeight.bold 
                    : FontWeight.w500,
              ),
            ),
          ),
          Text(
            times[index],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          lastMessages[index],
          style: theme.textTheme.bodyMedium?.copyWith(
            color: unreadCounts[index] > 0
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: unreadCounts[index] > 0 
                ? FontWeight.w500 
                : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        context.go('/chat/chat_$index', extra: 'match_$index');
      },
    );
  }
}