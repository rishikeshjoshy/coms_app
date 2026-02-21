import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  // Action: Mark as Shipped
  Future<void> _markAsShipped() async {
    setState(() => _isLoading = true);

    // Fixed typo here to match our ApiService method
    final success = await _apiService.updateOrderStatus(widget.order.id, 'Shipped');

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _currentStatus = 'Shipped');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order marked as Shipped!"), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update status"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isShipped = _currentStatus.toLowerCase() == 'shipped';

    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${widget.order.id}"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isShipped ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isShipped ? Colors.green : Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(
                    isShipped ? Icons.check_circle : Icons.schedule,
                    color: isShipped ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Status: $_currentStatus",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isShipped ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Customer Details
            const Text("Customer Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.person, widget.order.customerName),
                    const Divider(),
                    // REPLACED PLACEHOLDER WITH DYNAMIC PHONE DATA
                    _buildDetailRow(Icons.phone, widget.order.customerPhone),
                    const Divider(),
                    // REPLACED PLACEHOLDER WITH DYNAMIC EMAIL DATA
                    _buildDetailRow(Icons.email, widget.order.customerEmail),
                    const Divider(),
                    // REPLACED PLACEHOLDER WITH DYNAMIC ADDRESS DATA
                    _buildDetailRow(Icons.location_on, widget.order.shippingAddress),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Order Items
            const Text("Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.items.length,
              itemBuilder: (context, index) {
                final item = widget.order.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.shopping_bag, color: Colors.grey),
                    ),
                    title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    // ADDED COLOR DETAILS TO THE SUBTITLE
                    subtitle: Text("Color: ${item.colorName}  |  Qty: ${item.quantity}"),
                    trailing: Text(
                      currencyFormat.format(item.price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // 4. Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  currencyFormat.format(widget.order.totalAmount),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),

      // 5. The "Ship It" Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 55,
        child: FloatingActionButton.extended(
          onPressed: (_isLoading || isShipped) ? null : _markAsShipped,
          backgroundColor: isShipped ? Colors.green : Colors.black, // Sleek black to match app theme
          elevation: isShipped ? 0 : 6,
          icon: Icon(
            isShipped ? Icons.check_circle : Icons.local_shipping,
            color: Colors.white,
            size: 28,
          ),
          label: _isLoading
              ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
            isShipped ? "SHIPPED" : "MARK AS SHIPPED",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.3)),
        ),
      ],
    );
  }
}