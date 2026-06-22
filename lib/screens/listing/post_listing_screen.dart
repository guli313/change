import 'package:flutter/material.dart';

class PostListingScreen extends StatelessWidget {
  const PostListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Listing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Title')),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: 'Rent')),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: 'Description')),
        ],
      ),
    );
  }
}