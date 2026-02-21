import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  bool _isSaving = false;
  late String _selectedCategory;
  final List<String> _categories = ['Silk', 'Banarasi', 'Kanjivaram', 'Party', 'Office'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _descController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.basePrice.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());

    // --- THE BULLETPROOF FALLBACK ---
    // If the database category doesn't exist in your new list, safely grab the first item.
    _selectedCategory = _categories.contains(widget.product.category)
        ? widget.product.category
        : _categories.first;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await _apiService.updateProductDetails(
      id: widget.product.id,
      title: _titleController.text,
      description: _descController.text,
      price: _priceController.text,
      category: _selectedCategory,
      stock: _stockController.text,
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Return true to trigger a refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ID: #${widget.product.id}"),
        actions: [
          // --- THE DELETE BUTTON ---
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              // --- CONFIRMATION DIALOG ---
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text("Delete Saree?"),
                    content: const Text("Are you sure you want to permanently remove this item from the website and inventory?"),
                    actions: [
                      TextButton(
                        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                        onPressed: () => Navigator.pop(dialogContext), // Close dialog
                      ),
                      TextButton(
                        child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          Navigator.pop(dialogContext); // Close dialog first

                          setState(() => _isSaving = true);

                          // Call the API service
                          final success = await _apiService.deleteProduct(widget.product.id);

                          if (!mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Item Deleted 🗑️"), backgroundColor: Colors.red),
                            );
                            // Pop the Edit screen entirely and tell Inventory to refresh
                            Navigator.pop(context, true);
                          } else {
                            setState(() => _isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Failed to delete item")),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- MULTI-IMAGE CAROUSEL ---
              if (widget.product.imageUrls.isNotEmpty)
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.product.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.imageUrls[index],
                            width: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Product Title", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: "Price (₹)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: "Stock", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("SAVE CHANGES"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}