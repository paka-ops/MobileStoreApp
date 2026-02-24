import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/user_service.dart';

class ProductService{
  String? token = UserService().getToken();
  String baseUrl = UserService.baseUrl;
  Future<List<Product>> getAllProductByCategoryId(String categoryId) async{
    var response = await http.get(
    Uri.parse("$baseUrl/v1/products?categoryId=$categoryId"),
    headers: {
      "Authorization": "Bearer $token"
    }
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      print("voici product res ${map.values.first}");
      List<dynamic>productMaps = map.values.first;
      if (productMaps.isNotEmpty) {
        List<Product> products = [];
        productMaps.forEach((e) {
            products.add(Product.fromJson(e));
        });
        return products;
      }
    }
    return [];
  }
  Future<Product?> add(Map<String, dynamic> product,String categoryId)async{
    var response = await http.post(
      Uri.parse("$baseUrl/v1/products?categoryId=$categoryId"),
      body: jsonEncode(product),
      headers: {
        "Authorization": "Bearer $token",
        "content-type": "application/json"
      }
    );
    if(response.statusCode == 201){
      Map<String,dynamic> responseMap = jsonDecode(response.body);
      return Product.fromJson(responseMap.values.first);
    }
    return null;
  }
  Future<Product?> update(String id,Map<String, dynamic> product)async {
    var response = await http.patch(
      Uri.parse("$baseUrl/v1/products/$id"),
      body: jsonEncode(product),
      headers: {
        "Authorization": "Bearer $token",
        "content-type": "application/json"
      }
    );
    if(response.statusCode == 200){
      Map<String,dynamic> responseMap = jsonDecode(response.body);
      return Product.fromJson(responseMap.values.first);
    }
    return null;
  }
  Future<bool> delete(String id) async {
    var response = await http.delete(
        Uri.parse("$baseUrl/v1/products/$id"),
        headers: {
          "Authorization": "Bearer $token"
        }
    );
    if (response.statusCode == 204) {
      return true;
    }
    return false;
  }
}