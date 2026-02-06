import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ApiService _apiService = ApiService();
  late Future<Map<String , dynamic>> _statsFuture;


  @override
  void initState() {
    super.initState();
    _statsFuture = _apiService.fetchhStats();
  }

  // Pull-to-Refresh Logic
  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _apiService.fetchhStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN' , symbol: '₹');

    
    return RefreshIndicator(
        onRefresh: _refreshStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50,),
                /// HEADER
                const Text(
                    "Overview",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
                ),
                const SizedBox(height: 6,),
                Text(
                  "Here is how Maiee is performing today!",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20,),

                /// API BUILDER
                FutureBuilder<Map<String , dynamic>>(
                    future: _statsFuture,
                    builder: (context , snapshot){
                      if (snapshot.connectionState ==  ConnectionState.waiting) {
                        return Center(
                          child: Text("Please Wait! Data is getting loaded.",
                          style: TextStyle(color: Colors.green),)
                        );
                      } else if (!snapshot.hasData){
                        return const Center(
                            child: Text(
                              "No data available",
                        style: TextStyle(
                            color: Colors.red
                        ),
                            )
                        );
                      }

                      final data = snapshot.data!['data']; // This will access the Data key from backend json

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
                              value: "${data['total_orders'] ?? 0 }",
                              icon: Icons.add_shopping_cart_rounded,
                              color: Colors.lightBlue,
                          ),

                          // 3. PENDING CARD
                          StatCard(
                              title: "Pending",
                              value: "${data['pending_orders'] ?? 0 }",
                              icon: Icons.access_time_filled,
                              color: Colors.orange,
                          ),

                          // 4. Inventory (Placeholder for now --- > In-process)
                          const StatCard(
                              title: "Products",
                              value: "ACTIVE",
                              icon: Icons.inventory,
                              color: Colors.purple,
                          ),
                        ],
                      );
                    })
              ],
            ),
          ),
        )
    );
  }
}
