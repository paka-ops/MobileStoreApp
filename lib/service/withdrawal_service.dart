import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/withdrawal.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';
class WithdrawalService{
  String baseUrl = UserService.baseUrl;
  String? token = UserService.token;
  Future<List<Withdrawal>?> getWithdrawals({required storeId,required DateTime startDate, required DateTime endDate, required BuildContext context}) async {
    try {
      var result = await http.get(Uri.parse(
          "$baseUrl/withdrawal?storeId=$storeId&startDate=$startDate&endDate=$endDate"),
          headers: {
            "Authorization": "Bearer $token"
          }
      ).timeout(Duration(seconds: 10));
      if (result.statusCode == 200) {
        Map<String,dynamic> response = jsonDecode(result.body);
        List<dynamic> responseMap = response['withdrawals'];
        List<Withdrawal> withdrawals = [];
          responseMap.forEach((e){
            withdrawals.add(Withdrawal.fromJson(e));
          });
          return withdrawals;
      }else if(result.statusCode == 401){
        showSubscriptionExpiredMessage(context);
      }
    }catch(e){
      showErrorMessage("une erreur produite l' ors de la recuperation verifiez votre connexion internet puis reésayer ", context);
      return null;
    }
    Future<Withdrawal?> create({required String storeId,required Withdrawal withdrawal,required BuildContext context})async{
      try{
        var result = await http.post(Uri.parse("$baseUrl/withdrawal"),
            headers: {
              "Authorization" : "Bearer $token",
              "content-type" : "application/json"
            },
            body: withdrawal.toJson()).timeout(Duration(seconds: 10));
        if(result.statusCode == 201 ){
          Map<String,dynamic> responseMap = jsonDecode(result.body);
          return Withdrawal.fromJson(responseMap["withdrawal"]);
        }else if(result.statusCode == 401){
          showSubscriptionExpiredMessage(context);
        }
      }catch(e){
        showErrorMessage("une erreur produite l' ors de la creation verifiez votre connexion internet puis reésayer ", context);
        return null;
      }
      return null;
    }
    Future<Withdrawal?> update({required String storeId,required Withdrawal withdrawal,required BuildContext context})async{
      try{
        var result = await http.put(Uri.parse("$baseUrl/withdrawal/${withdrawal.id}"),
        headers: {
          "Authorization" : "Bearer $token",
          "content-type" : "application/json"
        }).timeout(Duration(seconds: 10));
        if(result.statusCode == 200 ){
          Map<String,dynamic> responseMap = jsonDecode(result.body);
          return Withdrawal.fromJson(responseMap["withdrawal"]);
        }else if(result.statusCode == 401){
          showSubscriptionExpiredMessage(context);
        }
      }catch(e){
        showErrorMessage("une erreur produite l' ors de la creation verifiez votre connexion internet puis reésayer ", context);
        return null;
      }
      return null;

    }
    Future<bool> delete({required String withdrawalId,required BuildContext context})async{
      try{
        var result = await http.delete(Uri.parse("$baseUrl/withdrawal/$withdrawalId"),
            headers: {
              "Authorization" : "Bearer $token",
              "content-type" : "application/json"
            }).timeout(Duration(seconds: 10));
        if(result.statusCode == 200 ){
          return true;
        }else if(result.statusCode == 401){
          showSubscriptionExpiredMessage(context);
        }
      }catch(e){
        showErrorMessage("une erreur produite l' ors de la creation verifiez votre connexion internet puis reésayer ", context);
        return false;
      }
      return false;
    }
    return null;
  }

}