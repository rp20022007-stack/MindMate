import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';
import 'journal_screen.dart';
import 'relax_screen.dart';
import 'profile_screen.dart';
import 'mood_history_screen.dart';
import 'sos_screen.dart';
import 'wellness_plan_screen.dart';
import 'stress_checkin_screen.dart';
import 'self_care_progress_screen.dart';
import 'professional_help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMood = -1;
  int selectedIndex = 0;

  List<String> moodHistory = [];

  final List<String> moods = [
    'Happy',
    'Okay',
    'Sad',
    'Stressed',
    'Anxious',
  ];

  @override
  void initState() {
    super.initState();
    loadMoodHistory();
  }

  // Load saved mood history.
  Future<void> loadMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMoods = prefs.getStringList('mood_history') ?? [];

    if (!mounted) return;

    setState(() {
      moodHistory = savedMoods;

      if (moodHistory.isNotEmpty) {
        selectedMood = moods.indexOf(moodHistory.last);
      }
    });
  }

  // Save mood history.
  Future<void> saveMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('mood_history', moodHistory);
  }

  // Get a supportive message based on the selected mood.
  String getSupportMessage(String mood) {
    switch (mood) {
      case 'Stressed':
        return "You don't have to solve everything today. "
            "Take one small step at a time. "
            "You deserve a moment of peace.";

      case 'Anxious':
        return "It's okay to feel anxious sometimes. "
            "Take a gentle breath, slow down, and focus on this moment. "
            "You are not alone.";

      case 'Sad':
        return "It's okay not to feel okay. "
            "Be gentle with yourself and give yourself time.";

      case 'Happy':
        return "Keep enjoying these positive moments! "
            "You deserve happiness and peace.";

      case 'Okay':
        return "You don't need to feel perfect every day. "
            "Taking care of yourself is enough.";

      default:
        return '';
    }
  }

  // Navigate to another screen.
  void _openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // Select a bottom navigation destination.
  
void _onNavigationTap(int index) {
  setState(() {
    selectedIndex = index;
  });

  switch (index) {
    case 0:
      // Already on the Home screen.
      break;

    case 1:
      _openScreen(const ChatScreen());
      break;

    case 2:
      _openScreen(const JournalScreen());
      break;

    case 3:
      _openScreen(const ProfileScreen());
      break;

    case 4:
      _openScreen(const ProfessionalHelpScreen());
      break;
  }
}


  // Reusable feature card.
  Widget featureCard(String title, IconData icon) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 30,
            color: const Color(0xFF5B8DEF),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable navigation card.
  Widget _navigationCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: iconBackground,
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  // SOS support card.
  Widget _buildSosCard() {
    return GestureDetector(
      onTap: () => _openScreen(const SosScreen()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEEE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFCCCC),
          ),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFFFDADA),
              child: Icon(
                Icons.favorite_rounded,
                color: Color(0xFFC62828),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help Right Now?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9E2020),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Open SOS Support for help and calming options.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF684848),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Color(0xFFC62828),
            ),
          ],
        ),
      ),
    );
  }

  // Mood selection card.
  Widget _buildMoodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How do you feel?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: List.generate(moods.length, (index) {
              return ChoiceChip(
                label: Text(moods[index]),
                selected: selectedMood == index,
                onSelected: (selected) async {
                  if (!selected) return;

                  final mood = moods[index];

                  setState(() {
                    selectedMood = index;
                    moodHistory.add(mood);
                  });

                  try {
                    await saveMoodHistory();
                  } catch (_) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unable to save mood history. Please try again.',
                        ),
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(getSupportMessage(mood)),
                      duration: const Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF5267C5),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // My Mood card.
  Widget _buildMyMoodCard() {
    return GestureDetector(
      onTap: () {
        _openScreen(
          MoodHistoryScreen(
            currentMood: selectedMood >= 0
                ? moods[selectedMood]
                : null,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Mood',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your emotions and understand '
              'your mood patterns over time.',
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              moodHistory.isEmpty
                  ? 'No mood recorded yet.'
                  : 'Moods recorded: ${moodHistory.length}',
              style: const TextStyle(
                color: Color(0xFF5B8DEF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'MindMate',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF263238),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),

              // Self-Care Progress.
              _navigationCard(
                icon: Icons.insights_rounded,
                iconBackground: const Color(0xFFE8EDFF),
                iconColor: const Color(0xFF5267C5),
                title: 'Self-Care Progress',
                subtitle:
                    'Track your weekly wellness activities and progress.',
                onTap: () => _openScreen(
                  const SelfCareProgressScreen(),
                ),
              ),

              const SizedBox(height: 14),

              // Stress-Level Check-In.
              _navigationCard(
                icon: Icons.psychology_rounded,
                iconBackground: const Color(0xFFFFE8E8),
                iconColor: const Color(0xFFD65A5A),
                title: 'Stress-Level Check-In',
                subtitle:
                    'Answer a few questions to understand your stress level.',
                onTap: () => _openScreen(
                  const StressCheckInScreen(),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 25),

              // Mood selection.
              _buildMoodCard(),

              const SizedBox(height: 20),

              // Smart Daily Wellness Plan.
              _navigationCard(
                icon: Icons.spa_rounded,
                iconBackground: const Color(0xFFE8EDFF),
                iconColor: const Color(0xFF5267C5),
                title: 'Smart Daily Wellness Plan',
                subtitle:
                    'Get self-care activities based on your mood.',
                onTap: () => _openScreen(
                  const WellnessPlanScreen(),
                ),
              ),

              const SizedBox(height: 14),

              // SOS Support.
              
              // QUICK ACCESS: SOS, Professional Support and Relax.
              _buildSosCard(),

              const SizedBox(height: 10),

              _navigationCard(
                icon: Icons.support_agent_rounded,
                iconBackground: const Color(0xFFE8EDFF),
                iconColor: const Color(0xFF5267C5),
                title: 'Professional Support',
                subtitle: 'Find counselling and support helplines.',
                onTap: () => _openScreen(
                  const ProfessionalHelpScreen(),
                ),
              ),

              const SizedBox(height: 10),

              _navigationCard(
                icon: Icons.spa_rounded,
                iconBackground: const Color(0xFFDDF4EA),
                iconColor: const Color(0xFF168A78),
                title: 'Relax Exercises',
                subtitle: 'Take a moment to breathe and unwind.',
                onTap: () => _openScreen(
                  const RelaxScreen(),
                ),
              ),
              const SizedBox(height: 20),

              // Journal and Relax.
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openScreen(
                        const JournalScreen(),
                      ),
                      child: featureCard(
                        'Journal',
                        Icons.menu_book_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openScreen(
                        const RelaxScreen(),
                      ),
                      child: featureCard(
                        'Relax',
                        Icons.spa_outlined,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Mood history.
              _buildMyMoodCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // Bottom navigation belongs inside Scaffold.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavigationTap,
        selectedItemColor: const Color(0xFF5267C5),
        unselectedItemColor: Colors.grey,
        
items: const [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.chat_outlined),
    activeIcon: Icon(Icons.chat),
    label: 'Chat',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.book_outlined),
    activeIcon: Icon(Icons.book),
    label: 'Journal',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outline),
    activeIcon: Icon(Icons.person),
    label: 'Profile',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.support_agent_outlined),
    activeIcon: Icon(Icons.support_agent),
    label: 'Support',
  ),
],

      ),
    );
  }
}