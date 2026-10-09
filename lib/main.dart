import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/core/theme/elynos_theme.dart';
import 'ui/features/home/views/home_screen.dart';
import 'data/services/local_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge Android system overlay styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: ElyonsColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize on-device SQLite database
  try {
    await LocalDatabaseService().database;
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  runApp(const ElynosApp());
}

class ElynosApp extends StatelessWidget {
  const ElynosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elynos AI',
      debugShowCheckedModeBanner: false,
      theme: ElyonsTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
