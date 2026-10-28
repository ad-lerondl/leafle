import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/day_rating.dart';
import '../providers/app_state.dart';
import '../theme/colors.dart';

class DayRatingsHistoryScreen extends StatefulWidget {
  const DayRatingsHistoryScreen({super.key});

  @override
  State<DayRatingsHistoryScreen> createState() => _DayRatingsHistoryScreenState();
}

class _DayRatingsHistoryScreenState extends State<DayRatingsHistoryScreen> {
  int _selectedPeriod = 30; // 7, 30, ou 90 jours

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Historique de mes journées'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(appState),
                _buildPeriodSelector(),
                _buildChart(appState),
                _buildStatistics(appState),
                _buildHistoryList(appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '📊',
            style: TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 12),
          const Text(
            'Votre humeur au fil du temps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Moyenne: ${appState.averageRating.toStringAsFixed(1)} ⭐',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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

  Widget _buildChart(AppState appState) {
    if (appState.dayRatings.isEmpty) {
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
              'Commencez à noter vos journées pour voir votre évolution',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _selectedPeriod));
    final relevantRatings = appState.dayRatings.where((rating) => rating.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (relevantRatings.isEmpty) {
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
            'Évolution de votre humeur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              _buildLineChartData(relevantRatings),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(List<DayRating> ratings) {
    final spots = <FlSpot>[];

    for (int i = 0; i < ratings.length; i++) {
      spots.add(FlSpot(i.toDouble(), ratings[i].stars.toDouble()));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
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
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value < 1 || value > 5) return const Text('');
              return Text(
                '${value.toInt()}⭐',
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
            interval: ratings.length > 7 ? (ratings.length / 5).ceilToDouble() : 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= ratings.length) return const Text('');
              final date = ratings[value.toInt()].date;
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
      maxX: (ratings.length - 1).toDouble(),
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.purple,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final rating = ratings[index];
              Color dotColor;
              if (rating.isGoodDay) {
                dotColor = kSuccess;
              } else if (rating.isAverageDay) {
                dotColor = Colors.orange;
              } else {
                dotColor = kDanger;
              }
              return FlDotCirclePainter(
                radius: 5,
                color: dotColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.3),
                Colors.purple.withValues(alpha: 0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.grey[800]!,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final rating = ratings[spot.x.toInt()];
              final date = DateFormat('dd/MM/yyyy').format(rating.date);
              return LineTooltipItem(
                '$date\n${spot.y.toInt()} étoiles',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildStatistics(AppState appState) {
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
                  icon: Icons.sentiment_very_satisfied,
                  label: 'Bonnes journées',
                  value: '${appState.goodDaysCount}',
                  color: kSuccess,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.sentiment_neutral,
                  label: 'Journées moyennes',
                  value: '${appState.averageDaysCount}',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.sentiment_dissatisfied,
                  label: 'Journées difficiles',
                  value: '${appState.badDaysCount}',
                  color: kDanger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  label: 'Total de jours',
                  value: '${appState.dayRatings.length}',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(AppState appState) {
    if (appState.dayRatings.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _selectedPeriod));
    final relevantRatings = appState.dayRatings.where((rating) => rating.date.isAfter(cutoffDate)).toList()
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
          ...relevantRatings.map((rating) => _buildHistoryItem(rating)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(DayRating rating) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (rating.isGoodDay) {
      statusColor = kSuccess;
      statusIcon = Icons.sentiment_very_satisfied;
      statusText = 'Bonne journée';
    } else if (rating.isAverageDay) {
      statusColor = Colors.orange;
      statusIcon = Icons.sentiment_neutral;
      statusText = 'Journée moyenne';
    } else {
      statusColor = kDanger;
      statusIcon = Icons.sentiment_dissatisfied;
      statusText = 'Journée difficile';
    }

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
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(rating.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating.stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
                if (rating.note != null && rating.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    rating.note!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
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
        backgroundColor: isSelected ? Colors.purple : Colors.grey[200],
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
