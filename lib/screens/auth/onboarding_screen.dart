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
      "image":
          "assets/images/ONBOARDING/ChatGPT Image Jul 4, 2026, 12_56_06 PM.png",
      "title": "Find Your\nPerfect Roommate",
      "subtitle": "Discover verified profiles\nthat match your lifestyle.",
      "isArch": true,
    },
    {
      "image": "assets/images/ONBOARDING/chat_boxes_icon.JPG",
      "title": "Connect & Chat\nSecurely",
      "subtitle":
          "Chat in real-time and get\nto know your potential\nroommate.",
      "isArch": false,
    },
    {
      "image": "assets/images/ONBOARDING/gold_users_checkmark.JPG",
      "title": "Send & Accept\nRequests",
      "subtitle": "Send requests and find\nthe best match for\nyourself.",
      "isArch": false,
    },
  ];

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
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
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),

              // Top logo
              Positioned(
                top: 24,
                left: 24,
                child: Image.asset('assets/icons/appicon.png', height: 45),
              ),

              // Page content
              PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 90, 24, 90),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          // Title
                          Text(
                            page["title"],
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              height: 1.25,
                            ),
                          ),
                          // Underline divider
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 16),
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Subtitle
                          Text(
                            page["subtitle"],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Image or Icon
                          Center(
                            child: index == 2
                                ? Image.asset(
                                    'assets/icons/appicon.png',
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.contain,
                                  )
                                : (page["isArch"]
                                      ? Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(
                                                0xFFD4AF37,
                                              ).withOpacity(0.8),
                                              width: 2,
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(160),
                                                  topRight: Radius.circular(
                                                    160,
                                                  ),
                                                ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(158),
                                                  topRight: Radius.circular(
                                                    158,
                                                  ),
                                                ),
                                            child: Image.asset(
                                              page["image"],
                                              height: 260,
                                              width: 190,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Image.asset(
                                            page["image"],
                                            height: 250,
                                            fit: BoxFit.contain,
                                          ),
                                        )),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Bottom control bar (Skip, Indicator, Button)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // Page indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentPage == index ? 16 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Next / Get Started button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E121E), // Dark burgundy color
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          if (currentPage < pages.length - 1) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _navigateToLogin();
                          }
                        },
                        child: Text(
                          currentPage == pages.length - 1
                              ? "Get Started"
                              : "Next",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
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
