import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';
import 'package:offline_data_transfer/features/bluetooth/controllers/bluetooth_controller.dart';
import 'package:offline_data_transfer/features/bluetooth/models/bt_device.dart';
import 'package:offline_data_transfer/features/bluetooth/widgets/paired_device_card.dart';
import 'package:offline_data_transfer/features/bluetooth/widgets/scanned_device_card.dart';

class DeviceScanScreen extends StatelessWidget {
  const DeviceScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BluetoothController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Find Devices')),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (!controller.isAdapterOn) {
            return Center(
              child: const _EmptyHint(message: 'Bluetooth is off!'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.searchingForBondedDevices)
                LinearProgressIndicator()
              else if (controller.connections.isEmpty)
                const _EmptyHint(message: 'No paired devices found')
              else
                Column(
                  children: controller.connections.entries.map((con) {
                    final device = con.key;
                    final connection = con.value;
                    return PairedDeviceCard(
                      name: device.name ?? "Unknown",
                      address: device.address,
                      isConnected: connection.isConnected,
                      onConnect: () => controller.connectToDevice(device),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Nearby Devices',
                count: 0,
                trailing: TextButton(
                  onPressed: controller.toggleScan,
                  child: controller.isScanning
                      ? const Text('Stop Scan')
                      : const Text('Scan'),
                ),
              ),
              if (controller.scannedDevices.isEmpty)
                const _EmptyHint(
                  message: 'Tap Scan to search for nearby devices',
                )
              else
                Column(
                  children: controller.scannedDevices.map((device) {
                    return ScannedDeviceCard(
                      name: device.name ?? device.alias ?? "Unknown",
                      address: device.address,
                      isLoading: controller.isPairing,
                      onPair: () => controller.pairToDevice(device),
                    );
                  }).toList(),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Reusable tile widgets ─────────────────────────────────────────────────────
// These are ready to use once you wire in your BT state.

class BtConnectedDeviceTile extends StatelessWidget {
  final BtDevice device;
  final VoidCallback onDisconnect;

  const BtConnectedDeviceTile({
    super.key,
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

class BtBondedDeviceTile extends StatelessWidget {
  final BtDevice device;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;

  const BtBondedDeviceTile({
    super.key,
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

class BtScannedDeviceTile extends StatelessWidget {
  final BtDevice device;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onTap;

  const BtScannedDeviceTile({
    super.key,
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

class BtScanningIndicator extends StatelessWidget {
  const BtScanningIndicator({super.key});

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

// ── Private layout helpers ────────────────────────────────────────────────────

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
