import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/pages/steps_goal_page.dart';
import 'package:welltrack/pages/calories_goal_page.dart';
import 'package:welltrack/pages/runs_goal_page.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/providers/stats_provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  double? runningGoal;
  double? goalCalories;
  final TextEditingController _goalController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Busca os dados do usuário da HomePage
    final userStats = Provider.of<UserStatsProvider>(context);

    final int steps = userStats.steps;
    final double calories = userStats.calories;
    final double distance = userStats.distance;
    final double dailyGoal = userStats.dailyGoal.toDouble();

    return AppLayout(
      showLogo: true,
      isMainPage: true,
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Steps Card
              GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StepsGoalPage()),
                );
              },
              child: 
              _StatCard(
                  value: steps.toDouble(),
                  maxValue: dailyGoal,
                  label: 'steps',
                  color: const Color(0xFFFFB3B3),
                  percentColor: Colors.black,
                  barColor: const Color(0xFFFFB3B3),
                ),
            ),
              // Calories Card
              GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CaloriesGoalPage()),
                );
              },
              child: 
              _StatCard(
                  value: calories,
                  maxValue: goalCalories ?? 10.0,
                  label: 'calories',
                  color: const Color(0xFFB3B3FF),
                  percentColor: Colors.black,
                  barColor: const Color(0xFFB3B3FF),
                ),
              ),
                
              // Distance Card
              GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RunsGoalPage()),
                );
              },
              child: 
                _StatCard(
                  value: distance,
                  maxValue: runningGoal ?? 1.0,
                  label: 'kilometers',
                  color: const Color(0xFFB3FFB3),
                  percentColor: Colors.black,
                  barColor: const Color(0xFFB3FFB3),
                  isDistance: true,
                ),
              ),

              const SizedBox(height: 15),

              // Running Goal Card
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (runningGoal != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Your goal: ${runningGoal!.toStringAsFixed(2).replaceAll('.', ',')} km',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _goalController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Distance (km)',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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
                            final input = _goalController.text.replaceAll(
                              ',',
                              '.',
                            );
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
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

              const SizedBox(height: 24),
              
              // Calories Goal Card
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
                      'Set your calories goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (goalCalories != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Your goal: ${goalCalories!.toStringAsFixed(2).replaceAll('.', ',')} cal',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _goalController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Calories (cal)',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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
                            final input = _goalController.text.replaceAll(
                              ',',
                              '.',
                            );
                            final goal = double.tryParse(input);
                            if (goal != null && goal > 0) {
                              setState(() {
                                goalCalories = goal;
                              });
                              _goalController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9CD0FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
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
    final valueText =
        isDistance
            ? value.toStringAsFixed(2).replaceAll('.', ',')
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
                style: const TextStyle(fontSize: 32, color: Colors.black),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
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
