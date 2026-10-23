import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  final List<Map<String, String>> messages = [];

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final response = getMindMateResponse(text);

    setState(() {
      messages.add({
        'sender': 'user',
        'message': text,
      });

      messages.add({
        'sender': 'mindmate',
        'message': response,
      });
    });

    messageController.clear();
  }

  String getMindMateResponse(String text) {
    final message = text.toLowerCase();

    // Immediate safety concern
    if (message.contains('kill myself') ||
        message.contains('suicide') ||
        message.contains('want to die') ||
        message.contains('end my life') ||
        message.contains('hurt myself') ||
        message.contains('self harm')) {
      return 'I am really sorry that you are going through this. Your safety is important. Please do not stay alone right now. Contact someone you trust, such as a family member, close friend, teacher, or counselor, and tell them how you are feeling. If you are in immediate danger, contact your local emergency service or go to the nearest emergency department.';
    }

    // Stress
    if (message.contains('stress') ||
        message.contains('stressed') ||
        message.contains('pressure') ||
        message.contains('overwhelmed')) {
      return 'It sounds like things are feeling overwhelming right now. Take a slow breath and try to focus only on the next small step. You do not have to handle everything at once. What is causing you the most stress right now?';
    }

    // Sadness
    if (message.contains('sad') ||
        message.contains('sadness') ||
        message.contains('cry') ||
        message.contains('crying') ||
        message.contains('upset')) {
      return 'I am sorry you are feeling this way. It is okay to have difficult moments. You do not have to hide your feelings. If you feel comfortable, tell me what happened.';
    }

    // Anxiety
    if (message.contains('anxiety') ||
        message.contains('anxious') ||
        message.contains('worried') ||
        message.contains('worry') ||
        message.contains('nervous') ||
        message.contains('panic')) {
      return 'When anxiety feels strong, try taking a slow breath and bringing your attention to the present moment. You can also name five things you can see around you. What is making you feel anxious right now?';
    }

    // Loneliness
    if (message.contains('lonely') ||
        message.contains('loneliness') ||
        message.contains('alone')) {
      return 'Feeling alone can be difficult. You deserve to have someone who listens to you. If possible, reach out to a trusted friend, family member, teacher, or counselor. You can also tell me more about what has been making you feel lonely.';
    }

    // Anger
    if (message.contains('angry') ||
        message.contains('anger') ||
        message.contains('frustrated') ||
        message.contains('frustration') ||
        message.contains('irritated')) {
      return 'It sounds like something has really frustrated you. Before reacting, give yourself a little time to calm down. Try taking a short walk, breathing slowly, or writing down what you are feeling. What happened?';
    }

    // Sleep
    if (message.contains('sleep') ||
        message.contains('sleeping') ||
        message.contains('insomnia') ||
        message.contains('cannot sleep') ||
        message.contains("can't sleep")) {
      return 'Having trouble sleeping can make everything feel harder. Try keeping a regular sleep routine and reducing screen time before bed. If this keeps happening, consider talking to a healthcare professional.';
    }

    // Studies and academics
    if (message.contains('exam') ||
        message.contains('study') ||
        message.contains('studies') ||
        message.contains('college') ||
        message.contains('assignment') ||
        message.contains('project') ||
        message.contains('marks') ||
        message.contains('result')) {
      return 'Academic pressure can feel overwhelming. Try breaking your work into small tasks and focusing on one task at a time. Take short breaks and avoid comparing your progress with others. What part of your studies is troubling you most?';
    }

    // Family
    if (message.contains('family') ||
        message.contains('parents') ||
        message.contains('mother') ||
        message.contains('father') ||
        message.contains('mom') ||
        message.contains('dad')) {
      return 'Family situations can affect us deeply. If you feel safe doing so, try talking calmly with someone in your family whom you trust. You can also tell me what happened, and we can think through it together.';
    }

    // Friends
    if (message.contains('friend') ||
        message.contains('friends') ||
        message.contains('friendship') ||
        message.contains('best friend')) {
      return 'Friendship problems can hurt a lot. Sometimes an honest and calm conversation can help. Give yourself some time before making an important decision. What happened between you and your friend?';
    }

    // Relationship
    if (message.contains('boyfriend') ||
        message.contains('girlfriend') ||
        message.contains('breakup') ||
        message.contains('relationship')) {
      return 'Relationship problems can bring many different emotions. Give yourself time to process what you are feeling and avoid blaming yourself for everything. If you want, you can tell me what happened.';
    }

    // Positive feelings
    if (message.contains('happy') ||
        message.contains('good') ||
        message.contains('great') ||
        message.contains('excited') ||
        message.contains('wonderful') ||
        message.contains('proud')) {
      return 'That is wonderful to hear. Take a moment to appreciate this feeling. Remember what helped make today better so you can return to it when you need a positive moment.';
    }

    // Greeting
    if (message.contains('hello') ||
        message.contains('hi') ||
        message.contains('hey')) {
      return 'Hello. I am MindMate. This is a space where you can express your thoughts without judgment. How are you feeling today?';
    }

    // Thanks
    if (message.contains('thank')) {
      return 'You are welcome. I am glad you shared your thoughts with me.';
    }

    // Help
    if (message.contains('help') ||
        message.contains('support')) {
      return 'I am here to listen. You can tell me what is troubling you, and we can take it one step at a time.';
    }

    // Default response
    return 'Thank you for sharing that with me. I want to understand you better. Could you tell me a little more about what you are feeling or what happened?';
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text(
          'Talk to MindMate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Share what is on your mind.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message['sender'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 320,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF5B8DEF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            message['message'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFF263238),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts...',
                      filled: true,
                      fillColor: const Color(0xFFF4F7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}