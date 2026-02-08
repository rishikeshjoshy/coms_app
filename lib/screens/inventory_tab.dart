import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../screens/add_product_screen.dart';
import '../main.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {

  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;


  @override
  void initState() {
    super.initState();
    _productsFuture = ApiService().fetchProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = ApiService().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN' , symbol: '₹');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saree Inventory"),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => const AddProductScreen()),
            ).then((_) => _refreshProducts());
          },
          label: const Text("Add Saree"),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
          onRefresh: _refreshProducts,
          child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context , snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if(snapshot.hasError){
                  return Center(
                    child: Text("Error: ${snapshot.error})"
                    ),
                  );
                } else if(!snapshot.hasData || snapshot.data!.isNotEmpty){
                  return const Center(
                    child: Text("No products added yet."),
                  );
                }

                final products = snapshot.data! ;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12
                    ),
                    itemCount: products.length,
                    itemBuilder: (context,length) {
                      final product = products[length];
                      return _buildProductCard(product , currencyFormat);
                    }
                );
              }
          )),
    );
  }
}

Widget _buildProductCard( Product product, NumberFormat format ){
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12)
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Image
        Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: product.imageUrl != null ? Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Icon(Icons.broken_image , color: Colors.grey,),
              )
                  : const Icon(Icons.image,  color: Colors.grey)
            ),
        ),

        // 2. The Details
        Padding(
            padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
              const SizedBox(height: 5,),
              Text(format.format(product.basePrice),
                style: TextStyle(
                  color: Color(0xFF800020),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5,),
              Text(
                "Stock: ${product.stock}",
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                ),
              )
            ],
          ),
        )
      ],
    ),
  );
}
