class Order {
  final int id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final String paymentMethod;
  final String status;
  final double totalAmount;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['order_items'] as List? ?? [];
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'],
      customerName: json['customer_name']?.toString() ?? 'Guest',
      customerEmail: json['customer_email']?.toString() ?? 'N/A',
      customerPhone: json['customer_phone']?.toString() ?? 'N/A',
      shippingAddress: json['shipping_address']?.toString() ?? 'N/A',
      paymentMethod: json['payment_method']?.toString() ?? 'COD',
      status: json['status']?.toString() ?? 'Pending',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      items: itemsList,
    );
  }

  void operator [](String other) {}
}

class OrderItem {
  final String productName;
  final String colorName; // Added to show Saree color!
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.colorName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name']?.toString() ?? 'Unknown Item',
      colorName: json['color_name']?.toString() ?? 'Standard',
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      price: double.tryParse(json['price_at_purchase'].toString()) ?? 0.0,
    );
  }
}