import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';
import 'package:welltrack/viewmodels/mental_state_view_model.dart';
import 'package:provider/provider.dart';

class MentalStateHistoryPage extends StatefulWidget {
  final int? originIndex;
  
  const MentalStateHistoryPage({
    super.key,
    this.originIndex,
  });

  @override
  State<MentalStateHistoryPage> createState() => _MentalStateHistoryPageState();
}

class _MentalStateHistoryPageState extends State<MentalStateHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load all mental states when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MentalStateViewModel>(context, listen: false).loadAllMentalStates();
    });
  }

  String _getMoodText(double state) {
    if (state <= 0.5) return 'Unpleasant';
    if (state <= 1.5) return 'Neutral';
    return 'Pleasant';
  }

  Color _getMoodColor(double state) {
    if (state <= 0.5) return Colors.red;
    if (state <= 1.5) return Colors.orange;
    return Colors.green;
  }

  IconData _getMoodIcon(double state) {
    if (state <= 0.5) return Icons.sentiment_dissatisfied;
    if (state <= 1.5) return Icons.sentiment_neutral;
    return Icons.sentiment_satisfied;
  }

  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: widget.originIndex,
      child: AppLayout(
        pageTitle: 'Mental State History',
        showLogo: false,
        isMainPage: false,
        showBackButton: true,
        content: Consumer<MentalStateViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final states = viewModel.allMentalStates;
            if (states.isEmpty) {
              return const Center(
                child: Text(
                  'No mental states recorded yet',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: states.length,
              itemBuilder: (context, index) {
                final state = states[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getMoodIcon(state.state),
                              color: _getMoodColor(state.state),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getMoodText(state.state),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getMoodColor(state.state),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${state.date.day}/${state.date.month}/${state.date.year} ${state.date.hour.toString().padLeft(2, '0')}:${state.date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (state.emotions?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.emotions!.map((emotion) {
                              return Chip(
                                label: Text(emotion),
                                backgroundColor: Colors.lightBlue,
                                labelStyle: const TextStyle(color: Colors.blue),
                              );
                            }).toList(),
                          ),
                        ],
                        if (state.factors?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.factors!.map((factor) {
                              return Chip(
                                label: Text(factor),
                                backgroundColor: Colors.pink,
                                labelStyle: const TextStyle(color: Colors.pink),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
} 