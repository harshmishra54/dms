import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class DashboardActionButtons extends StatefulWidget {
  final VoidCallback onInwardTap;
  final VoidCallback onScanTap;
  final VoidCallback onRewardTap;

  final String? highlightAction;

  const DashboardActionButtons({
    super.key,
    required this.onInwardTap,
    required this.onScanTap,
    required this.onRewardTap,
    this.highlightAction,
  });

  @override
  State<DashboardActionButtons> createState() => _DashboardActionButtonsState();
}

class _DashboardActionButtonsState extends State<DashboardActionButtons>
    with TickerProviderStateMixin {
  bool inwardTapped = false;
  bool rewardTapped = false;
  double _dragPosition = 0.0;

  late AnimationController _borderController;
  late AnimationController _pulseController;
  late AnimationController _leftArrowController;
  late AnimationController _rightArrowController;
  late Animation<Offset> _leftArrowAnimation;
  late Animation<Offset> _rightArrowAnimation;

  @override
  void initState() {
    super.initState();

    // Gradient border animation controller
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Pulsating scan button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    // Arrow animations
    _leftArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _rightArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _leftArrowAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.2, 0),
    ).animate(
        CurvedAnimation(parent: _leftArrowController, curve: Curves.easeInOut));

    _rightArrowAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.2, 0),
    ).animate(
        CurvedAnimation(parent: _rightArrowController, curve: Curves.easeInOut));

    if (widget.highlightAction == 'inward') inwardTapped = true;
    if (widget.highlightAction == 'reward') rewardTapped = true;
  }

  @override
  void dispose() {
    _borderController.dispose();
    _pulseController.dispose();
    _leftArrowController.dispose();
    _rightArrowController.dispose();
    super.dispose();
  }

  void _animateInward() {
    setState(() => inwardTapped = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => inwardTapped = false);
      widget.onInwardTap();
    });
  }

  void _animateReward() {
    setState(() => rewardTapped = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => rewardTapped = false);
      widget.onRewardTap();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxDragDistance) {
    setState(() {
      _dragPosition += details.delta.dx / maxDragDistance;
      if (_dragPosition > 1.0) _dragPosition = 1.0;
      if (_dragPosition < -1.0) _dragPosition = -1.0;
    });
  }

  void _handleDragEnd() {
    if (_dragPosition < -0.5) {
      _animateInward();
    } else if (_dragPosition > 0.5) {
      _animateReward();
    } else {
      widget.onScanTap();
    }
    setState(() {
      _dragPosition = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDragDistance = (screenWidth - 80) / 2;

    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          padding: const EdgeInsets.all(2), // thin border
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.purpleAccent,
                Colors.deepPurple,
                Colors.purpleAccent,
              ],
              stops: [
                (_borderController.value * 0.5).clamp(0.0, 1.0),
                (_borderController.value * 0.7).clamp(0.0, 1.0),
                (_borderController.value * 0.9).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Inward & Reward buttons
            Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6EAFE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: inwardTapped
                            ? AppColors.topBarColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        AutoTranslateText("📦", style: TextStyle(fontSize: 26)),
                        SizedBox(height: 6),
                        AutoTranslateText("Inward",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6EAFE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: rewardTapped
                            ? AppColors.topBarColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        AutoTranslateText("🎁", style: TextStyle(fontSize: 26)),
                        SizedBox(height: 6),
                        AutoTranslateText("Reward",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Center Scan button
            Positioned(
              child: GestureDetector(
                onHorizontalDragUpdate: (details) =>
                    _handleDragUpdate(details, maxDragDistance),
                onHorizontalDragEnd: (_) => _handleDragEnd(),
                child: Transform.translate(
                  offset: Offset(_dragPosition * maxDragDistance, 0),
                  child: ScaleTransition(
                    scale: (widget.highlightAction == 'scan')
                        ? _pulseController
                        : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.highlightAction == 'scan')
                                ? AppColors.topBarColor.withOpacity(0.4)
                                : Colors.grey.shade300,
                            blurRadius: 12,
                            spreadRadius:
                            (widget.highlightAction == 'scan') ? 4 : 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.document_scanner,
                            size: 28, color: AppColors.topBarColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Animated arrows left/right
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 65 / 2 - 45,
              child: SlideTransition(
                position: _leftArrowAnimation,
                child: Icon(Icons.arrow_back,
                    color: AppColors.topBarColor, size: 28),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 + 65 / 2 - 30,
              child: SlideTransition(
                position: _rightArrowAnimation,
                child: Icon(Icons.arrow_forward,
                    color: AppColors.topBarColor, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
