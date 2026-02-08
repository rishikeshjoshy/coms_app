class Product {
  final int id;
  final String title;
  final String description;
  final double basePrice;
  final String category;
  final String? imageUrl; // We will fill this from the variant
  final int stock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.category,
    this.imageUrl,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // 1. Dig for the Image
    String? foundImage;
    int totalStock = 0;

    // Check if 'product_variants' exists and is a list
    if (json['product_variants'] != null) {
      var variants = json['product_variants'] as List;

      if (variants.isNotEmpty) {
        // Take the first variant as the "Main" display
        var firstVar = variants[0];

        // Get Stock
        totalStock = firstVar['stock_quantity'] ?? 0;

        // Get Image: Check if 'images' array exists inside the variant
        if (firstVar['images'] != null) {
          var imgs = firstVar['images'] as List;
          if (imgs.isNotEmpty) {
            foundImage = imgs[0]; // Grab the first URL
          }
        }
      }
    }

    return Product(
      id: json['id'],
      title: json['title'] ?? 'Unknown Saree',
      description: json['description'] ?? '',
      // Safe Double Parsing (handles '12500' string or 12500 int)
      basePrice: double.tryParse(json['base_price'].toString()) ?? 0.0,
      category: json['category'] ?? 'General',
      imageUrl: foundImage, // <--- The Found URL
      stock: totalStock,
    );
  }
}