import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final int index;
  final String label;
  final double value;      // valor atual
  final double maxValue;   // valor máximo

  final Color color;

  const StatBar({
    super.key,
    required this.index,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (value / maxValue).clamp(0, 1);
    String percentageText = "${(percentage * 100).toStringAsFixed(0)}%";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            index.toString().padLeft(2, '0'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(percentageText,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const CircleAvatar(
                            radius: 6,
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
