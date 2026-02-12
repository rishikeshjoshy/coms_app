import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/order.dart';
import '../models/product.dart';

class ApiService {

  // ---------------------------------------------------------------------
  /// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

  static const String baseUrl = 'https://maiee-saree-backend.onrender.com/api';

  /// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  // ----------------------------------------------------------------------

  // 1. FETCH DASHBOARD STATS
  Future<Map<String, dynamic>> fetchhStats() async {
    print("----- STARTED FETCH STATS -----");
    try{
      final response = await http.get(Uri.parse('$baseUrl/orders/stats'));

      if( response.statusCode == 200 ){
        print("RAW DEBUG LINES : ${response.body}");
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats');
      }
    } catch(e) {
      throw("Critical fetch error !!");
    }

  }


  // 2. FETCH ALL PRODUCTS ( CMS )
  Future<List<Product>> fetchProducts() async {
    print("----- STARTED FETCH PRODUCTS -----");
    try {
      // FIX 1: Removed arguments from function (it should be empty brackets)
      // FIX 2: Fixed variable name typo (response, not responsse)
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        /// RAW DEBUG LINE - Shows us exactly what the server sent
        print("RAW API RESPONSE: ${response.body}");

        final Map<String, dynamic> body = json.decode(response.body);

        // Safety Check: If 'data' is missing, return empty list instead of crashing
        if (body['data'] == null) {
          print("CRITICAL: 'data' key is missing!");
          return [];
        }

        final List<dynamic> data = body['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        print("Server Error: ${response.statusCode}");
        throw Exception('Failed to load the products');
      }
    } catch (e) {
      print("----- CRITICAL FETCH ERROR: $e");
      // FIX 3: Must return an empty list on error so the app doesn't crash
      return [];
    }
  }

  // 3. FETCH ALL ORDERS ( OMS )
  Future<List<Order>> fetchOrder() async {
    print("------ STARTED FETCH ORDERS ------");
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/admin'));
      if (response.statusCode == 200) {
        print("RAW API RESPONSE: ${response.body}");

        /// DEBUG LINE
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch(e) {
      print("----- CRITICAL CRASH FETCH: $e");
      throw Exception('Error fetching orders: $e');
    }
  }


  // 4. UPDATE ORDERS STATUS
  Future<bool> updateORderStatus(int orderId, String status) async {
    final response = await http.put(
     Uri.parse('$baseUrl/orders/$orderId/status'),
     headers: {"Content-Type":"application/json"},
     body: json.encode({"status":status}),
    );
    return response.statusCode == 200;
  }

  // 5. UPLOAD NEW PRODUCT (Multipart Request - Multi Image Support)
  Future<bool> createProduct({
    required String title,
    required String description,
    required String price,
    required String category,
    required String colorName,
    required String colorHex,
    required String stock,
    required List<File> images, // <--- CHANGED: Accepts a List now
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));

    // Text Fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['base_price'] = price;
    request.fields['category'] = category;
    request.fields['color_name'] = colorName;
    request.fields['color_hex'] = colorHex;
    request.fields['stock'] = stock;

    // File Fields (Loop through all images)
    for (var file in images) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        // <--- IMPORTANT: Ensure your Backend Multer expects 'images' (plural)
        file.path,
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Upload Failed: ${response.statusCode}");
      // Optional: Read response stream to see backend error
      final respStr = await response.stream.bytesToString();
      print("Server Error: $respStr");
      return false;
    }
  }
  }