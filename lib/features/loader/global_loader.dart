import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loader_provider.dart';

class GlobalImageLoader extends StatelessWidget {
  const GlobalImageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final loader = context.watch<LoaderProvider>();

    if (!loader.isLoading) return const SizedBox.shrink();

    return Container(
      color: Colors.black45,
      child: Center(
        child: Image.asset(
          'assets/images/trust_tags.png', // your loader image
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
