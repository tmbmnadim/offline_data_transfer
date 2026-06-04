import 'package:flutter/material.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';

// Minimal device model — swap for your BT package's device type when wiring up
class BtDevice {
  final String address;
  final String? name;

  const BtDevice({required this.address, this.name});

  String get displayName => name?.isNotEmpty == true ? name! : address;
}

class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  // TODO: populate from your BT service
  final List<BtDevice> _bonded = [];
  final List<BtDevice> _discovered = [];
  BtDevice? _connected;
  bool _isScanning = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadBonded();
  }

  Future<void> _loadBonded() async {
    // TODO: fetch bonded/paired devices from your BT service
    // final devices = await yourBtService.bondedDevices;
    // setState(() => _bonded = devices.map(...).toList());
  }

  Future<void> _startScan() async {
    setState(() {
      _discovered.clear();
      _isScanning = true;
    });
    // TODO: start discovery via your BT service and populate _discovered
    // yourBtService.startDiscovery().listen((result) {
    //   setState(() => _discovered.add(BtDevice(address: result.device.address, name: result.device.name)));
    // }, onDone: () => setState(() => _isScanning = false));
  }

  void _stopScan() {
    // TODO: cancel discovery via your BT service
    setState(() => _isScanning = false);
  }

  Future<void> _connectTo(BtDevice device) async {
    setState(() => _isConnecting = true);
    // TODO: connect via your BT service
    // final error = await yourBtService.connect(device.address);
    // if (error != null) { show snackbar }
    setState(() {
      _isConnecting = false;
      _connected = device; // remove this placeholder once real call is wired
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connected to ${device.displayName}'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  Future<void> _disconnect() async {
    // TODO: disconnect via your BT service
    setState(() => _connected = null);
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
            if (_connected != null) ...[
              _ConnectedDeviceTile(
                device: _connected!,
                onDisconnect: _disconnect,
              ),
              const SizedBox(height: 16),
            ],
            _SectionHeader(title: 'Paired Devices', count: _bonded.length),
            if (_bonded.isEmpty)
              const _EmptyHint(message: 'No paired devices found')
            else
              ..._bonded.map(
                (d) => _DeviceTile(
                  device: d,
                  isConnected: _connected?.address == d.address,
                  isConnecting: _isConnecting,
                  onTap: () => _connectTo(d),
                ),
              ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Nearby Devices',
              count: _discovered.length,
              trailing: _isScanning
                  ? TextButton(onPressed: _stopScan, child: const Text('Stop'))
                  : TextButton(
                      onPressed: _startScan,
                      child: const Text('Scan'),
                    ),
            ),
            if (_isScanning && _discovered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: _ScanningIndicator()),
              )
            else if (!_isScanning && _discovered.isEmpty)
              const _EmptyHint(message: 'Tap Scan to search for nearby devices')
            else
              ..._discovered.map(
                (d) => _DeviceTile(
                  device: d,
                  isConnected: _connected?.address == d.address,
                  isConnecting: _isConnecting,
                  onTap: () => _connectTo(d),
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

class _DeviceTile extends StatelessWidget {
  final BtDevice device;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;

  const _DeviceTile({
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
