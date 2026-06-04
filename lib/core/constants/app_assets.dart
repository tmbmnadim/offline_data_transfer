// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart'; // Requires flutter_svg in pubspec.yaml

// /// Centralized access to all PNG/JPG images
// class AppImages {
//   AppImages._();

//   // --- Generic Placeholders ---
//   static const String logo = "assets/images/png/logo.png";
//   static const String userPlaceholder = "assets/images/png/user_placeholder.png";
  
//   // Add your onboarding or feature images here as needed
//   // static const String onboarding1 = "assets/images/png/onboarding_1.png";

//   /// Preload commonly used images into memory to avoid pop-in
//   static Future<void> preload(BuildContext context) async {
//     final assetImages = <String>[
//       logo, 
//       userPlaceholder,
//     ];

//     for (final path in assetImages) {
//       try {
//         await precacheImage(AssetImage(path), context);
//       } catch (e) {
//         debugPrint("Error pre-loading image: $path ($e)");
//       }
//     }
//   }
// }

// /// Centralized access to all SVG icons and builder utilities
// class AppIcons {
//   AppIcons._();
  
//   static const _path = 'assets/icons/svg';

//   // --- Generic Icons (Common to almost every app) ---
//   static const String arrowBack = '$_path/arrow_back.svg';
//   static const String arrowRight = '$_path/arrow_right.svg';
//   static const String close = '$_path/close.svg';
//   static const String menu = '$_path/menu.svg';
//   static const String user = '$_path/user.svg';
//   static const String email = '$_path/email.svg';
//   static const String lock = '$_path/lock.svg';
//   static const String visibility = '$_path/visibility.svg';
//   static const String visibilityOff = '$_path/visibility_off.svg';

//   /// A utility to render SVGs consistently with optional tap handling.
//   /// 
//   /// [icon]: The asset path string (e.g. AppIcons.user)
//   /// [size]: Defaults to 24
//   /// [color]: Optional override color (uses srcIn blend mode)
//   /// [onTap]: If provided, wraps the icon in a GestureDetector and increases touch area
//   static Widget svgIcon(
//     String icon, {
//     double size = 24,
//     Color? color,
//     VoidCallback? onTap,
//     BoxFit fit = BoxFit.contain,
//   }) {
//     // The core icon widget
//     Widget svgWidget = SvgPicture.asset(
//       icon,
//       width: size,
//       height: size,
//       fit: fit,
//       colorFilter: color != null
//           ? ColorFilter.mode(color, BlendMode.srcIn)
//           : null,
//     );

//     // If tappable, increase the touch target to at least 42x42 (accessibility standard)
//     if (onTap != null) {
//       return GestureDetector(
//         onTap: onTap,
//         behavior: HitTestBehavior.opaque, // Ensures clicks on transparent areas count
//         child: SizedBox.square(
//           dimension: math.max(size, 42), 
//           child: Center(child: svgWidget),
//         ),
//       );
//     }

//     // Otherwise just return the sized icon
//     return SizedBox.square(
//       dimension: size,
//       child: Center(child: svgWidget),
//     );
//   }
// }