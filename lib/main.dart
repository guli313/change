import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roommate_finder/screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qrtqvreqwbbdbaunjvvz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFydHF2cmVxd2JiZGJhdW5qdnZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxMTQxNDAsImV4cCI6MjA5NzY5MDE0MH0.kB6c3-iA0KcRBBgc6mxWkVjjogveQGmuUo4z_p1qQEs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roommate Finder',
      home: const SplashScreen(),
    );
  }
}