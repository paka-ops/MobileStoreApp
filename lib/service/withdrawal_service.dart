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
          "$baseUrl/withdrawal?storeId=$storeId&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}"),
          headers: {
            "Authorization": "Bearer $token"
          }
      ).timeout(Duration(seconds: 10));
      if (result.statusCode == 200) {
        Map<String,dynamic> response = jsonDecode(result.body);
        final dynamic raw = response['withdrawals'] ??
            response['Withdrawals'] ??
            (response.isEmpty ? null : response.values.first);
        if (raw is! List) {
          showErrorMessage("erreur lors de la lecture des retraits", context);
          return null;
        }
        List<Withdrawal> withdrawals = [];
          raw.forEach((e){
            withdrawals.add(Withdrawal.fromJson(e));
          });
          return withdrawals;
      }else if(result.statusCode == 401){
        showSubscriptionExpiredMessage(context);
      }else {
        showErrorMessage("erreur lors de la recuperation des retraits", context);
      }
    }catch(e){
      showErrorMessage("une erreur produite l' ors de la recuperation verifiez votre connexion internet puis reésayer ", context);
      return null;
    }
    return null;
  }

  Future<Withdrawal?> create({required String storeId,required Withdrawal withdrawal,required BuildContext context})async{
    try{
      var result = await http.post(Uri.parse("$baseUrl/withdrawal?storeId=$storeId"),
          headers: {
            "Authorization" : "Bearer $token",
            "content-type" : "application/json"
          },
          body: jsonEncode({
            ...withdrawal.toJson(),
            "storeId": storeId,
          })
      ).timeout(Duration(seconds: 10));
      if(result.statusCode == 201 || result.statusCode == 200 ){
        return _readWithdrawal(result.body, withdrawal);
      }else if(result.statusCode == 401){
        showSubscriptionExpiredMessage(context);
      }else {
        showErrorMessage("erreur lors de l'ajout du retrait", context);
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
          },
          body: jsonEncode(withdrawal.toJson())
      ).timeout(Duration(seconds: 10));
      if(result.statusCode == 200 ){
        return _readWithdrawal(result.body, withdrawal);
      }else if(result.statusCode == 401){
        showSubscriptionExpiredMessage(context);
      }else {
        showErrorMessage("erreur lors de la modification du retrait", context);
      }
    }catch(e){
      showErrorMessage("une erreur produite l' ors de la modification verifiez votre connexion internet puis reésayer ", context);
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
      if(result.statusCode == 200 || result.statusCode == 204 ){
        return true;
      }else if(result.statusCode == 401){
        showSubscriptionExpiredMessage(context);
      }else {
        showErrorMessage("erreur lors de la suppression du retrait", context);
      }
    }catch(e){
      showErrorMessage("une erreur produite l' ors de la suppression verifiez votre connexion internet puis reésayer ", context);
      return false;
    }
    return false;
  }

  /// Le serveur peut répondre avec un corps vide : on garde alors le retrait
  /// manipulé côté application pour ne pas perdre l'action de l'utilisateur.
  Withdrawal _readWithdrawal(String body, Withdrawal fallback){
    try{
      if (body.isEmpty) return fallback;
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map) {
        final dynamic value = decoded["withdrawal"] ?? decoded["Withdrawal"];
        if (value is Map) {
          return Withdrawal.fromJson(Map<String,dynamic>.from(value));
        }
        if (decoded.containsKey("id") || decoded.containsKey("amount")) {
          return Withdrawal.fromJson(Map<String,dynamic>.from(decoded));
        }
      }
    }catch(e){
      return fallback;
    }
    return fallback;
  }
}
