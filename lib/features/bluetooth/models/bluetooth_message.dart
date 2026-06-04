import 'dart:typed_data';

class BluetoothMessage {
  final String text;
  final bool isSent;
  final DateTime timestamp;

  BluetoothMessage({
    required this.text,
    required this.isSent,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class BluetoothImageTransfer {
  final Uint8List bytes;
  final bool isSent;
  final DateTime timestamp;

  BluetoothImageTransfer({
    required this.bytes,
    required this.isSent,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
