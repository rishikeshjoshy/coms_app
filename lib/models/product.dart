class Product
{
  final int id;
  final String title;
  final String description;
  final double basePrice;
  final String category;
  final String? imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.category,
    this.imageUrl,
    required this.stock,
    }
  );

// Factory constructore to create a product from JSON
factory Product.fromJson(Map<String , dynamic> json) {
  // Handle the nested variants array to get image and stock
  String? img;
  int qty = 0;

  // Checks if the product variants array exists and has variants of sarees
  if (json['product_variants'] != null &&
      (json['product_variants'] as List).isNotEmpty) {
    final variant = json['product_variants'][0];

    // Checks if the image array exists and is not empty
    if (variant['images'] != null && (variant['images'] as List).isNotEmpty) {
      img = variant['images'][0];
    }
    qty = variant['stock_quantity'] ?? 0;
  }

    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      // Safely parse price (Backend might send string or number)
      basePrice: double.parse(json['base_price'].toString()),
      category: json['category'] ?? 'General',
      imageUrl: img,
      stock: qty,
    );
  }
}