import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';
import 'package:offline_data_transfer/features/bluetooth/models/bt_device.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  final _flutterBlueClassicPlugin = FlutterBlueClassic();

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription? _adapterStateSubscription;

  final Set<BtDevice> _discovered = {};
  Set<BtDevice> get _discoveredNotBonded => _discovered.difference(_bonded);
  final Set<BtDevice> _bonded = {};
  StreamSubscription? _scanSubscription;
  BluetoothConnection? _connection;
  BtDevice? _connectedDevice;

  bool _isScanning = false;
  bool _isConnecting = false;
  int? _connectingToIndex;
  StreamSubscription? _scanningStateSubscription;

  @override
  void initState() {
    _permissions();
    super.initState();
    initPlatformState();
  }

  void _permissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]?.isDenied == true ||
        statuses[Permission.location]?.isDenied == true) {
      log('Permissions denied');
      return;
    }
  }

  Future<void> initPlatformState() async {
    BluetoothAdapterState adapterState = _adapterState;

    try {
      adapterState = await _flutterBlueClassicPlugin.adapterStateNow;
      await _checkBondedDevices();
      _adapterStateSubscription = _flutterBlueClassicPlugin.adapterState.listen(
        (current) {
          SchedulerBinding.instance.addPostFrameCallback(
            (_) => _checkBondedDevices(),
          );
          if (mounted) setState(() => _adapterState = current);
        },
      );
      _scanSubscription = _flutterBlueClassicPlugin.scanResults.listen((
        device,
      ) {
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            setState(
              () => _discoveredNotBonded.add(
                BtDevice(address: device.address, name: device.name),
              ),
            );
          });
        }
      });
      _scanningStateSubscription = _flutterBlueClassicPlugin.isScanning.listen((
        isScanning,
      ) {
        log("Scanning state changed: $isScanning");
        if (mounted) setState(() => _isScanning = isScanning);
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }

    if (!mounted) return;

    setState(() {
      _adapterState = adapterState;
    });
  }

  Future<void> _checkBondedDevices() async {
    try {
      final bonded = await _flutterBlueClassicPlugin.bondedDevices;
      if ((bonded ?? []).isNotEmpty) {
        setState(() {
          _bonded.clear();
          _bonded.addAll(
            bonded!.map((d) => BtDevice(address: d.address, name: d.name)),
          );
        });
      }
    } catch (e) {
      log('Error fetching bonded devices: $e');
    }
  }

  void _startScan() {
    try {
      _permissions();
      _flutterBlueClassicPlugin.startScan();
    } catch (e, s) {
      log('Error starting scan: $e\n$s');
    }
  }

  void _stopScan() {
    try {
      _flutterBlueClassicPlugin.stopScan();
    } catch (e, s) {
      log('Error stopping scan: $e\n$s');
    }
  }

  void _connectTo(BtDevice device) async {
    _isConnecting = true;
    setState(() {});
    _connection = await _flutterBlueClassicPlugin.connect(device.address);
    _isConnecting = false;
    setState(() {});
  }

  void _bondTo(BtDevice device) async {
    try {
      await _flutterBlueClassicPlugin.bondDevice(device.address);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bonded to ${device.displayName}')),
      );
      _bonded.add(device);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to bond: $e')));
    }
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanningStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Start scan',
              onPressed: _startScan,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_connection != null && _connectedDevice != null) ...[
              _ConnectedDeviceTile(
                device: _connectedDevice!,
                onDisconnect: () async {
                  _connection!.close();
                  setState(() => _connection = null);
                },
              ),
              const SizedBox(height: 16),
            ],
            // _SectionHeader(title: 'Paired Devices', count: _bonded.length),
            if (_bonded.isEmpty)
              const _EmptyHint(message: 'No paired devices found')
            else
              ..._bonded.map(
                (d) => _BondedDeviceTile(
                  device: d,
                  isConnected: _connection?.address == d.address,
                  isConnecting: _isConnecting,
                  onTap: () => _connectTo(d),
                ),
              ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Nearby Devices',
              count: _discoveredNotBonded.length,
              trailing: _isScanning
                  ? TextButton(onPressed: _stopScan, child: const Text('Stop'))
                  : TextButton(
                      onPressed: _startScan,
                      child: const Text('Scan'),
                    ),
            ),
            if (_isScanning && _discoveredNotBonded.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: _ScanningIndicator()),
              )
            else if (!_isScanning && _discoveredNotBonded.isEmpty)
              const _EmptyHint(message: 'Tap Scan to search for nearby devices')
            else
              ..._discoveredNotBonded.map(
                (d) => _ScannedDeviceTile(
                  device: d,
                  isConnected: false,
                  isConnecting: false,
                  onTap: () => _bondTo(d),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedDeviceTile extends StatelessWidget {
  final BtDevice device;
  final VoidCallback onDisconnect;

  const _ConnectedDeviceTile({
    required this.device,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withAlpha(20),
        border: Border.all(color: AppTheme.success),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.bluetooth_connected, color: AppTheme.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.displayName, style: TextStyles.semiBold),
                Text(
                  device.address,
                  style: TextStyles.regular.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onDisconnect,
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title, style: TextStyles.semiBold),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyles.regular.copyWith(
                  color: AppTheme.secondary,
                  fontSize: 12,
                ),
              ),
            ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _BondedDeviceTile extends StatelessWidget {
  final BtDevice device;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;

  const _BondedDeviceTile({
    required this.device,
    required this.isConnected,
    required this.isConnecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: isConnected ? AppTheme.success : AppTheme.textSecondary,
        ),
        title: Text(device.displayName, style: TextStyles.medium),
        subtitle: Text(
          device.address,
          style: TextStyles.regular.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 12,
          ),
        ),
        trailing: isConnected
            ? const Chip(
                label: Text('Sync On'),
                backgroundColor: Color(0xFFE6F9F1),
              )
            : isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Start Sync'),
              ),
      ),
    );
  }
}

class _ScannedDeviceTile extends StatelessWidget {
  final BtDevice device;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;

  const _ScannedDeviceTile({
    required this.device,
    required this.isConnected,
    required this.isConnecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: isConnected ? AppTheme.success : AppTheme.textSecondary,
        ),
        title: Text(device.displayName, style: TextStyles.medium),
        subtitle: Text(
          device.address,
          style: TextStyles.regular.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 12,
          ),
        ),
        trailing: isConnected
            ? const Chip(
                label: Text('Connected'),
                backgroundColor: Color(0xFFE6F9F1),
              )
            : isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Connect'),
              ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;

  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        style: TextStyles.regular.copyWith(color: AppTheme.textTertiary),
      ),
    );
  }
}

class _ScanningIndicator extends StatelessWidget {
  const _ScanningIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(
          'Scanning for devices...',
          style: TextStyles.regular.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
