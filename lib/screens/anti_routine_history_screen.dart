import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/anti_routine.dart';
import '../theme/colors.dart';

class AntiRoutineHistoryScreen extends StatefulWidget {
  final AntiRoutine antiRoutine;

  const AntiRoutineHistoryScreen({
    super.key,
    required this.antiRoutine,
  });

  @override
  State<AntiRoutineHistoryScreen> createState() => _AntiRoutineHistoryScreenState();
}

class _AntiRoutineHistoryScreenState extends State<AntiRoutineHistoryScreen> {
  int _selectedPeriod = 7; // 7, 30, ou 90 jours

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('Historique - ${widget.antiRoutine.name}'),
        backgroundColor: kAntiPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildPeriodSelector(),
            _buildChart(),
            _buildStatistics(),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: kAntiPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.antiRoutine.icon,
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 12),
          Text(
            widget.antiRoutine.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seuil journalier: ${widget.antiRoutine.dailyLimit} ${widget.antiRoutine.unit}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PeriodButton(
            label: '7j',
            isSelected: _selectedPeriod == 7,
            onPressed: () => setState(() => _selectedPeriod = 7),
          ),
          const SizedBox(width: 12),
          _PeriodButton(
            label: '30j',
            isSelected: _selectedPeriod == 30,
            onPressed: () => setState(() => _selectedPeriod = 30),
          ),
          const SizedBox(width: 12),
          _PeriodButton(
            label: '90j',
            isSelected: _selectedPeriod == 90,
            onPressed: () => setState(() => _selectedPeriod = 90),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (widget.antiRoutine.history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez à enregistrer vos valeurs quotidiennes pour voir votre progression',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _selectedPeriod));
    final relevantHistory = widget.antiRoutine.history.where((entry) => entry.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (relevantHistory.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Aucune donnée pour cette période',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution des valeurs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              _buildLineChartData(relevantHistory),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(List<dynamic> history) {
    final spots = <FlSpot>[];
    final thresholdSpots = <FlSpot>[];

    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].value.toDouble()));
      thresholdSpots.add(FlSpot(i.toDouble(), widget.antiRoutine.dailyLimit.toDouble()));
    }

    final maxValue = history.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue > widget.antiRoutine.dailyLimit ? maxValue : widget.antiRoutine.dailyLimit * 1.5).toDouble();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: history.length > 7 ? (history.length / 5).ceilToDouble() : 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= history.length) return const Text('');
              final date = history[value.toInt()].date;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('dd/MM').format(date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      minX: 0,
      maxX: (history.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        // Ligne du seuil
        LineChartBarData(
          spots: thresholdSpots,
          isCurved: false,
          color: kDanger.withValues(alpha: 0.5),
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
        ),
        // Ligne des valeurs
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: kAntiPrimary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isSuccess = history[index].isSuccess;
              return FlDotCirclePainter(
                radius: 4,
                color: isSuccess ? kSuccess : kDanger,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: kAntiPrimary.withValues(alpha: 0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.grey[800]!,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              if (spot.barIndex == 1) {
                final entry = history[spot.x.toInt()];
                final date = DateFormat('dd/MM/yyyy').format(entry.date);
                return LineTooltipItem(
                  '$date\n${spot.y.toInt()} ${widget.antiRoutine.unit}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Série actuelle',
                  value: '${widget.antiRoutine.successStreak} jours',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'Taux de réussite',
                  value: '${widget.antiRoutine.successRate.toStringAsFixed(1)}%',
                  color: kSuccess,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_down,
                  label: 'Moyenne',
                  value: '${widget.antiRoutine.averageValue.toStringAsFixed(1)} ${widget.antiRoutine.unit}',
                  color: kInfo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.star,
                  label: 'Jours réussis',
                  value: '${widget.antiRoutine.totalDaysSuccess}',
                  color: kPointsAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (widget.antiRoutine.history.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _selectedPeriod));
    final relevantHistory = widget.antiRoutine.history.where((entry) => entry.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique détaillé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...relevantHistory.map((entry) => _buildHistoryItem(entry)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic entry) {
    final isSuccess = entry.isSuccess;
    final statusColor = isSuccess ? kSuccess : kDanger;
    final statusIcon = isSuccess ? Icons.check_circle : Icons.error;
    final percentage = entry.percentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(entry.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.value} ${widget.antiRoutine.unit} / ${entry.dailyLimit} ${widget.antiRoutine.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              Text(
                isSuccess ? 'Réussi' : 'Dépassé',
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? kAntiPrimary : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.grey[700],
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
