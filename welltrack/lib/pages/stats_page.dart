import 'package:flutter/material.dart';
import 'package:welltrack/components/stat_bar.dart';

class StatsPage extends StatelessWidget {
  final double steps;
  final double calories;
  final double distance;

  const StatsPage({
    super.key,
    required this.steps,
    required this.calories,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Your Stats",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StatBar(
              label: "Steps",
              value: steps,
              maxValue: 10000,
              color: Colors.pinkAccent.shade100,
              unit: "steps",
            ),
            StatBar(
              label: "Calories",
              value: calories,
              maxValue: 500,
              color: Colors.deepPurpleAccent.shade100,
              unit: "calories",
            ),
            StatBar(
              label: "Distance",
              value: distance,
              maxValue: 10,
              color: Colors.lightGreenAccent.shade100,
              unit: "kilometers",
            ),
          ],
        ),
      ),
    );
  }
}
