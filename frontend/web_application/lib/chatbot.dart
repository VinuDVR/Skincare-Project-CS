import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SkincareChatPage extends StatefulWidget {
  const SkincareChatPage({Key? key}) : super(key: key);

  @override
  _SkincareChatPageState createState() => _SkincareChatPageState();
}

class _SkincareChatPageState extends State<SkincareChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': "Hello! I'm Genie 🧞✨ Your personal skincare assistant. How can I help with your skin routine today?"
        });
      });
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isTyping = true;
    });
    
    _scrollToBottom();
    _controller.clear();
    
    _getBotResponse(text);
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _getBotResponse(String userInput) async {
    final url = Uri.parse('http://127.0.0.1:5000/ask'); // Replace with your Flask server URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': userInput}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add({'role': 'bot', 'text': data['reply'] ?? "Sorry, I couldn't understand."});
          _isTyping = false;
        });
      } else {
        setState(() {
          _messages.add({'role': 'bot', 'text': "Error: ${response.statusCode}. Please try again later."});
          _isTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': "Failed to connect to server. Please check your connection."});
        _isTyping = false;
      });
    }
    
    _scrollToBottom();
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser 
              ? Colors.green.shade600 
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isUser ? Radius.circular(20) : Radius.circular(5),
            bottomRight: isUser ? Radius.circular(5) : Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 12, top: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPulsingDot(0),
            _buildPulsingDot(300),
            _buildPulsingDot(600),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingDot(int delay) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      width: 8,
      child: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          builder: (context, double value, child) {
            return Opacity(
              opacity: value <= 0.5 ? value * 2 : (1 - value) * 2,
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // This allows the body to extend behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade800, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.assistant,
                color: Colors.green.shade700,
                size: 20,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Genie",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.7,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Show help or info about the chatbot
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ask me anything about skincare!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green.shade800,
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';
                    return _buildChatBubble(message['text']!, isUser);
                  },
                ),
              ),
              // Input area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.textsms_outlined,
                                color: Colors.green.shade700.withOpacity(0.7),
                                size: 22,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: "Ask about your skin routine...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade700, Colors.green.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        onPressed: _sendMessage,
                        iconSize: 22,
                        splashRadius: 24,
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}