// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Sede para Provider------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;

///Status para saber si estoy editando o creando
enum StatusArea {
  ///Creacion
  creationMode,

  ///Modificacion
  editMode
}

/// clase para manejar las sedes en el cliente y servidor
class AreaModel extends ChangeNotifier {
  ///objecto de sede a crear o modificar
  Campus campus = Campus();

  ///objecto de sede a crear o modificar
  List<String> campusName = [];

  ///objecto de sede a crear o modificar
  List<String> companyName = [];

  ///nombre de company
  String nameC = '';

  ///filtro por empresa
  String filterNameSede = '';

  ///filtro por empresa
  String oldName = '';

  ///filtro por empresa
  String createName = '';

  ///filtro por linea de negocio
  String idSede = '';

  ///estado con el que se va a crear o editar
  StatusArea statusCreation = StatusArea.creationMode;

  ///reiniciar variables
  void resetAll() {
    oldName = '';
    createName = '';
    nameC = '';
    companyName = [];
    campusName = [];
    filterNameSede = '';
    idSede = '';
    statusCreation = StatusArea.creationMode;
    campus = Campus();
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

  ///cambiar nombre de company
  void changeNameC(String value) {
    nameC = value;
    notifyListeners();
  }

  ///asignar nombres filtrados
  void asingeNewNames(List<Campus> cs) {
    campusName.clear();
    for (final item in cs) {
      campusName.add(item.name!);
    }
    if (cs.isNotEmpty) {
      campus = cs[0];
    } else {
      if (campus.name != '') {
        campus = Campus();
      }
    }
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

  ///asignar status
  void asigneStatus(StatusArea statusValue) {
    statusCreation = statusValue;
    notifyListeners();
  }

  ///iniciar nombres de sedes y compañias
  void initFilter(List<Campus> ca, List<Company> lC) {
    ///llenar lista de nombres para sedes
    campusName.clear();
    for (final item in ca) {
      campusName.add(item.name!);
    }

    ///llenar lista de nombres para compañias
    companyName.clear();
    for (final item in lC) {
      companyName.add(item.name!);
    }
    notifyListeners();
  }

  ///
  Future<String> deleteArea(String name, String sedeCode) async {
    final data = <String, String>{'name': name, 'SedeCode': sedeCode};

    final url = Uri.parse(Config.deleteAreaURL);
    try {
      final response = await http.post(url,
          body: jsonEncode(data),
          headers: Config.authorizationHeader(Config.userToken));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        return response.body;
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return e.toString();
    }
  }

  ///
  Future<String> saveArea(String name, String sedeCode, String oldName,
      {bool creationMode = true}) async {
    final data = <String, String>{
      'name': name,
      'SedeCode': sedeCode,
      'UserName': 'user',
      'oldName': oldName
    };

    final url =
        Uri.parse(creationMode ? Config.saveAreaURL : Config.modifyAreaURL);
    try {
      final response = await http.post(url,
          body: jsonEncode(data),
          headers: Config.authorizationHeader(Config.userToken));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        return response.body;
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return e.toString();
    }
  }
}
