import 'package:flutter/foundation.dart'; // For debugPrint

class Product {
  final int id;
  final String title;
  final String description;
  final double basePrice;
  final int stock;
  final String category;
  final String? imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.stock,
    required this.category,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // 1. SAFE PRICE PARSING
    double price = 0.0;
    if (json['base_price'] != null) {
      price = double.tryParse(json['base_price'].toString()) ?? 0.0;
    }

    // 2. STRICT IMAGE EXTRACTION
    // We look for 'product_variants'. If it's missing, this product has NO image.
    String? img;
    int stok = 0;

    if (json['product_variants'] != null && (json['product_variants'] as List).isNotEmpty) {
      final firstVariant = json['product_variants'][0];

      // Stock
      stok = firstVariant['stock_quantity'] ?? 0;

      // Image: We only take the image if it exists INSIDE this specific variant
      if (firstVariant['images'] != null && (firstVariant['images'] as List).isNotEmpty) {
        img = firstVariant['images'][0];
      }
    }

    // 3. DEBUG LOG (Check your "Run" tab to see this!)
    // This proves the ID matches the Image.
    if (kDebugMode) {
      print("Parsed Product ID: ${json['id']} -> Image: $img");
    }

    return Product(
      id: json['id'],
      title: json['title'] ?? 'Unknown Item',
      description: json['description'] ?? '',
      basePrice: price,
      stock: stok,
      category: json['category'] ?? 'General',
      imageUrl: img,
    );
  }
}