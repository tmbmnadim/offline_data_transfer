import 'package:flutter/material.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';
import 'package:offline_data_transfer/features/bluetooth/models/bluetooth_message.dart';

class BluetoothChatScreen extends StatefulWidget {
  const BluetoothChatScreen({super.key});

  @override
  State<BluetoothChatScreen> createState() => _BluetoothChatScreenState();
}

class _BluetoothChatScreenState extends State<BluetoothChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Text Chat'),
            Text(
              'Not connected',
              style: TextStyles.regular.copyWith(
                fontSize: 13,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear messages',
            onPressed: null,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _DisconnectedBanner(),
            Expanded(
              child: _MessageList(
                messages: const [],
                scrollController: _scrollController,
              ),
            ),
            _InputBar(
              controller: _textController,
              isSending: false,
              isConnected: false,
              onSend: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DisconnectedBanner extends StatelessWidget {
  const _DisconnectedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.warning.withAlpha(40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'No active connection — messages cannot be sent',
            style: TextStyles.regular.copyWith(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<BtTextMessage> messages;
  final ScrollController scrollController;

  const _MessageList(
      {required this.messages, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.border),
            const SizedBox(height: 12),
            Text(
              'No messages yet',
              style:
                  TextStyles.regular.copyWith(color: AppTheme.textTertiary),
            ),
            Text(
              'Type something below and tap Send',
              style: TextStyles.regular.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) => _MessageBubble(
        message: messages[index],
        isSent: false,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final BtTextMessage message;
  final bool isSent;

  const _MessageBubble({required this.message, required this.isSent});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSent ? AppTheme.secondary : Colors.white,
          border: isSent ? null : Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSent ? 16 : 4),
            bottomRight: Radius.circular(isSent ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyles.regular.copyWith(
                color: isSent ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyles.regular.copyWith(
                fontSize: 11,
                color: isSent
                    ? Colors.white.withAlpha(180)
                    : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final bool isConnected;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.isConnected,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isConnected,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText:
                    isConnected ? 'Type a message...' : 'Not connected',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: isConnected && !isSending ? onSend : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
