import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';
import 'package:welltrack/models/action_card.dart';
import 'package:welltrack/pages/see_my_thoughts_page.dart';
import 'package:welltrack/pages/text_journal_page.dart';
import 'package:welltrack/pages/photo_journal_page.dart';
import 'package:welltrack/pages/audio_journal_page.dart';

class JournalSelectionPage extends StatelessWidget {
  final int? originIndex;
  final DateTime selectedDate;
  
  const JournalSelectionPage({
    super.key,
    this.originIndex,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: originIndex,
      child: AppLayout(
        pageTitle: 'journal',
        showLogo: false,
        isMainPage: false,
        showBackButton: true,
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'Choose journal type',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                
                // View entries button
                StyledActionButton(
                  icon: Icons.visibility,
                  label: 'View my journal',
                  color: Colors.lightBlue,
                  background: Colors.lightBlue.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeeMyThoughtsPage(
                          originIndex: originIndex,
                          selectedDate: selectedDate,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                const Text(
                  'Create new entry',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                
                // Text entry button
                StyledActionButton(
                  icon: Icons.edit_note,
                  label: 'Write text',
                  color: Colors.deepPurple,
                  background: Colors.deepPurple.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TextJournalPage(
                          originIndex: originIndex,
                          selectedDate: selectedDate,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Photo entry button
                StyledActionButton(
                  icon: Icons.photo_camera,
                  label: 'Add photo',
                  color: Colors.green,
                  background: Colors.green.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoJournalPage(
                          originIndex: originIndex,
                          selectedDate: selectedDate,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Audio entry button
                StyledActionButton(
                  icon: Icons.mic,
                  label: 'Record audio',
                  color: Colors.orange,
                  background: Colors.orange.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioJournalPage(
                          originIndex: originIndex,
                          selectedDate: selectedDate,
                        ),
                      ),
                    );
                  },
                ),
                // Add some bottom padding to ensure content doesn't get cut off
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 