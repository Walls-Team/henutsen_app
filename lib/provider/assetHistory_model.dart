// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Transferencias para Provider-------
// ----------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;

///estados
enum statusHistory {
  ///
  idle,

  ///
  error,

  ///s
  finished
}

/// Modelo para traer el historial del activo seleccionado
class AssetHistoryModel extends ChangeNotifier {
  ///lista de historias del activo
  List<AssetHistory> assetHistory = [];

  ///activo a usar
  Asset asset = Asset();

  ///estados
  statusHistory status = statusHistory.idle;

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    asset = Asset();
    status = statusHistory.idle;
    assetHistory = [];
  }

  ///asignar el activo
  void asigneAsset(Asset value) {
    asset = value;
    notifyListeners();
  }

  /// Finalizó edición
  void editDone() {
    notifyListeners();
  }

  /// Función para obtener el historial del activo
  Future<void> getAssetHistory(String assetCode) async {
    // Parámetros de solicitud GET
    final paramString = '?AssetCode=$assetCode';

    try {
      // Armar la solicitud GET/POST con la URL de la página y el parámetro
      final response = await http.get(
          Uri.parse(Config.getHistory + paramString),
          headers: Config.authorizationHeader(Config.userToken));

      if (response.statusCode == 200) {
        //print(response.body);
        final dynamic temp = json.decode(response.body);
        if (temp is List) {
          assetHistory.clear();
          for (final element in temp) {
            assetHistory.add(AssetHistory.fromJson(element));
          }
        } else {
          status = statusHistory.error;
        }
      } else {
        status = statusHistory.error;
      }
    } on Exception {
      status = statusHistory.error;
    }
  }
}
