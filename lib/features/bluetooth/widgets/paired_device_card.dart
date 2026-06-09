import 'package:flutter/material.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';

class PairedDeviceCard extends StatelessWidget {
  final String name;
  final String address;
  final bool isConnected;
  final bool isLoading;
  final VoidCallback onConnect;

  const PairedDeviceCard({
    super.key,
    required this.name,
    required this.address,
    required this.isConnected,
    required this.onConnect,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.bluetooth,
              color: isConnected ? AppTheme.success : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyles.medium),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: TextStyles.regular.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (isConnected)
              Text(
                'Connected',
                style: TextStyles.medium.copyWith(color: AppTheme.success),
              )
            else
              ElevatedButton(
                onPressed: onConnect,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }
}
