
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WellnessPlanScreen extends StatefulWidget {
  const WellnessPlanScreen({super.key});

  @override
  State<WellnessPlanScreen> createState() =>
      _WellnessPlanScreenState();
}

class _WellnessPlanScreenState extends State<WellnessPlanScreen> {
  static const Color primaryColor = Color(0xFF5267C5);
  static const Color backgroundColor = Color(0xFFF4F7FF);

  String selectedMood = 'Okay';
  List<bool> completed = List.filled(4, false);
  bool loading = true;

  final Map<String, List<Map<String, String>>> plans = {
    'Happy': [
      {'title': 'Write one thing you are grateful for', 'time': '2 min'},
      {'title': 'Take a refreshing walk', 'time': '10 min'},
      {'title': 'Share a kind message with someone', 'time': '2 min'},
      {'title': 'Celebrate one small achievement', 'time': '3 min'},
    ],
    'Okay': [
      {'title': 'Drink a glass of water', 'time': '1 min'},
      {'title': 'Stretch your body gently', 'time': '3 min'},
      {'title': 'Write down one thought', 'time': '5 min'},
      {'title': 'Take a short screen break', 'time': '5 min'},
    ],
    'Sad': [
      {'title': 'Write down how you feel', 'time': '5 min'},
      {'title': 'Listen to calming music', 'time': '5 min'},
      {'title': 'Talk to someone you trust', 'time': '5 min'},
      {'title': 'Do one small thing you enjoy', 'time': '5 min'},
    ],
    'Stressed': [
      {'title': 'Pause and breathe comfortably', 'time': '2 min'},
      {'title': 'Break one task into smaller steps', 'time': '5 min'},
      {'title': 'Relax your shoulders gently', 'time': '2 min'},
      {'title': 'Take a short break from screens', 'time': '5 min'},
    ],
    'Anxious': [
      {'title': 'Name five things you can see', 'time': '2 min'},
      {'title': 'Breathe slowly without forcing it', 'time': '2 min'},
      {'title': 'Write down one worry', 'time': '5 min'},
      {'title': 'Reach out to someone you trust', 'time': '5 min'},
    ],
  };

  String get storageKey {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month}-${now.day}';
    return 'wellness_${date}_$selectedMood';
  }

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(storageKey);

    if (!mounted) return;

    setState(() {
      completed = saved != null && saved.length == 4
          ? saved.map((value) => value == 'true').toList()
          : List.filled(4, false);
      loading = false;
    });
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storageKey,
      completed.map((value) => value.toString()).toList(),
    );
  }

  Future<void> changeMood(String? mood) async {
    if (mood == null) return;

    setState(() {
      selectedMood = mood;
      loading = true;
    });

    await loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final plan = plans[selectedMood]!;

    final doneCount =
        completed.where((item) => item).length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Daily Wellness Plan'),
        backgroundColor: backgroundColor,
        foregroundColor: const Color(0xFF253052),
        elevation: 0,
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.spa_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'A little care goes a long way',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose small, manageable activities '
                            'to support your wellbeing today.',
                            style: TextStyle(
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF253052),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMood,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: plans.keys.map((mood) {
                        return DropdownMenuItem(
                          value: mood,
                          child: Text(mood),
                        );
                      }).toList(),
                      onChanged: changeMood,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's activities",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF253052),
                          ),
                        ),
                        Text(
                          '$doneCount of 4',
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: doneCount / 4,
                        minHeight: 9,
                        backgroundColor: const Color(0xFFE0E6FA),
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(plan.length, (index) {
                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CheckboxListTile(
                          value: completed[index],
                          activeColor: primaryColor,
                          controlAffinity:
                              ListTileControlAffinity.leading,
                          title: Text(
                            plan[index]['title']!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: completed[index]
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(plan[index]['time']!),
                          onChanged: (value) async {
                            setState(() {
                              completed[index] = value ?? false;
                            });
                            await saveProgress();
                          },
                        ),
                      );
                    }),
                    if (doneCount == 4)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F5E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Well done! You completed your daily plan. '
                          'Be proud of the small steps you took.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF236B3A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'These are general self-care suggestions, '
                      'not a medical diagnosis. Choose activities '
                      'that feel comfortable for you.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF68718A),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
