import 'package:flutter/material.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:offline_data_transfer/core/theme/text_styles.dart';

class ScannedDeviceCard extends StatelessWidget {
  final String name;
  final String address;
  final bool isLoading;
  final VoidCallback onPair;

  const ScannedDeviceCard({
    super.key,
    required this.name,
    required this.address,
    required this.onPair,
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
            const Icon(Icons.bluetooth, color: AppTheme.textSecondary),
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
            else
              ElevatedButton(
                onPressed: onPair,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Pair'),
              ),
          ],
        ),
      ),
    );
  }
}
