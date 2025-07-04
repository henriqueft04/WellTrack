import 'package:flutter/material.dart';

class MoodUtils {
  // Convert mental_state string to mood value (0.0 to 4.0 scale)
  static double mentalStateToMoodValue(String? mentalState) {
    if (mentalState == null) return 2.0; // neutral default
    
    switch (mentalState.toLowerCase()) {
      case 'very_unpleasant':
        return 0.0;
      case 'unpleasant':
        return 1.0;
      case 'ok':
        return 2.0;
      case 'pleasant':
        return 3.0;
      case 'very_pleasant':
        return 4.0;
      default:
        return 2.0; // neutral default
    }
  }

  // Get mood icon based on mood value
  static IconData getMoodIcon(double moodValue) {
    if (moodValue <= 0.5) {
      return Icons.sentiment_very_dissatisfied;
    } else if (moodValue <= 1.5) {
      return Icons.sentiment_dissatisfied;
    } else if (moodValue <= 2.5) {
      return Icons.sentiment_neutral;
    } else if (moodValue <= 3.5) {
      return Icons.sentiment_satisfied;
    } else {
      return Icons.sentiment_very_satisfied;
    }
  }

  // Get mood icon directly from mental state string
  static IconData getMoodIconFromState(String? mentalState) {
    return getMoodIcon(mentalStateToMoodValue(mentalState));
  }

  // Get mood color based on mood value
  static Color getMoodColor(double moodValue) {
    if (moodValue <= 0.5) {
      return Colors.red;
    } else if (moodValue <= 1.5) {
      return Colors.deepOrange;
    } else if (moodValue <= 2.5) {
      return Colors.orange;
    } else if (moodValue <= 3.5) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }

  // Get mood color directly from mental state string
  static Color getMoodColorFromState(String? mentalState) {
    return getMoodColor(mentalStateToMoodValue(mentalState));
  }

  // Get user-friendly mood display name
  static String getMoodDisplayName(String? mentalState) {
    if (mentalState == null) return 'Unknown';
    
    switch (mentalState.toLowerCase()) {
      case 'very_unpleasant':
        return 'Very Unpleasant';
      case 'unpleasant':
        return 'Unpleasant';
      case 'ok':
        return 'Neutral';
      case 'pleasant':
        return 'Pleasant';
      case 'very_pleasant':
        return 'Very Pleasant';
      default:
        return mentalState.split('.').last; // fallback for enum-like values
    }
  }

  // Convert mood value back to mental state string
  static String moodValueToMentalState(double moodValue) {
    if (moodValue <= 0.5) {
      return 'very_unpleasant';
    } else if (moodValue <= 1.5) {
      return 'unpleasant';
    } else if (moodValue <= 2.5) {
      return 'ok';
    } else if (moodValue <= 3.5) {
      return 'pleasant';
    } else {
      return 'very_pleasant';
    }
  }
} 