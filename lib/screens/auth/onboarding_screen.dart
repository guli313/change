import 'package:flutter/material.dart';

import 'login_screen.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.search,
      "title": "Find Roommates",
      "subtitle": "Discover compatible roommates based on your preferences.",
    },
    {
      "icon": Icons.home,
      "title": "Find Rooms",
      "subtitle": "Browse available rooms and shared apartments near you.",
    },
    {
      "icon": Icons.chat,
      "title": "Connect & Chat",
      "subtitle": "Chat with potential roommates before making a decision.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(pages[index]["icon"], size: 120),
                      const SizedBox(height: 30),
                      Text(
                        pages[index]["title"],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        pages[index]["subtitle"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
                  (index) => Container(
                margin: const EdgeInsets.all(4),
                width: currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentPage == index ? Colors.blue : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (currentPage < pages.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                child: Text(
                  currentPage == pages.length - 1 ? "Get Started" : "Next",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}