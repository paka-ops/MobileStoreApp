import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_store_app/main.dart';

class GlobalErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // On cible l'erreur "Unable to fetch" / Problème de connexion
    if (err.type == DioExceptionType.connectionError || err.error is SocketException) {

      // On appelle ton message spécifique via la clé globale
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue lors de la liaison avec le serveur. "
              "Assurez-vous d'être connecté à Internet ou contactez votre "
              "administrateur si le problème persiste."),
          backgroundColor: Colors.red,
        ),
      );
    }

    // On laisse l'erreur continuer son chemin (pour la logique interne si besoin)
    return handler.next(err);
  }
}