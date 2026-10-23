import 'dart:async';
import 'package:flutter/material.dart';

class RelaxScreen extends StatefulWidget {
  const RelaxScreen({super.key});

  @override
  State<RelaxScreen> createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen> {
  Timer? timer;

  int selectedExercise = -1;
  int seconds = 4;
  int currentStep = 0;
  bool isRunning = false;

  final List<Map<String, dynamic>> exercises = [
    {
      'title': '4-4-4 Breathing',
      'description': 'Breathe in, hold, and breathe out slowly.',
      'steps': ['Breathe In', 'Hold', 'Breathe Out'],
      'duration': 4,
    },
    {
      'title': 'Box Breathing',
      'description': 'A simple technique to calm your breathing.',
      'steps': ['Breathe In', 'Hold', 'Breathe Out', 'Hold'],
      'duration': 4,
    },
    {
      'title': 'Deep Breathing',
      'description': 'Take a slow breath in and breathe out gently.',
      'steps': ['Breathe In', 'Breathe Out'],
      'duration': 5,
    },
    {
      'title': 'Mindful Relaxation',
      'description': 'Slow down and focus on your breathing.',
      'steps': ['Relax', 'Breathe In', 'Breathe Out'],
      'duration': 6,
    },
  ];

  void selectExercise(int index) {
    stopExercise();

    setState(() {
      selectedExercise = index;
      currentStep = 0;
      seconds = exercises[index]['duration'];
    });
  }

  void startExercise() {
    if (selectedExercise == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an exercise first.'),
        ),
      );
      return;
    }

    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        setState(() {
          seconds--;

          if (seconds <= 0) {
            currentStep++;

            final steps =
                exercises[selectedExercise]['steps'] as List<String>;

            if (currentStep >= steps.length) {
              currentStep = 0;
            }

            seconds =
                exercises[selectedExercise]['duration'] as int;
          }
        });
      },
    );
  }

  void stopExercise() {
    timer?.cancel();

    if (!mounted) return;

    setState(() {
      isRunning = false;
      currentStep = 0;

      if (selectedExercise != -1) {
        seconds =
            exercises[selectedExercise]['duration'] as int;
      } else {
        seconds = 4;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentStepText = 'Select an exercise';

    if (selectedExercise != -1) {
      final steps =
          exercises[selectedExercise]['steps'] as List<String>;

      currentStepText = steps[currentStep];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      appBar: AppBar(
        title: const Text(
          'Relax',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Take a Moment to Relax',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Choose an exercise that helps you slow down '
              'and feel more relaxed.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Choose an Exercise',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 15),

            // Exercise Cards
            ...List.generate(
              exercises.length,
              (index) {
                final exercise = exercises[index];
                final isSelected = selectedExercise == index;

                return GestureDetector(
                  onTap: () {
                    selectExercise(index);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEAF7F0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5B8DEF)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FF),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.spa_outlined,
                            color: Color(0xFF5B8DEF),
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise['title'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                exercise['description'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.arrow_forward_ios,
                          size: isSelected ? 25 : 16,
                          color: isSelected
                              ? const Color(0xFF5B8DEF)
                              : Colors.black38,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // Timer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
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
                children: [
                  const Text(
                    'Current Exercise',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: 190,
                    height: 190,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEAF7F0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            currentStepText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF263238),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '$seconds',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5B8DEF),
                            ),
                          ),

                          const Text(
                            'seconds',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isRunning
                          ? stopExercise
                          : startExercise,
                      child: Text(
                        isRunning
                            ? 'Stop Exercise'
                            : 'Start Exercise',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}