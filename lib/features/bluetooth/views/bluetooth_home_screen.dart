import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';
import 'package:offline_data_transfer/features/bluetooth/controllers/bluetooth_controller.dart';
import 'device_scan_screen.dart';
import 'bluetooth_chat_screen.dart';
import 'bluetooth_image_screen.dart';

class BluetoothHomeScreen extends StatelessWidget {
  const BluetoothHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BluetoothController());
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Lab')),
      body: SafeArea(
        top: false,
        child: Obx(() {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (controller.searchingForBondedDevices)
                LinearProgressIndicator()
              else
                _ConnectionBanner(
                  isConnected: controller.connections.isNotEmpty,
                  deviceName: controller.connections.isNotEmpty
                      ? controller.connections.keys.first.name
                      : null,
                  onDisconnect: null,
                ),
              const SizedBox(height: 24),
              Text('Features', style: TextStyles.semiBold),
              const SizedBox(height: 12),
              _FeatureTile(
                icon: Icons.bluetooth_searching,
                title: 'Find Devices',
                subtitle: 'Scan for and connect to nearby Bluetooth devices',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceScanScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _FeatureTile(
                icon: Icons.chat_bubble_outline,
                title: 'Text Chat',
                subtitle: 'Send and receive text messages over Bluetooth',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BluetoothChatScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _FeatureTile(
                icon: Icons.image_outlined,
                title: 'Image Transfer',
                subtitle: 'Send and receive images over Bluetooth',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BluetoothImageScreen(),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final bool isConnected;
  final String? deviceName;
  final VoidCallback? onDisconnect;

  const _ConnectionBanner({
    required this.isConnected,
    this.deviceName,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.success.withAlpha(25)
            : AppTheme.textTertiary.withAlpha(20),
        border: Border.all(
          color: isConnected ? AppTheme.success : AppTheme.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isConnected ? AppTheme.success : AppTheme.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Not Connected',
                  style: TextStyles.medium.copyWith(
                    color: isConnected
                        ? AppTheme.success
                        : AppTheme.textSecondary,
                  ),
                ),
                if (isConnected && deviceName != null)
                  Text(
                    deviceName!,
                    style: TextStyles.regular.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          if (isConnected && onDisconnect != null)
            TextButton(
              onPressed: onDisconnect,
              child: const Text('Disconnect'),
            ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.secondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyles.semiBold),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyles.regular.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
