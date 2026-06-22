import 'package:flutter/material.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Name')),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: 'Age')),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: 'Gender')),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: 'Religion')),
        ],
      ),
    );
  }
}