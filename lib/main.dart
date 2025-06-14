// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart'; // Make sure this path is correct for your project structure

// --- Firebase Imports ---
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import generated options (Should be in your 'lib' folder)
// ------------------------

// Make main function async to use await
void main() async {
  // --- Ensure Flutter bindings are initialized FIRST ---
  // Required before calling native code or Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();
  // -----------------------------------------------------

  // --- Initialize Firebase ---
  // Uses the generated firebase_options.dart file
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use options for the detected platform
  );
  // ---------------------------

  // Set system UI overlay style (can happen before or after Firebase init)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Run the app AFTER Firebase is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Removed the misplaced comment "flutterfire configure" - that's a terminal command, not Dart code.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educational App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        fontFamily: 'SFProDisplay', // Make sure this font is included in pubspec.yaml and assets
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const LoginScreen(), // Ensure LoginScreen() is correctly defined and imported
    );
  }
}