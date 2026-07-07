import 'package:flutter/material.dart';

class FilterCriteria {
  final String location;
  final String budget;
  final String religion;

  const FilterCriteria({
    this.location = '',
    this.budget = '',
    this.religion = '',
  });
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    _budgetController.dispose();
    _religionController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Navigator.of(context).pop(
      FilterCriteria(
        location: _locationController.text.trim(),
        budget: _budgetController.text.trim(),
        religion: _religionController.text.trim(),
      ),
    );
  }

  void _clearFilters() {
    _locationController.clear();
    _budgetController.clear();
    _religionController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _budgetController,
            decoration: const InputDecoration(
              labelText: 'Budget',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _religionController,
            decoration: const InputDecoration(
              labelText: 'Religion',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A1F35),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
