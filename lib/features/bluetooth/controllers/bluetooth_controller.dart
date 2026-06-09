import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BluetoothController extends GetxController {
  BluetoothController();
  final ImagePicker _picker = ImagePicker();

  final selectedImage = Rx<XFile?>(null);
  final RxBool _isScanning = false.obs;
  final RxBool _isPairing = false.obs;
  final RxBool _searchingForBondedDevices = false.obs;
  final RxBool _isConnecting = false.obs;

  bool get isScanning => _isScanning.value;
  bool get isPairing => _isPairing.value;
  bool get searchingForBondedDevices => _searchingForBondedDevices.value;

  final Rx<BluetoothAdapterState> _currentState =
      BluetoothAdapterState.unknown.obs;
  bool get isAdapterOn => _currentState.value == BluetoothAdapterState.on;

  final RxSet<BluetoothDevice> _scannedDevices = <BluetoothDevice>{}.obs;
  Set<BluetoothDevice> get scannedDevices => _scannedDevices;

  final RxSet<BluetoothDevice> _pairedDevices = <BluetoothDevice>{}.obs;
  Set<BluetoothDevice> get pairedDevices => _pairedDevices;

  final RxMap<BluetoothDevice, BluetoothConnection> _connections =
      <BluetoothDevice, BluetoothConnection>{}.obs;
  RxMap<BluetoothDevice, BluetoothConnection> get connections => _connections;

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothDevice>? _scanSubscription;
  StreamSubscription<bool>? _scanStateSubscription;

  final FlutterBlueClassic _blue = FlutterBlueClassic();

  @override
  void onInit() {
    super.onInit();
    _listenForAdapterState();
    _listenForDevices();
    _listenForScanState();
    getBondedDevices();
  }

  @override
  void onClose() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanStateSubscription?.cancel();
    super.onClose();
  }

  void _listenForAdapterState() async {
    log("Started listening to AdapterStateChange");
    _currentState.value = await _blue.adapterStateNow;
    _adapterStateSubscription = _blue.adapterState.listen((state) {
      log("ADAPTER STATE CHANGED TO: $state");
      _currentState.value = state;
    });
  }

  void _listenForDevices() {
    log("Started listening for devices");
    _scanSubscription = _blue.scanResults.listen((device) {
      log("Found device: ${device.alias}:${device.address}");
      if (device.alias == null) return;
      _scannedDevices.add(device);
    });
  }

  void _listenForScanState() async {
    log("Started listening for scan state");
    _isScanning.value = await _blue.isScanningNow;
    _scanStateSubscription = _blue.isScanning.listen((isScanning) {
      log("Scan state changed: isScanning: $isScanning");
      if (_isScanning.value == isScanning) return;
      _isScanning.value = isScanning;
    });
  }

  void toggleScan() async {
    if (_isScanning.value) {
      _stopScan();
    } else {
      _startScan();
    }
  }

  void _startScan() async {
    try {
      _isScanning.value = true;
      _blue.startScan();
    } catch (e, s) {
      log("BluetoothController<_startScan>: $e\n$s");
    }
  }

  void _stopScan() async {
    try {
      _isScanning.value = false;
      _blue.stopScan();
    } catch (e, s) {
      log("BluetoothController<_stopScan>: $e\n$s");
    }
  }

  void pairToDevice(BluetoothDevice device) async {
    try {
      _isPairing.value = true;
      final isSuccess = await _blue.bondDevice(device.address);
      if (isSuccess) {
        _pairedDevices.add(device);
      }
    } catch (e, s) {
      log("BluetoothController<pairToDevice>: $e\n$s");
    } finally {
      _isPairing.value = false;
    }
  }

  void getBondedDevices() async {
    try {
      _searchingForBondedDevices.value = true;
      final bonded = await _blue.bondedDevices;
      if(bonded == null || bonded.isEmpty) return;
      _pairedDevices.addAll(bonded);
    } catch (e, s) {
      log("BluetoothController<pairToDevice>: $e\n$s");
    } finally {
      _searchingForBondedDevices.value = false;
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      if (_connections.keys.contains(device)) return;
      _isPairing.value = true;
      final connection = await _blue.connect(device.address);

      if (connection != null) {
        _connections.addAll({device: connection});
      }
    } catch (e, s) {
      log("BluetoothController<pairToDevice>: $e\n$s");
    } finally {
      _isPairing.value = false;
    }
  }

  void pickImageFromCamera() => _pickImage(ImageSource.camera);
  void pickImageFromGallery() => _pickImage(ImageSource.gallery);

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (file == null) return;
    selectedImage.value = file;
  }
}
