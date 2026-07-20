import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';
class SpendingServcie{
  String baseUrl = UserService.baseUrl;
  String? token = UserService().getToken();
  saveSpending(Spending spending,BuildContext context)async{
    try{
    var result = await http.post(Uri.parse("$baseUrl/v1/spending"),
      body: jsonEncode(spending.toJson()),
      headers: {
        'Authorization' : 'Bearer $token',
        'content-type' : 'application/json'
      }
    ).timeout(Duration(seconds: 16));
    if(result.statusCode == 201){
      print("result : ${result.body}");
      showSuccessMessage("depense ajouté avec success", context);
    }else {
      showErrorMessage("erreur lors de l'ajout de la dépense", context);
    }
    }catch(e){
      showExceptionMessage(context);
    }
  }
  getAllSpending(String? storeId,BuildContext context)async{
    var result = await http.get(Uri.parse("$baseUrl/v1/spending?storeId=$storeId"),
        headers: {
          'Authorization' : 'Bearer $token',
          'content-type' : 'application/json'
        }
    ).timeout(Duration(seconds: 10));
    if(result.statusCode == 200){
      Map<String,dynamic> resultMap = jsonDecode(result.body);
      List<Spending> spending = [];
      List<dynamic> res = resultMap["ArrayList"];
      res.forEach((e){
        spending.add(Spending.fromJson(e));
      });
      return spending;
    }else {
      showErrorMessage("erreur lors de la récupération des dépenses", context);
      return [];
    }
  }
}
