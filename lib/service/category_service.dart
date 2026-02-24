import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/service/user_service.dart';
class CategoryService{
  String baseUrl = UserService.baseUrl;
  String? token = UserService().getToken();
  Future<List<Category>> getCategoryByStoreId(String storeId)async{
    var response = await http.get(
      Uri.parse("$baseUrl/v1/categories?storeId=$storeId"),
      headers: {
        "Authorization" : "Bearer $token"
      }
    );
    if(response.statusCode == 200){
      Map<String,dynamic> responseMap = jsonDecode(response.body);
      if(responseMap.isNotEmpty) {
        List<Category> catgories = [];
        for (Map<String, dynamic> element in responseMap.values.first) {
            Category category = Category.fromJson(element);
            catgories.add(category);
        }
        return catgories;
      }

    }
    return [];

  }
  Future<Category?> create(Map<String,dynamic> category,String storeId)async{
    var response = await http.post(
      Uri.parse("$baseUrl/v1/categories?storeId=$storeId"),
      body: jsonEncode(category),
      headers: {
        "Authorization" : "Bearer $token",
        "content-type" : "application/json"
      }
    );
    String res = response.body;
    print(res);
    if(response.statusCode == 201){
      Map<String,dynamic> responseMap = jsonDecode(response.body);
      return Category.fromJson(responseMap.values.first);
    }
    return null;
  }

}