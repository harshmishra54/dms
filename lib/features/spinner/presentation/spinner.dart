import 'package:TrustTags_DMS/features/scan/models/scan_response.dart';
import 'package:TrustTags_DMS/features/spinner/provider/spinner_reward_provider.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class SpinnerWidget extends StatefulWidget {
  final String spinnerId;
  final List<Segment> segments;

  const SpinnerWidget({
    Key? key,
    required this.spinnerId,
    required this.segments,
  }) : super(key: key);
  @override
  State<SpinnerWidget> createState() => _SpinnerWidgetState();
}


class _SpinnerWidgetState extends State<SpinnerWidget>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController(text: '8');

  late AnimationController _spinController;
  late AnimationController _celebrationController;
  late AnimationController _pointerBounceController;

  late Animation<double> _spinAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _pointerBounceAnimation;

  int get _segments => widget.segments.length;

  int? _selectedSegment;
  int? _pendingWinner;
  bool _isSpinning = false;
  bool _showWinDialog = false;

  double _currentRotation = 0.0;
  double _targetRotation = 0.0;
  late int segmentCount;

  static const double _twoPi = 2 * math.pi;

  @override
  void initState() {
    super.initState();

    segmentCount = widget.segments.length;

    _spinController = AnimationController(vsync: this);
    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    double startRotation = 0;

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        startRotation = _currentRotation;
      }
    });

    _spinController.addListener(() {
      setState(() {
        _currentRotation = startRotation +
            (_targetRotation - startRotation) * _spinAnimation.value;
      });
    });

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _selectedSegment = _pendingWinner;
          _showWinDialog = true;
        });
        _showWinnerDialog();
        _celebrationController.forward();
      }
    });

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeOut),
    );

    _pointerBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pointerBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pointerBounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _spinController.dispose();
    _celebrationController.dispose();
    _pointerBounceController.dispose();
    super.dispose();
  }

  void _spin({int? forceWinner}) {
    if (_isSpinning) return;
    final winner = forceWinner ?? math.Random().nextInt(_segments);
    _spinWithWinner(winner);
  }

  void _spinWithWinner(int winnerIndex) {
    if (_isSpinning) return;
    if (winnerIndex < 0 || winnerIndex >= _segments) {
      print('Invalid winner index requested: $winnerIndex');
      return;
    }

    _celebrationController.reset();

    setState(() {
      _isSpinning = true;
      _selectedSegment = null;
      _pendingWinner = winnerIndex;
    });

    final double segmentAngle = _twoPi / _segments;

    double currentWinnerCenterAngle = winnerIndex * segmentAngle;

    double angleToRotate = -currentWinnerCenterAngle;

    final double extraRotations = 5 + math.Random().nextDouble() * 3;
    double totalRotation = angleToRotate + (extraRotations * _twoPi);

    _targetRotation = _currentRotation + totalRotation;

    final double rotations = totalRotation / _twoPi;
    final int durationMs = (rotations * 500).clamp(3000, 7000).toInt();
    _spinController.duration = Duration(milliseconds: durationMs);

    print('🎯 Spinning to winner index: $winnerIndex');
    print('   Winner current angle: ${currentWinnerCenterAngle.toStringAsFixed(3)} rad');
    print('   Total rotation: ${totalRotation.toStringAsFixed(3)} rad (${rotations.toStringAsFixed(2)} full rotations)');
    print('   Duration: ${durationMs}ms');

    _spinController.forward(from: 0);
  }

  void _resetForNewSpin() {
    setState(() {
      _showWinDialog = false;
      _selectedSegment = null;
      _celebrationController.reset();
      _currentRotation = 0.0;
      _targetRotation = 0.0;
    });
  }

  void _showWinnerDialog() {
    final earnedPoints = Provider.of<SpinnerRewardProvider>(context, listen: false)
        .rewardResponse?.points ?? 0;

    final bool isZero = earnedPoints == 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isZero ? Colors.grey.shade400 : Colors.purple.shade400,
                width: 3,
              ),
            ),
            title: Text(
              isZero ? "Better Luck Next Time!" : "🎉 Congratulations! 🎉",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isZero ? Colors.grey.shade700 : Colors.purple.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isZero
                            ? [Colors.grey.shade300, Colors.grey.shade400]
                            : [Colors.purple.shade100, Colors.purple.shade200],
                      ),
                    ),
                    child: Icon(
                      isZero ? Icons.sentiment_dissatisfied : Icons.stars_rounded,
                      size: 50,
                      color: isZero ? Colors.grey.shade600 : Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isZero
                        ? "No points this time"
                        : "You won $earnedPoints Points!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isZero ? Colors.grey.shade700 : Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isZero ? Colors.grey.shade600 : Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double get _displayRotation => _currentRotation;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final wheelSize = math.min(screenWidth * 0.85, screenHeight * 0.45).clamp(280.0, 400.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade600,
              Colors.purple.shade800,
              Colors.deepPurple.shade900,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background circles
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purple.shade300.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.deepPurple.shade400.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedSegment != null && !_isSpinning && _showWinDialog)
                AnimatedBuilder(
                  animation: _confettiAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: ConfettiPainter(progress: _confettiAnimation.value),
                    );
                  },
                ),
              Column(
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  // Enhanced header
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.casino,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Spin the Wheel',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // Wheel with enhanced container
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Animated pulsing rings
                        if (!_isSpinning && !_showWinDialog)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.95, end: 1.05),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeInOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: wheelSize + 80,
                                  height: wheelSize + 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        // Decorative rings around wheel
                        Container(
                          width: wheelSize + 40,
                          height: wheelSize + 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: wheelSize + 60,
                          height: wheelSize + 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 2,
                            ),
                          ),
                        ),
                        // Rotating wheel
                        Transform.rotate(
                          angle: _displayRotation,
                          child: Container(
                            width: wheelSize,
                            height: wheelSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 35,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.5),
                                  blurRadius: 65,
                                  spreadRadius: 18,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              size: Size(wheelSize, wheelSize),
                              painter: SpinnerPainter(
                                segments: widget.segments,
                                selectedSegment: _isSpinning || _showWinDialog ? null : _selectedSegment,
                                isSpinning: _isSpinning,
                              ),
                            ),
                          ),
                        ),

                        // Fixed pointer at top - pointing inward
                        Positioned(
                          top: -25,
                          child: AnimatedBuilder(
                            animation: _isSpinning ? _spinController : _celebrationController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: const Size(60, 70),
                                painter: SharpPointerPainter(
                                  glowIntensity: _isSpinning ? 1.0 : (_showWinDialog ? 0.8 : 0.3),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Enhanced spin button - moved up
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: _isSpinning || _showWinDialog
                            ? null
                            : LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.purple.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: _isSpinning || _showWinDialog
                            ? []
                            : [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 3,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSpinning || _showWinDialog
                            ? null
                            : () async {
                          final spinnerProvider =
                          Provider.of<SpinnerRewardProvider>(context, listen: false);

                          await spinnerProvider.fetchSpinnerPoints(widget.spinnerId);

                          final points = spinnerProvider.rewardResponse?.points;
                          if (points == null) {
                            print("❌ API returned no points");
                            return;
                          }

                          int winnerIndex = widget.segments.indexWhere((s) => s.point == points);

                          if (winnerIndex == -1) {
                            print("⚠️ No segment matches API points: $points");
                            return;
                          }

                          print("🎯 API Winner: Segment #$winnerIndex with $points points");
                          _spin(forceWinner: winnerIndex);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSpinning || _showWinDialog
                              ? Colors.grey.shade600
                              : Colors.transparent,
                          foregroundColor: _isSpinning || _showWinDialog
                              ? Colors.white
                              : Colors.purple.shade700,
                          disabledBackgroundColor: Colors.grey.shade600,
                          disabledForegroundColor: Colors.white70,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSpinning)
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                ),
                              )
                            else
                              Icon(
                                Icons.refresh_rounded,
                                size: 28,
                                color: Colors.purple.shade700,
                              ),
                            const SizedBox(width: 12),
                            Text(
                              _isSpinning ? 'Spinning...' : 'SPIN NOW',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpinnerPainter extends CustomPainter {
  final List<Segment> segments;
  final int? selectedSegment;
  final bool isSpinning;

  SpinnerPainter({
    required this.segments,
    this.selectedSegment,
    this.isSpinning = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * math.pi / segments.length;

    // Enhanced color palette
    final colors = [
      Colors.purple.shade400,
      Colors.deepPurple.shade400,
      Colors.purple.shade500,
      Colors.deepPurple.shade500,
      Colors.purple.shade600,
      Colors.deepPurple.shade600,
      Colors.purple.shade700,
      Colors.deepPurple.shade700,
      Colors.purple.shade300,
      Colors.deepPurple.shade300,
      Colors.purple.shade800,
      Colors.deepPurple.shade800,
    ];

    // Outer glow
    final glowPaint = Paint()
      ..color = Colors.purple.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius + 5, glowPaint);

    // Draw segments
    for (int i = 0; i < segments.length; i++) {
      final baseColor = colors[i % colors.length];
      final isWinner = selectedSegment != null && i == selectedSegment;

      // Create gradient for each segment
      final segmentGradient = SweepGradient(
        center: Alignment.center,
        startAngle: -math.pi / 2 + i * segmentAngle,
        endAngle: -math.pi / 2 + (i + 1) * segmentAngle,
        colors: [
          baseColor.withOpacity(0.85),
          baseColor,
          baseColor.withOpacity(0.85),
        ],
      );

      final paint = Paint()
        ..shader = segmentGradient.createShader(Rect.fromCircle(center: center, radius: radius));

      if (isWinner) {
        paint.color = baseColor.withOpacity(1.0);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0);
      }

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2 + i * segmentAngle,
          segmentAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // White border between segments with shadow
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0.5),
      );

      // Draw points text with enhanced styling
      final angle = -math.pi / 2 + i * segmentAngle + segmentAngle / 2;
      final textRadius = radius * 0.68;

      final textX = center.dx + textRadius * math.cos(angle);
      final textY = center.dy + textRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${segments[i].point}',
          style: TextStyle(
            color: Colors.white,
            fontSize: segments.length <= 8 ? 26 : (segments.length <= 12 ? 22 : 18),
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(blurRadius: 6, color: Colors.black87, offset: Offset(2, 2)),
              Shadow(blurRadius: 3, color: Colors.black54, offset: Offset(1, 1)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // Center hub with enhanced gradient
    final hubGradient = RadialGradient(
      colors: [
        Colors.white,
        Colors.purple.shade50,
        Colors.purple.shade100,
        Colors.purple.shade200,
      ],
      stops: [0.0, 0.3, 0.6, 1.0],
    );

    canvas.drawCircle(
      center,
      45,
      Paint()..shader = hubGradient.createShader(Rect.fromCircle(center: center, radius: 45)),
    );

    // Inner circle with purple accent
    canvas.drawCircle(
      center,
      15,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.purple.shade700, Colors.deepPurple.shade800],
        ).createShader(Rect.fromCircle(center: center, radius: 15)),
    );

    // Highlight on center
    canvas.drawCircle(
      Offset(center.dx - 3, center.dy - 3),
      5,
      Paint()..color = Colors.white.withOpacity(0.8),
    );
  }

  @override
  bool shouldRepaint(covariant SpinnerPainter oldDelegate) =>
      oldDelegate.segments != segments ||
          oldDelegate.selectedSegment != selectedSegment ||
          oldDelegate.isSpinning != isSpinning;
}

class SharpPointerPainter extends CustomPainter {
  final double glowIntensity;

  SharpPointerPainter({this.glowIntensity = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 0);

    // Enhanced glow effect - reversed
    if (glowIntensity > 0) {
      final glowPaint = Paint()
        ..color = Colors.purple.withOpacity(glowIntensity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

      final glowPath = Path()
        ..moveTo(center.dx, center.dy + 50)
        ..lineTo(center.dx - 26, center.dy - 5)
        ..lineTo(center.dx + 26, center.dy - 5)
        ..close();

      canvas.drawPath(glowPath, glowPaint);
    }

    // Outer decorative circle at base
    canvas.drawCircle(
      center,
      18,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Main pointer triangle - pointing down into wheel
    final pointerPath = Path()
      ..moveTo(center.dx, center.dy + 45)
      ..lineTo(center.dx - 22, center.dy)
      ..lineTo(center.dx + 22, center.dy)
      ..close();

    // Enhanced shadow
    canvas.drawShadow(pointerPath, Colors.black, 12, true);

    // Enhanced gradient fill (reversed)
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.purple.shade400,
          Colors.purple.shade200,
          Colors.purple.shade50,
          Colors.white,
        ],
      ).createShader(Rect.fromLTWH(center.dx - 22, center.dy, 44, 45));

    canvas.drawPath(pointerPath, paint);

    // Purple border with gradient
    canvas.drawPath(
      pointerPath,
      Paint()
        ..color = Colors.purple.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // Inner highlight - reversed
    final highlightPath = Path()
      ..moveTo(center.dx, center.dy + 38)
      ..lineTo(center.dx - 9, center.dy + 18)
      ..lineTo(center.dx + 9, center.dy + 18)
      ..close();

    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );

    // Base circle decoration
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            Colors.purple.shade100,
            Colors.purple.shade300,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );

    // Shine on base
    canvas.drawCircle(
      Offset(center.dx - 3, center.dy - 3),
      4,
      Paint()..color = Colors.white.withOpacity(0.9),
    );
  }

  @override
  bool shouldRepaint(covariant SharpPointerPainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity;
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    final paint = Paint();
    final purpleShades = [
      Colors.purple.shade300,
      Colors.purple.shade400,
      Colors.deepPurple.shade300,
      Colors.deepPurple.shade400,
      Colors.white,
      Colors.purple.shade200,
      Colors.yellow.shade300,
      Colors.pink.shade300,
    ];

    for (int i = 0; i < 100; i++) {
      paint.color = purpleShades[i % purpleShades.length].withOpacity((1 - progress) * 0.9);
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * progress;
      final radius = 3 + rnd.nextDouble() * 5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}