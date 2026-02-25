import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/service/user_service.dart';

class StoreService {
    String? token = UserService().getToken();
    String baseUrl = UserService.baseUrl;
    Future<Store?> getStore(String id) async{
      http.Response httpResponse = await http.get(
        Uri.parse("http://localhost:8080/api/v1/stores/$id"),
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      Map<String,dynamic> response = jsonDecode(httpResponse.body);
      print(response);
      try {
        Store store = Store.fromJson(response.values.first);
        return store;
      }catch(e){
        return null;
      }
    }
    Future<List<Store>> getStoresByUser() async{
      var response = await http.get(Uri.parse("$baseUrl/v1/stores"),headers:{
        "accept": "application/json",
        "Authorization" : "Bearer $token"
      });
      String body = response.body;
      Map<String,dynamic> bodyMap = jsonDecode(body);
      print("voici  $bodyMap");
      List<dynamic> storeList = bodyMap.values.first;

      List<Store> stores = [];
      storeList.forEach((e){
        Store store = Store.fromJson(e);
        print(store.id);
        stores.add(store);
      });
      return stores;
    }
    Future<Store?> addStore(Map<String,dynamic> store)async{
      var response =await http.post(
        Uri.parse("$baseUrl/v1/stores"),
        body: jsonEncode(store),
        headers: {
          "Authorization": "Bearer $token",
          "content-type": "application/json"
        }
      );
      print(response.body);
      if(response.statusCode == 201){
        Map<String,dynamic> body = jsonDecode(response.body);
        Store store = Store.fromJson(body.values.first);
        return store;
      }
      return null;
    }

}