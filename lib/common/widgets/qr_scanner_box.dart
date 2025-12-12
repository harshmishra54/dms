import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:math';

class ReusableQRScanner extends StatefulWidget {
  final Function(String) onScanned;

  const ReusableQRScanner({Key? key, required this.onScanned}) : super(key: key);

  @override
  State<ReusableQRScanner> createState() => ReusableQRScannerState();
}

class ReusableQRScannerState extends State<ReusableQRScanner>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _torchOn = false;
  bool _isScanned = false;
  Function(String)? _onScannedOverride;

  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _borderAnimation = Tween<double>(begin: 0, end: 1).animate(_borderAnimationController);
  }

  void resetScanner() {
    setState(() {
      _isScanned = false;
    });
  }

  void setOnScanned(Function(String) callback) {
    _onScannedOverride = callback;
  }

  void pauseScanning() {
    setState(() {
      _isScanned = true;
    });
  }
  /// FORCE close camera immediately (for parent screens)
  void forceDisposeCamera() {
    try {
      _controller.stop();
    } catch (_) {}

    try {
      _controller.dispose();
    } catch (_) {}
  }


  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() {
      _torchOn = !_torchOn;
    });
  }

  @override
  void dispose() {
    try {
      _controller.stop();
    } catch (_) {}
    try {
      _controller.dispose();
    } catch (_) {}
    _borderAnimationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final qrHeight = MediaQuery.of(context).size.height * 0.50; // slightly bigger

    return Column(
      children: [
        // Scanner takes place directly below app bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          width: screenWidth - 32,
          height: qrHeight,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MobileScanner(
                  controller: _controller,
                  fit: BoxFit.cover,
                  onDetect: (capture) {
                    if (_isScanned) return;
                    final barcode = capture.barcodes.first;
                    if (barcode.rawValue != null) {
                      setState(() => _isScanned = true);

                      showCaptureEffect(context, width: screenWidth - 32, height: qrHeight);

                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (_onScannedOverride != null) {
                          _onScannedOverride!(barcode.rawValue!);
                        } else {
                          widget.onScanned(barcode.rawValue!);
                        }
                      });
                    }
                  },
                ),
              ),

              // Animated border
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _borderAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BorderPainter(_borderAnimation.value),
                    );
                  },
                ),
              ),

              // Torch toggle inside scanner (top-right corner)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _toggleTorch,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 22,
                    child: Icon(
                      _torchOn ? Icons.flashlight_off : Icons.flashlight_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showCaptureEffect(BuildContext context,
      {required double width, required double height}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          left: 16,
          width: width,
          height: height,
          child: QRShatterEffect(width: width, height: height),
        );
      },
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 600), () {
      overlayEntry.remove();
    });
  }
}

class BorderPainter extends CustomPainter {
  final double progress;
  BorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.purple, Colors.deepPurple, Colors.purple],
        stops: [progress, (progress + 0.2) % 1.0, (progress + 0.4) % 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant BorderPainter oldDelegate) => true;
}

class QRShatterEffect extends StatefulWidget {
  final double width;
  final double height;
  const QRShatterEffect({this.width = 250, this.height = 250});

  @override
  _QRShatterEffectState createState() => _QRShatterEffectState();
}

class _QRShatterEffectState extends State<QRShatterEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<_ShatterPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _pieces = List.generate(50, (index) => _ShatterPiece(widget.width, widget.height));

    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ShatterPainter(_pieces, _animation.value),
        );
      },
    );
  }
}

class _ShatterPiece {
  late double dx, dy;
  late double angle;
  late double size;
  late double scale;
  late Color color;

  _ShatterPiece(double width, double height) {
    final rand = Random();
    dx = rand.nextDouble() * width - width / 2;
    dy = rand.nextDouble() * height - height / 3;
    angle = rand.nextDouble() * pi * 6;
    size = rand.nextDouble() * 18 + 4;
    scale = rand.nextDouble() * 1.2 + 0.4;
    color = Color.lerp(Colors.white, Colors.white, rand.nextDouble())!;
  }
}

class _ShatterPainter extends CustomPainter {
  final List<_ShatterPiece> pieces;
  final double progress;

  _ShatterPainter(this.pieces, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in pieces) {
      final paint = Paint()
        ..color = p.color.withOpacity(1 - progress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final factor = sin(progress * pi);
      final x = size.width / 2 + p.dx * factor * 2;
      final y = size.height / 2 + p.dy * factor * 2;
      final s = p.size * (1 + factor * p.scale);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.angle * factor);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: s, height: s), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ShatterPainter oldDelegate) => true;
}
