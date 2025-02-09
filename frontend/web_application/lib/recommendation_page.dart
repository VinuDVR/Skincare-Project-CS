import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_model.dart';

class RecommendationPage extends StatelessWidget {
  final List<SkincareProduct> routineProducts;

  const RecommendationPage({
    Key? key,
    required this.routineProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Skincare Routine'),
        backgroundColor: Colors.green.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Custom Skincare Routine:', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: routineProducts.length,
                itemBuilder: (context, index) {
                  final product = routineProducts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                          Image.network(
                            product.imageUrl!,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.error_outline, size: 100),
                          ),
                        ListTile(
                          title: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                  text: product.brand,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${product.name}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category: ${product.category}'),
                              Text('Price: \$${product.price?.toStringAsFixed(2) ?? 'N/A'}'),
                              Text('Rating: ${product.rating?.toStringAsFixed(1) ?? 'N/A'}/5'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Buy Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade300,
                            ),
                            onPressed: () async {
                              final url = product.productUrl ?? 'https://www.sephora.com';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}