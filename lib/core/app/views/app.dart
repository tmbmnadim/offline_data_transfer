import 'package:offline_data_transfer/core/routes/app_router.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Data Transfer',
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      navigatorKey: AppRouter.navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.initial,
    );
  }
}
