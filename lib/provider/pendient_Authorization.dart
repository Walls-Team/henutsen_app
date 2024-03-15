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

/// Modelo para movimientos de activos y autorizaciones
class PendientModel extends ChangeNotifier {
  /// Lista de permisos de la empresa
  List<AuthorizationPendient> authorizationsList = <AuthorizationPendient>[];

  /// Autorización en edición
  AuthorizationPendient currentAuthorization = AuthorizationPendient();

  /// Activos autorizados para traslado
  List<String> authorizedAssetsList = [];

  /// Bandera para selección múltiple de activos para autorización de traslado
  bool allSelected = false;

  /// Bandera para autorización de traslado permanente
  bool permanentAuthorization = false;

  /// Status handling to send e-mail to the user creating the authorization
  bool isToSendEmail = false;

  /// Bandera para revocación de permiso
  bool revokeAuthorization = false;

  /// Starting date for the permit deadline
  String startDate = '';

  /// Permit expiration date
  String endDate = '';

  /// Ubicación adonde se trasladan los activos
  String transferLocation = 'No aplica';

  /// Ubicación seleccionada como filtro
  String selectedLocation = '';

  /// Categoría seleccionada como filtro
  String selectedCategory = '';

  /// Estado seleccionado como filtro
  String selectedState = '';

  ///filtro para activos asociados a un usuario
  String filterUserName = '';

  ///filtro para autorizaciones
  String filterAutho = 'Todas';

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    currentAuthorization = AuthorizationPendient();
    authorizedAssetsList = <String>[];
    allSelected = false;
    permanentAuthorization = false;
    revokeAuthorization = false;
    startDate = '';
    endDate = '';
    transferLocation = 'No aplica';
    filterUserName = '';
    selectedLocation = '';
    selectedCategory = '';
    filterAutho = 'Todas';
    selectedState = '';
    currentAuthorization.assets = [];
  }

  /// Actualizar lista de activos autorizados para traslado
  void updateAuthorizationList(String asset, bool addAsset) {
    addAsset
        ? authorizedAssetsList.add(asset)
        : authorizedAssetsList.remove(asset);
    notifyListeners();
  }

  /// Limpiar lista de activos autorizados para traslado
  void clearAuthorizationList() {
    authorizedAssetsList.clear();
    notifyListeners();
  }

  ///asignar valor al filtro
  void asigneFilter(String value) {
    filterAutho = value;
    notifyListeners();
  }

  /// Actualizar autorización permanente
  void updatePermanentAuthorization(bool value) {
    permanentAuthorization = value;
    notifyListeners();
  }

  /// Actualizar autorización permanente
  void updateSendEmail(bool value) {
    isToSendEmail = value;
    notifyListeners();
  }

  /// Actualizar revocación de autorización
  void updateRevocation(bool value) {
    revokeAuthorization = value;
    notifyListeners();
  }

  /// Cambio de ubicación seleccionada para filtrado
  void changeLocation(String newLocation) {
    selectedLocation = newLocation;
    notifyListeners();
  }

  /// Cambio de categoría seleccionada para filtrado
  void changeCategory(String newCategory) {
    selectedCategory = newCategory;
    notifyListeners();
  }

  /// Cambio de estado seleccionado para filtrado
  void changeStatus(String newStatus) {
    selectedState = newStatus;
    notifyListeners();
  }

  /// Update start date
  void changeStartDate(String value) {
    startDate = value;
    notifyListeners();
  }

  /// Update end date
  void changeEndDate(String value) {
    endDate = value;
    notifyListeners();
  }

  /// Actualizar ubicación destino de transferencia
  void changeTransferLocation(String value) {
    transferLocation = value;
    notifyListeners();
  }

  /// Cambio del responsable de una autorización
  void changeCustody(String custodyPerson) {
    currentAuthorization.person = custodyPerson;
    /* final auxCustody =
        custodyPerson.split(' ')[2].replaceAll('(', '').replaceAll(')', '');*/
    filterUserName = custodyPerson;
    notifyListeners();
  }

  /// Finalizó edición de autorización
  void editDone() {
    notifyListeners();
  }

  /// Función para obtener lista de autorizaciones
  Future<String> getAuthorizations(String companyCode) async {
    // Parámetros de solicitud GET
    final paramString = '?CompanyCode=$companyCode';

    try {
      // Armar la solicitud GET/POST con la URL de la página y el parámetro
      final response = await http.get(
          Uri.parse(Config.getPendientURL + paramString),
          headers: Config.authorizationHeader(Config.userToken));

      if (response.statusCode == 200) {
        //print(response.body);
        final dynamic temp = json.decode(response.body);
        if (temp is List) {
          authorizationsList.clear();
          for (final element in temp) {
            authorizationsList.add(AuthorizationPendient.fromJson(element));
          }
          return 'Listado recibido';
        } else {
          return 'Error obteniendo autorizaciones pendientes (tipo de datos).';
        }
      } else {
        return 'Error obteniendo autorizaciones pendientes.';
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  /// Función para hacer petición POST y crear autorización
  Future<HttpHenutsenResponse> newAuthorization(String thingToSend) async {
    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll({'Content-Type': 'application/json'});
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response = await http.post(Uri.parse(Config.newPendientURL),
          body: thingToSend, headers: headers);
      return HttpHenutsenResponse.fromJson(jsonDecode(response.body));
    } on Exception {
      return HttpHenutsenResponse(
          statusCode: 500, error: true, message: 'Error del Servidor');
    }
  }

  /// Función para hacer petición PATCH y modificar la autorización
  Future<HttpHenutsenResponse> modifyAuthorization(String thingToSend) async {
    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll({'Content-Type': 'application/json'});
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response = await http.patch(Uri.parse(Config.modifyPendientURL),
          body: thingToSend, headers: headers);
      return HttpHenutsenResponse.fromJson(jsonDecode(response.body));
    } on Exception {
      return HttpHenutsenResponse(
          statusCode: 500, error: true, message: 'Error del Servidor');
    }
  }

  /// Función para eliminar autorizaciones
  Future<String> deleteAuthorization(String authorizationToDelete) async {
    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll({'Content-Type': 'application/json'});
    try {
      final response = await http.delete(Uri.parse(Config.deletePendientURL),
          body: authorizationToDelete, headers: headers);

      final result = HttpHenutsenResponse.fromJson(jsonDecode(response.body));

      if (result.statusCode == 200) {
        return 'Ok';
      } else {
        return result.message ?? 'Error en el envío';
      }
    } on Exception catch (e) {
      return 'Error del Servidor: $e';
    }
  }

  /// Function para notificar por correo al usuario que realiza una autorización
  Future<Map<String, dynamic>> sendEmailToTheAuthorizingUser(
      String emailToSend) async {
    final response = await http.post(Uri.parse(Config.sendEmail),
        body: emailToSend, headers: {'Content-Type': 'application/json'});
    return jsonDecode(response.body);
  }
}
