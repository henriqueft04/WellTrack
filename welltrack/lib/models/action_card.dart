import 'package:flutter/material.dart';

class StyledActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const StyledActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildActionCard(
  BuildContext context,
  List<DateTime> calendarDays,
  int selectedDayIndex,
  Color color,
  Color background,
  IconData icon,
  String label,
  String actionType, // "update your state" or "create a journal entry"
  MaterialPageRoute Function() routeBuilder,
) {
  return StyledActionButton(
    icon: icon,
    label: label,
    color: color,
    background: background,
    onTap: () {
      // Check if the selected date is in the future
      final selectedDate = calendarDays[selectedDayIndex];
      if (selectedDate.isAfter(DateTime.now())) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Future Date'),
              content: Text(
                'You cannot $actionType in the future.',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Navigate using the route builder
        Navigator.push(context, routeBuilder());
      }
    },
  );
}
