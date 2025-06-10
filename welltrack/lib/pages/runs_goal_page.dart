import 'package:flutter/material.dart';

class RunsGoalPage extends StatefulWidget {
  const RunsGoalPage({super.key});

  @override
  State<RunsGoalPage> createState() => _RunsGoalPageState();
}

class _RunsGoalPageState extends State<RunsGoalPage> {
  double _goal = 325;
  final double _min = 0;
  final double _max = 650;
  final List<int> _mockData = [100, 250, 400, 500, 600, 650, 500];
  final List<String> _labels = ['12', '13', '14', '15', '16', '18', '19', '20'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('runs', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: Text('16/05', style: TextStyle(color: Colors.black))),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Chart Card
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: CustomPaint(
                painter: _BarChartPainter(_mockData, color: const Color(0xFFB3FFB3)),
                child: Container(),
              ),
            ),
            const SizedBox(height: 32),
            // Goal Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('set my goal', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 16,
                      activeTrackColor: Color(0xFFB3FFB3),
                      inactiveTrackColor: Color(0xFFB3FFB3),
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                    ),
                    child: Slider(
                      min: _min,
                      max: _max,
                      value: _goal,
                      onChanged: (v) => setState(() => _goal = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_min.toInt().toString()),
                      Text(_max.toInt().toString()),
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

class _BarChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;
  _BarChartPainter(this.data, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final barWidth = size.width / (data.length * 1.5);
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();
    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxVal) * (size.height * 0.7);
      final x = i * barWidth * 1.5 + barWidth / 2;
      final y = size.height - barHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(6),
        ),
        paint,
      );
    }
    // Draw dashed line
    final dashPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 2;
    const dashWidth = 8;
    const dashSpace = 6;
    double startX = 0;
    final y = size.height * 0.25;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), dashPaint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 