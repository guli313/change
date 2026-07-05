import 'package:flutter/material.dart';

// ---- Theme colors (same palette as Login/Signup screens) ----
const Color _kBackground = Color(0xFF0D0D0D);
const Color _kAppBarBg = Color(0xFF121010);
const Color _kFieldFill = Color(0xFF1A1717);
const Color _kBubbleReceived = Color(0xFF1E1B1B);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! I saw your post. Is the room still available?',
      'isMe': true,
      'time': '10:30 AM',
    },
    {
      'text': 'Yes, it is available. Would you like to visit?',
      'isMe': false,
      'time': '10:32 AM',
    },
    {
      'text': 'Sure! When are you free?',
      'isMe': true,
      'time': '10:33 AM',
    },
    {
      'text': 'Tomorrow at 4 PM?',
      'isMe': false,
      'time': '10:34 AM',
    },
    {
      'text': 'That works for me.',
      'isMe': true,
      'time': '10:35 AM',
    },
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': _getCurrentTime(),
      });
      _messageController.clear();
    });

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour =
    now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kAppBarBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: _kFieldFill,
              // Swap for a real avatar:
              // backgroundImage: NetworkImage('...'),
              child: Icon(Icons.person, color: _kGold, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hina Malik',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Online',
                      style: TextStyle(fontSize: 12, color: _kMutedText),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: _kGold),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: _kGold),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                        colors: [_kMaroonStart, _kMaroonEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: isMe ? null : _kBubbleReceived,
                      border: isMe
                          ? null
                          : Border.all(color: _kBorder, width: 1),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg['time'] as String,
                              style: TextStyle(
                                color:
                                isMe ? Colors.white70 : _kMutedText,
                                fontSize: 10,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.done_all,
                                size: 13,
                                color: _kGoldLight,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: _kAppBarBg,
              border: Border(top: BorderSide(color: _kBorder)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _kFieldFill,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: _kMutedText),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file_outlined,
                                color: _kGold),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_kMaroonStart, _kMaroonEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}