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

  // TODO: drive these from your BT service
  final bool _isConnected = false;
  final String _deviceName = '';
  final List<BluetoothMessage> _messages = [];
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _textController.clear();

    // TODO: send via your BT service, e.g.:
    // final error = await yourBtService.sendText(text);
    // if (error != null) { show snackbar }

    setState(() {
      _messages.add(BluetoothMessage(text: text, isSent: true));
      _isSending = false;
    });
    _scrollToBottom();
  }

  // Call this when your BT service receives a text message
  void onMessageReceived(String text) {
    setState(() => _messages.add(BluetoothMessage(text: text, isSent: false)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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
              _isConnected ? _deviceName : 'Not connected',
              style: TextStyles.regular.copyWith(
                fontSize: 13,
                color: _isConnected ? AppTheme.success : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear messages',
            onPressed: _messages.isEmpty
                ? null
                : () => setState(() => _messages.clear()),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (!_isConnected) _DisconnectedBanner(),
            Expanded(
              child: _MessageList(
                messages: _messages,
                scrollController: _scrollController,
              ),
            ),
            _InputBar(
              controller: _textController,
              isSending: _isSending,
              isConnected: _isConnected,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisconnectedBanner extends StatelessWidget {
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
  final List<BluetoothMessage> messages;
  final ScrollController scrollController;

  const _MessageList({required this.messages, required this.scrollController});

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
              style: TextStyles.regular.copyWith(color: AppTheme.textTertiary),
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
      itemBuilder: (context, index) => _MessageBubble(message: messages[index]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final BluetoothMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;
    final timeStr =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          crossAxisAlignment: isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
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
                hintText: isConnected ? 'Type a message...' : 'Not connected',
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
