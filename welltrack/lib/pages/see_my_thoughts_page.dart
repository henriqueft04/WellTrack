import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';

class SeeMyThoughtsPage extends StatelessWidget {
  final int? originIndex;
  
  const SeeMyThoughtsPage({super.key, this.originIndex});

  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: originIndex,
      child: AppLayout(
        pageTitle: 'journal',
        showLogo: false,
        isMainPage: false,
        showBackButton: true,
        content: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Date indicator
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('16/05', style: TextStyle(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Example text entry
            Align(
              alignment: Alignment.centerLeft,
              child: _ChatBubble(
                child: const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
              ),
            ),
            // Example image entry
            Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(
                color: Colors.blue.shade50,
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/8/8c/Cristiano_Ronaldo_2018.jpg',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
            // Example audio entry
            Align(
              alignment: Alignment.centerLeft,
              child: _ChatBubble(
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Color(0xFF9CD0FF),
                        size: 28,
                      ),
                      onPressed: () {
                        // TODO: Play audio
                      },
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF9CD0FF),
                          inactiveTrackColor: const Color(0xFF9CD0FF),
                          thumbColor: const Color(0xFF9CD0FF),
                        ),
                        child: Slider(
                          value: 0.3,
                          onChanged: (v) {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('1:51 minutes'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Widget child;
  final Color? color;
  
  const _ChatBubble({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
} 