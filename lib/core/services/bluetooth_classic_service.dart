part of 'bluetooth_service.dart';

class BtClassicService extends BtService {
  final _blueClassicPlugin = FlutterBlueClassic();

  bool _isAdapterListenerOn = false;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  final List<BtAdapterStateCallback> _adapterStateCallbacks = [];

  bool _isScanningStateListenerOn = false;
  StreamSubscription<bool>? _scanningStateSubscription;
  final List<BtScanStateCallback> _scanningStateCallbacks = [];

  bool _isConnectionStateListenerOn = false;
  StreamSubscription<BtConnectionState>? _connectionStateSubscription;
  BluetoothConnection? _connection;
  final List<BtConnectionStateCallback> _connectionStateCallbacks = [];

  bool _isDataListenerOn = false;
  final List<BtDataReceivedCallback> _dataReceivedCallbacks = [];
  StreamSubscription<Uint8List>? _dataReceivedSubscription;

  BtClassicService() {
    initPlatformState();
  }

  @override
  void addAdapterStateListener(BtAdapterStateCallback callback) {
    _startAdapterStateListener();
    _adapterStateCallbacks.add(callback);
  }

  @override
  void addScanStateListener(BtScanStateCallback callback) {
    _startScanStateListener();
    _scanningStateCallbacks.add(callback);
  }

  @override
  void addConnectionStateListener(BtConnectionStateCallback callback) {
    _startConnectionStateListener();
    _connectionStateCallbacks.add(callback);
  }

  @override
  void addDataListener(BtDataReceivedCallback callback) {
    _startDataListener();
    _dataReceivedCallbacks.add(callback);
  }

  @override
  Future<void> startScan() async {
    try {
      _blueClassicPlugin.startScan();
    } catch (e, s) {
      log('BluetoothClassicService<startScan>: $e\n$s');
      rethrow;
    }
  }

  @override
  void stopScan() {
    try {
      _blueClassicPlugin.stopScan();
    } catch (e, s) {
      log('BluetoothClassicService<stopScan>: $e\n$s');
      rethrow;
    }
  }

  @override
  Future<void> connect(String deviceId) async {
    try {
      _connection = await _blueClassicPlugin.connect(deviceId);
      _isConnected = true;
    } catch (e, s) {
      log('BluetoothClassicService<connect>: $e\n$s');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _connection?.close();
      _isConnected = false;
    } catch (e, s) {
      log('BluetoothClassicService<disconnect>: $e\n$s');
      rethrow;
    }
  }

  @override
  Future<void> sendData(BtData data, String filename) async {
    try {
      _isSending = true;
      // Implementation for sending data
    } catch (e, s) {
      log('BluetoothClassicService<sendData>: $e\n$s');
      rethrow;
    } finally {
      _isSending = false;
    }
  }

  Future<void> initPlatformState() async {
    try {
      _startAdapterStateListener();
      _startScanStateListener();
      _initialAdapterState();
      // Initial Check if the service is currently scanning.
      _isScanning = await _blueClassicPlugin.isScanningNow;

      final boundedDevices = await _blueClassicPlugin.bondedDevices ?? [];
      if (boundedDevices.isNotEmpty) {
        _isConnected = true;
      }
    } catch (e, s) {
      log('BluetoothClassicService<initPlatformState>: $e\n$s');
    }
  }

  void _startAdapterStateListener() {
    if (_isAdapterListenerOn) return;
    _isAdapterListenerOn = true;

    _adapterStateSubscription = _blueClassicPlugin.adapterState.listen((
      BluetoothAdapterState state,
    ) {
      BtAdapterState btState = _btAdapterStatefromBluetoothAdapterState(state);
      for (final callback in _adapterStateCallbacks) {
        callback(btState);
      }
    });
  }

  void _startScanStateListener() {
    if (_isScanningStateListenerOn) return;
    _isScanningStateListenerOn = true;

    _scanningStateSubscription ??= _blueClassicPlugin.isScanning.listen((
      isScanning,
    ) {
      _isScanning = isScanning;
      final btScanState = isScanning ? BtScanState.scanning : BtScanState.idle;
      for (final callback in _scanningStateCallbacks) {
        callback(btScanState);
      }
    });
  }

  void _startConnectionStateListener() {
    if (_isConnectionStateListenerOn) return;
    _isConnectionStateListenerOn = true;
  }

  void _startDataListener() {
    if (_isDataListenerOn) return;
    _isDataListenerOn = true;

    _dataReceivedSubscription ??= _connection!.input!.listen((data) {
      for (final callback in _dataReceivedCallbacks) {
        // TODO: Once data packet structure is created. Use that to determine the type of data.
        BtData btData = BtTextMessage(text: "TEST MODE");
        callback(btData);
      }
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanningStateSubscription?.cancel();
    super.dispose();
  }

  void _initialAdapterState() async {
    // Inital Check if the service is supported, and enabled.
    BluetoothAdapterState adapterState =
        await _blueClassicPlugin.adapterStateNow;
    switch (adapterState) {
      case BluetoothAdapterState.on:
        _isSupported = true;
        _isEnabled = true;
        break;
      case BluetoothAdapterState.off:
        _isSupported = true;
        _isEnabled = false;
        break;
      case BluetoothAdapterState.turningOn:
        _isSupported = true;
        _isEnabled = false;
        break;
      case BluetoothAdapterState.turningOff:
        _isSupported = true;
        _isEnabled = false;
        break;
      case BluetoothAdapterState.unknown:
        _isSupported = false;
        break;
    }
  }

  BtAdapterState _btAdapterStatefromBluetoothAdapterState(
    BluetoothAdapterState state,
  ) {
    switch (state) {
      case BluetoothAdapterState.unknown:
        return BtAdapterState.unknown;
      case BluetoothAdapterState.off:
        return BtAdapterState.off;
      case BluetoothAdapterState.on:
        return BtAdapterState.on;
      case BluetoothAdapterState.turningOn:
        return BtAdapterState.turningOn;
      case BluetoothAdapterState.turningOff:
        return BtAdapterState.turningOff;
    }
  }
}
