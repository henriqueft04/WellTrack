import 'package:flutter/material.dart';
import 'package:welltrack/pages/home_page.dart';

String getWeekdayLetter(int weekday) {
  // 1 = Monday, 7 = Sunday
  const weekLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return weekLetters[weekday - 1];
}

Widget buildCalendar(
  BuildContext context,
  List<DateTime> calendarDays,
  int selectedDayIndex,
  Function(int) onDayTapped,
  ScrollController calendarScrollController,
) {
  final today = DateTime.now();
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 16),
    height: 82,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      controller: calendarScrollController,
      itemCount: calendarDays.length,
      itemBuilder: (context, index) {
        final date = calendarDays[index];
        final isSelected = index == selectedDayIndex;
        final isToday =
            date.day == today.day &&
            date.month == today.month &&
            date.year == today.year;
        final weekDay = getWeekdayLetter(date.weekday);
        return GestureDetector(
          onTap: () => onDayTapped(index),
          child: Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? HomePageConstants.primaryColor
                      : isToday
                      ? Colors.white
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border:
                  isToday
                      ? Border.all(
                        color: HomePageConstants.primaryColor,
                        width: 2,
                      )
                      : null,
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: HomePageConstants.primaryColor.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekDay,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected
                            ? Colors.white
                            : isToday
                            ? HomePageConstants.primaryColor
                            : HomePageConstants.secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isSelected
                            ? Colors.white
                            : isToday
                            ? HomePageConstants.primaryColor
                            : HomePageConstants.textColor,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: HomePageConstants.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
