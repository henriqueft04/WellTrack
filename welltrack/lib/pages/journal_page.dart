import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDEDFD), // Background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Indicadores / informações do dia (Chama DataCard)
              // Steps and Calories são mostrados como inteiros, 
              // Distance é com uma casa decimal e tem "km" no final
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

              const SizedBox(height: 30),

              const Text(
                "What did you do?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Botões de entrada - Registo de radio buttons
              // Vai chamar o model EntryModeButton
              //  para ir trocando modo de input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  EntryModeButton(
                    mode: EntryMode.write,
                    icon: Icons.edit,
                    label: "Write",
                    selected: _selectedMode == EntryMode.write,
                    onTap:
                        () => setState(() => _selectedMode = EntryMode.write),
                  ),
                  EntryModeButton(
                    mode: EntryMode.photo,
                    icon: Icons.camera_alt,
                    label: "Video/Photo",
                    selected: _selectedMode == EntryMode.photo,
                    onTap:
                        () => setState(() => _selectedMode = EntryMode.photo),
                  ),
                  EntryModeButton(
                    mode: EntryMode.audio,
                    icon: Icons.audiotrack,
                    label: "Audio",
                    selected: _selectedMode == EntryMode.audio,
                    onTap:
                        () => setState(() => _selectedMode = EntryMode.audio),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Mostrar campo de entrada baseado no modo escolhido
              if (_selectedMode == EntryMode.write)
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: InputDecoration(
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
