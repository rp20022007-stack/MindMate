import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  static const String _contactsKey = 'mindmate_trusted_contacts';

  List<Map<String, String>> trustedContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Load saved contacts
  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_contactsKey);

      final List<Map<String, String>> loadedContacts = [];

      if (savedData != null) {
        final decodedData = jsonDecode(savedData);

        if (decodedData is List) {
          for (final item in decodedData) {
            if (item is Map) {
              loadedContacts.add({
                'name': item['name']?.toString() ?? '',
                'phone': item['phone']?.toString() ?? '',
              });
            }
          }
        }
      }

      if (!mounted) return;

      setState(() {
        trustedContacts = loadedContacts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading contacts: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Could not load saved contacts.');
    }
  }

  // Save contacts to SharedPreferences
  Future<bool> _saveContacts(
    List<Map<String, String>> contacts,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return await prefs.setString(
        _contactsKey,
        jsonEncode(contacts),
      );
    } catch (e) {
      debugPrint('Error saving contacts: $e');
      return false;
    }
  }

  // Show message
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // Call emergency number or trusted contact
  Future<void> _callNumber(String phone) async {
    if (phone.trim().isEmpty) {
      _showMessage('Phone number is not available.');
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showMessage('Unable to open the phone dialer.');
      }
    } catch (e) {
      debugPrint('Error opening dialer: $e');
      _showMessage('Could not open the phone dialer.');
    }
  }

  // Add a new trusted contact
  Future<void> _addContact() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    try {
      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Add Trusted Contact'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Contact Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a phone number';
                        }

                        if (!RegExp(r'^\+?[0-9\s()-]{7,20}$')
                            .hasMatch(value.trim())) {
                          return 'Please enter a valid phone number';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(dialogContext).pop({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                    });
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (result == null || !mounted) return;

      final updatedContacts = <Map<String, String>>[
        ...trustedContacts,
        result,
      ];

      // Save before updating the UI
      final saved = await _saveContacts(updatedContacts);

      if (!mounted) return;

      if (!saved) {
        _showMessage('Could not save contact. Please try again.');
        return;
      }

      setState(() {
        trustedContacts = updatedContacts;
      });

      _showMessage('Trusted contact saved successfully.');
    } catch (e, stackTrace) {
      debugPrint('Error adding contact: $e');
      debugPrintStack(stackTrace: stackTrace);

      _showMessage(
        'Something went wrong while saving the contact.',
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
    }
  }

  // Delete a trusted contact
  Future<void> _deleteContact(int index) async {
    if (index < 0 || index >= trustedContacts.length) return;

    final contact = trustedContacts[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Contact?'),
          content: Text(
            'Do you want to delete ${contact['name']} '
            'from your trusted contacts?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    final updatedContacts =
        List<Map<String, String>>.from(trustedContacts)
          ..removeAt(index);

    final saved = await _saveContacts(updatedContacts);

    if (!mounted) return;

    if (!saved) {
      _showMessage('Could not delete contact. Please try again.');
      return;
    }

    setState(() {
      trustedContacts = updatedContacts;
    });

    _showMessage('Contact deleted successfully.');
  }

  // Quick Calm information
  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Quick Calm'),
          content: const SingleChildScrollView(
            child: Text(
              'Try these simple steps when you feel overwhelmed:\n\n'
              '1. Sit somewhere safe and comfortable.\n\n'
              '2. Breathe in gently and breathe out slowly.\n\n'
              '3. Notice five things you can see around you.\n\n'
              '4. Drink some water if you need it.\n\n'
              '5. Contact someone you trust if you need support.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Reusable support card
  Widget _supportCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  // Trusted contacts section
  Widget _buildTrustedContacts() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (trustedContacts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No trusted contacts added yet.\n'
              'Add someone you trust for quick access.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(trustedContacts.length, (index) {
        final contact = trustedContacts[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(contact['name'] ?? ''),
            subtitle: Text(contact['phone'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Call contact',
                  icon: const Icon(
                    Icons.call,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    _callNumber(contact['phone'] ?? '');
                  },
                ),
                IconButton(
                  tooltip: 'Delete contact',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _deleteContact(index);
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Help'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.shade100,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    size: 52,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Need Immediate Help?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you are in immediate danger, contact '
                    'emergency services or someone you trust.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _callNumber('112'),
                      icon: const Icon(Icons.call),
                      label: const Text(
                        'Call Emergency Services (112)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Trusted Contacts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Add trusted contact',
                  onPressed: _isLoading ? null : _addContact,
                  icon: const Icon(Icons.person_add_alt_1),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _buildTrustedContacts(),

            const SizedBox(height: 24),

            const Text(
              'Quick Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _supportCard(
              icon: Icons.self_improvement,
              color: Colors.deepPurple,
              title: 'Quick Calm',
              subtitle: 'Simple steps to help you feel calmer.',
              onTap: _showInfo,
            ),

            _supportCard(
              icon: Icons.phone_in_talk,
              color: Colors.teal,
              title: 'Call a Trusted Contact',
              subtitle: 'Add a contact above, then tap the call icon.',
              onTap: () {
                if (trustedContacts.isEmpty) {
                  _showMessage(
                    'Please add a trusted contact first.',
                  );
                } else {
                  _callNumber(
                    trustedContacts.first['phone'] ?? '',
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.deepOrange,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This app does not replace emergency services '
                      'or professional medical care. In an emergency, '
                      'contact local emergency services.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}