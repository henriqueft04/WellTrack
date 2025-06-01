import 'package:flutter/material.dart';
import 'package:welltrack/models/action_card.dart';
import 'package:welltrack/pages/mental_state_form_page.dart';
import 'package:welltrack/pages/journal_selection_page.dart';

class MentalStatePage extends StatelessWidget {
  final int? originIndex; // Track which main page this was navigated from
  
  const MentalStatePage({super.key, this.originIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mental Health', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose an option',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            StyledActionButton(
              icon: Icons.sentiment_satisfied,
              label: 'State of Mind',
              color: Colors.lightBlue,
              background: Colors.lightBlue.withValues(alpha: 0.1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MentalStateFormPage(selectedDate: DateTime.now()),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            StyledActionButton(
              icon: Icons.book,
              label: 'Journal',
              color: Colors.pink.shade200,
              background: Colors.pink.shade200.withValues(alpha: 0.1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JournalSelectionPage(
                      selectedDate: DateTime.now(),
                      originIndex: originIndex,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 