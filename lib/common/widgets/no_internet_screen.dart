import 'dart:math';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class NoInternetScreen extends StatefulWidget {
  final String message;

  const NoInternetScreen({
    super.key,
    this.message = "Looks like you're offline!",
  });

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _legController;
  final Random _random = Random();

  // Game state
  bool gameStarted = false;
  bool gameOver = false;
  int score = 0;
  int highScore = 0;

  // Player
  double playerY = 0;
  double velocity = 0;
  bool isJumping = false;
  bool isDucking = false;

  // Obstacles
  List<Obstacle> obstacles = [];
  double gameSpeed = 5.0;
  int frameCount = 0;

  // Clouds for background
  List<Cloud> clouds = [];

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _legController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat(reverse: true);

    // Initialize clouds
    for (int i = 0; i < 5; i++) {
      clouds.add(Cloud(
        x: _random.nextDouble() * 400,
        y: _random.nextDouble() * 100 + 50,
        speed: 0.3 + _random.nextDouble() * 0.5,
      ));
    }

    // Game loop - 60 FPS
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16));
      if (mounted && gameStarted && !gameOver) {
        _updateGame();
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _legController.dispose();
    super.dispose();
  }

  void _updateGame() {
    setState(() {
      frameCount++;

      // Update clouds
      for (var cloud in clouds) {
        cloud.x -= cloud.speed;
        if (cloud.x < -100) {
          cloud.x = 400;
          cloud.y = _random.nextDouble() * 100 + 50;
        }
      }

      // Gravity and jumping
      if (isJumping || playerY < 0) {
        velocity += 0.9; // Gravity
        playerY += velocity;

        if (playerY >= 0) {
          playerY = 0;
          velocity = 0;
          isJumping = false;
        }
      }

      // Spawn obstacles with varied spacing
      if (frameCount % (70 + _random.nextInt(40)) == 0) {
        int obstacleType = _random.nextInt(100);
        if (obstacleType < 50) {
          obstacles.add(Obstacle(x: 400, type: 0)); // Small cactus
        } else if (obstacleType < 75) {
          obstacles.add(Obstacle(x: 400, type: 1)); // Large cactus
        } else if (obstacleType < 90) {
          obstacles.add(Obstacle(x: 400, type: 2)); // Bird
        } else {
          // Double cactus
          obstacles.add(Obstacle(x: 400, type: 0));
          obstacles.add(Obstacle(x: 440, type: 0));
        }
      }

      // Move obstacles
      for (var obstacle in obstacles) {
        obstacle.x -= gameSpeed;
      }

      // Remove off-screen obstacles and increase score
      obstacles.removeWhere((obstacle) {
        if (obstacle.x < -50 && !obstacle.scored) {
          obstacle.scored = true;
          score++;
          if (score > highScore) highScore = score;

          // Gradual speed increase
          if (score % 10 == 0) {
            gameSpeed += 0.5;
          }
          return false;
        }
        return obstacle.x < -50;
      });

      // Collision detection
      for (var obstacle in obstacles) {
        if (_checkCollision(obstacle)) {
          gameOver = true;
          break;
        }
      }
    });
  }

  bool _checkCollision(Obstacle obstacle) {
    // More precise hitbox
    double playerLeft = 50;
    double playerRight = 90;
    double playerBottom = isDucking ? 20 : 0;
    double playerTop = isDucking ? -25 : -40;

    double obstacleLeft = obstacle.x;
    double obstacleRight = obstacle.x + 30;

    if (obstacleRight < playerLeft || obstacleLeft > playerRight) {
      return false;
    }

    if (obstacle.type == 0) {
      // Small cactus
      return playerY + playerBottom >= -15;
    } else if (obstacle.type == 1) {
      // Large cactus
      return playerY + playerBottom >= -35;
    } else {
      // Flying bird (at height)
      double birdBottom = -70;
      double birdTop = -95;
      return playerY + playerTop <= birdTop && playerY + playerBottom >= birdBottom;
    }
  }

  void _jump() {
    if (!isJumping && playerY == 0 && !gameOver && !isDucking) {
      setState(() {
        isJumping = true;
        velocity = -16;
      });
    }
  }

  void _duck(bool duck) {
    if (!isJumping && !gameOver) {
      setState(() {
        isDucking = duck;
      });
    }
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      playerY = 0;
      velocity = 0;
      isJumping = false;
      isDucking = false;
      obstacles.clear();
      gameSpeed = 5.0;
      frameCount = 0;
    });
  }

  void _restartGame() {
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (!gameStarted) {
            _startGame();
          } else if (gameOver) {
            _restartGame();
          } else {
            _jump();
          }
        },
        onLongPressStart: (_) => _duck(true),
        onLongPressEnd: (_) => _duck(false),
        child: Stack(
          children: [
            // Purple Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFA259FF),
                    Color(0xFF673AB7),
                    Color(0xFFE1BEE7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            Column(
              children: [
                const AppStatusBar(),
                const SizedBox(height: 30),

                // WiFi Icon & Title
                ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.1).animate(
                    CurvedAnimation(
                      parent: _iconController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "No Internet",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),

                const SizedBox(height: 20),

                // Game Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Desert gradient background
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFF8DC),
                                  Color(0xFFFFF0C9),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Sun in background
                          Positioned(
                            top: 30,
                            right: 40,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.shade200.withOpacity(0.4),
                              ),
                            ),
                          ),

                          // Distant mountains
                          Positioned(
                            bottom: 100,
                            left: 0,
                            right: 0,
                            child: CustomPaint(
                              size: const Size(double.infinity, 60),
                              painter: MountainPainter(),
                            ),
                          ),
                          // Clouds
                          ...clouds.map((cloud) {
                            return Positioned(
                              top: cloud.y,
                              left: cloud.x,
                              child: CustomPaint(
                                size: const Size(60, 30),
                                painter: CloudPainter(),
                              ),
                            );
                          }).toList(),

                          // Ground with shadow
                          Positioned(
                            bottom: 60,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B7355),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Sand texture below ground
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: Container(
                              color: const Color(0xFFD2B48C),
                            ),
                          ),

                          // Ground texture (moving dashes with better spacing)
                          if (gameStarted && !gameOver)
                            ...List.generate(20, (index) {
                              double dashX = ((frameCount * gameSpeed * 0.8) % 600) - (index * 30);
                              return Positioned(
                                bottom: 58,
                                left: dashX,
                                child: Container(
                                  width: 15,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B5345),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              );
                            }),

                          // Player (Dinosaur) with shadow
                          Positioned(
                            bottom: 60 - playerY,
                            left: 50,
                            child: Stack(
                              children: [
                                // Shadow
                                if (!isDucking)
                                  Positioned(
                                    top: 47,
                                    left: 5,
                                    child: Container(
                                      width: 35,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                _buildPlayer(),
                              ],
                            ),
                          ),

                          // Obstacles with shadows
                          ...obstacles.map((obstacle) {
                            return Positioned(
                              bottom: obstacle.type == 2 ? 120 : 60,
                              left: obstacle.x,
                              child: Stack(
                                children: [
                                  // Shadow for ground obstacles
                                  if (obstacle.type != 2)
                                    Positioned(
                                      top: obstacle.type == 0 ? 35 : 50,
                                      left: 2,
                                      child: Container(
                                        width: obstacle.type == 0 ? 15 : 23,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  _buildObstacle(obstacle),
                                ],
                              ),
                            );
                          }).toList(),

                          // Score with better styling
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                score.toString().padLeft(5, '0'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.topBarColor,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),

                          // High Score indicator with better styling
                          if (highScore > 0)
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      highScore.toString().padLeft(5, '0'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                        fontFamily: 'monospace',
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Start/Game Over overlay with glass effect
                          if (!gameStarted || gameOver)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                backgroundBlendMode: BlendMode.overlay,
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!gameStarted)
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.sports_esports,
                                            size: 60,
                                            color: AppColors.topBarColor,
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.cancel_rounded,
                                            size: 60,
                                            color: Colors.red,
                                          ),
                                        ),
                                      const SizedBox(height: 20),
                                      Text(
                                        gameOver ? "GAME OVER" : "DINO RUN",
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF535353),
                                          letterSpacing: 3,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      if (gameOver)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            "Score: $score",
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        )
                                      else
                                        const Text(
                                          "TAP TO START",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF535353),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      const SizedBox(height: 15),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          gameOver
                                              ? "Tap Anywhere to Restart"
                                              : "Tap: Jump • Hold: Duck",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Retry Connection Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF673AB7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 13,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    "Retry Connection",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 25),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return AnimatedBuilder(
      animation: _legController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(44, 47),
          painter: DinosaurPainter(
            isRunning: !isJumping && !isDucking,
            isDucking: isDucking,
            legFrame: _legController.value,
          ),
        );
      },
    );
  }

  Widget _buildObstacle(Obstacle obstacle) {
    if (obstacle.type == 0) {
      // Small cactus
      return CustomPaint(
        size: const Size(17, 35),
        painter: CactusPainter(isSmall: true),
      );
    } else if (obstacle.type == 1) {
      // Large cactus
      return CustomPaint(
        size: const Size(25, 50),
        painter: CactusPainter(isSmall: false),
      );
    } else {
      // Flying bird
      return AnimatedBuilder(
        animation: _legController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(46, 40),
            painter: BirdPainter(wingUp: _legController.value > 0.5),
          );
        },
      );
    }
  }
}

