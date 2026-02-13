import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  // Use the class instance, don't create a new one every time
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = _apiService.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saree Inventory"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Wait for the Add Screen to close, then refresh
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
          _loadProducts();
        },
        label: const Text("Add Saree"),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.black,
        // Sleek look
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadProducts(),
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            // 1. LOADING
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. ERROR
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                      "Error: ${snapshot.error}", textAlign: TextAlign.center),
                ),
              );
            }

            // 3. EMPTY STATE (Fixed Logic)
            // Use 'isEmpty' to check if list has 0 items
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 60,
                        color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text("No products found.\nTap '+ Add Saree' to start!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            // 4. DATA LIST
            final products = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70, // Taller cards for better image view
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) { // Corrected 'length' to 'index'
                final product = products[index];
                return _buildProductCard(product, currencyFormat);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, NumberFormat format) {
    return Card(
      key: ValueKey(product.id),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack( // Wrap everything in a Stack to position the Edit Button
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IMAGE SECTION
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  // Use 'mainImage', which hands us a clean, single String URL
                  child: product.mainImage != null
                      ? Image.network(
                    product.mainImage!, // <-- The ! says "trust me, it's a string"
                    fit: BoxFit.fitHeight,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                  )
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),

              // 2. DETAILS SECTION
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- NEW: PRODUCT ID ---
                    Text(
                      "ID: #${product.id}",
                      style: TextStyle(fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      format.format(product.basePrice),
                      style: const TextStyle(color: Color(0xFF800020),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Stock: ${product.stock}",
                          style: TextStyle(fontSize: 12,
                              color: product.stock < 5 ? Colors.red : Colors
                                  .grey[800],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),

          // --- NEW: EDIT BUTTON OVERLAY ---
          Positioned(
            top: 5,
            right: 5,
            child: Material(
              color: Colors.white.withOpacity(0.9),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () async {
                  // Navigate to Edit Screen
                  final didUpdate = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        EditProductScreen(product: product)),
                  );
                  // Refresh grid if changes were saved
                  if (didUpdate == true) {
                    _loadProducts();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.edit, size: 18, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}