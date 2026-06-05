import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/themes/color_palette.dart';

class AttendancePieChart extends StatelessWidget {
  final int hadir;
  final int telat;
  final int alpha;
  final int izin;

  const AttendancePieChart({
    super.key,
    required this.hadir,
    required this.telat,
    required this.alpha,
    required this.izin,
  });

  @override
  Widget build(BuildContext context) {
    final total = hadir + telat + alpha + izin;
    if (total == 0) {
      return const Center(
        child: Text(
          'Tidak ada data untuk ditampilkan',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            if (hadir > 0)
              PieChartSectionData(
                color: AppColors.statusHadir,
                value: hadir.toDouble(),
                title: '${((hadir / total) * 100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (telat > 0)
              PieChartSectionData(
                color: AppColors.statusTelat,
                value: telat.toDouble(),
                title: '${((telat / total) * 100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (alpha > 0)
              PieChartSectionData(
                color: AppColors.statusAlpha,
                value: alpha.toDouble(),
                title: '${((alpha / total) * 100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (izin > 0)
              PieChartSectionData(
                color: AppColors.statusIzin,
                value: izin.toDouble(),
                title: '${((izin / total) * 100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WeeklyAttendanceChart extends StatelessWidget {
  final List<double> rates;
  final List<String> days;

  const WeeklyAttendanceChart({
    super.key,
    required this.rates,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.bgCardLight.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(rates.length, (i) => FlSpot(i.toDouble(), rates[i])),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [
                  AppColors.safetyOrange,
                  AppColors.info,
                ],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.safetyOrange.withValues(alpha: 0.2),
                    AppColors.info.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LateTrendChart extends StatelessWidget {
  final List<double> lates;
  final List<String> days;

  const LateTrendChart({
    super.key,
    required this.lates,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final double maxVal = lates.fold(5, (max, val) => val > max ? val : max);
    final double backgroundMax = maxVal + 1;

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(lates.length, (i) => _makeGroupData(i, lates[i], backgroundMax)),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.bgCardLight.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: backgroundMax > 10 ? 5 : 2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} org',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          maxY: backgroundMax,
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, double backgroundMax) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [
              AppColors.statusTelat,
              AppColors.safetyOrange,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 14,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: backgroundMax,
            color: AppColors.bgCardLight.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

class HourlyDistributionChart extends StatelessWidget {
  final Map<int, int> hourlyData;

  const HourlyDistributionChart({
    super.key,
    required this.hourlyData,
  });

  @override
  Widget build(BuildContext context) {
    final double maxVal = hourlyData.values.fold(5, (max, val) => val > max ? val.toDouble() : max);
    final double backgroundMax = maxVal + 1;

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          barGroups: [
            _makeGroupData(0, (hourlyData[7] ?? 0).toDouble(), backgroundMax),
            _makeGroupData(1, (hourlyData[8] ?? 0).toDouble(), backgroundMax),
            _makeGroupData(2, (hourlyData[9] ?? 0).toDouble(), backgroundMax),
            _makeGroupData(3, (hourlyData[10] ?? 0).toDouble(), backgroundMax),
            _makeGroupData(4, (hourlyData[11] ?? 0).toDouble(), backgroundMax),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.bgCardLight.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const hours = ['07:00', '08:00', '09:00', '10:00', '11:00'];
                  final index = value.toInt();
                  if (index >= 0 && index < hours.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        hours[index],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: backgroundMax > 10 ? 5 : 2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} org',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          maxY: backgroundMax,
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, double backgroundMax) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [
              AppColors.statusHadir,
              AppColors.success,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: backgroundMax,
            color: AppColors.bgCardLight.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
