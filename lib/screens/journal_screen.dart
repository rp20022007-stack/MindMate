import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController journalController =
      TextEditingController();

  List<String> entries = [];

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  // Load saved journal entries
  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      entries = prefs.getStringList('journal_entries') ?? [];
    });
  }

  // Save journal entries
  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('journal_entries', entries);
  }

  // Add new journal entry
  Future<void> saveEntry() async {
    final text = journalController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something first.'),
        ),
      );
      return;
    }

    setState(() {
      entries.insert(0, text);
      journalController.clear();
    });

    await saveEntries();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal entry saved.'),
      ),
    );
  }

  // Delete journal entry
  Future<void> deleteEntry(int index) async {
    setState(() {
      entries.removeAt(index);
    });

    await saveEntries();
  }

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      appBar: AppBar(
        title: const Text(
          'My Journal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Write your thoughts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Take a moment to express how you feel.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: TextField(
                controller: journalController,
                maxLines: 6,

                decoration: const InputDecoration(
                  hintText: 'Write something on your mind...',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: saveEntry,

                child: const Text(
                  'Save Entry',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Previous Entries',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Text(
                        'No journal entries yet.',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: entries.length,

                      itemBuilder: (context, index) {
                        return Card(
                          margin:
                              const EdgeInsets.only(bottom: 12),

                          child: ListTile(
                            title: Text(entries[index]),

                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                              ),

                              onPressed: () {
                                deleteEntry(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}