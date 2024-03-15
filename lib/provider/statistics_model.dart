// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -----Reportes y estadísticas de los inventarios-----
// ----------------------------------------------------

import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;

/// Status
enum MainStatisticsStatus {
  /// Inicial
  idle,

  /// Error
  error,

  /// Sin información
  empty,

  /// Carga completa
  finished,

  /// Recargar
  reload
}

/// Modos de visualización de estadísticas
enum StatisticsMode {
  /// Visualizar por conteos realizados
  stocktaking,

  /// Visualizar por ubicaciones
  location,
}

/// Clase para obtener las estadísticas
class StatisticsModel extends ChangeNotifier {
  /// Reporte total obtenido de activos
  AssetsReport fullStatisticsLoad = AssetsReport();

  // Reporte de activos de la ubicación actual
  //AssetsReport _currentLocationStatistics;
  //AssetsReport get currentLocationStatistics => _currentLocationStatistics;

  /// Lista de activos no encontrados filtrados
  List<Asset> filteredMissingAssetsList = [];

  /// Lista de todos los activos no encontrados
  List<Asset> allMissingAssetsList = [];

  /// Lista de todos los activos fuera de ubicación
  List<Asset> allOutOfLocationAssetsList = [];

  /// Lista de todos los activos fuera de ubicación
  List<Asset> inAutorizationAsset = [];

  /// Lista de todos los conteos realizados
  List<Stocktaking> stocktakingList = [];

  /// Status de carga de estadísticas
  MainStatisticsStatus mainStatisticsStatus = MainStatisticsStatus.idle;

  /// Modo de visualización seleccionado
  StatisticsMode statisticsMode = StatisticsMode.stocktaking;

  /// Variable para selección de ubicación
  String currentLocation = 'Todas';

  ///
  String currentStatus = 'Todos';

  /// Lista de todos los activos detectados como fuera de ubicación
  //List<Asset> allAssetsOut = [];

