// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Codificador para Provider----------
// ----------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;

/// Tipo de codificador
enum EncoderType {
  /// Lector Chainway
  handheld,

  /// Escritorio
  desktop,
}

/// Modelo para la estación de codificación
// ignore: prefer_mixin
class EncoderModel with ChangeNotifier {
  /// Estación seleccionada
  String? currentEncoder;

  /// Etiqueta de activos a grabar
  List<String> tag2write = [];

  /// Información del lector
  Map<String, String> info = {
    'FirmwareVersion': '',
    'Power': '',
    'Address': '',
    'ScanTime': '',
    'FrequencyBand': '',
    'MinFrequency': '',
    'MaxFrequency': '',
    'Reader': '',
    'Protocols': ''
  };

  /// Tag ha sido detectado
  bool tagDetected = false;

  /// Tag ha sido escrito
  bool tagWritten = false;

  /// Tag detectado
  String foundTag = '';

  /// Dirección del servidor de codificación
  String serverUrl = '';

  /// Tipo de codificador seleccionado
  EncoderType encoderType = EncoderType.handheld;

  /// Contraseña por defecto para escribir tags
  String defaultPassword = '00000000';

  /// Contraseña para tags generada para esta empresa
  String currentPassword = '00000000';

  /// Bandera para indicar uso de contraseña actualizada al escribir tag
  bool isProtected = false;

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    currentEncoder = null;
    tag2write = [];
    tagDetected = false;
    tagWritten = false;
    foundTag = '';
    serverUrl = '';
    encoderType = EncoderType.handheld;
    defaultPassword = '00000000';
    currentPassword = '00000000';
    isProtected = false;
  }

  /// Asignar codificador
  void asignEncoder(String? encoder) {
    currentEncoder = encoder;
    notifyListeners();
  }

  /// Actualizar tipo de codificador
  void updateencoderType(EncoderType myEncoder) {
    encoderType = myEncoder;
    notifyListeners();
  }

  /// Cambio de detección de tag
  void changeDetection(bool detectionValue) {
    tagDetected = detectionValue;
    notifyListeners();
  }

  /// Cambio de escritura de tag
  void changeWriting(bool writingValue) {
    tagWritten = writingValue;
    notifyListeners();
  }

  /// Cambio de uso de contraseña
  void changeProtectionLevel(bool protectionValue, String cCode) {
    isProtected = protectionValue;
    if (protectionValue == true) {
      currentPassword = getTagPassword(cCode);
    }
    notifyListeners();
  }

  /// Actualizar dirección del servidor de impresión
  void updateURL(String address) {
    serverUrl = address;
    notifyListeners();
  }

  /// Agregar tag a la lista de impresión
  void addAsset(Asset asset) {
    // Para usar la clase AssetCode
    final assetCodeTemp = AssetCode()..uri = asset.assetCode!;
    // Lista de tres posiciones, con URi en formato EPC
    // (también incluye URI original y nombre del activo)
    final assetOutput = <String>[
      assetCodeTemp.asEpcHex,
      assetCodeTemp.uri,
      asset.name!
    ];
    tag2write = assetOutput;
  }

  /// Método para conectar a servidor de codificación
  Future<String> connectToServer() async {
    const endPoint = '/api/Oppiot/';
    final response = await http.post(
      Uri.parse(Config.oppiotURL),
      body: "{'action': 'connect'}",
      headers: {
        'Content-Type': 'application/json',
        'TrueEndpoint': serverUrl + endPoint,
      },
    );

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        //print(response.body);
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is bool) {
          if (fetchedData) {
            return 'Ok';
          } else {
            return 'Error de conexión al lector.';
          }
        } else {
          return 'Error de conexión al lector.';
        }
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para desconectar servidor de codificación
  Future<String> disconnectFromServer() async {
    const endPoint = '/api/Oppiot/';
    final response = await http.post(
      Uri.parse(Config.oppiotURL),
      body: "{'action': 'disconnect'}",
      headers: {
        'Content-Type': 'application/json',
        'TrueEndpoint': serverUrl + endPoint,
      },
    );

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is bool) {
          if (fetchedData) {
            return 'Ok';
          } else {
            return 'Error de conexión al lector.';
          }
        } else {
          return 'Error de conexión al lector.';
        }
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para obtener información del codificador
  Future<String> getEncoderInfo() async {
    const endPoint = '/api/Oppiot/';
    final response = await http.post(
      Uri.parse(Config.oppiotURL),
      body: "{'action': 'info'}",
      headers: {
        'Content-Type': 'application/json',
        'TrueEndpoint': serverUrl + endPoint,
      },
    );

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        //print(response.body);
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is Map) {
          info['FirmwareVersion'] = fetchedData['FirmwareVersion'];
          info['Power'] = fetchedData['Power'];
          info['Address'] = fetchedData['Address'];
          info['ScanTime'] = fetchedData['ScanTime'];
          info['FrequencyBand'] = fetchedData['FrequencyBand'];
          info['MinFrequency'] = fetchedData['MinFrequency'];
          info['MaxFrequency'] = fetchedData['MaxFrequency'];
          info['Reader'] = fetchedData['Reader'];
          info['Protocols'] = fetchedData['Protocols'];
          return 'Ok';
        } else {
          return 'Error de conexión al lector.';
        }
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para leer tag
  Future<String> readTag() async {
    const endPoint = '/api/Oppiot/';
    final response = await http.post(
      Uri.parse(Config.oppiotURL),
      body: "{'action': 'inventory'}",
      headers: {
        'Content-Type': 'application/json',
        'TrueEndpoint': serverUrl + endPoint,
      },
    );

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        //print(response.body);
        final dynamic fetchedData = response.body;
        return fetchedData.toString();
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para grabar tag
  Future<String> writeTag(String data2write) async {
    const endPoint = '/api/Oppiot/';
    final response = await http.post(
      Uri.parse(Config.oppiotURL),
      body: "{'action': 'tagWrite', 'dataToWrite': '$data2write'}",
      headers: {
        'Content-Type': 'application/json',
        'TrueEndpoint': serverUrl + endPoint,
      },
    );

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is bool) {
          if (fetchedData) {
            return 'Ok';
          } else {
            return 'Error de conexión al lector.';
          }
        } else {
          return 'Error de conexión al lector.';
        }
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para generar contraseña a partir del código de la empresa
  String getTagPassword(String companyCode) {
    final password = companyCode
        .replaceAll('-', '')
        .split('')
        .reversed
        .join('')
        .padRight(8, 'F');
    //print(password);
    return password;
  }
}
