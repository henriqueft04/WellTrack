import 'package:flutter/material.dart';
import 'package:welltrack/pages/home_page.dart';
import 'package:welltrack/utils/mood_utils.dart';

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
          MoodUtils.getMoodIcon(moodValue),
          size: 50,
          color: MoodUtils.getMoodColor(moodValue),
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
            max: 4,
            divisions: 4,
            value: moodValue,
            onChanged: onMoodChanged,
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('very\nunpleasant', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
            Text('unpleasant', style: TextStyle(fontSize: 10)),
            Text('ok', style: TextStyle(fontSize: 10)),
            Text('pleasant', style: TextStyle(fontSize: 10)),
            Text('very\npleasant', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
          ],
        ),
      ],
    ),
  );
}
