import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';
import 'package:offline_data_transfer/features/bluetooth/models/bluetooth_message.dart';

class BluetoothImageScreen extends StatefulWidget {
  const BluetoothImageScreen({super.key});

  @override
  State<BluetoothImageScreen> createState() => _BluetoothImageScreenState();
}

class _BluetoothImageScreenState extends State<BluetoothImageScreen> {
  final _picker = ImagePicker();

  // TODO: drive these from your BT service
  final bool _isConnected = false;
  final List<BluetoothImageTransfer> _transfers = [];
  bool _isSending = false;

  Uint8List? _selectedImage;
  BluetoothImageTransfer? _previewTransfer;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedImage = bytes;
      _previewTransfer = null;
    });
  }

  Future<void> _sendSelected() async {
    if (_selectedImage == null || _isSending) return;
    setState(() => _isSending = true);

    // TODO: send via your BT service, e.g.:
    // final error = await yourBtService.sendImage(_selectedImage!);
    // if (error != null) { show snackbar; return; }

    setState(() {
      _transfers.add(
        BluetoothImageTransfer(bytes: _selectedImage!, isSent: true),
      );
      _selectedImage = null;
      _isSending = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image sent'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  // Call this when your BT service receives image bytes
  void onImageReceived(Uint8List bytes) {
    setState(() {
      final transfer = BluetoothImageTransfer(bytes: bytes, isSent: false);
      _transfers.add(transfer);
      _previewTransfer = transfer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Transfer'),
        actions: [
          if (_transfers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear history',
              onPressed: () => setState(() {
                _transfers.clear();
                _previewTransfer = null;
                _selectedImage = null;
              }),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (!_isConnected) _DisconnectedBanner(),
            Expanded(
              child: _previewTransfer != null
                  ? _ImagePreview(
                      transfer: _previewTransfer!,
                      onDismiss: () => setState(() => _previewTransfer = null),
                    )
                  : _selectedImage != null
                  ? _SelectedImagePreview(
                      bytes: _selectedImage!,
                      isSending: _isSending,
                      onSend: _isConnected ? _sendSelected : null,
                      onClear: () => setState(() => _selectedImage = null),
                    )
                  : _TransferHistory(
                      transfers: _transfers,
                      onTapTransfer: (t) =>
                          setState(() => _previewTransfer = t),
                    ),
            ),
            _BottomActions(
              isConnected: _isConnected,
              isSending: _isSending,
              hasSelection: _selectedImage != null,
              onPickGallery: () => _pickImage(ImageSource.gallery),
              onPickCamera: () => _pickImage(ImageSource.camera),
              onSend: _isConnected && _selectedImage != null && !_isSending
                  ? _sendSelected
                  : null,
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
            'No active connection — you can preview but not send',
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

class _ImagePreview extends StatelessWidget {
  final BluetoothImageTransfer transfer;
  final VoidCallback onDismiss;

  const _ImagePreview({required this.transfer, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: InteractiveViewer(
            child: Image.memory(transfer.bytes, fit: BoxFit.contain),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _BadgeChip(
                label: transfer.isSent ? 'Sent' : 'Received',
                color: transfer.isSent ? AppTheme.secondary : AppTheme.success,
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  final Uint8List bytes;
  final bool isSending;
  final VoidCallback? onSend;
  final VoidCallback onClear;

  const _SelectedImagePreview({
    required this.bytes,
    required this.isSending,
    required this.onSend,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: InteractiveViewer(
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              const _BadgeChip(label: 'Selected', color: AppTheme.warning),
              const SizedBox(width: 8),
              if (!isSending)
                IconButton.filled(
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
        if (isSending)
          Container(
            color: Colors.black45,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Sending...',
                    style: TextStyles.medium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TransferHistory extends StatelessWidget {
  final List<BluetoothImageTransfer> transfers;
  final ValueChanged<BluetoothImageTransfer> onTapTransfer;

  const _TransferHistory({
    required this.transfers,
    required this.onTapTransfer,
  });

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
              style: TextStyles.regular.copyWith(color: AppTheme.textTertiary),
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
        return GestureDetector(
          onTap: () => onTapTransfer(t),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(t.bytes, fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: _BadgeChip(
                  label: t.isSent ? 'Sent' : 'Rcvd',
                  color: t.isSent ? AppTheme.secondary : AppTheme.success,
                  small: true,
                ),
              ),
            ],
          ),
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

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _BadgeChip({
    required this.label,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyles.regular.copyWith(
          color: Colors.white,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
