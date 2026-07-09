import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:roommate_finder/screens/auth/login_screen.dart';
import 'package:roommate_finder/screens/auth/splash_screen.dart';
import 'package:roommate_finder/screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qrtqvreqwbbdbaunjvvz.supabase.co',
    anonKey:
    'YOUR_SUPABASE_ANON_KEY',
  );

  final prefs = await SharedPreferences.getInstance();

  final bool hasLoggedInBefore =
      prefs.getBool('has_logged_in') ?? false;

  final bool hasActiveSession =
      Supabase.instance.client.auth.currentSession != null;

  runApp(
    MyApp(
      hasLoggedInBefore: hasLoggedInBefore,
      hasActiveSession: hasActiveSession,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasLoggedInBefore;
  final bool hasActiveSession;

  const MyApp({
    super.key,
    required this.hasLoggedInBefore,
    required this.hasActiveSession,
  });

  @override
  Widget build(BuildContext context) {
    Widget startScreen;

    if (hasActiveSession) {
      startScreen = const HomeScreen();
    } else if (hasLoggedInBefore) {
      startScreen = const LoginScreen();
    } else {
      startScreen = const SplashScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roommate Finder',
      home: startScreen,
    );
  }
}