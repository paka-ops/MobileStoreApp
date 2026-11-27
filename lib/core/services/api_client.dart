import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// ============================================================================
/// API CLIENT — transport HTTP unique de l'application.
///
/// Ce composant ne contient **aucune règle métier** : il construit la requête
/// (URL, en-têtes, corps JSON), applique le délai d'attente et renvoie une
/// [ApiResponse] brute, sans jamais lever d'exception sur un code d'erreur
/// HTTP. C'est exactement le contrat implicite des services existants, qui
/// inspectent `statusCode` puis décident du message à afficher.
///
/// Il est introduit à l'étape 2 comme socle technique ; son adoption par les
/// neuf services (`lib/data/services/`) a lieu lors de la réécriture des
/// modules métier, à requêtes strictement identiques :
///
///   GET  /v1/stores           → getStoresByUser
///   POST /v1/orders?storeId=… → createOrder
///   …
///
/// Aucun écran, aucun service n'est modifié aujourd'hui : brancher ce client
/// ne change donc pas le comportement observable de l'application.
/// ============================================================================
class ApiClient {
  ApiClient({
    this.baseUrl = AppConfig.apiBaseUrl,
    this.defaultTimeout = AppConfig.timeoutStandard,
  });

  /// Racine des endpoints, sans slash final (ex. `http://host:8080/api`).
  final String baseUrl;

  /// Délai appliqué lorsqu'un appel n'en précise pas un.
  final Duration defaultTimeout;

  // ---------------------------------------------------------------------------
  // URL & EN-TÊTES
  // ---------------------------------------------------------------------------

  /// Construit l'URL d'un chemin relatif : `"/v1/stores"` → `baseUrl/v1/stores`.
  Uri uri(String path) => Uri.parse('$baseUrl$path');

  /// En-tête d'authentification, omis lorsque le jeton est absent (comportement
  /// historique : `"Authorization": "Bearer null"` n'est jamais envoyé).
  static Map<String, String> authHeaders(String? token) => <String, String>{
        if (token != null) AppConfig.authorizationHeader: '${AppConfig.bearerPrefix} $token',
      };

  /// En-tête d'authentification + corps JSON.
  static Map<String, String> jsonHeaders(String? token) => <String, String>{
        ...authHeaders(token),
        'content-type': 'application/json',
      };

  /// En-tête d'authentification + formulaire encodé (connexion).
  static Map<String, String> formHeaders() => <String, String>{
        'content-type': 'application/x-www-form-urlencoded',
      };

  // ---------------------------------------------------------------------------
  // VERBES HTTP
  // ---------------------------------------------------------------------------

  /// `GET path`
  Future<ApiResponse> get(
    String path, {
    String? token,
    Map<String, String>? headers,
    Duration? timeout,
  }) =>
      _send(
        'GET',
        path,
        token: token,
        headers: headers,
        timeout: timeout,
      );

  /// `POST path` avec un corps JSON optionnel.
  Future<ApiResponse> post(
    String path, {
    Object? body,
    String? token,
    Map<String, String>? headers,
    Duration? timeout,
  }) =>
      _send(
        'POST',
        path,
        body: body,
        token: token,
        headers: headers,
        timeout: timeout,
      );

  /// `PATCH path` avec un corps JSON optionnel.
  Future<ApiResponse> patch(
    String path, {
    Object? body,
    String? token,
    Map<String, String>? headers,
    Duration? timeout,
  }) =>
      _send(
        'PATCH',
        path,
        body: body,
        token: token,
        headers: headers,
        timeout: timeout,
      );

  /// `PUT path` avec un corps JSON optionnel.
  Future<ApiResponse> put(
    String path, {
    Object? body,
    String? token,
    Map<String, String>? headers,
    Duration? timeout,
  }) =>
      _send(
        'PUT',
        path,
        body: body,
        token: token,
        headers: headers,
        timeout: timeout,
      );

  /// `DELETE path`
  Future<ApiResponse> delete(
    String path, {
    String? token,
    Map<String, String>? headers,
    Duration? timeout,
  }) =>
      _send(
        'DELETE',
        path,
        token: token,
        headers: headers,
        timeout: timeout,
      );

  // ---------------------------------------------------------------------------
  // EXÉCUTION
  // ---------------------------------------------------------------------------

  Future<ApiResponse> _send(
    String method,
    String path, {
    Object? body,
    String? token,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final Duration delay = timeout ?? defaultTimeout;
    final Uri target = uri(path);
    final Map<String, String> effectiveHeaders =
        headers ?? authHeaders(token);
    final String? payload = body == null ? null : jsonEncode(body);

    Future<http.Response> request() {
      switch (method) {
        case 'GET':
          return http.get(target, headers: effectiveHeaders);
        case 'POST':
          return http.post(target, headers: effectiveHeaders, body: payload);
        case 'PATCH':
          return http.patch(target, headers: effectiveHeaders, body: payload);
        case 'PUT':
          return http.put(target, headers: effectiveHeaders, body: payload);
        case 'DELETE':
          return http.delete(target, headers: effectiveHeaders);
        default:
          throw ArgumentError.value(method, 'method', 'Verbe HTTP non supporté');
      }
    }

    final http.Response response = await request().timeout(delay);
    return ApiResponse(statusCode: response.statusCode, body: response.body);
  }
}

/// ============================================================================
/// API RESPONSE — réponse brute et classification des codes de l'API.
///
/// Les catégories reprennent exactement les décisions prises par les services
/// historiques : 401 et 402 déclenchent le message d'abonnement expiré, 409 est
/// le conflit de rupture de stock, le reste est traité comme une erreur
/// générique.
/// ============================================================================
class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  /// `true` pour toute réponse 2xx.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// `true` pour un succès de lecture (200).
  bool get isOk => statusCode == AppConfig.statusOk;

  /// `true` pour une création (201).
  bool get isCreated => statusCode == AppConfig.statusCreated;

  /// `true` pour une suppression sans contenu (204).
  bool get isNoContent => statusCode == AppConfig.statusNoContent;

  /// `true` lorsque la session doit être considérée comme expirée
  /// (401 ou 402 — comportement historique identique).
  bool get isSubscriptionExpired =>
      statusCode == AppConfig.statusUnauthorized ||
      statusCode == AppConfig.statusSubscriptionExpired;

  /// `true` en cas de conflit métier (rupture de stock).
  bool get isConflict => statusCode == AppConfig.statusConflict;

  /// Corps décodé (`null` si le corps est vide). Peut lever si le corps n'est
  /// pas du JSON : l'appelant gère, comme les services actuels.
  dynamic get json => body.isEmpty ? null : jsonDecode(body);

  /// Corps décodé sous forme de map, ou `null`.
  Map<String, dynamic>? get jsonMap {
    final dynamic decoded = json;
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  /// Corps décodé sous forme de liste, ou `null`.
  List<dynamic>? get jsonList {
    final dynamic decoded = json;
    return decoded is List<dynamic> ? decoded : null;
  }
}
