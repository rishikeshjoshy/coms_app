// lib/screens/orders_tab.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import '../widgets/order_tile.dart';
import 'order_detail_screen.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final ApiService _apiService = ApiService();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _apiService.fetchOrder();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _apiService.fetchOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Orders")),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: FutureBuilder<List<Order>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No orders found"));
            }

            final orders = snapshot.data!;
            // Sort Newest First
            orders.sort((a, b) => b.id.compareTo(a.id));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderTile(
                  order: order,
                  onTap: () {
                    // Navigate to Detail Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    ).then((_) => _refreshOrders());
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}