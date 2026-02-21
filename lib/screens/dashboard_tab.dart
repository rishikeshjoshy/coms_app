import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import '../models/product.dart'; // Make sure to import your Product model!

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ApiService _apiService = ApiService();

  // We upgraded this to hold a List of dynamic data so we can store multiple futures
  late Future<List<dynamic>> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _fetchEverything();
  }

  // Fetch both stats and products at the EXACT SAME TIME for speed
  Future<List<dynamic>> _fetchEverything() async {
    return Future.wait([
      _apiService.fetchhStats(),     // Index 0: Returns Map<String, dynamic>
      _apiService.fetchProducts(),   // Index 1: Returns List<Product>
    ]);
  }

  // Pull-to-Refresh Logic
  Future<void> _refreshStats() async {
    setState(() {
      _dashboardDataFuture = _fetchEverything();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                /// HEADER
                const Text(
                  "Overview",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Here is how Maiee is performing today!",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                /// API BUILDER
                FutureBuilder<List<dynamic>>(
                  future: _dashboardDataFuture,
                  builder: (context, snapshot) {
                    // 1. LOADING
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Colors.black),
                        ),
                      );
                    }

                    // 2. ERROR HANDLER
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Connection Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    // 3. EXTRACT THE PARALLEL DATA
                    // Safety check to ensure we have data, otherwise default to empty
                    final List<dynamic> results = snapshot.data ?? [{}, []];

                    // Index 0 is our fetchhStats() result
                    final rawStatsData = results[0] as Map<String, dynamic>? ?? {};
                    final data = rawStatsData['stats'] ?? {};

                    // Index 1 is our fetchProducts() result
                    final productsList = results[1] as List<Product>? ?? [];
                    final activeProductsCount = productsList.length;

                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // 1. REVENUE CARD
                        StatCard(
                          title: "Total Revenue",
                          value: currencyFormat.format(data['total_revenue'] ?? 0),
                          icon: Icons.currency_rupee_rounded,
                          color: Colors.green,
                        ),

                        // 2. ORDERS CARD
                        StatCard(
                          title: "Total Orders",
                          value: "${data['total_orders'] ?? 0}",
                          icon: Icons.add_shopping_cart_rounded,
                          color: Colors.lightBlue,
                        ),

                        // 3. PENDING CARD
                        StatCard(
                          title: "Pending",
                          value: "${data['pending_orders'] ?? 0}",
                          icon: Icons.access_time_filled,
                          color: Colors.orange,
                        ),

                        // 4. INVENTORY CARD (Now 100% Live!)
                        StatCard(
                          title: "Products",
                          value: "$activeProductsCount", // <-- REPLACED "ACTIVE"
                          icon: Icons.inventory,
                          color: Colors.purple,
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}