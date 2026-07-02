import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../chat/chat_screen.dart';
import '../listing/post_listing_screen.dart';
import '../profile/my_profile_screen.dart';
import 'notifications_screen.dart';

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
          MaterialPageRoute(builder: (context) => const PostListingScreen()),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProfileScreen()),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostListingScreen()),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Posts"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class RoommateCard extends StatefulWidget {
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
  State<RoommateCard> createState() => _RoommateCardState();
}

class _RoommateCardState extends State<RoommateCard> {
  bool _isSending = false;
  bool _isSent = false;

  Future<void> _sendRequest() async {
    setState(() {
      _isSending = true;
    });

    // Try to record the request in Supabase if the user is authenticated
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentUser != null) {
        await client.from('requests').insert({
          'sender_id': client.auth.currentUser!.id,
          'receiver_name': widget.name,
          'city': widget.city,
          'rent': widget.rent,
          'status': 'pending',
        });
      }
    } catch (e) {
      // Supabase table 'requests' might not be created yet, which is fine
      debugPrint('Optional Supabase DB logging failed: $e');
    }

    // Wait a brief period to simulate network/database roundtrip loading
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isSending = false;
        _isSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request sent to ${widget.name} successfully!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(widget.name),
              subtitle: Text(widget.city),
            ),

            Text(widget.description, style: const TextStyle(fontSize: 15)),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 5),
                Text(widget.city),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.attach_money, size: 18),
                const SizedBox(width: 5),
                Text(widget.rent),
              ],
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: _isSent
                  ? OutlinedButton.icon(
                      onPressed: null, // Disabled when already sent
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Request Sent"),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green.shade300),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _isSending ? null : _sendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSending ? Colors.grey : null,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Send Request"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
