// lib/models/order.dart
class Order {
  final int id;
  final String customerName;
  final String status;
  final double totalAmount;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
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
      customerName: json['customer_name']?.toString() ?? 'Guest', // Safety
      status: json['status']?.toString() ?? 'Pending', // Safety
      // The Magic Fix: toString() before parsing handles Int/Double/String automatically
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      items: itemsList,
    );
  }
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name']?.toString() ?? 'Unknown Item',
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      price: double.tryParse(json['price_at_purchase'].toString()) ?? 0.0,
    );
  }
}