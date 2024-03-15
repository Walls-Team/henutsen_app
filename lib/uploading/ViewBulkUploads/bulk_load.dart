// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// -------------------------------------------------------------------
// ------Provider para manejo de visualización de cargas masivas------
// -------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/load_data.dart';
import 'package:henutsen_cli/uploading/ViewBulkUploads/bulk_class.dart';
import 'package:http/http.dart' as http;

/// Estado de cargas masivas a visualizar
enum BulkLoadStatus {
  /// Inicial
  idle,

  /// Error
  error,

  /// Sin cargas
  empty,

  /// Borrando
  erasing,

  /// Acción finalizada
  finished,

  /// Recarga
  reload,
}

/// Clase de Provider para manejo de visualización de cargas
class BulkLoad extends ChangeNotifier {
  static const String _getbulkLoadEndpoint = 'ObtainLoads';

  /// Lista a presentar de cargas masivas realizadas
  List<ViewLoads> listViews = <ViewLoads>[];

  /// Estado de visualización de cargas masivas
  BulkLoadStatus bulkLoadStatus = BulkLoadStatus.idle;

  /// Limpiar estado
  void clearBulkLoadStatus() => bulkLoadStatus = BulkLoadStatus.idle;

  /// Recargar visualización
  void reloadStatus() {
    bulkLoadStatus = BulkLoadStatus.reload;
    notifyListeners();
  }

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    listViews.clear();
    clearBulkLoadStatus();
  }

  /// Obtener cargas masivas
  Future<void> viewLoads(ConfigureService configureService,
      {String? companyCode}) async {
    final queryParams = '?CompanyCode=$companyCode';
    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll({'Content-Type': 'application/json'});

    await http
        .get(
            Uri.parse(
                configureService.apiUrl + _getbulkLoadEndpoint + queryParams),
            headers: headers)
        .then((value) {
      if (value.statusCode != 200) {
        if (value.statusCode == 404) {
          bulkLoadStatus = BulkLoadStatus.empty;
        }
        bulkLoadStatus = BulkLoadStatus.error;
      } else {
        // Lista de json que devuelve el servidor
        final List<dynamic> responseJson = json.decode(value.body);
        if (responseJson.isNotEmpty) {
          ViewLoads? view;
          List<Stocktaking> auxList;
          final ubicacionesAux = <String>[];
          var assetsCount = 0;
          var locationsCount = 0;
          String? dates;
          String? userName;
          String? fileName;

          // Lista de <Stocktaking> para guardar las cargas masivas
          final loadsList = <Stocktaking>[];
          final listMap = <Stocktaking>[];
          // Lista desde el más reciente
          final listMap2 = <Stocktaking>[];
          for (final item in responseJson) {
            final dynamic temp = json.decode(item);
            if (temp is Map<String, dynamic>) {
              loadsList.add(Stocktaking.fromJson(temp));
            }
          }
          loadsList.sort((first, second) {
            final time1 = DateTime.parse(first.timeStamp!);
            final time2 = DateTime.parse(second.timeStamp!);
            return time1.compareTo(time2);
          });
          for (var i = loadsList.length - 1; i >= 0; i--) {
            final auxM = loadsList.elementAt(i);
            listMap2.add(auxM);
          }
          listViews.clear();
          ubicacionesAux.clear();
          //print(listMap2);
          for (var i = 0; i < listMap2.length; i++) {
            auxList = <Stocktaking>[];
            final aux = listMap2.elementAt(i);
            if (i == 0) {
              // Primera carga
              fileName = aux.fileName;
              userName = aux.userName;
              dates = aux.timeStamp.toString();
              ubicacionesAux.add(aux.locationName!);
              final listA = aux.assets!;
              assetsCount += listA.length;
              listMap.add(aux);
              locationsCount++;
            } else {
              if (fileName == aux.fileName) {
                for (var k = 0; k < ubicacionesAux.length; k++) {
                  if (ubicacionesAux.elementAt(k) == aux.locationName) {
                    break;
                  }
                  if (k == ubicacionesAux.length - 1) {
                    ubicacionesAux.add(aux.locationName!);
                    locationsCount++;
                  }
                }
                final listA = aux.assets!;
                assetsCount += listA.length;
                listMap.add(aux);
              } else {
                // Guardo la carga si ya no tiene mas stocks
                auxList.addAll(listMap);
                view = ViewLoads()
                  ..fileName = fileName
                  ..date = dates
                  ..quantity = assetsCount
                  ..userName = userName
                  ..locations = locationsCount
                  ..reports = auxList;
                listViews.add(view);
                assetsCount = 0;
                locationsCount = 0;
                listMap.clear();
                ubicacionesAux.clear();
                //asigno la nueva carga
                fileName = aux.fileName;
                userName = aux.userName;
                dates = aux.timeStamp.toString();
                ubicacionesAux.add(aux.locationName!);
                final listA = aux.assets!;
                assetsCount += listA.length;
                locationsCount++;
                listMap.add(aux);
              }
            }
            if (i == loadsList.length - 1) {
              view = ViewLoads()
                ..fileName = fileName
                ..date = dates
                ..quantity = assetsCount
                ..userName = userName
                ..locations = locationsCount
                ..reports = listMap;
              listViews.add(view);
              listMap.clear();
              assetsCount = 0;
              locationsCount = 0;
            }
          }
          assetsCount = 0;

          bulkLoadStatus = BulkLoadStatus.finished;
        } else {
          bulkLoadStatus = BulkLoadStatus.empty;
        }
      }
      notifyListeners();
    }).catchError((e) {
      bulkLoadStatus = BulkLoadStatus.error;
      notifyListeners();
    });
  }
}
