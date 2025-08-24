// import 'package:flutter/material.dart';

// class AppTheme {
//   final darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     scaffoldBackgroundColor: const Color(0xFF121212), // deep dark background
//     colorScheme: const ColorScheme.dark(
//       primary: Color(0xFFFF8A00), // orange accent
//       secondary: Color(0xFF2D2D2D), // dark gray for cards
//       surface: Color(0xFF1E1E1E), // slightly lighter than background
//       onPrimary: Colors.white, // text on orange
//       onSecondary: Colors.white70,
//       onSurface: Colors.white,
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Color(0xFF1A1A1A),
//       foregroundColor: Colors.white,
//       elevation: 0,
//     ),
//     cardTheme: CardThemeData(
//       color: const Color(0xFF1E1E1E), // card bg
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 4,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: const Color(0xFF1E1E1E),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFFFF8A00),
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//       ),
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Color(0xFF1A1A1A),
//       selectedItemColor: Color(0xFFFF8A00),
//       unselectedItemColor: Colors.white54,
//       type: BottomNavigationBarType.fixed,
//       showUnselectedLabels: true,
//     ),
//     textTheme: ThemeData.dark().textTheme.apply(
//       fontFamily: 'Poppins',
//       bodyColor: Colors.white,
//       displayColor: Colors.white,
//     ),
//   );
// }
import 'package:flutter/material.dart';

class AppTheme {
   final darkTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFF089), // pastel yellow
    colorScheme: const ColorScheme.light(
      primary: Colors.black, // buttons, text accents
      secondary: Color(0xFFFFE45C), // softer yellow
      surface: Colors.white,
      onPrimary: Colors.white, // text on black
      onSecondary: Colors.black87,
      onSurface: Colors.black, // general text
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFF089),
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      ),
    ),
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Poppins',
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
  );
}
