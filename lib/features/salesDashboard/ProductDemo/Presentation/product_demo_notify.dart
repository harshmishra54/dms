import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:flutter/material.dart';

class ProductDemoScreen extends StatefulWidget {
  const ProductDemoScreen({super.key});

  @override
  State<ProductDemoScreen> createState() => _ProductDemoScreenState();
}

class _ProductDemoScreenState extends State<ProductDemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
        children: [
          const AppStatusBar(),
          Material(
            elevation: 2,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [],
              ),
            ),
          )
        ],
      ),
    );
  }
}
