class SkincareProduct {
  final String brand;
  final String name;
  final String category;
  final double? price;
  final double? rating;
  final String? imageUrl;
  final String? productUrl;

  SkincareProduct({
    required this.brand,
    required this.name,
    required this.category,
    this.price,
    this.rating,
    this.imageUrl,
    this.productUrl,
  });

  factory SkincareProduct.fromJson(Map<String, dynamic> json) {
    return SkincareProduct(
      brand: json['Brand'],
      name: json['Name'] as String? ?? 'Unknown Product',
      category: json['Category'] as String? ?? 'Uncategorized',
      price: (json['Price'] as num?)?.toDouble(),
      rating: (json['Rating'] as num?)?.toDouble(),
      imageUrl: json['Image URL'] as String?,
      productUrl: json['Product URL'] as String?,
    );
  }

  String get fullName => '$brand $name';
}