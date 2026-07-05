import 'dart:async';

import 'package:flutter/material.dart';

import 'onboarding_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/splash_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Dark overlay gradient to blend bottom particles with black top
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 4),
                    // Wing icon
                    Image.asset(
                      'assets/icons/appicon.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 35),
                    // ROOMMATE
                    const Text(
                      'ROOMMATE',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // FINDER
                    Text(
                      'FINDER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFD4AF37).withOpacity(0.9),
                        letterSpacing: 8,
                      ),
                    ),
                    const Spacer(flex: 1),
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Find your perfect\nliving partner',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Spacer(flex: 4),
                  ],
                ),
              ),
              // Carousel / indicator dots at the bottom
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}