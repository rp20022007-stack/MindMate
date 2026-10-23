
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StressCheckInScreen extends StatefulWidget {
  const StressCheckInScreen({super.key});

  @override
  State<StressCheckInScreen> createState() =>
      _StressCheckInScreenState();
}

class _StressCheckInScreenState extends State<StressCheckInScreen> {
  static const Color primaryColor = Color(0xFF5267C5);
  static const Color backgroundColor = Color(0xFFF4F7FF);

  final List<String> questions = [
    'I found it difficult to relax.',
    'I felt nervous, tense, or overwhelmed.',
    'I found it difficult to manage my daily responsibilities.',
    'Stress made it difficult for me to get restful sleep.',
  ];

  final List<String> options = [
    'Never',
    'Sometimes',
    'Often',
    'Almost always',
  ];

  final List<int?> answers = [null, null, null, null];

  bool showResult = false;
  bool isSaving = false;

  int get score =>
      answers.fold(0, (sum, answer) => sum + (answer ?? 0));

  int get answeredCount =>
      answers.where((answer) => answer != null).length;

  String get stressLevel {
    if (score <= 3) return 'Lower reported stress';
    if (score <= 7) return 'Some reported stress';
    return 'More frequent reported stress';
  }

  String get suggestion {
    if (score <= 3) {
      return 'Continue supporting your wellbeing with regular breaks, '
          'adequate rest, enjoyable activities, and time to relax.';
    }

    if (score <= 7) {
      return 'Try dividing tasks into smaller steps, taking short breaks, '
          'practising slow breathing, and speaking with someone you trust.';
    }

    return 'Consider making time to rest, reducing avoidable demands '
        'where possible, and reaching out to someone you trust. '
        'A qualified mental health professional can help if stress '
        'is affecting your daily life.';
  }

  Future<void> saveCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    await prefs.setString('stress_checkin_$date', '$score');
  }

  Future<void> submitCheckIn() async {
    if (answeredCount != questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer every question to continue.'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await saveCheckIn();

      if (!mounted) return;

      setState(() {
        isSaving = false;
        showResult = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save your check-in. Please try again.'),
        ),
      );
    }
  }

  void resetCheckIn() {
    setState(() {
      for (var i = 0; i < answers.length; i++) {
        answers[i] = null;
      }
      showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Stress & Wellbeing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: const Color(0xFF253052),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5267C5),
                      Color(0xFF8293EB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.self_improvement_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Take a moment for yourself',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Reflect on how you have been feeling over the '
                      'past 7 days. Choose the answers that best '
                      'describe your experience.',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (!showResult) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your check-in',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF253052),
                      ),
                    ),
                    Text(
                      '$answeredCount of ${questions.length}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: answeredCount / questions.length,
                    minHeight: 7,
                    color: primaryColor,
                    backgroundColor: const Color(0xFFE0E6FA),
                  ),
                ),
                const SizedBox(height: 18),

                ...List.generate(questions.length, (index) {
                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QUESTION ${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            questions[index],
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF253052),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(options.length, (optionIndex) {
                            final selected =
                                answers[index] == optionIndex;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    answers[index] = optionIndex;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFE8EDFF)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? primaryColor
                                          : const Color(0xFFE1E5EF),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: selected
                                            ? primaryColor
                                            : Colors.grey,
                                        size: 21,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          options[optionIndex],
                                          style: TextStyle(
                                            color: const Color(0xFF253052),
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : submitCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'View My Results',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        color: primaryColor,
                        size: 48,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Your wellbeing summary',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF253052),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        stressLevel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reflection score: $score / 12',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: score / 12,
                          minHeight: 10,
                          color: primaryColor,
                          backgroundColor: const Color(0xFFE0E6FA),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        suggestion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Color(0xFF68718A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: resetCheckIn,
                    child: const Text('Take Check-In Again'),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                'This is an informal self-reflection tool, not a '
                'validated clinical assessment or medical diagnosis. '
                'The score is based only on your responses.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF68718A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
