import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app/views/app.dart';
import 'core/di/dependency_injection.dart'; // We will create this placeholder

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize generic dependencies (Api, Storage, etc.)
  await setupDependencies();

  // Set standard UI overlay (Status bar color, etc.)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // For Android
      statusBarBrightness: Brightness.light, // For iOS
    ),
  );

  // Force portrait mode (Optional, but good for offline_data_transfers)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MainApp());
}
