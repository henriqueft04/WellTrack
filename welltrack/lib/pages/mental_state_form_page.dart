import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';

class MentalStateFormPage extends StatefulWidget {
  final int? originIndex;
  final DateTime selectedDate;
  
  const MentalStateFormPage({
    super.key, 
    this.originIndex, 
    required this.selectedDate,
  });

  @override
  State<MentalStateFormPage> createState() => _MentalStateFormPageState();
}

class _MentalStateFormPageState extends State<MentalStateFormPage> {
  double _moodValue = 1.0; // 0 = unpleasant, 1 = neutral, 2 = pleasant
  final Set<String> _selectedEmotions = {};
  final Set<String> _selectedImpacts = {};

  final List<String> _emotions = [
    'Happy',
    'Calm',
    'Anxious',
    'Stressed',
    'Excited',
    'Tired',
    'Energetic',
    'Focused',
    'Distracted',
    'Motivated'
  ];

  final List<String> _impacts = [
    'Work',
    'Family',
    'Health',
    'Relationships',
    'Exercise',
    'Sleep',
    'Diet',
    'Social Life',
    'Hobbies',
    'Weather'
  ];

  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: widget.originIndex,
      child: AppLayout(
        pageTitle: 'State of Mind',
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
                      '${widget.selectedDate.day.toString().padLeft(2, '0')}/${widget.selectedDate.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Mood Section
                const Text(
                  'How are you feeling?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.lightBlueAccent, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getMoodIcon(),
                        size: 80,
                        color: _getMoodColor(),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 12,
                            activeTrackColor: const Color(0xFF9CD0FF),
                            inactiveTrackColor: const Color(0xFF9CD0FF),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20),
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbColor: Colors.white,
                            trackShape: RoundedRectSliderTrackShape(),
                          ),
                          child: Slider(
                            min: 0,
                            max: 2,
                            divisions: 4,
                            value: _moodValue,
                            onChanged: (value) {
                              setState(() {
                                _moodValue = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('unpleasant', style: TextStyle(fontSize: 12)),
                            Text('neutral', style: TextStyle(fontSize: 12)),
                            Text('pleasant', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Emotions Section
                const Text(
                  'What emotions are you experiencing?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emotions.map((emotion) {
                    final isSelected = _selectedEmotions.contains(emotion);
                    return FilterChip(
                      label: Text(emotion),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedEmotions.add(emotion);
                          } else {
                            _selectedEmotions.remove(emotion);
                          }
                        });
                      },
                      selectedColor: Colors.lightBlue.withValues(alpha: 0.3),
                      checkmarkColor: Colors.lightBlue,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Impact Section
                const Text(
                  'What factors are impacting your mood?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _impacts.map((impact) {
                    final isSelected = _selectedImpacts.contains(impact);
                    return FilterChip(
                      label: Text(impact),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedImpacts.add(impact);
                          } else {
                            _selectedImpacts.remove(impact);
                          }
                        });
                      },
                      selectedColor: Colors.pink.withValues(alpha: 0.3),
                      checkmarkColor: Colors.pink,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save the mental state data
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9CD0FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMoodIcon() {
    if (_moodValue <= 0.5) {
      return Icons.sentiment_dissatisfied;
    } else if (_moodValue <= 1.5) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_satisfied;
    }
  }

  Color _getMoodColor() {
    if (_moodValue <= 0.5) {
      return Colors.red;
    } else if (_moodValue <= 1.5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
} 