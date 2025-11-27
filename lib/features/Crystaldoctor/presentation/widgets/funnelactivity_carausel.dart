import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/new_activity_screen.dart';

class FunnelActivityCarousel extends StatefulWidget {
  final Widget funnelSection;

  const FunnelActivityCarousel({super.key, required this.funnelSection});

  @override
  State<FunnelActivityCarousel> createState() => _FunnelActivityCarouselState();
}

class _FunnelActivityCarouselState extends State<FunnelActivityCarousel> {
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    // Start auto-slide timer
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_pageController.hasClients) return;
      final nextPage = _pageController.page == 0 ? 1 : 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 440, // 👈 enough space for both slides
          child: PageView(
            controller: _pageController,
            children: [
              widget.funnelSection,
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: NewActivityScreen(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SmoothPageIndicator(
          controller: _pageController,
          count: 2,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            expansionFactor: 3,
            spacing: 6,
            activeDotColor: Colors.deepPurple,
            dotColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}
