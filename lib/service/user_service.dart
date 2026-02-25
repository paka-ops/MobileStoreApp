
import 'dart:convert';

import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/models/person.dart';
import 'package:http/http.dart' as http;

class UserService {
  static String baseUrl = "http://localhost:8080/api";
  static String? token;
  String? getToken(){
    return token;
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    String url = "$baseUrl/login";
    final response = await http.post(
      Uri.parse(url),
      headers: {"content-type": "application/x-www-form-urlencoded"},
      body: {"username": username, "password": password},
    );
    print(response.body);
    if (response.statusCode == 200)  {
      Map<String,dynamic> responseMap = jsonDecode(response.body);
      token = responseMap["jwtToken"];
      return true;
    } else {
      return false;
    }
  }

}