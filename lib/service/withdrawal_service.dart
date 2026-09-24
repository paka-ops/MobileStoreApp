import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/withdrawal.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';

class WithdrawalService {
  String baseUrl = UserService.baseUrl;
  String? token = UserService().getToken();

  static const List<String> _endpointCandidates = ['withdrawal', 'withdrawall'];

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

  Future<http.Response> _request({
    required String method,
    required String pathSuffix,
    Object? body,
  }) async {
    http.Response? lastResponse;

    for (final endpoint in _endpointCandidates) {
      final uri = Uri.parse('$baseUrl/v1/$endpoint$pathSuffix');
      final upperMethod = method.toUpperCase();

      final response = switch (upperMethod) {
        'GET' => await http.get(uri, headers: _headers),
        'POST' => await http.post(uri, headers: _headers, body: body),
        'PATCH' => await http.patch(uri, headers: _headers, body: body),
        'DELETE' => await http.delete(uri, headers: _headers),
        _ => throw UnsupportedError('Méthode HTTP non supportée: $method'),
      };

      lastResponse = response;
      if (response.statusCode != 404) {
        return response;
      }
    }

    return lastResponse ??
        http.Response(
          '{"message":"endpoint indisponible"}',
          404,
        );
  }

  Future<bool> saveWithdrawal(
    Withdrawal withdrawal,
    BuildContext context,
  ) async {
    try {
      final result = await _request(
        method: 'POST',
        pathSuffix: '',
        body: jsonEncode(withdrawal.toJson()),
      ).timeout(const Duration(seconds: 16));

      if (result.statusCode == 201 || result.statusCode == 200) {
        showSuccessMessage('retrait ajouté avec succès', context);
        return true;
      } else if (result.statusCode == 402) {
        showSubscriptionExpiredMessage(context);
      } else {
        showErrorMessage("erreur lors de l'ajout du retrait", context);
      }
      return false;
    } catch (e) {
      showExceptionMessage(context);
      return false;
    }
  }

  Future<List<Withdrawal>> getAllWithdrawals(
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    BuildContext context,
  ) async {
    try {
      final result = await _request(
        method: 'GET',
        pathSuffix:
            '?storeId=$storeId&startDate=${startDate?.toIso8601String()}&endDate=${endDate?.toIso8601String()}',
      ).timeout(const Duration(seconds: 10));

      if (result.statusCode == 200) {
        final Map<String, dynamic> resultMap =
            jsonDecode(result.body) as Map<String, dynamic>;
        final List<dynamic> data =
            (resultMap['ArrayList'] ?? <dynamic>[]) as List<dynamic>;

        return data
            .map((e) => Withdrawal.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (result.statusCode == 402) {
        showSubscriptionExpiredMessage(context);
      } else {
        showErrorMessage(
          'erreur lors de la récupération des retraits',
          context,
        );
      }
      return [];
    } catch (e) {
      showExceptionMessage(context);
      return [];
    }
  }

  Future<bool> updateWithdrawal(
    String withdrawalId,
    Withdrawal withdrawal,
    BuildContext context,
  ) async {
    try {
      final result = await _request(
        method: 'PATCH',
        pathSuffix: '/$withdrawalId',
        body: jsonEncode(withdrawal.toJson()),
      ).timeout(const Duration(seconds: 16));

      if (result.statusCode == 200 || result.statusCode == 204) {
        showSuccessMessage('retrait modifié avec succès', context);
        return true;
      } else if (result.statusCode == 402) {
        showSubscriptionExpiredMessage(context);
      } else {
        showErrorMessage(
          "erreur lors de la modification du retrait",
          context,
        );
      }
      return false;
    } catch (e) {
      showExceptionMessage(context);
      return false;
    }
  }

  Future<bool> deleteWithdrawal(
    String withdrawalId,
    BuildContext context,
  ) async {
    try {
      final result = await _request(
        method: 'DELETE',
        pathSuffix: '/$withdrawalId',
      ).timeout(const Duration(seconds: 16));

      if (result.statusCode == 200 || result.statusCode == 204) {
        showSuccessMessage('retrait supprimé avec succès', context);
        return true;
      } else if (result.statusCode == 402) {
        showSubscriptionExpiredMessage(context);
      } else {
        showErrorMessage(
          "erreur lors de la suppression du retrait",
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
