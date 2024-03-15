// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Empresa para Provider------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/utils/regions_towns.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Estados de la empresa (en login)
enum CompanyStatus {
  /// En espera
  idle,

  /// Cargando
  loading,

  /// Cargado
  loaded,

  /// Error genérico
  error
}

/// Estado activo o inactivo de la empresa
enum CompanyActive {
  /// Empresa activa
  active,

  /// Empresa inactiva
  inactive
}

///clase para manejar el textField
class ProviderSearch extends ChangeNotifier {
  ///
  String searchFilter = '';

  ///cambiar estado para searchFilter
  void changeSearchFilter(String value) {
    searchFilter = value;
    notifyListeners();
  }

  ///cleaning data
  void clear() {
    searchFilter = '';
    notifyListeners();
  }

  ///cleaning data
  void clearWithoutNotify() {
    searchFilter = '';
  }
}

/// Modelo de empresa
class CompanyModel extends ChangeNotifier {
  /// Datos de la empresa del usuario actual
  Company currentCompany = Company();

  /// Sede seleccionada en menú
  String? currentLocation;

  /// Listado de sedes
  List<String> places = <String>[];

  /// Listado de sedes dependiendo el usuario
  List<String> placesUser = <String>[];

  /// Lista de roles de la empresa
  List<String> roleNames = <String>[];

  /// Estado actual de carga de empresa
  CompanyStatus status = CompanyStatus.idle;

  /// Lista de empresas completas
  List<Company> fullCompanyList = <Company>[];

  /// Lista temporal de roles de la empresa seleccionada
  List<String> tempRoles = <String>[];

  /// Empresa actual en edición
  Company tempCompany = Company();

  /// Estado activo o inactivo de la empresa en edición
  CompanyActive tempCompanyActive = CompanyActive.active;

  /// País de la empresa en edición
  String tempCompanyCountry = '';

  /// Departamento de la empresa en edición
  String? tempCompanyRegion;

  /// Municipio de la empresa en edición
  String? tempCompanyTown;

  /// Búsqueda por estado de empresa (activa o inactiva)
  String currentSearchStatus = 'Todas';

  /// Variable para campos de texto de búsqueda
  String currentSearchField = '';

  ///
  String leaving = '';

  ///nombre de negocio
  String nameBusiness = 'Todas';

  ///filter
  String filetBusiness = '';

  ///
  Company auxCompany = Company();

  ///
  bool creationMode = false;

  ///
  String olNameBusiness = '';

