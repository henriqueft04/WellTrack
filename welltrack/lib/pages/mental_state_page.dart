import 'package:flutter/material.dart';
import 'package:welltrack/models/action_card.dart';
import 'package:welltrack/pages/mental_state_form_page.dart';
import 'package:welltrack/pages/mental_state_history_page.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/viewmodels/mental_state_view_model.dart';
import 'package:fl_chart/fl_chart.dart';

class MentalStatePage extends StatefulWidget {
  final int? originIndex;

  const MentalStatePage({
    super.key,
    this.originIndex,
  });

  @override
  State<MentalStatePage> createState() => _MentalStatePageState();
}

class _MentalStatePageState extends State<MentalStatePage> {
  @override
  void initState() {
    super.initState();
    // Load daily mental states for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MentalStateViewModel>(context, listen: false)
          .loadDailyMentalStates(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mental Health', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose an option',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            StyledActionButton(
              icon: Icons.sentiment_satisfied,
              label: 'State of Mind',
              color: Colors.lightBlue,
              background: Colors.lightBlue.withValues(alpha: 0.1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MentalStateFormPage(selectedDate: DateTime.now()),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            StyledActionButton(
              icon: Icons.history,
              label: 'View History',
              color: Colors.pink.shade200,
              background: Colors.pink.shade200.withValues(alpha: 0.1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MentalStateHistoryPage(originIndex: widget.originIndex),
                  ),
                );
              },
            ),
          
            const SizedBox(height: 32),
            const Text(
              'Today\'s Mood Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<MentalStateViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dailyStates = viewModel.dailyMentalStates;

                  if (dailyStates.isEmpty) {
                    return const Center(
                      child: Text(
                        'No mood data for today yet.',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  // Sort states by hour
                  dailyStates.sort((a, b) => a.date.hour.compareTo(b.date.hour));

                  return Padding(
                    padding: const EdgeInsets.only(right: 22.0, top: 18.0),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0: return const Text('Unpleasant', style: TextStyle(fontSize: 10));
                                  case 1: return const Text('Neutral', style: TextStyle(fontSize: 10));
                                  case 2: return const Text('Pleasant', style: TextStyle(fontSize: 10));
                                  default: return const Text('');
                                }
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final hour = value.toInt();
                                if (hour % 2 == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('$hour:00', style: const TextStyle(fontSize: 10)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xff37434d), width: 1),
                        ),
                        minX: 0,
                        maxX: 24,
                        minY: 0,
                        maxY: 3,
                        lineBarsData: [
                          LineChartBarData(
                            spots: dailyStates.map((state) {
                              final hour = state.date.hour;
                              final minute = state.date.minute;
                              final second = state.date.second;
                              final xValue = hour.toDouble() + (minute / 60.0) + (second / 3600.0);
                              return FlSpot(xValue, state.state);
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3.0,
                            dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(radius: 4, color: Colors.red, strokeWidth: 0)),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 