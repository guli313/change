import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:roommate_finder/screens/auth/login_screen.dart';
import 'package:roommate_finder/screens/auth/splash_screen.dart';
import 'package:roommate_finder/screens/home/home_screen.dart';
import 'package:roommate_finder/utils/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qrtqvreqwbbdbaunjvvz.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFydHF2cmVxd2JiZGJhdW5qdnZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxMTQxNDAsImV4cCI6MjA5NzY5MDE0MH0.kB6c3-iA0KcRBBgc6mxWkVjjogveQGmuUo4z_p1qQEs',
  );

  bool isSupabaseConfigured = false;
  if (!SupabaseConfig.isConfigured(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  )) {
    debugPrint(
      'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  } else {
    try {
      await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
      isSupabaseConfigured = true;
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
    }
  }

  bool hasLoggedInBefore = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    hasLoggedInBefore = prefs.getBool('has_logged_in') ?? false;
  } catch (e) {
    debugPrint('Failed to initialize SharedPreferences: $e');
  }

  bool hasActiveSession = false;
  if (isSupabaseConfigured) {
    try {
      hasActiveSession = Supabase.instance.client.auth.currentSession != null;
    } catch (e) {
      debugPrint('Failed to check active session: $e');
    }
  }

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
