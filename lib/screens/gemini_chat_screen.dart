import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/colors.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  bool _isChatLoading = false;
  final ScrollController _scrollController = ScrollController();

late final GenerativeModel _model;
late final ChatSession _chat;

@override
void initState() {
  super.initState();
  _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyD5U7gUO83aX0i5KskR8om9Joae_U-4duY',
    generationConfig: GenerationConfig(
      temperature: 0.7,
      maxOutputTokens: 500,
    ),
  );
  _chat = _model.startChat();
}

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
  if (message.trim().isEmpty) return;

  setState(() {
    _messages.add({'role': 'user', 'content': message});
    _isChatLoading = true;
  });
  _chatController.clear();

  Future.delayed(const Duration(milliseconds: 100), () {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });

  try {
    final prompt = '''You are SwiftRide AI assistant - a helpful customer support agent for SwiftRide ride booking app in Pakistan.
    
SwiftRide features:
- Book Car, Bike, Rickshaw rides
- Real-time driver tracking
- OTP verification for safety
- Payment via Cash, JazzCash, EasyPaisa
- Rate and review drivers
- Passenger and Rider accounts

Answer questions helpfully and concisely. If asked in Urdu or mixed language, respond in same language.

User question: $message''';

    final response = await _chat.sendMessage(Content.text(prompt));
    
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': response.text ?? 'Sorry, could not process your request.',
      });
      _isChatLoading = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  } catch (e) {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': 'Connection error. Please check your internet and try again.',
      });
      _isChatLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: accentOrange,
              radius: 16,
              child: Icon(Icons.smart_toy, color: whiteColor, size: 18),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SwiftRide AI',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powered by Gemini',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy,
                            color: primaryBlue,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'SwiftRide AI Assistant',
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ask me anything about SwiftRide!',
                          style: TextStyle(color: greyColor, fontSize: 14),
                        ),
                        const SizedBox(height: 24),

                        // Quick Questions
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildQuickQuestion('How to book a ride?'),
                            _buildQuickQuestion('How is fare calculated?'),
                            _buildQuickQuestion('How to become a rider?'),
                            _buildQuickQuestion('Payment methods?'),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? primaryBlue : whiteColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            message['content']!,
                            style: TextStyle(
                              color: isUser ? whiteColor : primaryBlue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Loading indicator
          if (_isChatLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Thinking...',
                        style: TextStyle(color: greyColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      hintStyle: const TextStyle(color: greyColor),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_chatController.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: whiteColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestion(String question) {
    return GestureDetector(
      onTap: () => _sendMessage(question),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryBlue.withOpacity(0.3)),
        ),
        child: Text(
          question,
          style: const TextStyle(color: primaryBlue, fontSize: 12),
        ),
      ),
    );
  }
}