import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_mediapipe/flutter_gemma_mediapipe.dart';

import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline Gemma engine.
  await FlutterGemma.initialize(
    inferenceEngines: const [
      MediaPipeEngine(),
    ],
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const FarmHelperApp(),
    ),
  );
}

class FarmHelperApp extends StatelessWidget {
  const FarmHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return MaterialApp(
          title: 'FarmHelper',
          debugShowCheckedModeBanner: false,
          theme: appProvider.themeData,
          home: const SplashScreen(),
        );
      },
    );
  }
}