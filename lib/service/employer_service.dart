import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mobile_store_app/models/employer.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/utils/message.dart';
class EmployerService{
    String baseUrl = UserService.baseUrl;
    Future<bool> createEmployer(Map<String,dynamic> employer,BuildContext context) async {
      try {
        var response = await http.post(
            Uri.parse("$baseUrl/v1/employers"),
            headers: {
              'content-type': 'application/json'
            },
            body: jsonEncode(employer)
        ).timeout(Duration(seconds: 15));
        if (response.statusCode == 201) {

          return true;
        }else {
          showErrorMessage("Erreur l' ors de la creation veuillez ressayer plutard,Si le problème persiste veuillez contacter l' administrateur", context);
        }
      } catch (e) {
        showExceptionMessage(context);
        throw Exception(e);
      }
      return false;
    }
}