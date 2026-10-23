
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfCareProgressScreen extends StatefulWidget {
  const SelfCareProgressScreen({super.key});

  @override
  State<SelfCareProgressScreen> createState() =>
      _SelfCareProgressScreenState();
}

class _SelfCareProgressScreenState
    extends State<SelfCareProgressScreen> {
  static const Color primaryColor = Color(0xFF5267C5);

  static const List<String> moods = [
    'Happy',
    'Okay',
    'Sad',
    'Stressed',
    'Anxious',
  ];

  List<int> dailyCompleted = List<int>.filled(7, 0);
  bool isLoading = true;

  int get totalCompleted =>
      dailyCompleted.fold(0, (sum, count) => sum + count);

  int get activeDays =>
      dailyCompleted.where((count) => count > 0).length;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final results = <int>[];

    for (int daysAgo = 6; daysAgo >= 0; daysAgo--) {
      final date = DateTime.now().subtract(
        Duration(days: daysAgo),
      );

      int bestCompleted = 0;

      for (final mood in moods) {
        final saved = prefs.getStringList(
          'wellness_${_dateKey(date)}_$mood',
        );

        if (saved != null) {
          final completed = saved
              .where((item) => item.toLowerCase() == 'true')
              .length;

          if (completed > bestCompleted) {
            bestCompleted = completed;
          }
        }
      }

      results.add(bestCompleted.clamp(0, 4));
    }

    if (!mounted) return;

    setState(() {
      dailyCompleted = results;
      isLoading = false;
    });
  }

  String _dayLabel(int index) {
    final daysAgo = 6 - index;

    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';

    final date = DateTime.now().subtract(
      Duration(days: daysAgo),
    );

    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];

    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (totalCompleted / 28 * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text('Self-Care Progress'),
        backgroundColor: const Color(0xFFF4F7FF),
        foregroundColor: const Color(0xFF26345F),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgress,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.self_improvement_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Small steps matter.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your self-care activities over the last seven days.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$totalCompleted',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 6,
                                bottom: 6,
                              ),
                              child: Text(
                                'of 28 activities',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: totalCompleted / 28,
                            minHeight: 9,
                            backgroundColor: Colors.white24,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          Icons.calendar_month_rounded,
                          'Active days',
                          '$activeDays / 7',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          Icons.check_circle_outline_rounded,
                          'Daily average',
                          (totalCompleted / 7).toStringAsFixed(1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Animated weekly graph
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Activity',
                          style: TextStyle(
                            color: Color(0xFF26345F),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Your daily self-care activities out of 4',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 190,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (index) {
                              final completed = dailyCompleted[index];

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$completed',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: TweenAnimationBuilder<double>(
                                            key: ValueKey(
                                              'weekly_bar_$index',
                                            ),
                                            tween: Tween<double>(
                                              begin: 0,
                                              end: completed / 4,
                                            ),
                                            duration: Duration(
                                              milliseconds: 650 + index * 100,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            builder: (
                                              context,
                                              value,
                                              child,
                                            ) {
                                              return FractionallySizedBox(
                                                heightFactor: value == 0
                                                    ? 0.015
                                                    : value,
                                                widthFactor: 0.78,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(9),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: completed > 0
                                                          ? const [
                                                              Color(0xFF8D9CF0),
                                                              primaryColor,
                                                            ]
                                                          : const [
                                                              Color(0xFFE8ECF8),
                                                              Color(0xFFE8ECF8),
                                                            ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 9),
                                      Text(
                                        _dayLabel(index) == 'Yesterday'
                                            ? 'Yest.'
                                            : _dayLabel(index),
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: primaryColor,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Higher bars mean more activities completed.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Your last 7 days',
                    style: TextStyle(
                      color: Color(0xFF26345F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Each day can include up to four activities.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(7, (index) {
                    final completed = dailyCompleted[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _dayLabel(index),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF26345F),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$completed / 4',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: completed / 4,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE8ECF8),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.favorite_rounded, color: primaryColor),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Progress is not a test. Missing a day is okay. Start again whenever you feel ready.',
                            style: TextStyle(
                              color: Color(0xFF34416D),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _loadProgress,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh progress'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 25),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26345F),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