  ///
  String modifyNameBusiness = '';

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    olNameBusiness = '';
    modifyNameBusiness = '';
    auxCompany = Company();
    creationMode = false;
    nameBusiness = 'Todas';
    filetBusiness = '';
    leaving = '';
    currentCompany = Company();
    currentLocation = null;
    places = <String>[];
    roleNames = <String>[];
    status = CompanyStatus.idle;
    fullCompanyList = <Company>[];
    placesUser = <String>[];
    tempRoles = <String>[];
    tempCompany = Company();
    tempCompanyActive = CompanyActive.active;
    tempCompanyCountry = '';
    tempCompanyRegion = null;
    tempCompanyTown = null;
    currentSearchStatus = 'Todas';
    currentSearchField = '';
  }

  /// cambio de linea de negocio
  void asigneNewNameBusiness(String value, Company c) {
    nameBusiness = value;
    auxCompany = c;
    notifyListeners();
  }

  /// cambio de linea de negocio
  void asigneFilterBusiness(String value) {
    filetBusiness = value;
    notifyListeners();
  }

  ///limpiar
  void clearFilters() {
    filetBusiness = '';
    notifyListeners();
  }

  /// Cambio de sede seleccionada
  void changeLocation(String? newLocation) {
    currentLocation = newLocation;
    notifyListeners();
  }

  /// Actualizar estado activo o inactivo
  void updateCompanyMode(CompanyActive newMode) {
    tempCompanyActive = newMode;
    notifyListeners();
  }

  ///Ordenar la lista por orden alfabético
  void sortListCompany() {
    fullCompanyList.sort((a, b) =>
        a.name!.trim().toLowerCase().compareTo(b.name!.trim().toLowerCase()));
    notifyListeners();
  }

  /// Cambio de país para empresa
  void changeCountry(String newCountry) {
    tempCompanyCountry = newCountry;
    notifyListeners();
  }

  /// Cambio de departamento
  void changeRegion(String value) {
    tempCompanyRegion = value;
    notifyListeners();
  }

  /// Cambio de municipio
  void changeTown(String value) {
    tempCompanyTown = value;
    notifyListeners();
  }

  /// Reiniciar sedes
  void resetLocation() {
    currentLocation = null;
    places.clear();
    notifyListeners();
  }

  ////
  void asigneLocalPlaces() {
    placesUser
      ..clear()
      ..addAll(places);
    notifyListeners();
  }

  ///asignar sedes segun las que tenga el usuario seleccionado
  void asigneLocations(User user) {
    placesUser.clear();
    for (final itemIdR in user.roles!) {
      for (final itemC in currentCompany.roles!) {
        if (itemIdR == itemC.roleId) {
          for (final itemLocation in currentCompany.locations!) {
            if (itemC.resources!.contains(itemLocation)) {
              placesUser.add(itemLocation);
            }
          }
        }
      }
    }
    notifyListeners();
  }

  /// Agregar nuevas sedes a la empresa actual
  void loadLocations(List<dynamic> newLocations) {
    for (var i = 0; i < newLocations.length; i++) {
      places.add(newLocations.elementAt(i));
      currentCompany.locations?.add(newLocations.elementAt(i));
    }
    notifyListeners();
  }

  ///ordenar lista de ubicaciones
  void sortListLocations() {
    if (places.isNotEmpty) {
      places.sort(
          (a, b) => a.trim().toLowerCase().compareTo(b.trim().toLowerCase()));
    }
    notifyListeners();
  }

  /// Finalizó edición de empresa
  void editDone() {
    notifyListeners();
  }

  /// Obtener lista de departamentos
  List<String> loadRegions() => RegionsAndTowns().getDepartments();

  /// Obtener lista de municipios
  List<String> loadTowns(String department) =>
      RegionsAndTowns().getTowns(department);

  /// Búsqueda de empresa por estado (activa o inactiva)
  void changeSearchStatus(String status) {
    currentSearchStatus = status;
    notifyListeners();
  }

  /// Actualizar campo de búsqueda de empresa
  void changeSearchField(String value) {
    currentSearchField = value;
    notifyListeners();
  }

  /// Método para filtrar empresas en búsqueda
  List<Company> filterCompanies(String? value, List<Company> initialList) {
    var _filteredList = <Company>[];
    if (value != null && value != '') {
      // Acepta búsqueda por nombre o NIT
      _filteredList = initialList
          .where((company) =>
              company.name!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()) ||
              company.externalId!.trim().startsWith(value.trim()))
          .toList();
    } else {
      _filteredList = initialList;
    }
    return _filteredList;
  }

  ///Valida la integridad de YYYY del código gs1
  String? validatorGs1(String? value) {
    if (value!.trim().isNotEmpty) {
      if (int.tryParse(value) == null) {
        return 'El código GS1 solo debe tener números.';
      }
    }
    return null;
  }

  /// Carga de datos de empresa
  Future<void> loadCompany(String companyName) async {
    status = CompanyStatus.loading;
    final futureResult = await getCompany(companyName);
    if (futureResult == 'Empresa cargada') {
      for (final role in currentCompany.roles!) {
        roleNames.add(role.name!);
      }
      status = CompanyStatus.loaded;
    } else {
      status = CompanyStatus.error;
    }
    notifyListeners();
  }

  /// Función para obtener información de la empresa
  Future<String> getCompany(String companyId) async {
    try {
      final response = await http.get(
        Uri.parse(Config.companyDataURL + companyId),
        headers: Config.authorizationHeader(Config.userToken),
      );

      if (response.statusCode == 200) {
        final dynamic temp = json.decode(response.body);
        if (temp is Map<String, dynamic>) {
          currentCompany = Company.fromJson(temp);
          if (currentCompany.name != null) {
            return 'Empresa cargada';
          } else {
            return 'Error obteniendo datos de empresa';
          }
        } else {
          return 'Error obteniendo datos de empresa';
        }
      } else {
        return 'Error obteniendo datos de empresa';
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  /// Carga de lista de empresas
  Future<void> loadCompanies() async {
    status = CompanyStatus.loading;
    notifyListeners();
    final futureResult = await getCompanyList();
    if (futureResult == 'Listado recibido') {
      status = CompanyStatus.loaded;
    } else {
      status = CompanyStatus.error;
    }
    notifyListeners();
  }

  /// Función para obtener lista de empresas a través de HTTP
  Future<String> getCompanyList() async {
    // Parámetros de solicitud GET
    const paramString = '?Authorization=Henutsen';
    try {
      // Armar la solicitud GET/POST con la URL de la página y el parámetro
      final response = await http.get(
        Uri.parse(Config.fullCompanyDataURL + paramString),
        headers: Config.authorizationHeader(Config.userToken),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        final dynamic temp = json.decode(response.body);
        if (temp is List) {
          fullCompanyList.clear();
          for (final item in temp) {
            final comp = Company.fromJson(item);
            fullCompanyList.add(comp);
          }
          return 'Listado recibido';
        } else {
          return 'Error obteniendo empresas (tipo de datos).';
        }
      } else {
        return 'Error obteniendo empresas.';
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  /// Función para hacer petición POST y crear la empresa
  Future<String> newCompany(
      List<PlatformFile> files2send, String thingToSend) async {
    // Armar la solicitud con la URL de la página y el parámetro
    //final response = await http.post(newCompanyURL, body: thingToSend);

    // Armar petición multiparte
    final url = Uri.parse(Config.newCompanyURL);
    final request = http.MultipartRequest('POST', url);
    // Armar la solicitud con los campos adecuados
    for (var i = 0; i < files2send.length; i++) {
      request.files
          .add(http.MultipartFile.fromBytes('file$i', files2send[i].bytes!,
              //contentType: MediaType('image', 'png'),
              filename: files2send[i].name));
    }
    // Campos adicionales
    request.fields['body'] = thingToSend;
    final customHeaders = Config.authorizationHeader(Config.userToken);
    request.headers.addAll(customHeaders);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Se espera una respuesta 201 según el estándar
      if (streamedResponse.statusCode == 201) {
        //return response.body;
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is Map<String, dynamic>) {
          return 'Ok';
        } else {
          return 'Error leyendo datos del recurso creado';
        }
      } else {
        // Proceder según respuesta
        if (response.body == 'Acceso inválido' ||
            response.body == 'Empresa ya registrada') {
          return response.body;
        } else {
          return 'Error leyendo datos del recurso creado';
        }
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  /// Función para modificar empresa
  Future<String> modifyCompany(List<PlatformFile> files2send,
      String thingToSend, String companyId) async {
    // Armar petición multiparte
    final url = Uri.parse(Config.modifyCompanyURL + companyId);
    final request = http.MultipartRequest('PUT', url);
    // Armar la solicitud con los campos adecuados
    for (var i = 0; i < files2send.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
          'file$i', files2send[i].bytes!,
          contentType: MediaType('image', files2send[i].extension!),
          filename: files2send[i].name));
    }
    // Campos adicionales
    request.fields['body'] = thingToSend;
    final customHeaders = Config.authorizationHeader(Config.userToken);
    request.headers.addAll(customHeaders);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Se espera una respuesta 200 según el estándar
      if (streamedResponse.statusCode == 200) {
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is Map<String, dynamic>) {
          return 'Ok';
        } else {
          return 'Error leyendo datos del recurso modificado';
        }
      } else {
        // Proceder según respuesta
        if (response.body == 'Acceso inválido' ||
            response.body.toString().startsWith('No se pudo modificar')) {
          return response.body;
        } else {
          return 'Error leyendo datos del recurso modificado';
        }
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  ///
  Future<String> deleteBussinesLine(String name, String companyCode) async {
    final data = <String, String>{'name': name, 'CompanyCode': companyCode};

    final url = Uri.parse(Config.deleteBusinessURL);
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
  Future<String> bussinesLineSave(
      String name, String companyCode, String oldName,
      {bool creationMode = true}) async {
    final data = <String, String>{
      'name': name,
      'CompanyCode': companyCode,
      'UserName': 'user',
      'oldName': oldName
    };

    final url = Uri.parse(
        creationMode ? Config.newBusinessURL : Config.modidyBusinessURL);
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

  /// Función para hacer petición DELETE y eliminar la empresa
  /*
  Future<String> deleteCompany(String companyId) async {
    // Armar la solicitud con la URL de la página y el parámetro
    final response =
        await http.delete(Uri.parse(Config.deleteCompanyURL + companyId));

    // Se espera una respuesta 204 según el estándar
    if (response.statusCode == 204) {
      return 'Ok';
    } else {
      // Proceder según respuesta
      if (response.body.startsWith("'Error")) {
        return response.body;
      } else {
        return 'Error del Servidor';
      }
    }
  }
  */
}
