import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:offline_data_transfer/core/enums/bt_adapter_state.dart';
import 'package:offline_data_transfer/core/enums/bt_connection_state.dart';
import 'package:offline_data_transfer/core/enums/bt_scan_state.dart';
import 'package:offline_data_transfer/features/bluetooth/models/bluetooth_message.dart';
import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter_blue_classic/flutter_blue_classic.dart';

part 'bluetooth_classic_service.dart';

typedef BtAdapterStateCallback = void Function(BtAdapterState state);
typedef BtScanStateCallback = void Function(BtScanState state);
typedef BtConnectionStateCallback = void Function(BtConnectionState state);
typedef BtDataReceivedCallback = void Function(BtData data);

sealed class BtService extends GetxService {
  bool _isSupported = false;
  bool _isEnabled = false;
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isSending = false;

  final List<BtData> _transfers = [];

  BtData? _previewTransfer;

  bool get isSupported => _isSupported;
  bool get isEnabled => _isEnabled;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isSending => _isSending;

  List<BtData> get transfers => _transfers;
  BtData? get previewTransfer => _previewTransfer;

  // Core Bluetooth operations
  Future<void> sendData(BtData data, String filename);

  Future<void> startScan();

  void stopScan();

  Future<void> connect(String deviceId);

  Future<void> disconnect();

  // Listener registration methods
  void addAdapterStateListener(BtAdapterStateCallback callback);

  void addScanStateListener(BtScanStateCallback callback);

  void addConnectionStateListener(BtConnectionStateCallback callback);

  void addDataListener(BtDataReceivedCallback callback);

  void dispose() {}
}
