import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/data/models/smart_recommendation_model.dart';
import 'package:translator/translator.dart';

class RecommendProductToFarmerScreen extends StatefulWidget {
  final String mobileNumber;
  final RecommendationResponse recommendationResponse;

  const RecommendProductToFarmerScreen({
    super.key,
    required this.mobileNumber,
    required this.recommendationResponse,
  });

  @override
  State<RecommendProductToFarmerScreen> createState() =>
      _RecommendProductToFarmerScreenState();
}

class RecommendationWithTranslation {
  final Recommendation original;
  String directionsOfUse = '';
  String features = '';
  String reason = '';

  RecommendationWithTranslation({required this.original});
}

class _RecommendProductToFarmerScreenState
    extends State<RecommendProductToFarmerScreen> {
  final GoogleTranslator _translator = GoogleTranslator();
  bool _loadingTranslations = false;
  bool _showHindi = false;
  List<RecommendationWithTranslation> translatedRecs = [];

  @override
  void initState() {
    super.initState();
    _prepareRecommendations();
  }

  void _prepareRecommendations() async {
    setState(() => _loadingTranslations = true);

    translatedRecs = widget.recommendationResponse.recommendations
        .map((r) => RecommendationWithTranslation(original: r))
        .toList();

    for (var rec in translatedRecs) {
      rec.directionsOfUse =
      await _translateText(rec.original.directionsOfUse ?? 'N/A');
      rec.features =
      await _translateText(rec.original.features?.join(', ') ?? 'N/A');
      rec.reason = await _translateText(rec.original.reason ?? 'N/A');
    }

    setState(() => _loadingTranslations = false);
  }

  Future<String> _translateText(String text, {String to = 'hi'}) async {
    if (text.isEmpty) return '';
    try {
      var translation = await _translator.translate(text, to: to);
      return translation.text;
    } catch (e) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          const AppStatusBar(),
          _buildModernAppBar(context),
          Expanded(
            child: _loadingTranslations
                ? _buildLoadingState()
                : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildFarmerInfoCard()),
                SliverToBoxAdapter(child: _buildLanguageToggle()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return _showHindi
                            ? _buildModernTranslatedCard(
                            translatedRecs[index], index)
                            : _buildModernRecommendationCard(
                            translatedRecs[index].original, index);
                      },
                      childCount: translatedRecs.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.topBarColor, AppColors.topBarColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.topBarColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Smart Recommendations',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'AI-Powered Product Suggestions',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.topBarColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          const Text(
            'Preparing recommendations...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Translating content for you',
            style: TextStyle(fontSize: 13, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.person, color: Colors.green.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farmer Details',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.mobileNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${translatedRecs.length} Products',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.translate, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language Preference',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Switch to Hindi translation',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _showHindi,
              onChanged: (val) => setState(() => _showHindi = val),
              activeColor: Colors.green.shade600,
              activeTrackColor: Colors.green.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernRecommendationCard(Recommendation r, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.purple.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'product_${index}_${r.name}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: r.image != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(r.image!),
                      radius: 32,
                      backgroundColor: Colors.white,
                    )
                        : CircleAvatar(
                      backgroundColor: AppColors.topBarColor,
                      radius: 32,
                      child: const Icon(Icons.science,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${r.crop} • ${r.disease}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildModernInfoRow(
                  Icons.water_drop_outlined,
                  'Dosage',
                  r.dosage?.toString() ?? '-',
                  Colors.blue,
                ),
                _buildModernInfoRow(
                  Icons.opacity,
                  'Water Volume',
                  r.waterVolume ?? '-',
                  Colors.cyan,
                ),
                _buildModernInfoRow(
                  Icons.wb_sunny_outlined,
                  'Season',
                  r.season ?? '-',
                  Colors.orange,
                ),
                _buildModernInfoRow(
                  Icons.map_outlined,
                  'Area',
                  r.area ?? '-',
                  Colors.green,
                ),
                const Divider(height: 24),
                _buildExpandableSection(
                  'Directions of Use',
                  r.directionsOfUse ?? 'N/A',
                  Icons.info_outline,
                  Colors.purple,
                ),
                _buildExpandableSection(
                  'Features',
                  r.features != null ? r.features!.join(', ') : 'N/A',
                  Icons.star_outline,
                  Colors.amber,
                ),
                _buildExpandableSection(
                  'Why Recommended',
                  r.reason ?? 'N/A',
                  Icons.lightbulb_outline,
                  Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTranslatedCard(RecommendationWithTranslation r, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.red.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'product_${index}_${r.original.name}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: r.original.image != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(r.original.image!),
                      radius: 32,
                      backgroundColor: Colors.white,
                    )
                        : CircleAvatar(
                      backgroundColor: AppColors.topBarColor,
                      radius: 32,
                      child: const Icon(Icons.science,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.original.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${r.original.crop} • ${r.original.disease}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildModernInfoRow(
                  Icons.water_drop_outlined,
                  'Dosage',
                  r.original.dosage?.toString() ?? '-',
                  Colors.blue,
                ),
                _buildModernInfoRow(
                  Icons.opacity,
                  'Water Volume',
                  r.original.waterVolume ?? '-',
                  Colors.cyan,
                ),
                _buildModernInfoRow(
                  Icons.wb_sunny_outlined,
                  'Season',
                  r.original.season ?? '-',
                  Colors.orange,
                ),
                _buildModernInfoRow(
                  Icons.map_outlined,
                  'Area',
                  r.original.area ?? '-',
                  Colors.green,
                ),
                const Divider(height: 24),
                _buildExpandableSection(
                  'Directions of Use',
                  r.directionsOfUse,
                  Icons.info_outline,
                  Colors.purple,
                ),
                _buildExpandableSection(
                  'Features',
                  r.features,
                  Icons.star_outline,
                  Colors.amber,
                ),
                _buildExpandableSection(
                  'Why Recommended',
                  r.reason,
                  Icons.lightbulb_outline,
                  Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
      String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
