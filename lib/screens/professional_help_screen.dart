
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfessionalHelpScreen extends StatelessWidget {
  const ProfessionalHelpScreen({super.key});

  Future<void> _openLink(
    BuildContext context,
    String value,
  ) async {
    final uri = Uri.parse(value);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open this link. Please try again.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open this link.'),
          ),
        );
      }
    }
  }

  Widget _supportCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String buttonText,
    required String actionValue,
    required bool isWebsite,
  }) {
    return Card(
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
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: color.withAlpha(25),
                  child: Icon(icon, color: color, size: 27),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openLink(context, actionValue),
                icon: Icon(
                  isWebsite ? Icons.open_in_new : Icons.call,
                ),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5267D8);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text(
          'Professional Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF4F7FF),
        foregroundColor: const Color(0xFF26345C),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6578E8),
                    Color(0xFF8998F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'You do not have to face everything alone.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reach out to a support service or a qualified '
                    'mental health professional when you need help.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Support resources',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26345C),
              ),
            ),
            const SizedBox(height: 14),
            _supportCard(
              context: context,
              icon: Icons.support_agent,
              color: primaryColor,
              title: 'Tele-MANAS',
              description:
                  'Free, confidential, 24-hour mental health '
                  'support provided by the Government of India.',
              buttonText: 'Call 14416',
              actionValue: 'tel:14416',
              isWebsite: false,
            ),
            _supportCard(
              context: context,
              icon: Icons.language,
              color: const Color(0xFF168A78),
              title: 'Mental Health Information',
              description:
                  'Visit the official Ministry of Health website '
                  'to learn about national mental health services.',
              buttonText: 'Visit official website',
              actionValue: 'https://dghs.mohfw.gov.in/national-mental-health-programme.php',
              isWebsite: true,
            ),
            _supportCard(
              context: context,
              icon: Icons.emergency,
              color: const Color(0xFFD94343),
              title: 'Emergency Support',
              description:
                  'For immediate danger or an urgent emergency '
                  'in India, contact the national emergency service.',
              buttonText: 'Call 112',
              actionValue: 'tel:112',
              isWebsite: false,
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'MindMate offers wellbeing support but does not '
                'replace professional assessment, diagnosis, '
                'or treatment. If possible, speak with a trusted '
                'person or qualified professional.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
