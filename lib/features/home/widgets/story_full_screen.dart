import 'package:flutter/material.dart';

class StoryFullScreen extends StatelessWidget {
  final String imageUrl;

  const StoryFullScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 100, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
