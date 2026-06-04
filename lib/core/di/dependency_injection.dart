import 'package:flutter/foundation.dart';

/// Initialize global services (Storage, API, etc.) here.
Future<void> setupDependencies() async {
  debugPrint("📦 Setting up dependencies...");
  
  // Example: 
  // final sharedPrefs = await SharedPreferences.getInstance();
  // GetIt.I.registerSingleton(sharedPrefs);
  
  debugPrint("✅ Dependencies initialized.");
}