// Custom Painters for realistic graphics
class DinosaurPainter extends CustomPainter {
  final bool isRunning;
  final bool isDucking;
  final double legFrame;

  DinosaurPainter({
    required this.isRunning,
    required this.isDucking,
    required this.legFrame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF535353)
      ..style = PaintingStyle.fill;

    // Add slight gradient effect
    final bodyGradient = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFA259FF), Color(0xFF673AB7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(0, 0, 44, 47));

    if (isDucking) {
      // Ducking dino (simplified body)
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(10, 25, 34, 15),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        ),
        bodyGradient,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(0, 30, 12, 10),
          topLeft: const Radius.circular(2),
          bottomLeft: const Radius.circular(2),
        ),
        bodyGradient,
      );
      // Eye
      canvas.drawCircle(const Offset(42, 32), 3, paint);
      canvas.drawCircle(const Offset(43, 31), 1, Paint()..color = Colors.white);
    } else {
      // Body with rounded corners
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(18, 15, 22, 25),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        ),
        bodyGradient,
      );
      // Head
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(26, 0, 18, 18),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        ),
        bodyGradient,
      );
      // Eye with shine
      canvas.drawCircle(const Offset(38, 8), 3, paint);
      canvas.drawCircle(const Offset(39, 7), 1.5, Paint()..color = Colors.white);

      // Tail with rounded end
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(10, 20, 10, 8),
          topLeft: const Radius.circular(2),
          bottomLeft: const Radius.circular(3),
        ),
        bodyGradient,
      );
      // Arms
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(20, 25, 5, 10),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        ),
        paint,
      );

      // Legs with rounded corners (running animation)
      if (isRunning) {
        double leftLegY = 40 + (legFrame > 0.5 ? 3 : 0);
        double rightLegY = 40 + (legFrame > 0.5 ? 0 : 3);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(22, leftLegY, 6, 7),
            bottomLeft: const Radius.circular(2),
            bottomRight: const Radius.circular(2),
          ),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(30, rightLegY, 6, 7),
            bottomLeft: const Radius.circular(2),
            bottomRight: const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            const Rect.fromLTWH(22, 40, 6, 7),
            bottomLeft: const Radius.circular(2),
            bottomRight: const Radius.circular(2),
          ),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            const Rect.fromLTWH(30, 40, 6, 7),
            bottomLeft: const Radius.circular(2),
            bottomRight: const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DinosaurPainter oldDelegate) =>
      legFrame != oldDelegate.legFrame || isDucking != oldDelegate.isDucking;
}

