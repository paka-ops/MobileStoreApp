import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';
class CategoryService{
  String baseUrl = UserService.baseUrl;
  String? token = UserService().getToken();
  Future<List<Category>> getCategoryByStoreId(String storeId,BuildContext  context)async{
    try{
      var response = await http.get(
          Uri.parse("$baseUrl/v1/categories?storeId=$storeId"),
          headers: {
            "Authorization" : "Bearer $token"
          }
      ).timeout(Duration(seconds: 15));
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

      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return [];
    }catch(e){
      showExceptionMessage(context);
      throw Exception();
    }


  }
  Future<Category?> create(Map<String,dynamic> category,String storeId,BuildContext context)async{
    try{
      var response = await http.post(
          Uri.parse("$baseUrl/v1/categories?storeId=$storeId"),
          body: jsonEncode(category),
          headers: {
            "Authorization" : "Bearer $token",
            "content-type" : "application/json"
          }
      ).timeout(Duration(seconds: 15));
      String res = response.body;
      print(res);
      if(response.statusCode == 201){
        Map<String,dynamic> responseMap = jsonDecode(response.body);
        return Category.fromJson(responseMap.values.first);
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return null;
    }catch(e){
      showExceptionMessage(context);
      throw Exception();
    }

  }
  Future<Category?> update(String id,Map<String,dynamic> category,BuildContext context)async {
    try{
      var response = await http.patch(
          Uri.parse("$baseUrl/v1/categories/$id"),
          body: jsonEncode(category),
          headers: {
            "Authorization": "Bearer $token",
            "content-type": "application/json"
          }
      ).timeout(Duration(seconds: 15));
      String res = response.body;
      print(res);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        return Category.fromJson(responseMap.values.first);
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return null;
    }catch(e){
      showExceptionMessage(context);
      throw Exception();
    }

  }
  Future<bool> delete(String id,BuildContext context) async {
    try {
      var response = await http.delete(
          Uri.parse("$baseUrl/v1/categories/$id"),
          headers: {
            "Authorization": "Bearer $token"
          }
      ).timeout(Duration(seconds: 15));
      if (response.statusCode == 204) {
        return true;
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return false;
    } catch (e) {
      showExceptionMessage(context);
      throw Exception();
    }
  }


}