import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _chat.add({
      'isBot': true,
      'message':
          'Hello! I’m a fish knowledge expert. Ask me anything about ${widget.speciesName}.',
    });
  }

  void _sendMessage(String msg) {
    setState(() {
      _chat.add({'isBot': false, 'message': msg});
      // Simulate response for now
      _chat.add({
        'isBot': true,
        'message':
            'Here’s some information about ${widget.speciesName}. (LLM response will appear here)',
      });
      _controller.clear();
    });
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
              itemCount: _chat.length,
              itemBuilder: (_, i) {
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
                        child: Icon(
                          Icons.smart_toy,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),

                    Flexible(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              isBot
                                  ? const Color.fromARGB(255, 243, 243, 243)
                                  : primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['message'],
                          style: TextStyle(
                            color:
                                isBot
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Colors.white,
                          ),
                        ),
                      ),
                    ),

                    if (!isBot)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.blueGrey,
                        ),
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
