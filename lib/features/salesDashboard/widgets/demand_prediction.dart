import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FarmerDemandDashboard extends StatefulWidget {
  const FarmerDemandDashboard({super.key});

  @override
  State<FarmerDemandDashboard> createState() => _FarmerDemandDashboardState();
}

class _FarmerDemandDashboardState extends State<FarmerDemandDashboard> {
  bool isLoading = true;
  String selectedRegion = 'All Regions';
  String selectedCrop = 'All Crops';

  // API Data Models - Replace with actual API response
  List<RegionPrediction> regionPredictions = [];
  List<CropDemand> cropDemands = [];
  Map<String, dynamic> marketTrends = {};

  @override
  void initState() {
    super.initState();
    _fetchPredictionData();
  }

  Future<void> _fetchPredictionData() async {
    setState(() => isLoading = true);

    try {
      // TODO: Replace with actual API calls
      // final predictions = await ApiService.getRegionPredictions();
      // final demands = await ApiService.getCropDemands();
      // final trends = await ApiService.getMarketTrends();

      // Simulating API delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - Replace with actual API response
      regionPredictions = _getMockRegionData();
      cropDemands = _getMockCropData();
      marketTrends = _getMockMarketTrends();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load predictions')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const AppStatusBar(),
          _buildAppBar(context),
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchPredictionData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilters(),
                      const SizedBox(height: 20),
                      _buildPredictionSummary(),
                      const SizedBox(height: 20),
                      _buildRegionWisePredictions(),
                      const SizedBox(height: 20),
                      _buildCropDemandForecast(),
                      const SizedBox(height: 20),
                      _buildMarketTrendAnalysis(),
                      const SizedBox(height: 20),
                      _buildRecommendations(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- APP BAR -----------------
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6A1B9A)),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: AutoTranslateText(
                'Area-Wise Predictions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF6A1B9A)),
              onPressed: () => _showFilterDialog(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FILTERS -----------------
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All Regions', Icons.public, true),
          const SizedBox(width: 8),
          _buildFilterChip('Vidarbha', Icons.location_on, false),
          const SizedBox(width: 8),
          _buildFilterChip('Marathwada', Icons.location_on, false),
          const SizedBox(width: 8),
          _buildFilterChip('Western MH', Icons.location_on, false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isSelected) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF6A1B9A)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => selectedRegion = label);
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF6A1B9A),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF6A1B9A),
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFFE0E0E0),
      ),
    );
  }

  // ---------------- PREDICTION SUMMARY -----------------
  Widget _buildPredictionSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0), Color(0xFFBA68C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AI Prediction Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Regions Analyzed', '12', Icons.map),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildSummaryItem('Predictions Made', '48', Icons.insights),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildSummaryItem('Accuracy', '92%', Icons.check_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ---------------- REGION-WISE PREDICTIONS -----------------
  Widget _buildRegionWisePredictions() {
    return _buildCard(
      title: 'Region-Wise Demand Predictions',
      subtitle: 'Next 6 months forecast by district',
      icon: Icons.location_city,
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: regionPredictions.length,
              itemBuilder: (context, index) {
                final region = regionPredictions[index];
                return _buildRegionCard(region);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionCard(RegionPrediction region) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getPredictionColor(region.confidence).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: _getPredictionColor(region.confidence),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  region.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Predicted Demand', '${region.predictedDemand}L'),
          const SizedBox(height: 8),
          _buildMetricRow('Current Stock', '${region.currentStock}L'),
          const SizedBox(height: 8),
          _buildMetricRow('Gap', '${region.gap}L',
              color: region.gap > 0 ? Colors.red : Colors.green),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: region.confidence / 100,
                  backgroundColor: Colors.grey[300],
                  color: _getPredictionColor(region.confidence),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${region.confidence}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getPredictionColor(region.confidence),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Confidence Score',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Color _getPredictionColor(int confidence) {
    if (confidence >= 80) return const Color(0xFF6A1B9A);
    if (confidence >= 60) return const Color(0xFFF57C00);
    return const Color(0xFFD32F2F);
  }

  // ---------------- CROP DEMAND FORECAST -----------------
  Widget _buildCropDemandForecast() {
    return _buildCard(
      title: 'Crop-Specific Demand Forecast',
      subtitle: 'Product demand by crop type',
      icon: Icons.agriculture,
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: cropDemands.map((e) => e.demand).reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // tooltipBgColor: const Color(0xFF2E7D32),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${cropDemands[group.x.toInt()].name}\n${rod.toY.toInt()}L',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      },
                    )

                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toInt()}k',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < cropDemands.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              cropDemands[value.toInt()].name,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: const Color(0xFFE0E0E0), strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: cropDemands.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.demand.toDouble(),
                        width: 28,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        gradient: LinearGradient(
                          colors: [entry.value.color.withOpacity(0.7), entry.value.color],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- MARKET TREND ANALYSIS -----------------
  Widget _buildMarketTrendAnalysis() {
    return _buildCard(
      title: 'Market Trend Analysis',
      subtitle: 'Price & demand trends over time',
      icon: Icons.trending_up,
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF2E7D32),
                    // tooltipRoundedRadius: 8,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}k',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"];
                        if (value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: const Color(0xFFE0E0E0), strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: const Color(0xFF6A1B9A),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6A1B9A).withOpacity(0.3),
                          const Color(0xFF6A1B9A).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    spots: const [
                      FlSpot(0, 25),
                      FlSpot(1, 32),
                      FlSpot(2, 28),
                      FlSpot(3, 42),
                      FlSpot(4, 48),
                      FlSpot(5, 55),
                    ],
                  ),
                ],
                minY: 0,
                maxY: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- RECOMMENDATIONS -----------------
  Widget _buildRecommendations() {
    final recommendations = [
      {
        'title': 'High Demand Expected in Akola',
        'desc': 'Stock up 15% more for cotton season',
        'priority': 'high',
        'icon': Icons.warning_amber,
      },
      {
        'title': 'Low Stock Alert - Nagpur',
        'desc': 'Current stock below predicted demand',
        'priority': 'medium',
        'icon': Icons.inventory_2,
      },
      {
        'title': 'Price Optimization Opportunity',
        'desc': 'Adjust pricing in Marathwada region',
        'priority': 'low',
        'icon': Icons.attach_money,
      },
    ];

    return _buildCard(
      title: 'AI Recommendations',
      subtitle: 'Action items based on predictions',
      icon: Icons.lightbulb,
      child: Column(
        children: recommendations.map((rec) {
          return Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _getRecommendationColor(rec['priority'] as String).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getRecommendationColor(rec['priority'] as String).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getRecommendationColor(rec['priority'] as String),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    rec['icon'] as IconData,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rec['desc'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getRecommendationColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFD32F2F);
      case 'medium':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF1976D2);
    }
  }

  // ---------------- COMMON CARD WRAPPER -----------------
  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF6A1B9A), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: const Text('Filter functionality coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ---------------- MOCK DATA (Replace with API) -----------------
  List<RegionPrediction> _getMockRegionData() {
    return [
      RegionPrediction('Akola', 10800, 9200, 1600, 88),
      RegionPrediction('Nagpur', 8500, 8100, 400, 92),
      RegionPrediction('Bhandara', 6900, 7200, -300, 85),
      RegionPrediction('Amravati', 5400, 4800, 600, 78),
      RegionPrediction('Wardha', 4200, 4500, -300, 90),
    ];
  }

  List<CropDemand> _getMockCropData() {
    return [
      CropDemand('Cotton', 12000, const Color(0xFF6A1B9A)),
      CropDemand('Paddy', 8500, const Color(0xFF9C27B0)),
      CropDemand('Chili', 6200, const Color(0xFFD32F2F)),
      CropDemand('Soybean', 9000, const Color(0xFF1976D2)),
      CropDemand('Wheat', 7500, const Color(0xFF7B1FA2)),
    ];
  }

  Map<String, dynamic> _getMockMarketTrends() {
    return {
      'avgPrice': 450,
      'priceChange': 5.2,
      'demandGrowth': 8.5,
    };
  }
}

// ---------------- DATA MODELS -----------------
class RegionPrediction {
  final String name;
  final int predictedDemand;
  final int currentStock;
  final int gap;
  final int confidence;

  RegionPrediction(
      this.name,
      this.predictedDemand,
      this.currentStock,
      this.gap,
      this.confidence,
      );
}

class CropDemand {
  final String name;
  final int demand;
  final Color color;

  CropDemand(this.name, this.demand, this.color);
}