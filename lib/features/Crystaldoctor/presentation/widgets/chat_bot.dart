import 'package:TrustTags_DMS/common/provider/recommend_product_query_provider.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/general_query_request.dart';
import 'package:TrustTags_DMS/data/models/product_recommendation_request.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/suggest_product_to_farmer_widgets.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/crop_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cropSearchController = TextEditingController();
  late AnimationController _animationController;

  // Conversation state
  final List<ChatMessage> _messages = [];
  ConversationMode _currentMode = ConversationMode.idle;

  // Product recommendation flow state
  String? _selectedCrop;
  double? _selectedArea;
  String? _selectedSeason;

  final List<String> seasons = ["Rabi", "Kharif", "Summer"];
  List<Recomm> _getAllRecommendations() {
    final all = _messages
        .where((m) => m.recommendations != null && m.recommendations!.isNotEmpty)
        .expand((m) => m.recommendations!)
        .toList();
    return all;
  }


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _showWelcomeMessage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CropProvider>(context, listen: false).fetchCropList();
    });
  }
  Future<int?> _getRoleId() async {
    return await SharedPrefsHelper.getRoleId();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _queryController.dispose();
    _areaController.dispose();
    _cropSearchController.dispose();
    super.dispose();
  }

  void _showWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "Hello! 👋 I'm your Smart Crop Assistant.\n\n"
            "I can help you with:\n"
            "• Product recommendations for crops\n"
            "• General crop and farming questions\n\n"
            "What would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _resetConversationFlow() {
    setState(() {
      _currentMode = ConversationMode.idle;
      _selectedCrop = null;
      _selectedArea = null;
      _selectedSeason = null;
      _areaController.clear();
      _cropSearchController.clear();
    });
  }

  void _startProductRecommendation() {
    setState(() {
      _currentMode = ConversationMode.productRecommendation;
      _messages.add(ChatMessage(
        text: "Product Recommendation",
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        text: "Great! Let's find the best product for your crop.\n\n"
            "First, please select your crop from the options below:",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _selectCrop(String crop) {
    setState(() {
      _selectedCrop = crop;
      _cropSearchController.clear();
      _messages.add(ChatMessage(
        text: crop,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        text: "Perfect! Now, please enter the area of your farm (in acres):",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _submitArea() {
    final area = double.tryParse(_areaController.text.trim());
    if (area == null || area <= 0) {
      _showSnackBar("Please enter a valid area");
      return;
    }

    setState(() {
      _selectedArea = area;
      _messages.add(ChatMessage(
        text: "${area} acres",
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        text: "Great! Finally, please select the season:",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _areaController.clear();
    });
    _scrollToBottom();
  }

  void _selectSeason(String season) {
    setState(() {
      _selectedSeason = season;
      _messages.add(ChatMessage(
        text: season,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
    _fetchProductRecommendations();
  }

  Future<void> _fetchProductRecommendations() async {
    if (_selectedCrop == null || _selectedArea == null || _selectedSeason == null) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: "Analyzing and finding the best products for you...",
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      ));
    });
    _scrollToBottom();

    final provider = Provider.of<SmartProductRecommendationProvider>(
      context,
      listen: false,
    );

    try {
      final request = ProductRecommendationRequest(
        crops: [CropItem(name: _selectedCrop!)],
        farmer: Farmer(area: _selectedArea!, season: _selectedSeason!),
      );

      await provider.fetchProductRecommendations(request);
      _updateWithRecommendations(provider.productRecommendations);
    } catch (e) {
      setState(() {
        if (_messages.isNotEmpty && _messages.last.isLoading) {
          _messages.removeLast();
        }
        _messages.add(ChatMessage(
          text: "Sorry, I encountered an error: ${provider.error ?? e.toString()}",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }

    _resetConversationFlow();
    _scrollToBottom();
  }

  void _updateWithRecommendations(List<Recomm> recommendations) {
    setState(() {
      if (_messages.isNotEmpty && _messages.last.isLoading) {
        _messages.removeLast();
      }

      if (recommendations.isEmpty) {
        _messages.add(ChatMessage(
          text: "I couldn't find any specific recommendations for your query. "
              "Would you like to try with different parameters?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        _messages.add(ChatMessage(
          text: "Here are my top recommendations for $_selectedCrop:",
          isUser: false,
          timestamp: DateTime.now(),
          recommendations: recommendations,
        ));
      }
    });
  }

  Future<void> _sendGeneralQuery() async {
    final query = _queryController.text.trim();

    if (query.isEmpty) {
      _showSnackBar("Please enter your question");
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: query,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        text: "Let me think about that...",
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      ));
    });

    _queryController.clear();
    _scrollToBottom();

    final provider = Provider.of<SmartProductRecommendationProvider>(
      context,
      listen: false,
    );

    try {
      await provider.fetchGeneralQueryAnswer(
        GeneralQueryRequest(query: query),
      );
      _updateWithGeneralQuery(provider.generalQueryAnswer);
    } catch (e) {
      setState(() {
        if (_messages.isNotEmpty && _messages.last.isLoading) {
          _messages.removeLast();
        }
        _messages.add(ChatMessage(
          text: "Sorry, I encountered an error: ${provider.error ?? e.toString()}",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }

    _scrollToBottom();
  }

  void _updateWithGeneralQuery(String answer) {
    setState(() {
      if (_messages.isNotEmpty && _messages.last.isLoading) {
        _messages.removeLast();
      }
      _messages.add(ChatMessage(
        text: answer.isNotEmpty
            ? answer
            : "I don't have enough information to answer that. Could you please rephrase your question?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: AutoTranslateText(message)),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const AppStatusBar(),
          _buildAppBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(cropProvider),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoTranslateText(
                  'Smart Assistant',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                AutoTranslateText(
                  'AI-Powered Crop Advisor',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // ✅ Conditionally show icon button only for roleId 23
          FutureBuilder<int?>(
            future: _getRoleId(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == 23) {
                return IconButton(
                  icon: const Icon(Icons.settings_suggest, color: Color(0xFF8E2DE2)),
                  tooltip: "View Recommended Products",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecommendedProductsFarmerScreen(
                          recommendations: _getAllRecommendations(),
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink(); // Hide button if roleId is not 23
            },
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
  Widget _buildInputArea(CropProvider cropProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentMode == ConversationMode.idle)
            _buildModeSelection()
          else if (_currentMode == ConversationMode.productRecommendation)
            _buildProductRecommendationFlow(cropProvider)
          else
            _buildGeneralQueryInput(),
        ],
      ),
    );
  }

  Widget _buildModeSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  icon: Icons.shopping_bag,
                  label: "Recommend Product",
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  ),
                  onTap: _startProductRecommendation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeButton(
                  icon: Icons.help_outline,
                  label: "Ask Question",
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                  ),
                  onTap: () {
                    setState(() {
                      _currentMode = ConversationMode.generalQuery;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100, // ✅ consistent height
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Flexible(
                child: AutoTranslateText(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                    maxLines: null,
                    overflow: null,
                    softWrap: true // ✅ trims gracefully
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProductRecommendationFlow(CropProvider cropProvider) {
    if (_selectedCrop == null) {
      return _buildCropSelection(cropProvider);
    } else if (_selectedArea == null) {
      return _buildAreaInput();
    } else if (_selectedSeason == null) {
      return _buildSeasonSelection();
    }
    return const SizedBox.shrink();
  }

  Widget _buildCropSelection(CropProvider cropProvider) {
    if (cropProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      );
    }

    if (cropProvider.cropResponse != null &&
        cropProvider.cropResponse!.data.isNotEmpty) {
      final allCrops = cropProvider.cropResponse!.data
          .map((e) => e.cropTypeName)
          .toList();

      // Filter crops based on search
      final searchQuery = _cropSearchController.text.toLowerCase();
      final filteredCrops = searchQuery.isEmpty
          ? allCrops
          : allCrops.where((crop) =>
          crop.toLowerCase().contains(searchQuery)).toList();

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scrollable crop list
            Expanded(
              child: filteredCrops.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AutoTranslateText(
                    "No crops found matching '$searchQuery'",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
                  : SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: filteredCrops
                      .map((crop) => Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectCrop(crop),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8E2DE2).withOpacity(0.1),
                              const Color(0xFF4A00E0).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF8E2DE2)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.eco,
                              size: 16,
                              color: Color(0xFF8E2DE2),
                            ),
                            const SizedBox(width: 6),
                            AutoTranslateText(
                              crop,
                              style: const TextStyle(
                                color: Color(0xFF8E2DE2),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),

            // Cancel button
            _buildCancelButton(),
          ],
        ),
      );

    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const AutoTranslateText("No crops available. Please try again later."),
          const SizedBox(height: 12),
          _buildCancelButton(),
        ],
      ),
    );
  }

  Widget _buildAreaInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _areaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: "Enter area in acres (e.g., 5.5)",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.landscape,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                    onSubmitted: (_) => _submitArea(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildSubmitButton(_submitArea),
            ],
          ),
          const SizedBox(height: 12),
          _buildCancelButton(),
        ],
      ),
    );
  }

  Widget _buildSeasonSelection() {
    return Column(
      children: [
        _buildOptionChips(seasons, _selectSeason),
        _buildCancelButton(),
      ],
    );
  }

  Widget _buildGeneralQueryInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _queryController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: "Ask me anything about crops...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                    onSubmitted: (_) => _sendGeneralQuery(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildSubmitButton(_sendGeneralQuery),
            ],
          ),
          const SizedBox(height: 12),
          _buildCancelButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton.icon(
      onPressed: _resetConversationFlow,
      icon: const Icon(Icons.close, size: 16),
      label: const AutoTranslateText("Cancel"),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[600],
      ),
    );
  }

  Widget _buildOptionChips(List<String> options, Function(String) onSelect) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTranslateText(
            "Select an option:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map((e) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(e),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8E2DE2).withOpacity(0.1),
                        const Color(0xFF4A00E0).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF8E2DE2).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForOption(e),
                        size: 16,
                        color: const Color(0xFF8E2DE2),
                      ),
                      const SizedBox(width: 6),
                      AutoTranslateText(
                        e,
                        style: const TextStyle(
                          color: Color(0xFF8E2DE2),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  IconData _getIconForOption(String option) {
    if (seasons.contains(option)) return Icons.wb_sunny;
    return Icons.eco;
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child:
              const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    )
                        : null,
                    color: message.isUser ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: message.isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : AutoTranslateText(
                    message.text,
                    style: TextStyle(
                      color:
                      message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: null,   // ✅ allow unlimited lines
                    overflow: null,   // ✅ prevent ellipsis
                    softWrap: true,
                  ),
                ),
                if (message.recommendations != null &&
                    message.recommendations!.isNotEmpty)
                  ...message.recommendations!
                      .map((rec) => _buildRecommendationCard(rec)),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Recomm rec) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8E2DE2).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Product Image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF8E2DE2).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: rec.image != null && rec.image!.isNotEmpty
                      ? Image.network(
                    rec.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  )
                      : Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:AutoTranslateText(
                  rec.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.eco, "Crop", rec.crop),
          if (rec.disease.isNotEmpty)
            _buildInfoRow(Icons.bug_report, "Disease", rec.disease),
          if (rec.dosage != null && rec.dosage!.isNotEmpty)
            _buildInfoRow(Icons.medication, "Dosage", rec.dosage!),
          if (rec.waterVolume != null && rec.waterVolume!.isNotEmpty)
            _buildInfoRow(Icons.water_drop, "Water Volume", rec.waterVolume!),
          if (rec.features.isNotEmpty) ...[
            const SizedBox(height: 8),
            const AutoTranslateText(
              "Key Features:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 6),
            ...rec.features.map((feature) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF48BB78),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AutoTranslateText(
                      feature,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8E2DE2)),
          const SizedBox(width: 8),
          AutoTranslateText(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF4A5568),
            ),
          ),
          Expanded(
            child: AutoTranslateText(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enums and Models
enum ConversationMode {
  idle,
  productRecommendation,
  generalQuery,
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Recomm>? recommendations;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendations,
    this.isLoading = false,
  });
}