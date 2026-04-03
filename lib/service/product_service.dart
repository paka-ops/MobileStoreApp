import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/models/stock.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';

class ProductService{
  String? token = UserService().getToken();
  String baseUrl = UserService.baseUrl;
  Future<List<Product>> getAllProductByCategoryId(String categoryId,BuildContext context) async{
    try{
      var response = await http.get(
          Uri.parse("$baseUrl/v1/products?categoryId=$categoryId"),
          headers: {
            "Authorization": "Bearer $token"
          }
      ).timeout(Duration(seconds: 15));
      if(response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        List<dynamic>productMaps = map.values.first;
        if (productMaps.isNotEmpty) {
          List<Product> products = [];
          productMaps.forEach((e) {
            print(e);
            products.add(Product.fromJson(e));
          });
          return products;
        }
      }
      return [];
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }

  }
  Future<Product?> add(Map<String, dynamic> product,String categoryId,BuildContext context)async{
    try{
      var response = await http.post(
          Uri.parse("$baseUrl/v1/products?categoryId=$categoryId"),
          body: jsonEncode(product),
          headers: {
            "Authorization": "Bearer $token",
            "content-type": "application/json"
          }
      ).timeout(Duration(seconds: 15));
      if(response.statusCode == 201){
        Map<String,dynamic> responseMap = jsonDecode(response.body);
        return Product.fromJson(responseMap.values.first);
      }
      return null;
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }

  }
  Future<Product?> update(String id,Map<String, dynamic> product,BuildContext context)async {
    try{
      var response = await http.patch(
          Uri.parse("$baseUrl/v1/products/$id"),
          body: jsonEncode(product),
          headers: {
            "Authorization": "Bearer $token",
            "content-type": "application/json"
          }
      ).timeout(Duration(seconds: 15));
      if(response.statusCode == 200){
        Map<String,dynamic> responseMap = jsonDecode(response.body);
        return Product.fromJson(responseMap['Product']);
      }
      return null;
    }catch(e){
      print(e);
      showExceptionMessage(context);
      throw Exception(e);
    }

  }
  Future<bool> delete(String id,BuildContext context) async {
    try{
      var response = await http.delete(
          Uri.parse("$baseUrl/v1/products/$id"),
          headers: {
            "Authorization": "Bearer $token"
          }
      ).timeout(Duration(seconds: 15));
      if (response.statusCode == 204) {
        return true;
      }
      return false;
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }

  }
  Future<List<dynamic>> getStatsForProduct(String productId,BuildContext context) async {
    var response = await http.get(
        Uri.parse("$baseUrl/v1/products/$productId/stats"),
        headers: {
          "Authorization": "Bearer $token"
        }
    ).timeout(Duration(seconds: 15));

    if(response.statusCode == 200) {
      Map<String, dynamic> responseMap = jsonDecode(response.body);
      return responseMap['ArrayList'];
    }else if(response.statusCode == 402){
      showSubscriptionExpiredMessage(context);
    }
    return [];
  }
  Future<Product?> updateStock(String productId,double quantity,BuildContext context) async {
    try {
      var response = await http.patch(
          Uri.parse("$baseUrl/v1/products/$productId?quantity=$quantity"),
          headers: {
            "Authorization": "Bearer $token"
          }
      ).timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        return Product.fromJson(responseMap.values.first);
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return null;
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);

    }
  }
  Future<List<Product>> getAllProductByStoreId(String storeId) async{
    var response = await http.get(
        Uri.parse("$baseUrl/v1/products?storeId=$storeId"),
        headers: {
          "Authorization": "Bearer $token"
        }
    ).timeout(Duration(seconds: 15));
    if(response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
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
  Future<List<Product>> getLowStockProducts(String storeId) async {
    var response = await http.get(
      Uri.parse("$baseUrl/v1/products/low-stock?storeId=$storeId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    ).timeout(Duration(seconds: 15));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      print("voici low stock product res ${map.values.first}");
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
  Future<List<Stock>?> getAllProductStocks(DateTime startDate,DateTime endDate ,List<String> productIds,BuildContext context)async {

    try {
      var response = await http.post(
          Uri.parse("$baseUrl/v1/stocks?startDate=$startDate&endDate=$endDate"),
          body: jsonEncode(productIds),
          headers: {"Authorization": "Bearer $token","content-type": "application/json"},
      ).timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        List<dynamic> stocksMap = responseMap['ArrayList'];
        List<Stock> stocks = [];
        stocksMap.forEach((e) {
          stocks.add(Stock.fromJson(e));
        });
        return stocks;
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return [];
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }
  }
}