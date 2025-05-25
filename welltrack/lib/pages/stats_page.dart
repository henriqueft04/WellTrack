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
    // Define metas arbitrárias
    const double maxSteps = 15000;
    const double maxCalories = 500;
    const double maxDistance = 10;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Stats")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StatBar(
              index: 1,
              label: "Steps",
              value: steps,
              maxValue: maxSteps,
              color: Colors.orange,
            ),
            StatBar(
              index: 2,
              label: "Calories",
              value: calories,
              maxValue: maxCalories,
              color: Colors.pink,
            ),
            StatBar(
              index: 3,
              label: "Distance",
              value: distance,
              maxValue: maxDistance,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
