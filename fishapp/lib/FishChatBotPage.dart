import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FishChatBotPage extends StatefulWidget {
  final String speciesName;

  const FishChatBotPage({Key? key, required this.speciesName})
      : super(key: key);

  @override
  State<FishChatBotPage> createState() => _FishChatBotPageState();
}

class _FishChatBotPageState extends State<FishChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _chat = [];
  String? _sessionId; // Track session
  bool _isTyping = false; // Bot typing state

  @override
  void initState() {
    super.initState();
    _chat.add({
      'isBot': true,
      'message':
          'Hello! I’m a fish knowledge expert. Ask me anything about ${widget.speciesName}.',
    });
  }

  Future<void> _sendMessage(String msg) async {
    if (msg.trim().isEmpty) return;

    setState(() {
      _chat.add({'isBot': false, 'message': msg});
      _controller.clear();
      _isTyping = true; // start typing animation
    });

    try {
      final url = Uri.parse("http://192.168.1.135:8000/chatbot/api/chat/");

      final body = {
        "message": msg,
        if (_sessionId != null) "session_id": _sessionId,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botMessage = data["response"] ?? "No response from server.";
        _sessionId = data["session_id"];

        setState(() {
          _chat.add({'isBot': true, 'message': botMessage});
        });
      } else {
        setState(() {
          _chat.add({
            'isBot': true,
            'message': "Error: ${response.statusCode} from server."
          });
        });
      }
    } catch (e) {
      setState(() {
        _chat.add({
          'isBot': true,
          'message': "Failed to connect to server: $e"
        });
      });
    } finally {
      setState(() {
        _isTyping = false; // stop typing animation
      });
    }
  }

  // Parse text with **bold** markers
  Widget _buildFormattedText(String text, bool isBot) {
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];
    int start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: TextStyle(color: isBot ? Colors.black : Colors.white),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isBot ? Colors.black : Colors.white,
        ),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(color: isBot ? Colors.black : Colors.white),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF001F59);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fish Knowledge Chatbot",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _chat.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _chat.length) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const Icon(Icons.smart_toy, size: 24, color: Colors.grey),
      const SizedBox(width: 6),
      const TypingIndicator(), // 👈 bouncing dots here
    ],
  );
}


                final item = _chat[i];
                final isBot = item['isBot'];

                return Row(
                  mainAxisAlignment:
                      isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBot)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.smart_toy,
                            size: 24, color: Colors.grey),
                      ),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isBot
                              ? const Color.fromARGB(255, 243, 243, 243)
                              : primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildFormattedText(item['message'], isBot),
                      ),
                    ),
                    if (!isBot)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(Icons.person,
                            size: 24, color: Colors.blueGrey),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "What would you like to know about fish?",
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 112, 112, 112),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 253, 253, 253),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: primaryColor),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            double value = (_controller.value * 3 - index).clamp(0.0, 1.0);
            return Opacity(
              opacity: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}


