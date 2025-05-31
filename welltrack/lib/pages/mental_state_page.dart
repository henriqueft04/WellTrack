import 'package:flutter/material.dart';

class MentalStatePage extends StatelessWidget {
  const MentalStatePage({super.key});

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
            _buildOptionCard(
              context,
              title: 'State of Mind',
              icon: Icons.sentiment_satisfied,
              color: Colors.lightBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MentalStateFormPage()),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: 'Journal',
              icon: Icons.book,
              color: Colors.pink.shade200,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JournalSelectionPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MentalStateFormPage extends StatefulWidget {
  const MentalStateFormPage({super.key});

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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('State of Mind', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: Text('16/05', style: TextStyle(color: Colors.black))),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  color: Colors.lightBlueAccent.withOpacity(0.1),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('unpleasant'),
                          Text(''),
                          Text('neutral'),
                          Text(''),
                          Text('pleasant'),
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
                  final bool isSelected = _selectedEmotions.contains(emotion);
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
                    selectedColor: Colors.lightBlue,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Impact Section
              const Text(
                'What\'s having the most impact on you?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _impacts.map((impact) {
                  final bool isSelected = _selectedImpacts.contains(impact);
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
                    selectedColor: Colors.pink.shade200,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save the state of mind data
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade200,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMoodIcon() {
    if (_moodValue <= 0.5) {
      return Icons.sentiment_very_dissatisfied;
    } else if (_moodValue <= 1.5) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_satisfied;
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

// --- JournalSelectionPage ---
class JournalSelectionPage extends StatelessWidget {
  const JournalSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('journal', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: Text('16/05', style: TextStyle(color: Colors.black))),
          )
        ],
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
            _buildOptionCard(
              context,
              title: 'See my thoughts',
              icon: Icons.visibility,
              color: Colors.lightBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SeeMyThoughtsPage()),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: 'Insert',
              icon: Icons.edit,
              color: Colors.pink.shade200,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InsertThoughtsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- InsertThoughtsPage ---
class InsertThoughtsPage extends StatefulWidget {
  const InsertThoughtsPage({super.key});

  @override
  State<InsertThoughtsPage> createState() => _InsertThoughtsPageState();
}

class _InsertThoughtsPageState extends State<InsertThoughtsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF9CD0FF);
    final unselectedColor = Colors.black54;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('journal', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: Text('16/05', style: TextStyle(color: Colors.black))),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: StatefulBuilder(
            builder: (context, setStateTab) {
              return TabBar(
                controller: _tabController,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4.0, color: selectedColor),
                  insets: EdgeInsets.symmetric(
                    horizontal: (MediaQuery.of(context).size.width / 3 - 32) / 2,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.edit,
                      color: _tabController.index == 0 ? selectedColor : unselectedColor,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.camera_alt,
                      color: _tabController.index == 1 ? selectedColor : unselectedColor,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.graphic_eq,
                      color: _tabController.index == 2 ? selectedColor : unselectedColor,
                    ),
                  ),
                ],
                onTap: (index) {
                  setStateTab(() {
                    _tabController.index = index;
                  });
                  setState(() {});
                },
              );
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Text input
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Insert text here',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // Image input
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Take a photo', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade200,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Choose from gallery', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
          // Audio input (placeholder)
          Center(
            child: Text('Audio input coming soon...', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

// --- SeeMyThoughtsPage ---
class SeeMyThoughtsPage extends StatelessWidget {
  const SeeMyThoughtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('journal', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: Text('16/05', style: TextStyle(color: Colors.black))),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
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
                    icon: const Icon(Icons.play_arrow, color: Color(0xFF9CD0FF), size: 28),
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}