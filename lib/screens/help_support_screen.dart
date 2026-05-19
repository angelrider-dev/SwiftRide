import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/colors.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a ride?',
      'answer': 'Tap on "Where do you want to go?" on the home screen, enter your destination, select ride type and tap Book Ride Now.',
    },
    {
      'question': 'How do I cancel a ride?',
      'answer': 'You can cancel a ride before the driver arrives by going to your active ride and tapping Cancel Ride.',
    },
    {
      'question': 'How is the fare calculated?',
      'answer': 'Fare is calculated based on distance, ride type (Car, Bike, Rickshaw) and current demand in your area.',
    },
    {
      'question': 'How do I become a rider?',
      'answer': 'Go to User Selection screen and tap "Continue as Driver". Register with your vehicle details to start accepting rides.',
    },
    {
      'question': 'Is my payment secure?',
      'answer': 'Yes! SwiftRide uses secure payment methods. Cash and digital payments are both supported.',
    },
    {
      'question': 'How do I rate my driver?',
      'answer': 'After completing a ride, you will be prompted to rate your driver from 1 to 5 stars.',
    },
  ];

  int _expandedIndex = -1;

  // Gemini Chat
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  bool _isChatLoading = false;
  bool _showChat = false;

late final GenerativeModel _model;
late final ChatSession _chat;

@override
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
  Future<void> _makeCall() async {
    final Uri url = Uri(scheme: 'tel', path: '+923493890880');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendEmail() async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: 'zohaibsafdar151@gmail.com',
      query: 'subject=SwiftRide Support',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _reportBug() async {
    final Uri url = Uri.parse('https://github.com/ANGELRIDER280/SwiftRide/issues/new');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
@override
void dispose() {
  _chatController.dispose();
  _scrollController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Help & Support', style: TextStyle(color: whiteColor)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _showChat ? _buildChatScreen() : _buildMainScreen(),
    );
  }

  Widget _buildMainScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryBlue, lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How can we help?',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'We are here to help you 24/7',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.support_agent, color: accentOrange, size: 50),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Options
          const Text(
            'Contact Us',
            style: TextStyle(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  icon: Icons.phone,
                  title: 'Call Us',
                  subtitle: '+92 349 3890880',
                  color: Colors.green,
                  onTap: _makeCall,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactCard(
                  icon: Icons.email,
                  title: 'Email Us',
                  subtitle: 'zohaibsafdar151@gmail.com',
                  color: accentOrange,
                  onTap: _sendEmail,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  icon: Icons.chat,
                  title: 'Live Chat',
                  subtitle: 'AI Powered',
                  color: primaryBlue,
                  onTap: () => setState(() => _showChat = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactCard(
                  icon: Icons.bug_report,
                  title: 'Report Bug',
                  subtitle: 'Via GitHub',
                  color: Colors.red,
                  onTap: _reportBug,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // FAQ Section
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_faqs.length, (index) {
            final isExpanded = _expandedIndex == index;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isExpanded ? accentOrange : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => setState(() {
                  _expandedIndex = isExpanded ? -1 : index;
                }),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _faqs[index]['question']!,
                              style: const TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: accentOrange,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          _faqs[index]['answer']!,
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // About App
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About SwiftRide',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Version', style: TextStyle(color: greyColor)),
                    Text('1.0.0', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Developer', style: TextStyle(color: greyColor)),
                    Text('SwiftRide Team', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Contact', style: TextStyle(color: greyColor)),
                    Text('zohaibsafdar151@gmail.com', style: TextStyle(color: accentOrange, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChatScreen() {
    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          color: primaryBlue,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: whiteColor),
                onPressed: () => setState(() => _showChat = false),
              ),
              const CircleAvatar(
                backgroundColor: accentOrange,
                child: Icon(Icons.smart_toy, color: whiteColor),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SwiftRide AI Support',
                    style: TextStyle(
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Powered by Gemini',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.smart_toy, color: primaryBlue, size: 50),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Hi! I am SwiftRide AI Support',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ask me anything about SwiftRide!',
                        style: TextStyle(color: greyColor),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? primaryBlue : whiteColor,
                          borderRadius: BorderRadius.circular(16),
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

        // Loading
        if (_isChatLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(color: primaryBlue),
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
                  decoration: BoxDecoration(
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
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: greyColor, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}