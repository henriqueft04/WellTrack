import 'package:flutter/material.dart';
import 'package:welltrack/pages/home_page.dart';

Widget buildMoodSlider(
  BuildContext context,
  double moodValue,
  Function(double) onMoodChanged,
) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: HomePageConstants.cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(
          _getMoodIcon(moodValue),
          size: 50,
          color: _getMoodColor(moodValue),
        ),
        const SizedBox(height: 16),
        SliderTheme(
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
            value: moodValue,
            onChanged: onMoodChanged,
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
      ],
    ),
  );
}

IconData _getMoodIcon(double moodValue) {
  if (moodValue == 0.0) {
    return Icons.sentiment_very_dissatisfied;
  } else if (moodValue == 0.5) {
    return Icons.sentiment_dissatisfied;
  } else if (moodValue <= 1.5) {
    return Icons.sentiment_neutral;
  } else {
    return Icons.sentiment_very_satisfied;
  }
}

Color _getMoodColor(double moodValue) {
  if (moodValue == 0.0) {
    return Colors.red;
  } else if (moodValue == 0.5) {
    return Colors.deepOrange;
  } else if (moodValue == 1.0) {
    return Colors.orange;
  } else if (moodValue == 1.5) {
    return Colors.lightGreen;
  } else {
    return Colors.green;
  }
}
