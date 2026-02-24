import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/service/user_service.dart';

class StoreService {
    String? token = UserService().getToken();
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

}