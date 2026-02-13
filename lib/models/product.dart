import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double basePrice;
  final int stock;
  final String category;
  final List<String> imageUrls; // Stores all uploaded images

  // SHORTCUT: Safely extracts exactly ONE image as a String for the Grid
  String? get mainImage => imageUrls.isNotEmpty ? imageUrls.first : null;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.stock,
    required this.category,
    required this.imageUrls,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Safely parse price
    double price = 0.0;
    if (json['base_price'] != null) {
      price = double.tryParse(json['base_price'].toString()) ?? 0.0;
    }

    List<String> images = [];
    int stok = 0;

    // Dig into variants
    if (json['product_variants'] != null && (json['product_variants'] as List).isNotEmpty) {
      final firstVariant = json['product_variants'][0];
      stok = firstVariant['stock_quantity'] ?? 0;

      // STRICT PARSING: Forces the JSON array into a clean Dart List of Strings
      if (firstVariant['images'] != null && firstVariant['images'] is List) {
        images = (firstVariant['images'] as List).map((item) => item.toString()).toList();
      }
    }

    if (kDebugMode) {
      print("Parsed Product ID: ${json['id']} -> Images Count: ${images.length}");
    }

    return Product(
      id: json['id'],
      title: json['title'] ?? 'Unknown Item',
      description: json['description'] ?? '',
      basePrice: price,
      stock: stok,
      category: json['category'] ?? 'General',
      imageUrls: images,
    );
  }
}