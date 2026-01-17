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

enum PlayerAction { running, jumping, sliding }

class _NoInternetScreenState extends State<NoInternetScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _runController;
  final Random _random = Random();

  // Game state
  bool gameStarted = false;
  bool gameOver = false;
  int score = 0;
  int highScore = 0;
  int coins = 0;
  int combo = 0;

  // Player
  double playerY = 0;
  double velocity = 0;
  PlayerAction currentAction = PlayerAction.running;
  bool canDoubleJump = false;
  bool hasDoubleJumped = false;

  // Game objects
  List<GameObject> gameObjects = [];
  List<Particle> particles = [];
  double gameSpeed = 7.0;
  int frameCount = 0;

  // Background
  List<Building> buildings = [];
  List<CloudObj> clouds = [];
  double parallaxOffset = 0;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _runController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..repeat();

    // Initialize background
    for (int i = 0; i < 4; i++) {
      buildings.add(Building(
        x: i * 200.0,
        height: 100 + _random.nextDouble() * 80,
        width: 120 + _random.nextDouble() * 80,
      ));
    }

    for (int i = 0; i < 5; i++) {
      clouds.add(CloudObj(
        x: _random.nextDouble() * 400,
        y: _random.nextDouble() * 60 + 20,
        speed: 0.15 + _random.nextDouble() * 0.25,
        size: 50 + _random.nextDouble() * 40,
      ));
    }

    // Game loop
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
    _runController.dispose();
    super.dispose();
  }

  void _updateGame() {
    setState(() {
      frameCount++;
      parallaxOffset += gameSpeed * 0.3;

      // Update clouds
      for (var cloud in clouds) {
        cloud.x -= cloud.speed;
        if (cloud.x < -cloud.size * 2) {
          cloud.x = 420;
          cloud.y = _random.nextDouble() * 60 + 20;
        }
      }

      // Update buildings
      for (var building in buildings) {
        building.x -= gameSpeed * 0.5;
        if (building.x < -building.width - 50) {
          building.x = buildings.map((b) => b.x).reduce(max) + 150;
          building.height = 100 + _random.nextDouble() * 80;
          building.width = 120 + _random.nextDouble() * 80;
        }
      }

      // Physics
      if (currentAction == PlayerAction.jumping || playerY < 0) {
        velocity += 1.1; // Gravity
        playerY += velocity;

        if (playerY >= 0) {
          playerY = 0;
          velocity = 0;
          currentAction = PlayerAction.running;
          hasDoubleJumped = false;
          canDoubleJump = false;
          _createLandingParticles();
        }
      }

      // Spawn obstacles
      if (frameCount % (60 + _random.nextInt(50)) == 0) {
        _spawnObstacle();
      }

      // Spawn coins
      if (frameCount % 80 == 0 && _random.nextDouble() > 0.3) {
        gameObjects.add(GameObject(
          x: 420,
          y: -(_random.nextDouble() * 80 + 40),
          type: GameObjectType.coin,
        ));
      }

      // Move objects
      for (var obj in gameObjects) {
        obj.x -= gameSpeed;
        if (obj.type == GameObjectType.coin) {
          obj.rotation += 0.15;
        }
      }

      // Update particles
      for (var particle in particles) {
        particle.update();
      }
      particles.removeWhere((p) => p.lifetime <= 0);

      // Collision & scoring
      gameObjects.removeWhere((obj) {
        if (obj.x < -50) {
          if (!obj.passed && obj.type != GameObjectType.coin) {
            score += 10;
            combo++;
            if (combo > 5) score += combo;
            if (score > highScore) highScore = score;
          }
          return true;
        }

        // Coin collection
        if (obj.type == GameObjectType.coin && !obj.collected) {
          if (_checkCoinCollision(obj)) {
            obj.collected = true;
            coins += 1;
            score += 5;
            _createCoinParticles(obj.x, obj.y);
            return true;
          }
        }

        // Obstacle collision
        if (obj.type != GameObjectType.coin && _checkCollision(obj)) {
          gameOver = true;
          combo = 0;
        }

        return false;
      });

      // Speed increase
      if (score > 0 && score % 100 == 0 && frameCount % 60 == 0) {
        gameSpeed = min(gameSpeed + 0.3, 12.0);
      }
    });
  }

  void _spawnObstacle() {
    int obstacleType = _random.nextInt(100);
    if (obstacleType < 40) {
      gameObjects.add(GameObject(x: 420, y: 0, type: GameObjectType.barrier));
    } else if (obstacleType < 70) {
      gameObjects.add(GameObject(x: 420, y: 0, type: GameObjectType.box));
    } else if (obstacleType < 85) {
      gameObjects.add(GameObject(x: 420, y: -90, type: GameObjectType.drone));
    } else {
      // Double obstacle
      gameObjects.add(GameObject(x: 420, y: 0, type: GameObjectType.barrier));
      gameObjects.add(GameObject(x: 420, y: -90, type: GameObjectType.drone));
    }
  }

  bool _checkCollision(GameObject obj) {
    double playerLeft = 70;
    double playerRight = 105;
    double playerBottom = currentAction == PlayerAction.sliding ? 20 : 0;
    double playerTop = currentAction == PlayerAction.sliding ? -30 : -50;

    double objLeft = obj.x;
    double objRight = obj.x + obj.width;

    if (objRight < playerLeft || objLeft > playerRight) return false;

    if (obj.type == GameObjectType.barrier || obj.type == GameObjectType.box) {
      return playerY + playerBottom >= obj.y - obj.height;
    } else if (obj.type == GameObjectType.drone) {
      double droneBottom = obj.y;
      double droneTop = obj.y - obj.height;
      return playerY + playerTop <= droneTop && playerY + playerBottom >= droneBottom;
    }

    return false;
  }

  bool _checkCoinCollision(GameObject coin) {
    double playerLeft = 70;
    double playerRight = 105;
    double playerTop = currentAction == PlayerAction.sliding ? -30 : -50;
    double playerBottom = 10;

    double coinLeft = coin.x;
    double coinRight = coin.x + 25;
    double coinTop = coin.y - 25;
    double coinBottom = coin.y;

    return !(coinRight < playerLeft ||
        coinLeft > playerRight ||
        coinBottom < playerY + playerTop ||
        coinTop > playerY + playerBottom);
  }

  void _jump() {
    if (currentAction == PlayerAction.running && playerY == 0) {
      setState(() {
        currentAction = PlayerAction.jumping;
        velocity = -18;
        canDoubleJump = true;
        combo++;
      });
      _createJumpParticles();
    } else if (canDoubleJump && !hasDoubleJumped && currentAction == PlayerAction.jumping) {
      setState(() {
        velocity = -16;
        hasDoubleJumped = true;
        canDoubleJump = false;
        combo++;
      });
      _createDoubleJumpParticles();
    }
  }

  void _slide(bool shouldSlide) {
    if (shouldSlide && !gameOver && playerY == 0) {
      setState(() {
        currentAction = PlayerAction.sliding;
        combo++;
      });
    } else if (!shouldSlide && currentAction == PlayerAction.sliding) {
      setState(() {
        currentAction = PlayerAction.running;
      });
    }
  }

  void _createJumpParticles() {
    for (int i = 0; i < 5; i++) {
      particles.add(Particle(
        x: 85 + _random.nextDouble() * 20,
        y: -5,
        vx: -2 - _random.nextDouble() * 3,
        vy: -_random.nextDouble() * 2,
        color: const Color(0xFFB39DDB),
        size: 3 + _random.nextDouble() * 3,
      ));
    }
  }

  void _createDoubleJumpParticles() {
    for (int i = 0; i < 8; i++) {
      particles.add(Particle(
        x: 90,
        y: playerY - 25,
        vx: (_random.nextDouble() - 0.5) * 6,
        vy: (_random.nextDouble() - 0.5) * 6,
        color: const Color(0xFF7E57C2),
        size: 4 + _random.nextDouble() * 4,
      ));
    }
  }

  void _createLandingParticles() {
    for (int i = 0; i < 6; i++) {
      particles.add(Particle(
        x: 85 + _random.nextDouble() * 20,
        y: -2,
        vx: (_random.nextDouble() - 0.5) * 4,
        vy: -_random.nextDouble() * 3,
        color: const Color(0xFF9575CD),
        size: 2 + _random.nextDouble() * 2,
      ));
    }
  }

  void _createCoinParticles(double x, double y) {
    for (int i = 0; i < 10; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 8,
        vy: (_random.nextDouble() - 0.5) * 8,
        color: const Color(0xFFFFC107),
        size: 3 + _random.nextDouble() * 3,
      ));
    }
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      coins = 0;
      playerY = 0;
      velocity = 0;
      currentAction = PlayerAction.running;
      hasDoubleJumped = false;
      canDoubleJump = false;
      gameObjects.clear();
      particles.clear();
      gameSpeed = 7.0;
      frameCount = 0;
      combo = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (!gameStarted) {
            _startGame();
          } else if (gameOver) {
            _startGame();
          } else {
            _jump();
          }
        },
        onLongPressStart: (_) => _slide(true),
        onLongPressEnd: (_) => _slide(false),
        child: Stack(
          children: [
            // Gradient Sky
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5E35B1),
                    const Color(0xFF7E57C2),
                    const Color(0xFF9575CD),
                    const Color(0xFFB39DDB).withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Column(
              children: [
                const AppStatusBar(),
                const SizedBox(height: 25),

                // WiFi Icon & Title
                ScaleTransition(
                  scale: Tween(begin: 0.92, end: 1.08).animate(
                    CurvedAnimation(
                      parent: _iconController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "No Internet Connection",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 20),

                // Game Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF283593)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Sky gradient
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF303F9F),
                                  Color(0xFF3949AB),
                                  Color(0xFF5C6BC0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Stars
                          ...List.generate(15, (i) {
                            return Positioned(
                              top: _random.nextDouble() * 100 + 10,
                              left: _random.nextDouble() * 400,
                              child: Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),

                          // Clouds
                          ...clouds.map((cloud) {
                            return Positioned(
                              top: cloud.y,
                              left: cloud.x,
                              child: CustomPaint(
                                size: Size(cloud.size, cloud.size * 0.5),
                                painter: ModernCloudPainter(),
                              ),
                            );
                          }),

                          // Buildings
                          ...buildings.map((building) {
                            return Positioned(
                              bottom: 70,
                              left: building.x,
                              child: CustomPaint(
                                size: Size(building.width, building.height),
                                painter: BuildingPainter(),
                              ),
                            );
                          }),

                          // Ground platform
                          Positioned(
                            bottom: 65,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7E57C2),
                                    Color(0xFF9575CD),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7E57C2).withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Ground base
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 65,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1A237E), Color(0xFF0D1642)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          // Moving ground pattern
                          if (gameStarted && !gameOver)
                            ...List.generate(25, (i) {
                              double dashX = ((frameCount * gameSpeed * 0.6) % 500) - (i * 20);
                              return Positioned(
                                bottom: 63,
                                left: dashX,
                                child: Container(
                                  width: 10,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9575CD).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              );
                            }),

                          // Particles
                          ...particles.map((particle) {
                            return Positioned(
                              bottom: 65 - particle.y,
                              left: particle.x,
                              child: Container(
                                width: particle.size,
                                height: particle.size,
                                decoration: BoxDecoration(
                                  color: particle.color.withOpacity(particle.opacity),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: particle.color.withOpacity(0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Player
                          Positioned(
                            bottom: 65 - playerY,
                            left: 70,
                            child: AnimatedBuilder(
                              animation: _runController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(
                                    currentAction == PlayerAction.sliding ? 50 : 35,
                                    currentAction == PlayerAction.sliding ? 30 : 50,
                                  ),
                                  painter: RunnerPainter(
                                    action: currentAction,
                                    animValue: _runController.value,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Game Objects
                          ...gameObjects.map((obj) {
                            return Positioned(
                              bottom: 65 - obj.y,
                              left: obj.x,
                              child: _buildGameObject(obj),
                            );
                          }),

                          // HUD - Score
                          Positioned(
                            top: 15,
                            right: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    score.toString().padLeft(5, '0'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Coins
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFC107).withOpacity(0.3),
                                    const Color(0xFFFFB300).withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFFC107).withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFC107),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '◎',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    coins.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFC107),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // High Score
                          if (highScore > 0)
                            Positioned(
                              top: 55,
                              right: 15,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  'Best: ${highScore.toString()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          // Combo indicator
                          if (combo > 3 && !gameOver)
                            Positioned(
                              top: 100,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6F00), Color(0xFFFF9800)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF6F00).withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${combo}x COMBO!',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Game Over / Start Overlay
                          if (!gameStarted || gameOver)
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withOpacity(0.92),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.15),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: gameOver
                                                ? [const Color(0xFFE53935), const Color(0xFFD32F2F)]
                                                : [const Color(0xFF7E57C2), const Color(0xFF9575CD)],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: (gameOver ? Colors.red : const Color(0xFF7E57C2))
                                                  .withOpacity(0.4),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          gameOver ? Icons.sports_esports_outlined : Icons.play_arrow_rounded,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        gameOver ? "GAME OVER" : "PARKOUR RUNNER",
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (gameOver) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star, color: Color(0xFFFFC107), size: 20),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Score: $score',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text('◎', style: TextStyle(color: Color(0xFFFFC107), fontSize: 18)),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Coins: $coins',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFFFFC107),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          gameOver ? "TAP TO RESTART" : "TAP TO START",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Tap: Jump (Double Jump) • Hold: Slide",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.6),
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

                // Retry Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5E35B1),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                    label: const Text(
                      "Retry Connection",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameObject(GameObject obj) {
    switch (obj.type) {
      case GameObjectType.barrier:
        return CustomPaint(
          size: Size(obj.width, obj.height),
          painter: BarrierPainter(),
        );
      case GameObjectType.box:
        return CustomPaint(
          size: Size(obj.width, obj.height),
          painter: BoxPainter(),
        );
      case GameObjectType.drone:
        return CustomPaint(
          size: Size(obj.width, obj.height),
          painter: DronePainter(),
        );
      case GameObjectType.coin:
        return Transform.rotate(
          angle: obj.rotation,
          child: CustomPaint(
            size: const Size(25, 25),
            painter: CoinPainter(),
          ),
        );
    }
  }
}

// Game Objects
enum GameObjectType { barrier, box, drone, coin }

class GameObject {
  double x;
  double y;
  GameObjectType type;
  bool passed = false;
  bool collected = false;
  double rotation = 0;

  double get width {
    switch (type) {
      case GameObjectType.barrier:
        return 15;
      case GameObjectType.box:
        return 35;
      case GameObjectType.drone:
        return 45;
      case GameObjectType.coin:
        return 25;
    }
  }

  double get height {
    switch (type) {
      case GameObjectType.barrier:
        return 40;
      case GameObjectType.box:
        return 35;
      case GameObjectType.drone:
        return 25;
      case GameObjectType.coin:
        return 25;
    }
  }

  GameObject({required this.x, required this.y, required this.type});
}

// Particle System
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  int lifetime = 30;
  double opacity = 1.0;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.3; // Gravity
    lifetime--;
    opacity = lifetime / 30.0;
  }
}

// Background Objects
class Building {
  double x;
  double height;
  double width;

  Building({required this.x, required this.height, required this.width});
}

class CloudObj {
  double x;
  double y;
  double speed;
  double size;

  CloudObj({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}

// Custom Painters
class RunnerPainter extends CustomPainter {
  final PlayerAction action;
  final double animValue;

  RunnerPainter({required this.action, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyGradient = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final accentPaint = Paint()
      ..color = const Color(0xFFB39DDB)
      ..style = PaintingStyle.fill;

    if (action == PlayerAction.sliding) {
      // Sliding pose
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(5, size.height - 20, 40, 18),
          const Radius.circular(4),
        ),
        bodyGradient,
      );
      // Head
      canvas.drawCircle(Offset(size.width - 8, size.height - 10), 8, bodyGradient);
      canvas.drawCircle(Offset(size.width - 5, size.height - 12), 2, Paint()..color = Colors.white);
    } else {
      // Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(8, 15, 20, 28),
          const Radius.circular(5),
        ),
        bodyGradient,
      );

      // Head
      canvas.drawCircle(const Offset(18, 10), 10, bodyGradient);
      // Eye
      canvas.drawCircle(const Offset(22, 8), 2.5, Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(23, 7.5), 1.5, Paint()..color = const Color(0xFF1A237E));

      // Arms
      double armSwing = sin(animValue * 2 * pi) * 5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(6, 20 + armSwing, 4, 15),
          const Radius.circular(2),
        ),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(22, 20 - armSwing, 4, 15),
          const Radius.circular(2),
        ),
        accentPaint,
      );

      // Legs with running animation
      double legSwing = sin(animValue * 2 * pi) * 8;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(10, 43 + legSwing, 5, 7),
          const Radius.circular(2),
        ),
        bodyGradient,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(17, 43 - legSwing, 5, 7),
          const Radius.circular(2),
        ),
        bodyGradient,
      );
    }
  }

  @override
  bool shouldRepaint(RunnerPainter oldDelegate) =>
      animValue != oldDelegate.animValue || action != oldDelegate.action;
}

class BarrierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFC62828)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final stripePaint = Paint()
      ..color = const Color(0xFFFDD835)
      ..style = PaintingStyle.fill;

    // Main barrier
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(3),
      ),
      paint,
    );

    // Warning stripes
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(2, i * 15.0, size.width - 4, 5),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final highlightPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    // Box body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(4),
      ),
      paint,
    );

    // Highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, 8, size.height - 6),
        const Radius.circular(2),
      ),
      highlightPaint,
    );

    // Details
    canvas.drawLine(
      Offset(size.width / 2, 5),
      Offset(size.width / 2, size.height - 5),
      Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DronePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.fill;

    final propellerPaint = Paint()
      ..color = const Color(0xFF607D8B)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFF00BCD4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, size.height * 0.3, size.width * 0.4, size.height * 0.4),
        const Radius.circular(3),
      ),
      bodyPaint,
    );

    // Propellers
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 8, propellerPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 8, propellerPaint);

    // Glow light
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 3, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFC107), Color(0xFFFF9800), Color(0xFFF57C00)],
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));

    final innerPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    // Outer circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    // Inner circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 3, innerPaint);

    // Symbol
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '◎',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFFFF9800),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - 7, size.height / 2 - 9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ModernCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), size.height * 0.5, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.height * 0.6, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), size.height * 0.5, paint);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.6, size.width * 0.4, size.height * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A237E).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = const Color(0xFFFFC107).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Building body
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Windows
    for (int row = 0; row < (size.height / 20).floor(); row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            col * (size.width / 4) + 8,
            row * 20.0 + 5,
            8,
            10,
          ),
          windowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}