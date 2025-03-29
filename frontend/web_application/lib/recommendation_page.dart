import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_model.dart';
import 'questionnaire_page.dart';
import 'main.dart';


class ProductPair {
  final SkincareProduct primary;
  final SkincareProduct? alternate;

  ProductPair({required this.primary, this.alternate});
}

class RecommendationPage extends StatelessWidget {
  final List<SkincareProduct> primaryProducts;
  final List<SkincareProduct> alternateProducts;

  const RecommendationPage({
    Key? key,
    required this.primaryProducts,
    required this.alternateProducts,
=======
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_model.dart';

class RecommendationPage extends StatelessWidget {
  final List<SkincareProduct> routineProducts;

  const RecommendationPage({
    Key? key,
    required this.routineProducts,
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    
    Map<String, SkincareProduct> alternateMap = {};
    for (var product in alternateProducts) {
      alternateMap[product.category] = product;
    }
    
    List<ProductPair> productPairs = primaryProducts.map((primary) {
      return ProductPair(
        primary: primary,
        alternate: alternateMap[primary.category],
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.teal.shade600,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: const Text('SkinGenie',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            tooltip: "Go to Home",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.assignment),
            tooltip: "Go to Questionnaire",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => QuestionnairePage()),
              );
            },
          ),
        ],
      ),
    
      body: Column(
        children: [
          _buildHeader(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.teal.shade600.withOpacity(0.9),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red.shade700, size: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 6, 6, 6)
                            .withOpacity(0.95),
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(
                            text: "Important: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                                "Recommendations are based on ingredient analysis. "
                                "Individual results may vary. Consult a dermatologist if "
                                "you experience any adverse reactions."),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: productPairs.length,
              itemBuilder: (context, index) {
                return FlipProductCard(productPair: productPairs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curated just for your skin needs',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}



class FlipProductCard extends StatefulWidget {
  final ProductPair productPair;
  const FlipProductCard({Key? key, required this.productPair}) : super(key: key);

  @override
  _FlipProductCardState createState() => _FlipProductCardState();
}

class _FlipProductCardState extends State<FlipProductCard> {
  bool _showAlternate = false;

  void _toggleCard() {
    if (widget.productPair.alternate != null) {
      setState(() {
        _showAlternate = !_showAlternate;
      });
    }
  }

  String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }


  @override
  Widget build(BuildContext context) {
    SkincareProduct product = _showAlternate && widget.productPair.alternate != null
        ? widget.productPair.alternate!
        : widget.productPair.primary;

    return Stack(
      children: [
        Card(
          color: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevents overflow issues
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Image
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Brand Name
                Text(
                  toTitleCase(product.brand),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),

                // Product Name
                Text(
                  toTitleCase(product.name),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 8),

                // Category
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),

                // Rating with Star Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      product.rating?.toStringAsFixed(1) ?? 'N/A',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  "\£${product.price?.toStringAsFixed(2) ?? 'N/A'}",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade400),
                ),
                const SizedBox(height: 12),

                // "Buy Now" Button
                ElevatedButton(
                  onPressed: () async {
                    final url = product.productUrl ?? 'https://www.sephora.com';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Find Product", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Small Button at the Top Right for Switching Products
        if (widget.productPair.alternate != null) 
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: _toggleCard,
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
              tooltip: _showAlternate ? "Show Main Product" : "Show Alternate",
              color: Colors.blueAccent,
              iconSize: 28,
            ),
          ),
      ],
    );
  }
}
=======
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
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
