import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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
  // ---------------------------------------------------------------------------
  // 4. UPLOAD PRODUCT (Multi-Part Request)
  // ---------------------------------------------------------------------------
  Future<bool> createProduct({
    required String title,
    required String description,
    required String price,
    required String category,
    required String colorName, // NEW
    required String colorHex,  // NEW
    required String stock,
    required List<File> images,
  }) async {
    try {
      print("----- STARTED UPLOAD NEW PRODUCT -----");
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));

      // 1. Add Text Fields
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['base_price'] = price;
      request.fields['category'] = category;
      request.fields['color_name'] = colorName;
      request.fields['color_hex'] = colorHex;
      request.fields['stock'] = stock;

      // 2. Add Images (Loop)
      // CRITICAL: The key must be 'image' (Singular) to match Node.js Multer
      for (var file in images) {
        // lookupMimeType requires 'package:mime/mime.dart'
        // It reads the file extension (e.g., .jpg) and returns 'image/jpeg'
        final mimeType = lookupMimeType(file.path) ?? 'image/jpg';
        final mimeSplit = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Key matching backend
            file.path,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]), // <--- THE FIX
          ),
        );
      }

      // 3. Send & Check
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Upload Success: ${response.body}");
        return true;
      } else {
        print("Upload Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error uploading product: $e");
      return false;
    }
  }
  // ---------------------------------------------------------------------------
// 5. GET ALL PRODUCTS
// ---------------------------------------------------------------------------
  Future<List<Product>> fetchhProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        print("Failed to load products: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 6. UPDATE PRODUCT (Text & Stock Only)
  // ---------------------------------------------------------------------------
  Future<bool> updateProductDetails({
    required int id,
    required String title,
    required String description,
    required String price,
    required String category,
    required String stock,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "title": title,
          "description": description,
          "base_price": price,
          "category": category,
          "stock": stock,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating product: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 7. DELETE PRODUCT
  // ---------------------------------------------------------------------------
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error deleting product: $e");
      return false;
    }
  }

  }

