import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/location_service.dart';
import 'viewmodels/map_viewmodel.dart';
import 'views/map_screen.dart';

void main() {
  // Ensure Flutter engine bindings are initialized prior to shared preferences accesses
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // Services dependency injections
        Provider<StorageService>(
          create: (_) => SharedPreferencesStorageService(),
        ),
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
        // ViewModel dependency injection
        ChangeNotifierProvider<MapViewModel>(
          create: (context) => MapViewModel(
            storageService: context.read<StorageService>(),
            locationService: context.read<LocationService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to theme changes from ViewModel
    final isDarkMode = context.watch<MapViewModel>().isDarkMode;

    return MaterialApp(
      title: 'Where Is My Bin',
      debugShowCheckedModeBanner: false,
      
      // Dynamic Theme configurations
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Emerald Green
          brightness: Brightness.light,
          primary: const Color(0xFF10B981),
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        chipTheme: const ChipThemeData(
          side: BorderSide.none,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Emerald Green
          brightness: Brightness.dark,
          primary: const Color(0xFF10B981),
          surface: const Color(0xFF1E293B), // Slate Dark
          background: const Color(0xFF0F172A),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        chipTheme: const ChipThemeData(
          side: BorderSide.none,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      
      home: const MapScreen(),
    );
  }
}
