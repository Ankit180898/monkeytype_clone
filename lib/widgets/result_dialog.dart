import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/typing_test_controller.dart';

class ResultsScreen extends StatelessWidget {
  final TypingTestController typingController = Get.find();

  ResultsScreen({super.key});

  TextStyle monoTextStyle({
    double fontSize = 28,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 58, 58, 61),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: AppBar(
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Test Results',
            style: monoTextStyle(fontSize: 18, color: Colors.white70),
          ),
          backgroundColor: const Color(0xFF232427),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.white30),
              onPressed: () {
                // Return to typing test and restart
                typingController.restartTest();
                Get.back();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 40),
              _buildStatisticsGraph(),
              const SizedBox(height: 40),
              _buildMainStats(),
              const SizedBox(height: 40),
              _buildDetailedStats(),
              const SizedBox(height: 40),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsGraph() {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2E31),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'wpm',
                style: monoTextStyle(fontSize: 14, color: Colors.white54),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2B714),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  typingController.wpm.value.toStringAsFixed(0),
                  style: monoTextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildLineChart()),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    // placeholder message
    if (typingController.wpmHistory.isEmpty) {
      return Center(
        child: Text(
          'No typing data available',
          style: monoTextStyle(fontSize: 14, color: Colors.white30),
        ),
      );
    }

    // Prepare data points
    final List<FlSpot> spots = [];
    final maxTime = typingController.testDuration.value.toDouble();

    for (int i = 0; i < typingController.wpmHistory.length; i++) {
      final time = typingController.timePoints[i];
      final wpm = typingController.wpmHistory[i];
      spots.add(FlSpot(time, wpm));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.white10, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: maxTime / 4,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${value.toInt()}s',
                    style: monoTextStyle(fontSize: 10, color: Colors.white30),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: monoTextStyle(fontSize: 10, color: Colors.white30),
                  textAlign: TextAlign.right,
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: maxTime,
        minY: 0,
        maxY:
            (typingController.wpmHistory.reduce((a, b) => a > b ? a : b) * 1.2)
                .ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFFE2B714),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFE2B714).withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = monoTextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                );
                return LineTooltipItem(
                  '${touchedSpot.y.toStringAsFixed(1)} wpm\n${touchedSpot.x.toStringAsFixed(1)}s',
                  textStyle,
                );
              }).toList();
            },
          ),
          touchCallback:
              (FlTouchEvent event, LineTouchResponse? touchResponse) {},
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          'wpm',
          typingController.wpm.value.toStringAsFixed(0),
          isLarge: true,
        ),
        _buildStatCard(
          'acc',
          '${typingController.accuracy.value.toStringAsFixed(0)}%',
          isLarge: true,
        ),
        _buildStatCard(
          'time',
          '${typingController.testDuration.value}s',
          isLarge: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2E31),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: monoTextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: monoTextStyle(
              fontSize: isLarge ? 36 : 20,
              color: const Color(0xFFE2B714),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2E31),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'detailed statistics',
            style: monoTextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow(
                      'characters',
                      '${typingController.correctChars.value + typingController.incorrectChars.value}',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'correct',
                      '${typingController.correctChars.value}',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'incorrect',
                      '${typingController.incorrectChars.value}',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow(
                      'consistency',
                      '${typingController.accuracy.value.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'raw',
                      typingController.wpm.value.toStringAsFixed(0),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(label, style: monoTextStyle(fontSize: 14, color: Colors.white38)),
        Text(value, style: monoTextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          Icons.replay,
          'restart test',
          onPressed: () {
            typingController.restartTest();
            Get.back();
          },
        ),
        const SizedBox(width: 12),
        _buildActionButton(Icons.share, 'share result'),
        const SizedBox(width: 12),
        _buildActionButton(Icons.save_alt, 'save result'),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed ?? () {},
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF2C2E31),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          const SizedBox(width: 8),
          Text(
            label,
            style: monoTextStyle(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
