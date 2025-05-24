import 'package:flutter/material.dart';
import '../enum/entry_mode.dart';

class EntryModeButton extends StatelessWidget {
  final EntryMode mode;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const EntryModeButton({super.key, 
    required this.mode,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: selected ? Colors.lightBlue : Colors.grey[200],
            child: Icon(icon, color: selected ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}