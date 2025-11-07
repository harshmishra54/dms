import 'package:TrustTags_DMS/common/provider/product_catalogue_provider.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductCatalogueScreen extends StatefulWidget {
  const ProductCatalogueScreen({super.key});

  @override
  State<ProductCatalogueScreen> createState() => _ProductCatalogueScreenState();
}

class _ProductCatalogueScreenState extends State<ProductCatalogueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCatalogueProvider>().fetchProductCatalogue();
    });
  }

  Future<void> _openProductUrl(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No product URL available")),
      );
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: const Center(
              child: AutoTranslateText(
                "Product Catalogue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          /// 🧩 Product Grid
          Expanded(
            child: Consumer<ProductCatalogueProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return const Center(
                    child: AutoTranslateText(
                      'No products found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchProductCatalogue(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.products.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final product = provider.products[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openProductUrl(product.productUrl),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 7,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Image.network(
                                    product.mainImage,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image,
                                        size: 60),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: AutoTranslateText(
                                          product.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "MRP: ₹${product.mrp}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
