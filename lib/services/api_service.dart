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
    final response = await http.get(Uri.parse('$baseUrl/orders/stats'));

    if( response.statusCode == 200 ){
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  // 2. FETCH ALL PRODUCTS ( CMS )
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
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

  // 5. UPLOAD NEW PRODUCT
  Future<bool> createProduct({
    required String title,
    required String description,
    required String price,
    required String category,
    required String colorName,
    required String colorHex,
    required String stock,
    required File imageFile,
}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));

    // TEXT FIELDS __ FAAAHHH !!!
    request.fields['title'] = title;
    request.fields['price'] = price;
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.fields['colorName'] = colorName;
    request.fields['colorHex'] = colorHex;
    request.fields['stock'] = stock;

    // FILE FIELDS ___ RAAAAAAH !!!
    request.files.add(
        await http.MultipartFile.fromPath(
            'image',
            imageFile.path
        )
    );

    var response = await request.send();
    return response.statusCode == 201;

  }

}