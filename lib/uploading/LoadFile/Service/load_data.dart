// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------------------------------
// -------Clase y métodos para procesar carga de masiva de activos-------------
// ----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:http/http.dart' as http;

/// Posibles estados específicos de carga del archivo
enum DataFileStatus {
  /// Inactivo
  idle,

  /// Archivo preparado para carga
  prepared,

  /// Error en carga
  error,

  /// Carga finalizada
  finished,

  /// Cancelación de carga
  cancel,
}

///load data file csv
class LoadDataProvider extends ChangeNotifier {
  /// Estado de carga
  DataFileStatus statusLoadData = DataFileStatus.idle;

  // EndPoint LoadFileData
  static const String _loadFileEndpoint = 'FileLoad';
  static const String _reviewFileEndpoint = 'ReviewFile';
  static const String _deleteFile = 'DeleteFile';
  static const String _saveNewLocations = 'SaveNewLocations';

  /// Número para saber qué despliegue de estadística voy a hacer
  /// 0: general, 1: errores, 2: duplicados, 3: activos totales
  int summary = 0;

  /// Cambiar resumen a mostrar
  void changeSummary(int value) {
    summary = value;
    notifyListeners();
  }

  /// Volver al estado de carga inicial
  void clear() {
    statusLoadData = DataFileStatus.idle;
    summary = 0;
    notifyListeners();
  }

  /// Cancelar carga
  void cancelFile() {
    statusLoadData = DataFileStatus.cancel;
    notifyListeners();
  }

  /// Revisar si archivo a cargar ya está en la BD
  Future<String> reviewFile(
      ConfigureService configuration, String fileName, String code) async {
    assert(fileName != '', 'No hay nombre de archivo');
    statusLoadData = DataFileStatus.prepared;
    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll({'code': code});
    notifyListeners();
    try {
      final response = await http.post(
          Uri.parse(configuration.apiUrl + _reviewFileEndpoint),
          body: fileName,
          headers: headers);
      if (response.statusCode == 200) {
        final request = response.body;
        return request;
      } else {
        throw Exception('Error del Servidor');
      }
    } on Exception catch (e) {
      return 'Error: $e';
    }
  }

  /// Borrar archivo ya cargado en la DB
  Future<String> deleteFile(
      ConfigureService configuration, String fileName) async {
    assert(fileName != '', 'No hay nombre de archivo');
    statusLoadData = DataFileStatus.prepared;
    notifyListeners();
    try {
      final response = await http.delete(
          Uri.parse(configuration.apiUrl + _deleteFile),
          body: fileName,
          headers: Config.authorizationHeader(Config.userToken));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Error del Servidor');
      }
    } on Exception catch (e) {
      return 'Error: $e';
    }
  }

  /// Guardar nuevas ubicaciones encontradas en el archivo
  Future<String> sendLocations(
      ConfigureService configuration, String jsonFormat, String cCode) async {
    assert(cCode != '', 'No hay código de empresa');
    statusLoadData = DataFileStatus.prepared;
    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll({'CodeC': cCode});
    notifyListeners();
    try {
      final response = await http.patch(
          Uri.parse(configuration.apiUrl + _saveNewLocations),
          body: jsonFormat,
          headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Error del Servidor');
      }
    } on Exception catch (e) {
      return 'Error: $e';
    }
  }

  /// Enviar archivo
  Future<void> sendFormattedData(
      ConfigureService configuration,
      dynamic dataFileJson,
      String user,
      String companyCode,
      String fileName,
      String date) async {
    assert(dataFileJson != null || dataFileJson != '', 'dataFileJson Not Null');

    statusLoadData = DataFileStatus.prepared;
    notifyListeners();

    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll({'Content-Type': 'application/json'});

    const _loadSystem = 'EXCEL';
    // Armar parámetros
    final queryParams =
        '?CompanyCode=$companyCode&Name=$user&System=$_loadSystem&'
        'FileName=$fileName&Date=$date';
    await http
        .post(Uri.parse(configuration.apiUrl + _loadFileEndpoint + queryParams),
            body: dataFileJson, headers: headers)
        .then((response) {
      if (response.statusCode != 200) {
        statusLoadData = DataFileStatus.error;
      } else {
        statusLoadData = DataFileStatus.finished;
      }
      notifyListeners();
    }).catchError((onError) {
      statusLoadData = DataFileStatus.error;
      notifyListeners();
      //print(onError);
    });
  }
}

/// Clase para invocar servicios
class ConfigureService {
  /// Constructor
  const ConfigureService(this._resourceApi)
      : assert(_resourceApi != '', 'resourceApi Not Null');

  final String _resourceApi;

  /// URL del servicio
  String get apiUrl => _resourceApi;
}