  /// Mapa de posibles campos en reportes generados
  Map selectableFieldsList = <String, bool>{
    'Código de activo': true,
    'Nombre': true,
    'Descripción': true,
    'Ubicación': true,
    'Estado': true,
    'Categoría': true,
    'Fabricante': false,
    'Modelo': false,
    'Número serial': true,
    'Responsable': false,
    'Último conteo': true,
    'Último movimiento detectado': true,
    'Código heredado': false
  };

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    fullStatisticsLoad = AssetsReport();
    filteredMissingAssetsList = [];
    inAutorizationAsset = [];
    allOutOfLocationAssetsList = [];
    allMissingAssetsList = [];
    stocktakingList = [];
    mainStatisticsStatus = MainStatisticsStatus.idle;
    statisticsMode = StatisticsMode.stocktaking;
    currentLocation = 'Todas';
    currentStatus = 'Todos';
    //allAssetsOut = [];
  }

  ///asignar ubicaion
  void asigneLocation(String value) {
    currentLocation = value;
    notifyListeners();
  }

  /// Método para establecer estado inicial
  void clearStatus() {
    mainStatisticsStatus = MainStatisticsStatus.idle;
    notifyListeners();
  }

  /// Actualizar modo de visualización
  void updateStatisticsMode(StatisticsMode mode) {
    statisticsMode = mode;
    notifyListeners();
  }

  /// Actualizar selección de campos
  // ignore: avoid_positional_boolean_parameters
  void updateFieldSelection(String field, bool value) {
    selectableFieldsList[field] = value;
    notifyListeners();
  }

  /// Método para filtrar los activos faltantes
  void filterMissingAssets(String value) {
    filteredMissingAssetsList = allMissingAssetsList;
    if (value.isNotEmpty) {
      filteredMissingAssetsList = filteredMissingAssetsList
          .where((asset) =>
              asset.name!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()) ||
              asset.locationName!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()) ||
              asset.status!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()) ||
              asset.lastStocktaking!.userName
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()))
          .toList();
    } else {
      filteredMissingAssetsList = allMissingAssetsList;
    }
    notifyListeners();
  }

  /// Obtener estadísticas básicas
  Future<void> viewIndicator(String companyCode, String listLocations,
      {String locationName = ''}) async {
    final queryParams = '?CompanyCode=$companyCode&LocationName=$locationName&'
        'Locations=$listLocations';
    final headers = Config.authorizationHeader(Config.userToken);
    headers['Content-Type'] = 'application/json';
    await http
        .get(Uri.parse(Config.statisticsURL + queryParams), headers: headers)
        .then((value) {
      if (value.statusCode == 200 || value.statusCode == 404) {
        if (value.body.isNotEmpty) {
          fullStatisticsLoad = AssetsReport.fromJson(jsonDecode(value.body));
          // Extraer lista de elementos perdidos del reporte obtenido
          allMissingAssetsList = fullStatisticsLoad.missingAssetsList ??
              List<Asset>.empty(growable: true);
          allOutOfLocationAssetsList =
              fullStatisticsLoad.outOfLocationAssetsList ??
                  List<Asset>.empty(growable: true);
          inAutorizationAsset = fullStatisticsLoad.inAutorizationAssetsList ??
              List<Asset>.empty(growable: true);
          filteredMissingAssetsList = allMissingAssetsList;
          mainStatisticsStatus = MainStatisticsStatus.finished;
        } else {
          mainStatisticsStatus = MainStatisticsStatus.empty;
        }
      } else {
        mainStatisticsStatus = MainStatisticsStatus.error;
      }
      notifyListeners();
    }).catchError((e) {
      //print(e);
      mainStatisticsStatus = MainStatisticsStatus.error;
      notifyListeners();
    });
  }

  ///cambiar [currentStatus]
  void changeCurrentStatus(String value) {
    currentStatus = value;
    notifyListeners();
  }

  ///
  void changeFilterAsset(List<Asset> listA) {
    filteredMissingAssetsList = listA;
    notifyListeners();
  }
  // Método para filtrar reporte por ubicación
  /*
  void filterAssetsReport(String value) {
    if (value != 'Todas') {
      for (final item in _fullStatisticsLoad) {
      _currentLocationStatistics = _fullStatisticsLoad;
    } else {
      _currentLocationStatistics = _fullStatisticsLoad;
    }
    notifyListeners();
  }
  */

  /// Función para obtener conteos de inventario a través de HTTP
  Future<String> getStocktakingReports(String companyCode,
      {String date1 = '', String date2 = ''}) async {
    // Parámetros de solicitud GET
    final paramString = '?CompanyCode=$companyCode'
        '&InitialDate=$date1&FinalDate=$date2';
    try {
      // Armar la solicitud GET con la URL de la página y el parámetro
      final response = await http.get(
        Uri.parse(Config.getStocktakingURL + paramString),
        headers: Config.authorizationHeader(Config.userToken),
      );

      if (response.statusCode == 200) {
        final dynamic tempList = json.decode(response.body);
        if (tempList is List) {
          final numCont = tempList.length;
          stocktakingList.clear();
          for (var i = 0; i < numCont; i++) {
            final dynamic temp = tempList[i];
            if (temp is Map<String, dynamic>) {
              final conteo = Stocktaking.fromJson(temp);
              stocktakingList.add(conteo);
            }
          }
          return 'Inventario recibido';
        } else {
          return 'Error obteniendo inventarios (tipo de datos).';
        }
      } else {
        return 'Error obteniendo inventarios.';
      }
    } on Exception {
      return 'Error del servidor.';
    }
  }

  /// Indicar pérdidas por ubicación según último reporte
  Map<String, int> lossesPerLocation(List<String> locationsList) {
    final lossesXLocation = <String, int>{};

    for (final item in locationsList) {
      // Buscamos el informe más reciente para cada ubicación
      DateTime? _mostRecentDate;
      var _notFoundAssets = 0;
      for (final subitem in stocktakingList) {
        if (subitem.locationName == item) {
          var _includeReport = false;
          // La primera vez se asigna la fecha del item actual
          if (_mostRecentDate == null) {
            _mostRecentDate = DateTime.parse(subitem.timeStamp!);
            _includeReport = true;
          } else {
            // Si la fecha del ítem actual es más reciente que la guardada,
            // la reemplaza
            if (DateTime.parse(subitem.timeStamp!).isAfter(_mostRecentDate)) {
              _mostRecentDate = DateTime.parse(subitem.timeStamp!);
              _includeReport = true;
            }
          }
          // Si es el reporte más reciente hasta el momento, contamos sus
          // activos no encontrados
          if (_includeReport) {
            _notFoundAssets = 0;
            for (final asset in subitem.assets!) {
              if (asset.findStatus == 'No Encontrado') {
                _notFoundAssets++;
              }
            }
          }
        }
      }
      lossesXLocation.putIfAbsent(item, () => _notFoundAssets);
    }
    return lossesXLocation;
  }

  /// Calcular pérdidas promedio por año
  Map<String, double> averageLossesPerYear(
      String year, List<String> locationsList) {
    final averageLossesYearLocation = <String, double>{};

    // Hacer listado únicamente de los conteos del año ingresado
    final _currentYearStocktaking = <Stocktaking>[];
    for (final item in stocktakingList) {
      if (DateTime.parse(item.timeStamp!).year.toString() == year) {
        _currentYearStocktaking.add(item);
      }
    }

    // Calculamos promedio de pérdidas por cada ubicación
    for (final item in locationsList) {
      var _numReports = 0;
      var _numLosses = 0;
      for (final subitem in _currentYearStocktaking) {
        if (subitem.locationName == item) {
          _numReports++;
          for (final asset in subitem.assets!) {
            if (asset.findStatus == 'No Encontrado') {
              _numLosses++;
            }
          }
        }
      }
      var _average = 0.0;
      if (_numReports != 0) {
        _average = _numLosses / _numReports;
      }
      averageLossesYearLocation.putIfAbsent(item, () => _average);
    }
    return averageLossesYearLocation;
  }
}

/// Clase para el manejo del histograma
class LossesHistogram {
  /// Ubicación
  String location;

  /// Número de pérdidas
  int losses;

  /// Color a utilizar
  charts.Color color;

  /// Constructor
  // ignore: sort_constructors_first
  LossesHistogram(this.location, this.losses, Color color)
      : color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

/// Clase para manejo de diagramas de pastel
class AssetPieInfo {
  /// Número de etiqueta
  int? labelNumber;

  /// Número de activos de interés para la gráfica
  int? assetsNumber;

  /// Total de activos
  int? totalAssets;

  /// Trabajar como porcentajes
  int? assetsPercentage;

  /// Color a usar
  charts.Color? color;

  /// Constructor
  // ignore: sort_constructors_first
  AssetPieInfo(
      this.labelNumber, this.assetsNumber, this.totalAssets, this.color) {
    try {
      //print("Porc " + assetsNumber.toString() + " " + totalAssets.toString());
      assetsPercentage = (assetsNumber! / totalAssets! * 100).round();
    } on Exception {
      assetsPercentage = 0;
    }
  }
}
