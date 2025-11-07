import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExecutiveSummary extends StatefulWidget {
  const ExecutiveSummary({super.key});

  @override
  State<ExecutiveSummary> createState() => _ExecutiveSummaryState();
}

class _ExecutiveSummaryState extends State<ExecutiveSummary> {
  // KPI Cards Data
  final List<Map<String, dynamic>> kpis = [
    {"title": "Sales", "value": "10 M", "period": "AMJ'25"},
    {"title": "Distributors", "value": "1 K", "period": "AMJ'25"},
    {"title": "Scan Rate", "value": "80%", "period": "AMJ'25"},
    {"title": "Points", "value": "80 K", "period": "AMJ'25"},
  ];

  // Alerts
  final List<String> alerts = [
    "Alert 1",
    "Alert 2",
    "Alert 3",
    "Alert 4",
  ];

  // X-axis labels
  final List<String> quarters = ["JFM24", "AMJ24", "JAS24", "OND24", "JFM25", "AMJ25"];

  // Distributor data
  final Map<String, List<double>> distributors = {
    "Dist 1": [92, 83, 77, 99, 86, 93],
    "Dist 2": [80, 76, 66, 90, 81, 89],
    "Dist 3": [85, 70, 72, 88, 79, 92],
    "Dist 4": [78, 74, 60, 91, 82, 87],
    "Dist 5": [90, 81, 77, 95, 83, 96],
  };

  // Regional sales
  final Map<String, List<double>> regions = {
    "North": [95, 81, 88, 96, 84, 98],
    "East": [54, 61, 51, 62, 56, 73],
    "West": [82, 77, 85, 83, 79, 94],
    "South": [70, 72, 66, 78, 76, 91],
  };

  // ASM data
  final Map<String, List<double>> asms = {
    "Rajesh": [25, 27, 22, 30, 32, 35],
    "Suresh": [20, 21, 19, 28, 31, 36],
    "Sanjay": [15, 16, 14, 18, 26, 33],
    "Virat": [18, 20, 16, 25, 30, 39],
    "Yash": [22, 27, 21, 29, 33, 37],
  };

  // Products
  final Map<String, List<double>> products = {
    "Maize": [24, 22, 21, 25, 26, 26],
    "Cotton": [20, 19, 18, 22, 23, 25],
    "Tomatoes": [14, 15, 12, 19, 21, 20],
    "Wheat": [16, 17, 15, 18, 22, 24],
    "Paddy": [12, 14, 11, 16, 19, 23],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          const AppStatusBar(),

          // 🔹 Custom App StatusBar Container
          Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: AutoTranslateText(
                      'Executive Summary',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // 🔹 Rest of the scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards (Horizontally scrollable, equal width)
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: kpis.map((kpi) {
                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 120,
                            maxWidth: 120, // ✅ Equal width for all cards
                          ),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoTranslateText(kpi["title"],
                                      style: const TextStyle(fontSize: 10)),
                                  AutoTranslateText(kpi["value"],
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple)),
                                  const SizedBox(height: 4),
                                  AutoTranslateText(kpi["period"],
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),
                  AutoTranslateText("Top 5 Distributors (Quarterly)", style: sectionTitleStyle()),
                  SizedBox(
                      height: 250,
                      child: MultiSeriesChart(
                          title: "Distributors",
                          seriesData: distributors,
                          quarters: quarters)),

                  const SizedBox(height: 20), // 🔹 Extra spacing
                  AutoTranslateText("Regional Sales (Quarterly)", style: sectionTitleStyle()),
                  SizedBox(
                      height: 250,
                      child: MultiSeriesChart(
                          title: "Regions",
                          seriesData: regions,
                          quarters: quarters)),

                  const SizedBox(height: 20),
                  AutoTranslateText("Top 5 ASM (Quarterly)", style: sectionTitleStyle()),
                  SizedBox(
                      height: 250,
                      child: MultiSeriesChart(
                          title: "ASMs",
                          seriesData: asms,
                          quarters: quarters)),

                  const SizedBox(height: 20),
                  AutoTranslateText("Top 5 Products (Quarterly)", style: sectionTitleStyle()),
                  SizedBox(
                      height: 250,
                      child: MultiSeriesChart(
                          title: "Products",
                          seriesData: products,
                          quarters: quarters)),

                  const SizedBox(height: 20),
                  AutoTranslateText("Alerts", style: sectionTitleStyle()),
                  ...alerts.map((a) => AutoTranslateText(a,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 14)))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle sectionTitleStyle() {
    return const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);
  }
}

// 🔹 Reusable Chart
class MultiSeriesChart extends StatelessWidget {
  final String title;
  final Map<String, List<double>> seriesData;
  final List<String> quarters;

  const MultiSeriesChart(
      {super.key,
        required this.title,
        required this.seriesData,
        required this.quarters});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: seriesData.entries.map((entry) {
        final seriesName = entry.key;
        final values = entry.value;

        return ColumnSeries<_ChartPoint, String>(
          name: seriesName,
          dataSource: List.generate(
            quarters.length,
                (index) => _ChartPoint(quarters[index], values[index]),
          ),
          xValueMapper: (_ChartPoint point, _) => point.quarter,
          yValueMapper: (_ChartPoint point, _) => point.value,

          // flat bars (no rounded top)
          borderRadius: BorderRadius.zero,

          // gap between series
          spacing: 0.2,
          width: 0.6,
        );
      }).toList(),
    );
  }
}

class _ChartPoint {
  final String quarter;
  final double value;
  _ChartPoint(this.quarter, this.value);
}
