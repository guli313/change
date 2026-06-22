import 'package:flutter/material.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filters')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Location')),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: 'Budget')),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: 'Religion')),
        ],
      ),
    );
  }
}