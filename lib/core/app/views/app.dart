import 'package:offline_data_transfer/core/routes/app_router.dart';
import 'package:offline_data_transfer/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Preload assets if needed
    // AppImages.preload(context);

    // If you use ScreenUtil, wrap MaterialApp with it here.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My offline_data_transfer App",
      // --- Theme Configuration ---
      theme: AppTheme.light,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // We use a global key so we can navigate without context if needed (Service Locator pattern)
      navigatorKey: AppRouter.navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.initial,

      // --- Localization Configuration ---
      // Add 'flutter_localizations' to pubspec.yaml for this to work
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en', 'US'),
      // ],
    );
  }
}