class CactusPainter extends CustomPainter {
  final bool isSmall;

  CactusPainter({required this.isSmall});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D5016)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = const Color(0xFF3A6B1F)
      ..style = PaintingStyle.fill;

    if (isSmall) {
      // Main trunk with gradient effect
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(5, 10, 7, 25),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
          bottomLeft: const Radius.circular(1),
          bottomRight: const Radius.circular(1),
        ),
        paint,
      );
      // Highlight
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(6, 10, 2, 25),
          topLeft: const Radius.circular(2),
        ),
        highlightPaint,
      );
      // Arms
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(0, 15, 5, 8),
          topLeft: const Radius.circular(2),
          bottomLeft: const Radius.circular(2),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(12, 18, 5, 8),
          topRight: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        ),
        paint,
      );
    } else {
      // Large cactus
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(8, 5, 9, 45),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        paint,
      );
      // Highlight on main trunk
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(9, 5, 2, 45),
          topLeft: const Radius.circular(2),
        ),
        highlightPaint,
      );
      // Arms with rounded edges
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(0, 15, 8, 12),
          topLeft: const Radius.circular(3),
          bottomLeft: const Radius.circular(3),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(17, 20, 8, 12),
          topRight: const Radius.circular(3),
          bottomRight: const Radius.circular(3),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(2, 10, 6, 10),
          topLeft: const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BirdPainter extends CustomPainter {
  final bool wingUp;

  BirdPainter({required this.wingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF535353)
      ..style = PaintingStyle.fill;

    // Body
    canvas.drawOval(const Rect.fromLTWH(15, 15, 20, 12), paint);
    // Head
    canvas.drawCircle(const Offset(35, 18), 6, paint);
    // Beak
    canvas.drawRect(const Rect.fromLTWH(40, 17, 4, 2), paint);

    // Wings
    if (wingUp) {
      canvas.drawRect(const Rect.fromLTWH(18, 8, 15, 8), paint);
    } else {
      canvas.drawRect(const Rect.fromLTWH(18, 22, 15, 8), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BirdPainter oldDelegate) =>
      wingUp != oldDelegate.wingUp;
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(15, 20), 12, paint);
    canvas.drawCircle(const Offset(30, 18), 14, paint);
    canvas.drawCircle(const Offset(45, 20), 12, paint);
    canvas.drawRect(const Rect.fromLTWH(15, 20, 30, 10), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Obstacle {
  double x;
  int type;
  bool scored;

  Obstacle({
    required this.x,
    required this.type,
    this.scored = false,
  });
}

class Cloud {
  double x;
  double y;
  double speed;

  Cloud({
    required this.x,
    required this.y,
    required this.speed,
  });
}

// Mountain painter for background
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD2B48C).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.35, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width * 0.85, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}