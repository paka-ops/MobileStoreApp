import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';

class SpendingServcie {
  String baseUrl = UserService.baseUrl;
  String? token = UserService().getToken();

  Future<bool> saveSpending(Spending spending, BuildContext context) async {
    try {
      final result = await http
          .post(
            Uri.parse('$baseUrl/v1/spending'),
            body: jsonEncode(spending.toJson()),
            headers: {
              'Authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 16));

      if (result.statusCode == 201 || result.statusCode == 200) {
        showSuccessMessage('dépense ajoutée avec succès', context);
        return true;
      } else if (result.statusCode == 402) {
        showSubscriptionExpiredMessage(context);
      } else {
        showErrorMessage("erreur lors de l'ajout de la dépense", context);
      }
      return false;
    } catch (e) {
      showExceptionMessage(context);
      return false;
    }
  }

  Future<List<Spending>> getAllSpending(
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    BuildContext context,
  ) async {
    try {
      final result = await http
          .get(
            Uri.parse(
              '$baseUrl/v1/spending?storeId=$storeId&startDate=${startDate?.toIso8601String()}&endDate=${endDate?.toIso8601String()}',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (result.statusCode == 200) {
        final Map<String, dynamic> resultMap =
            jsonDecode(result.body) as Map<String, dynamic>;
        final List<dynamic> res = (resultMap['ArrayList'] ?? <dynamic>[]) as List<dynamic>;
        return res
            .map((e) => Spending.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (result.statusCode == 402) {
        showSubscriptionExpiredMessage(context);
      } else {
        showErrorMessage(
          'erreur lors de la récupération des dépenses',
          context,
        );
      }
      return [];
    } catch (e) {
      showExceptionMessage(context);
      return [];
    }
  }

  Future<bool> updateSpending(
    String spendingId,
    Spending spending,
    BuildContext context,
  ) async {
    try {
      final result = await http
          .patch(
            Uri.parse('$baseUrl/v1/spending/$spendingId'),
            body: jsonEncode(spending.toJson()),
            headers: {
              'Authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 16));

      if (result.statusCode == 200 || result.statusCode == 204) {
        showSuccessMessage('dépense modifiée avec succès', context);
        return true;
      } else if (result.statusCode == 402) {
        showSubscriptionExpiredMessage(context);
      } else {
        showErrorMessage(
          "erreur lors de la modification de la dépense",
          context,
        );
      }
      return false;
    } catch (e) {
      showExceptionMessage(context);
      return false;
    }
  }

  Future<bool> deleteSpending(String spendingId, BuildContext context) async {
    try {
      final result = await http
          .delete(
            Uri.parse('$baseUrl/v1/spending/$spendingId'),
            headers: {
              'Authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 16));

      if (result.statusCode == 200 || result.statusCode == 204) {
        showSuccessMessage('dépense supprimée avec succès', context);
        return true;
      } else if (result.statusCode == 402) {
        showSubscriptionExpiredMessage(context);
      } else {
        showErrorMessage(
          "erreur lors de la suppression de la dépense",
          context,
        );
      }
      return false;
    } catch (e) {
      showExceptionMessage(context);
      return false;
    }
  }
}
