import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class PostListingScreen extends StatefulWidget {
  const PostListingScreen({super.key});

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final rent = _rentController.text.trim();
    final description = _descriptionController.text.trim();
    final religion = _religionController.text.trim();

    if (title.isEmpty || rent.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields before posting.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    var bodyText = 'Rent: $rent\n$description';
    if (religion.isNotEmpty) {
      bodyText = 'Religion: $religion\n$bodyText';
    }

    NotificationService.addNotification(
      title: 'New post published',
      subtitle: title,
      body: bodyText,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your listing has been posted and added to notifications.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Listing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _rentController,
            decoration: const InputDecoration(labelText: 'Rent'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _religionController,
            decoration: const InputDecoration(
              labelText: 'Religion (optional)',
              hintText: 'e.g. Islam, Christianity, None',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit Listing'),
            ),
          ),
        ],
      ),
    );
  }
}
