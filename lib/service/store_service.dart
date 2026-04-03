import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';

class StoreService {
    String? token = UserService().getToken();

    String baseUrl = UserService.baseUrl;
    Future<Store?> getStore(String id,BuildContext context) async{
    try {
      http.Response httpResponse = await http.get(
        Uri.parse("$baseUrl/v1/stores/$id"),
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      Map<String, dynamic> response = jsonDecode(httpResponse.body);
        print(response);
        Store store = Store.fromJson(response.values.first);
        return store;

    }catch(e){
      showExceptionMessage(context);
      throw Exception("Erreur lors de la recherche");
    }
    }
    Future<List<Store>> getStoresByUser(BuildContext context) async{
    try {
      var response = await http.get(Uri.parse("$baseUrl/v1/stores"), headers: {
        "accept": "application/json",
        "Authorization": "Bearer ${UserService().getToken()}"
      }).timeout(Duration(seconds: 10));
      String body = response.body;
      Map<String, dynamic> bodyMap = jsonDecode(body);
      List<dynamic> storeList = bodyMap.values.first;
      print(storeList);
      List<Store> stores = [];
      storeList.forEach((e) {
        Store store = Store.fromJson(e);
        stores.add(store);
      });
      return stores;
    }catch(e){
      showExceptionMessage(context);
      throw Exception("Erreur lors de la recherche");
    }
    }
    Future<Store?> addStore(Map<String,dynamic> store,BuildContext context)async{
      try{
        var response =await http.post(
            Uri.parse("$baseUrl/v1/stores"),
            body: jsonEncode(store),
            headers: {
              "Authorization": "Bearer $token",
              "content-type": "application/json"
            }
        ).timeout(Duration(seconds: 10));
        if(response.statusCode == 201){
          Map<String,dynamic> body = jsonDecode(response.body);
          Store store = Store.fromJson(body.values.first);
          return store;
        }
        return null;
      }catch(e){
        showExceptionMessage(context);
        throw Exception("Erreur lors de l' ajout de la boutique");
      }
    }
    Future<Store> updateStore(String id,Map<String,dynamic> store,BuildContext context) async{
      try{
        var response = await http.patch(
            Uri.parse("$baseUrl/v1/stores/$id"),
            body: jsonEncode(store),
            headers: {
              "Authorization": "Bearer $token",
              "content-type": "application/json"
            }
        ).timeout(Duration(seconds: 10));
        if(response.statusCode == 200){
          Map<String,dynamic> body = jsonDecode(response.body);
          Store store = Store.fromJson(body.values.first);
          return store;
        }
        throw Exception("Erreur lors de la mise à jour de la boutique");
      }catch(e){
        showExceptionMessage(context);
        throw Exception("Erreur lors de la mise à jour de la boutique");
      }
    }
    Future<bool> deleteStore(String id,BuildContext context) async {
      try{
        var response = await http.delete(
            Uri.parse("$baseUrl/v1/stores/$id"),
            headers: {
              "Authorization": "Bearer $token"
            }
        ).timeout(Duration(seconds: 10));
        if(response.statusCode == 204){
          return true;
        }
        return false;
      }catch(e){
        showExceptionMessage(context);
        throw Exception("erreur");
      }
    }


}