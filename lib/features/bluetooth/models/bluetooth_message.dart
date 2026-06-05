import 'dart:typed_data';

import 'package:offline_data_transfer/core/enums/bt_data_type.dart';

sealed class BtData {
  final Object data;
  final BtDataType type;
  final DateTime timestamp;
  BtData({required this.data, required this.type, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class BtTextMessage extends BtData {
  final String text;

  BtTextMessage({required this.text, super.timestamp})
    : super(data: text, type: BtDataType.text);
}

class BtImageTransfer extends BtData {
  final Uint8List bytes;

  BtImageTransfer({required this.bytes, super.timestamp})
    : super(data: bytes, type: BtDataType.image);
}
