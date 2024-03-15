// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Ubicación para Provider------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Modelo de ubicación
class LocationModel extends ChangeNotifier {
  /// Ubicación actual en edición
  Location? tempLocation;

  /// En modo creación de ubicación
  bool creationMode = true;

  /// Nombre antiguo (para modificar ubicación)
  String oldName = '';

  // Variables para campos de texto de búsqueda
  /// Búsqueda por nombre
  String currentSearchName = '';

  /// Búsqueda por empresa
  Company currentSearchCompany = Company(addresses: [CompanyAddress()]);

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    tempLocation = null;
    creationMode = true;
    oldName = '';
    currentSearchName = '';
    currentSearchCompany = Company(addresses: [CompanyAddress()]);
  }

  /// Búsqueda de ubicación por empresa
  void changeSearchCompany(Company company) {
    currentSearchCompany = company;
    notifyListeners();
  }

  /// Búsqueda de ubicación por nombre
  void changeSearchName(String name) {
    currentSearchName = name;
    notifyListeners();
  }

/*
  void updateCompany(Company newCompany) {
    currentSearchCompany = newCompany;
    notifyListeners();
  }
*/
  /// Finalizó edición de ubicación
  void editDone() {
    notifyListeners();
  }

  /// Función para hacer petición POST y agregar sede de empresa
  Future<String> newLocation(List<PlatformFile> files2send, String thingToSend,
      String companyCode, String userName) async {
    // Armar petición multiparte
    final url = Uri.parse(Config.newLocationURL);
    final request = http.MultipartRequest('POST', url);
    // Armar la solicitud con los campos adecuados
    for (var i = 0; i < files2send.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
          'file$i', files2send[i].bytes!,
          contentType: MediaType('multipart', 'form-data'),
          filename: files2send[i].name));
    }
    // Campos adicionales
    request.fields['body'] = thingToSend;
    request.fields['CompanyCode'] = companyCode;
    request.fields['UserName'] = userName;
    final customHeaders = Config.authorizationHeader(Config.userToken)
      ..addAll({'Content-Type': 'multipart/form-data'});
    request.headers.addAll(customHeaders);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Se espera una respuesta 200
      if (streamedResponse.statusCode == 200) {
        // If the server did return a 200 OK response:
        if (response.body == 'Nueva ubicación agregada') {
          return 'Ok';
        } else {
          return response.body;
        }
      } else {
        return response.body;
      }
    } on Exception catch (e) {
      return 'Error del Servidor: $e';
    }
  }

  /// Función para modificar ubicación
  Future<String> modifyLocation(
      List<PlatformFile> files2send,
      String thingToSend,
      String companyCode,
      String userName,
      String oldLocationName) async {
    // Armar petición multiparte
    final url = Uri.parse(Config.modifyLocationURL);
    final request = http.MultipartRequest('POST', url);
    // Armar la solicitud con los campos adecuados
    for (var i = 0; i < files2send.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
          'file$i', files2send[i].bytes!,
          contentType: MediaType('multipart', 'form-data'),
          filename: files2send[i].name));
    }
    // Campos adicionales
    request.fields['body'] = thingToSend;
    request.fields['CompanyCode'] = companyCode;
    request.fields['UserName'] = userName;
    request.fields['OldLocationName'] = oldLocationName;
    final customHeaders = Config.authorizationHeader(Config.userToken)
      ..addAll({'Content-Type': 'multipart/form-data'});
    request.headers.addAll(customHeaders);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      // Se espera una respuesta 200
      if (streamedResponse.statusCode == 200) {
        if (response.body == 'Ubicación modificada') {
          return 'Ok';
        } else {
          return response.body;
        }
      } else {
        return response.body;
      }
    } on Exception catch (e) {
      return 'Error del Servidor: $e';
    }
  }

  /// Función para hacer petición DELETE y eliminar la ubicación
  Future<String> deleteLocation(
      String locationToDelete, String companyCode, String userName) async {
    final reqBody = <String, dynamic>{
      'CompanyCode': companyCode,
      'UserName': userName,
      'LocationToDelete': locationToDelete
    };
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response = await http.delete(
        Uri.parse(Config.deleteLocationURL),
        body: jsonEncode(reqBody),
        headers: Config.authorizationHeader(Config.userToken),
      );

      // Se espera una respuesta 200
      if (response.statusCode == 200) {
        if (response.body == 'Ubicación eliminada') {
          return 'Ok';
        } else {
          return response.body;
        }
      } else {
        // Proceder según respuesta
        if (response.body.startsWith("'Error")) {
          return response.body;
        } else {
          return 'Error del Servidor';
        }
      }
    } on Exception catch (e) {
      return 'Error del Servidor: $e';
    }
  }
}
