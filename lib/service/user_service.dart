
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/models/person.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/utils/message.dart';

class UserService {
  static String baseUrl = "http://10.211.219.85:8080/api";
  static String? token;
  static String? userType;
  static String? username;
  String? getToken(){
    return token;
  }


  Future<bool> login({
    required String username,
    required String password,
    required BuildContext context
  }) async {
    try {
      String url = "$baseUrl/login";
      final response = await http.post(
        Uri.parse(url),
        headers: {"content-type": "application/x-www-form-urlencoded"},
        body: {"username": username, "password": password},

      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        print(responseMap);
        token = responseMap["jwtToken"];
        userType = responseMap["userType"];
        UserService.username = responseMap["username"];
        print("login en cours ");
        return true;
      } else {
        return false;
      }
    }catch(e){
      showExceptionMessage(context);
      print(e);
      throw Exception(e);
    }
  }
  // Dans user_service.dart
  static Future<void> logout() async {
    // 1. Réinitialiser les variables de session
    userType = null;

    // 2. Si tu utilises SharedPreferences pour garder la session active :
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
  }

}