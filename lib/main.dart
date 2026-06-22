import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'providers/auth_provider.dart';
import 'providers/cottage_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force database creation and dummy data injection
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CottageProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const AquaResortApp(),
    ),
  );
}

class AquaResortApp extends StatelessWidget {
  const AquaResortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaResort Reservation',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
