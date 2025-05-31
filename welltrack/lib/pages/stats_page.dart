import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
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
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  double? runningGoal;
  final TextEditingController _goalController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define metas arbitrárias
    const double maxSteps = 10000;
    const double maxCalories = 500;
    const double maxDistance = 6;

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
            const SizedBox(height: 24),
            // Logo and title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/images/martim.png', height: 60),
              ],
            ),
            const SizedBox(height: 32),
            // Steps Card
            _StatCard(
              value: widget.steps,
              maxValue: maxSteps,
              label: 'steps',
              color: const Color(0xFFFFB3B3),
              percentColor: Colors.black,
              barColor: const Color(0xFFFFB3B3),
            ),
            // Calories Card
            _StatCard(
              value: widget.calories,
              maxValue: maxCalories,
              label: 'calories',
              color: const Color(0xFFB3B3FF),
              percentColor: Colors.black,
              barColor: const Color(0xFFB3B3FF),
            ),
            // Distance Card
            _StatCard(
              value: widget.distance,
              maxValue: maxDistance,
              label: 'kilometers',
              color: const Color(0xFFB3FFB3),
              percentColor: Colors.black,
              barColor: const Color(0xFFB3FFB3),
              isDistance: true,
            ),
            // Running Goal Card
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set your running goal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (runningGoal != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Your goal: ${runningGoal!.toStringAsFixed(1).replaceAll('.', ',')} km',
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _goalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Distance (km)',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final input = _goalController.text.replaceAll(',', '.');
                          final goal = double.tryParse(input);
                          if (goal != null && goal > 0) {
                            setState(() {
                              runningGoal = goal;
                            });
                            _goalController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9CD0FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Set Goal'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;
  final Color color;
  final Color percentColor;
  final Color barColor;
  final bool isDistance;

  const _StatCard({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
    required this.percentColor,
    required this.barColor,
    this.isDistance = false,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value / maxValue).clamp(0, 1.0);
    final percentText = "${(percent * 100).toStringAsFixed(0)}%";
    final valueText = isDistance
        ? value.toStringAsFixed(1).replaceAll('.', ',')
        : value.toInt().toString();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                percentText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: percentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: percent.toDouble(),
              minHeight: 18,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
