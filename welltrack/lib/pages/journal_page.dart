import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/pages/mental_state_page.dart';
import '../models/data_card.dart';
import '../models/entry_mode_button.dart';
import '../enum/entry_mode.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  // Modo de input default -> write
  EntryMode _selectedMode = EntryMode.write;
  final TextEditingController _textController = TextEditingController();
  double _moodValue = 1.0; // 0 = unpleasant, 1 = neutral, 2 = pleasant
  int _selectedDayIndex = 3; // Index for the 16th in the mockup

  void _onMoodChanged(double value) {
    setState(() {
      _moodValue = value;
    });
  }

  void _onDayTapped(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageTitle: "Today",
      showLogo: true,
      isMainPage: true,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Slider Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    onChanged: _onMoodChanged,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('unpleasant'),
                  Text(''),
                  Text('neutral'),
                  Text(''),
                  Text('pleasant'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Horizontal Calendar
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
                    final dates = [12, 13, 14, 15, 16, 17, 18];
                    final isSelected = index == _selectedDayIndex;
                    return GestureDetector(
                      onTap: () => _onDayTapped(index),
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[100] : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weekDays[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dates[index].toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Indicadores / informações do dia (Chama DataCard)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  DataCard(
                    icon: Icons.directions_walk,
                    label: "Steps",
                    value: 12212.0,
                  ),
                  DataCard(
                    icon: Icons.local_fire_department,
                    label: "Calories",
                    value: 210.0,
                  ),
                  DataCard(icon: Icons.map, label: "Distance", value: 2.5),
                ],
              ),

              const SizedBox(height: 24),
              
              // Cards for Mental State and Stats
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MentalStatePage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 187, 186, 186),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sentiment_satisfied, size: 40, color: Colors.white),
                          SizedBox(width: 16),
                          Text(
                            'mental state',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Removed direct navigation to StatsPage since it's handled by navbar
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "What did you do?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Botões de entrada - Registo de radio buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  EntryModeButton(
                    mode: EntryMode.write,
                    icon: Icons.edit,
                    label: "Write",
                    selected: _selectedMode == EntryMode.write,
                    onTap: () => setState(() => _selectedMode = EntryMode.write),
                  ),
                  EntryModeButton(
                    mode: EntryMode.photo,
                    icon: Icons.camera_alt,
                    label: "Video/Photo",
                    selected: _selectedMode == EntryMode.photo,
                    onTap: () => setState(() => _selectedMode = EntryMode.photo),
                  ),
                  EntryModeButton(
                    mode: EntryMode.audio,
                    icon: Icons.audiotrack,
                    label: "Audio",
                    selected: _selectedMode == EntryMode.audio,
                    onTap: () => setState(() => _selectedMode = EntryMode.audio),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Mostrar campo de entrada baseado no modo escolhido
              if (_selectedMode == EntryMode.write)
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    hintText: "Describe your day",
                    border: OutlineInputBorder(),
                  ),
                ),

              if (_selectedMode == EntryMode.photo)
                const Center(child: Text("Photo/Video input coming soon...")),

              if (_selectedMode == EntryMode.audio)
                const Center(child: Text("Audio input coming soon...")),
            ],
          ),
        ),
      ),
    );
  }
}
