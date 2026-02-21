import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/order.dart'; // Make sure this is imported!
import 'order_detail_screen.dart'; // Make sure this path is correct!

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _stats;

  // --- SEARCH STATE VARIABLES ---
  List<Order> _allOrders = [];      // Holds everything from the database
  List<Order> _filteredOrders = []; // Holds what is currently searched
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final statsFuture = _apiService.fetchOrderStats();
    final ordersFuture = _apiService.fetchAllOrders();

    final results = await Future.wait([statsFuture, ordersFuture]);

    if (mounted) {
      setState(() {
        _stats = results[0] as Map<String, dynamic>?;
        _allOrders = results[1] as List<Order>;
        _filteredOrders = _allOrders; // On load, show all orders
        _searchController.clear();    // Reset search bar on refresh
        _isLoading = false;
      });
    }
  }

  // --- THE SEARCH LOGIC ---
  void _runFilter(String enteredKeyword) {
    List<Order> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allOrders; // If search is empty, show everything
    } else {
      results = _allOrders.where((order) =>
      // Search by Customer Name (case-insensitive)
      order.customerName.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          // OR Search by Phone Number
          order.customerPhone.contains(enteredKeyword)
      ).toList();
    }

    setState(() {
      _filteredOrders = results;
    });
  }

  Future<void> _updateStatus(int orderId, String currentStatus) async {
    String newStatus = currentStatus == 'Pending' ? 'Shipped' : 'Pending';

    final success = await _apiService.updateOrderStatus(orderId, newStatus);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order marked as $newStatus! 🚀"), backgroundColor: Colors.green),
        );
      }
      _loadData(); // Refresh the dashboard to get new stats and status
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

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Command Center", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.black,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. STATS DASHBOARD ---
              if (_stats != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black, // Brutally minimal solid black
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Revenue", style: TextStyle(color: Colors.grey, fontSize: 13, letterSpacing: 1.2)),
                          const SizedBox(height: 5),
                          Text(
                            currencyFormat.format(_stats!['total_revenue'] ?? 0),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Pending: ${_stats!['pending_orders'] ?? 0}", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Shipped: ${_stats!['shipping_orders'] ?? 0}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // --- 2. CLASSY MINIMAL SEARCH BAR ---
              TextField(
                controller: _searchController,
                onChanged: (value) => _runFilter(value),
                cursorColor: Colors.black,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "Search name or phone...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 22),
                  // Clear button appears only when there's text
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _runFilter(''); // Reset list
                      FocusScope.of(context).unfocus(); // Close keyboard
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100, // Very subtle flat grey
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // Invisible border by default
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5), // Crisp black border when typing
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. ORDERS LIST ---
              if (_filteredOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      _searchController.text.isEmpty
                          ? "No orders yet."
                          : "No orders found matching '${_searchController.text}'",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredOrders.length, // Uses filtered list
                  itemBuilder: (context, index) {
                    final Order order = _filteredOrders[index]; // Uses filtered list

                    final normalizedStatus = order.status.trim().toLowerCase();
                    final isShipped = normalizedStatus == 'shipped';
                    final itemNames = order.items.map((i) => i.productName).join(', ');

                    return Card(
                      elevation: 0, // Minimalist flat card
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isShipped ? Colors.green.shade300 : Colors.orange.shade300, width: 1.5),
                      ),
                      child: ListTile(
                        onTap: () {
                          // Close keyboard when navigating
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(order: order),
                            ),
                          ).then((_) => _loadData());
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(itemNames, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            const SizedBox(height: 8),
                            Text(currencyFormat.format(order.totalAmount), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _updateStatus(order.id, order.status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isShipped ? Colors.green : Colors.black, // Sleek black for pending
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(isShipped ? "SHIPPED ✔" : "SHIP IT", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}