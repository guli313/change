import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('CreateProfileScreen initialized');
    _nameController.addListener(_logProfileState);
    _ageController.addListener(_logProfileState);
    _genderController.addListener(_logProfileState);
    _religionController.addListener(_logProfileState);
  }

  void _logProfileState() {
    debugPrint(
      'CreateProfileScreen input -> name: ${_nameController.text}, '
      'age: ${_ageController.text}, gender: ${_genderController.text}, '
      'religion: ${_religionController.text}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _religionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CreateProfileScreen build');

    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: 'Age'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _genderController,
            decoration: const InputDecoration(labelText: 'Gender'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _religionController,
            decoration: const InputDecoration(labelText: 'Religion'),
          ),
        ],
      ),
    );
  }
}
