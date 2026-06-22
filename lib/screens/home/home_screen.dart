import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';
import '../listing/post_listing_screen.dart';
import '../profile/my_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  void _onItemTapped(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
      // Home Screen
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PostListingScreen(),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyProfileScreen(),
          ),
        );
        break;
    }

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Roommate Finder"),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostListingScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search by city...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  Chip(label: Text("All")),
                  SizedBox(width: 10),
                  Chip(label: Text("Boys")),
                  SizedBox(width: 10),
                  Chip(label: Text("Girls")),
                  SizedBox(width: 10),
                  Chip(label: Text("Family")),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: const [
                  RoommateCard(
                    name: "Ali",
                    city: "Islamabad",
                    description: "Need a roommate near FAST University.",
                    rent: "Rs. 18,000 / Month",
                  ),
                  SizedBox(height: 15),
                  RoommateCard(
                    name: "Ahmed",
                    city: "Lahore",
                    description: "Looking for a clean roommate.",
                    rent: "Rs. 15,000 / Month",
                  ),
                  SizedBox(height: 15),
                  RoommateCard(
                    name: "Bilal",
                    city: "Karachi",
                    description: "Room available near DHA.",
                    rent: "Rs. 22,000 / Month",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Posts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class RoommateCard extends StatelessWidget {
  final String name;
  final String city;
  final String description;
  final String rent;

  const RoommateCard({
    super.key,
    required this.name,
    required this.city,
    required this.description,
    required this.rent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(name),
              subtitle: Text(city),
            ),

            Text(
              description,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 5),
                Text(city),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.attach_money, size: 18),
                const SizedBox(width: 5),
                Text(rent),
              ],
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Send Request
                },
                child: const Text("Send Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}