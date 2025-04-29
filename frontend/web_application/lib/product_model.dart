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
      productUrl: json['URL'] as String?,
    );
  }

  //Converting products to JSON
  Map<String, dynamic> toJson() {
    return {
      "brand": brand,
      "name": name,
      "category": category,
      "price": price,
      "rating": rating,
      "imageUrl": imageUrl,
      "productUrl": productUrl,
    };
  }

  String get fullName => '$brand $name';
}