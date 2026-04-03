import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/enums.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';

import '../models/product.dart';
class OrderService {
  String? token = UserService.token;
  String basedUrl = UserService.baseUrl;

  Future<Order?> createOrder(String storeId,BuildContext context) async {
    try{
      var response = await http.post(
        Uri.parse("$basedUrl/v1/orders?storeId=$storeId"),
        headers: {
          "Authorization": "Bearer $token",
          "content-type": "application/json"
        },
      ).timeout(Duration(seconds: 15));
      if (response.statusCode == 201) {
        Map<dynamic, dynamic> res = jsonDecode(response.body) as Map<dynamic, dynamic>;
        return Order.fromJson(res['Order']);
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return null;
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }

  }

  Future<Order?> makeOrder(String orderId,
      List<Map<String, dynamic>> products,BuildContext context) async {
    try{
      var response = await http.post(
          Uri.parse("$basedUrl/v1/orderContents?orderId=$orderId"),
          headers: {
            "Authorization": "Bearer $token",
            "content-type": "application/json"
          },
          body: jsonEncode(products)
      ).timeout(Duration(seconds: 15));
      print( "voici response body de vente ${response.body}");
      Map<dynamic, dynamic> res = jsonDecode(response.body) as Map<dynamic, dynamic>;
      if (response.statusCode == 201) {
        return Order.fromJson(res['Order']);
      }else if(response.statusCode == 409){
        String message = res['message'];
        showErrorMessage("produit en rupture de stock", context);
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return null;
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }

  }

  Future<List<Order>> getAllOrderBetweenTwoDate(String storeId, DateTime start,
      DateTime? end,BuildContext context) async {
    try{
      var response = await http.get(
        Uri.parse("$basedUrl/v1/orders?storeId=$storeId&startDate=${start
            .toIso8601String()}&endDate=${end?.toIso8601String()}"),
        headers: {
          "Authorization": "Bearer $token",
          "content-type": "application/json"
        },
      ).timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        Map<String,dynamic> responseMap = jsonDecode(response.body) as Map<String,dynamic>;
        List<dynamic> orderMaps = responseMap.values.first;
        List<Order> orders = [];
        orderMaps.forEach((e) {
          orders.add(Order.fromJson(e));
        });
        return orders;
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return [];
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }

  }
  Future<bool> deleteOrder(String orderId,BuildContext context) async {
    var response = await http.delete(
        Uri.parse("$basedUrl/v1/orders/$orderId"),
        headers: {
          "Authorization": "Bearer $token",
        }).timeout(Duration(seconds: 15));
    if(response.statusCode == 200){
      return true;
    }else if(response.statusCode == 402){
      showSubscriptionExpiredMessage(context);
    }
    return false;
  }
  Future<List<Order>> getOrders(String storeId,DateFormat startDate,DateFormat endDate,BuildContext
       context) async{
    try{
      var response = await http.get(
          Uri.parse("$basedUrl/v1/orders?storeId=$storeId?startDate=$startDate&endDate=$endDate"),
          headers: {
            "Authorization": "Bearer $token",
          }
      ).timeout(Duration(seconds: 15));
      Map<String,dynamic> responseMap = jsonDecode(response.body);

      if(responseMap == 200){
        List<Map<String,dynamic>> ordersMap = responseMap['Order'];
        List<Order> orders = [];
        ordersMap.forEach((e){
          Order order = Order.fromJson(e);
          orders.add(order);
        });
        return orders;

      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return [];
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }


  }
  Future<Map<Product,dynamic>> getOrderContent(String orderId,BuildContext context)async{
    try{
      var response =await http.get(
          Uri.parse("$basedUrl/v1/orderContents?orderId=$orderId"),
          headers: {
            "Authorization": "Bearer $token",
          }
      ).timeout(Duration(seconds: 15));
      if(response.statusCode == 200){
        Map<dynamic,dynamic> responseMap = jsonDecode(response.body);

        List<dynamic> contents= responseMap.values.first;
        Map<Product,double> orderContents = {};
        if(contents.isNotEmpty) {
          contents.forEach((element) {
            Product pro = Product.fromJson(element['productDto']);
            double qty = (element['quantity'] as num).toDouble();
            orderContents.putIfAbsent(pro, ()=>qty);
          });
        }

        return orderContents;
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return {};
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }


  }
  Future<List<Map<String,dynamic>>> getcontentsByOrdersIds(List<String> orderIds,BuildContext context)async{
    try{
      var response = await  http.post(Uri.parse("$basedUrl/v1/orderContents"),
          headers: {
            "Authorization": "Bearer $token",
            "content-type": "application/json"
          },
          body: jsonEncode(orderIds)
      ).timeout(Duration(seconds: 15));
      if(response.statusCode == 200){
        Map<String,dynamic> responseMap = jsonDecode(response.body);
        List<dynamic> contents = responseMap['ArrayList'];
        if(contents.isNotEmpty){
          List<Map<String,dynamic>> contentsMap = [];
          for (var e in contents) {
            contentsMap.add(e);
          }
          return contentsMap;
        }
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return [];
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }

  }
  Future<Order?> changeOrderStatus(String status,String orderId,BuildContext context) async{
    try{
      var response = await http.patch(Uri.parse("$basedUrl/v1/orders/status/$orderId"),
          headers: {"Authorization": "Bearer $token","content-type" : "application/json"},
          body:jsonEncode(status)
      ).timeout(Duration(seconds: 15));
      if(response.statusCode == HttpStatus.ok){
        Map<String,dynamic> responseMap = jsonDecode(response.body);
        Map<String,dynamic> orderMap = responseMap['Order'];
        Order order = Order.fromJson(orderMap);
        return order;
      }else if(response.statusCode == 401) {
        throw Exception("vous n' etes pas le vendeur de ces produits");
      }else if(response.statusCode == 402){
        showSubscriptionExpiredMessage(context);
      }
      return null;
    }catch(e){
      showExceptionMessage(context);
      throw Exception(e);
    }

  }


}
