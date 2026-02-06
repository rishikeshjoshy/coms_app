import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/api_service.dart';
// Add this to pubspec if missing, or use ScaffoldMessenger

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

    final success = await _apiService.updateORderStatus(widget.order.id, 'Shipped');

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _currentStatus = 'Shipped');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order marked as Shipped!"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isShipped = _currentStatus.toLowerCase() == 'shipped';

    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${widget.order.id}"),
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
                    // Ideally, pass phone/address in the Order model if available
                    _buildDetailRow(Icons.phone, "+91 98765 43210"), // Placeholder
                    const Divider(),
                    _buildDetailRow(Icons.location_on, "Flat 402, Saoner, Maharashtra, 441107"), // Placeholder
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
                      child: const Icon(Icons.image, color: Colors.grey), // Placeholder for Saree Image
                    ),
                    title: Text(item.productName),
                    subtitle: Text("Qty: ${item.quantity}"),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
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
          // Logic: If loading or already shipped, disable the click (null)
          onPressed: (_isLoading || isShipped) ? null : _markAsShipped,

          // Style: Green if Shipped, Red/BrandColor if Pending
          backgroundColor: isShipped ? Colors.green : Theme.of(context).primaryColor,
          elevation: isShipped ? 0 : 6, // Flat look if completed

          // Icon: Tick if Shipped, Truck if Pending
          icon: Icon(
            isShipped ? Icons.check_circle : Icons.local_shipping,
            color: Colors.white,
            size: 28,
          ),

          // Text: "SHIPPED" vs "MARK AS SHIPPED"
          label: _isLoading
              ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
          )
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
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}