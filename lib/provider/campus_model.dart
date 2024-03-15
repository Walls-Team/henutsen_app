// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Sede para Provider------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;

///Status para saber si estoy editando o creando
enum Status {
  ///Creacion
  creationMode,

  ///Modificacion
  editMode
}

/// clase para manejar las sedes en el cliente y servidor
class CampusModel extends ChangeNotifier {
  ///Lista de sedes a mostrar
  List<Campus> campusList = [];

  ///Lista de nombres de compañias a mostrar
  List<String> filterNamesC = [];

  ///Lista de lineas de negocio a mostrar
  List<String> filterNamesB = [];

  ///objecto de sede a crear o modificar
  Campus campus = Campus();

  ///filtro por empresa
  String filterCompany = '';

  ///filtro por linea de negocio
  String filterBusiness = 'Todas';

  ///filtro por linea de negocio
  String filterCompanyCode = '';

  ///estado con el que se va a crear o editar
  Status statusCreation = Status.creationMode;

  ///reiniciar variables
  void resetAll() {
    filterBusiness = 'Todas';
    filterCompany = '';
    filterCompanyCode = '';
    statusCreation = Status.creationMode;
    campus = Campus();
    campusList = [];
    filterNamesC = [];
    filterNamesB = [];
  }

  ///asignar objecto de creacion o edicion
  void asigneCampus(Campus campusValue) {
    campus = campusValue;
    notifyListeners();
  }

  ///refresco
  void editDone() {
    notifyListeners();
  }

  ///llenar lista inicial de nombres a mostrar
  void initFilters(String nameC, Company c, List<Company> listC, int opt) {
    filterCompany = nameC;
    filterCompanyCode = c.companyCode!;
    if (opt == 1) {
      for (final company in listC) {
        filterNamesC.add(company.name!);
      }
    } else {
      filterNamesC.add(c.name!);
    }
    filterNamesB.add('Todas');
    // ignore: prefer_foreach
    for (final nameB in c.businessLines!) {
      filterNamesB.add(nameB);
    }
    notifyListeners();
  }

  ///cambiar nombre de empresa y llenar la lista con sus lineas de negocio
  void changeNameC(String value, Company c) {
    filterCompany = value;
    filterCompanyCode = c.companyCode!;
    filterNamesB
      ..clear()
      ..add('Todas');
    // ignore: prefer_foreach
    for (final nameB in c.businessLines!) {
      filterNamesB.add(nameB);
    }
    notifyListeners();
  }

  /// Método para filtrar sedes en búsqueda
  List<Campus> filterUsers(String? value, List<Campus> initialList) {
    var _filteredList = <Campus>[];
    if (value != null && value != '') {
      // Acepta búsqueda por correo, nombre o documento
      _filteredList = initialList
          .where((campus) =>
              campus.name!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()) ||
              campus.name!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()))
          .toList();
    } else {
      _filteredList = initialList;
    }
    return _filteredList;
  }

  ///cambiar nombre de la linea de negocio
  void changeNameB(String value) {
    filterBusiness = value;
    notifyListeners();
  }

  ///asignar status
  void asigneStatus(Status statusValue) {
    statusCreation = statusValue;
    notifyListeners();
  }

  ///asignar filtro Empresa
  void asigneFilterCompany(String nameValue) {
    filterCompany = nameValue;
    notifyListeners();
  }

  ///asignar filtro Empresa
  void asigneFilterBusiness(String nameValue) {
    filterBusiness = nameValue;
    notifyListeners();
  }

  ///traer todas las sedes
  Future<void> getListCampus() async {
    campusList.clear();
    try {
      final response = await http.get(Uri.parse(Config.getCampusListURL),
          headers: Config.authorizationHeader(Config.userToken));
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          final dynamic body = jsonDecode(response.body);
          if (body is List) {
            for (final campus in body) {
              final objectCampus = Campus.fromJson(campus);
              campusList.add(objectCampus);
            }
          }

          notifyListeners();
        }
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      campusList.clear();
      notifyListeners();
    }
  }

  ///funcion para eliminar una sede
  Future<String> deleteCampus(String id) async {
    try {
      final response = await http.delete(Uri.parse(Config.deleteCampusURL),
          body: id, headers: Config.authorizationHeader(Config.userToken));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.toString();
      } else {
        return response.body;
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  ///funcion para guardar o editar una sede
  Future<String> saveCampus(Campus c, List<PlatformFile> files2send,
      {bool creation = true}) async {
    // Armar petición multiparte
    final url =
        Uri.parse(creation ? Config.saveCampusURL : Config.modifyCampusURL);
    final request = http.MultipartRequest(creation ? 'POST' : 'PUT', url);
    // Armar la solicitud con los campos adecuados
    for (var i = 0; i < files2send.length; i++) {
      request.files
          .add(http.MultipartFile.fromBytes('file$i', files2send[i].bytes!,
              //contentType: MediaType('image', 'png'),
              filename: files2send[i].name));
    }

    // Campos adicionales
    request.fields['Body'] = jsonEncode(c);
    final customHeaders = Config.authorizationHeader(Config.userToken);
    request.headers.addAll(customHeaders);
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.body.toString();
      } else {
        return response.body;
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
