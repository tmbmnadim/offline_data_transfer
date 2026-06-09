import 'package:flutter/material.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';
import 'package:offline_data_transfer/features/bluetooth/models/bluetooth_message.dart';

class BluetoothImageScreen extends StatelessWidget {
  const BluetoothImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Transfer')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _DisconnectedBanner(),
            const Expanded(
              child: _TransferHistory(transfers: []),
            ),
            _BottomActions(
              isConnected: false,
              isSending: false,
              hasSelection: false,
              onPickGallery: () {},
              onPickCamera: () {},
              onSend: null,
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
            'No active connection. Please connect to a device to send or receive images.',
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

class _TransferHistory extends StatelessWidget {
  final List<BtImageTransfer> transfers;

  const _TransferHistory({required this.transfers});

  @override
  Widget build(BuildContext context) {
    if (transfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 56, color: AppTheme.border),
            const SizedBox(height: 12),
            Text(
              'No images yet',
              style:
                  TextStyles.regular.copyWith(color: AppTheme.textTertiary),
            ),
            Text(
              'Pick an image below to send, or wait to receive one',
              style: TextStyles.regular.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final t = transfers[transfers.length - 1 - index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(t.bytes, fit: BoxFit.cover),
        );
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool isConnected;
  final bool isSending;
  final bool hasSelection;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback? onSend;

  const _BottomActions({
    required this.isConnected,
    required this.isSending,
    required this.hasSelection,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Gallery'),
              onPressed: isSending ? null : onPickGallery,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Camera'),
              onPressed: isSending ? null : onPickCamera,
            ),
          ),
          if (hasSelection) ...[
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Send'),
                onPressed: onSend,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
