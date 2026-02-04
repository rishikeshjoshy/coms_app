class Order {
  final int id;
  final String customerName;
  final String status;
  final double totalAmount;
  final String createdAt;
  final List<OrderItem> items;

  Order ({
    required this.id,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,

});
  factory Order.fromJson(Map<String , dynamic> json){
    var list = json['order_items'] as List ?? [];
    List <OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    return Order (
      id : json['id'],
      customerName : json['customer_details'] is Map
        ? json['customer_details']['name'] ?? 'Guest'
        : 'Guest Customer',
      status : json['status'],
      totalAmount : double.parse(json['total_amount'].toString()),
      createdAt : json['created_at'],
      items : itemsList,
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
    required this.price
  });

  factory OrderItem.fromJson(Map<String , dynamic> json) {
    return OrderItem(
        productName: json['products'] ? ['title'] ?? 'Unknown Item',
        quantity: json['quantity'],
        price: double.parse(json['price_at_purchase'].toString()),
    );
  }
}