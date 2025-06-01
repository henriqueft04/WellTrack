import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';
import 'package:welltrack/models/action_card.dart';
import 'package:welltrack/pages/see_my_thoughts_page.dart';
import 'package:welltrack/pages/insert_thoughts_page.dart';

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
        content: Padding(
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
                'Choose an option',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              StyledActionButton(
                icon: Icons.visibility,
                label: 'See my thoughts',
                color: Colors.lightBlue,
                background: Colors.lightBlue.withValues(alpha: 0.1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeMyThoughtsPage(originIndex: originIndex),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              StyledActionButton(
                icon: Icons.edit,
                label: 'Insert',
                color: Colors.pink.shade200,
                background: Colors.pink.shade200.withValues(alpha: 0.1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InsertThoughtsPage(originIndex: originIndex),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 