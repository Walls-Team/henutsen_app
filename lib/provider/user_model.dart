// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// ---------Modelo de Usuario para Provider------------
// ----------------------------------------------------

import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;

/// Estados del usuario (en login)
enum UserStatus {
  /// En espera
  idle,

  /// Cargando
  loading,

  /// Cargado
  loaded,

  /// Error de contraseña
  passwordError,

  /// Usuario no autorizado
  userNotAuthorized,

  /// Usuario no activo
  userNotActive,

  /// Error genérico
  error
}

/// Estado activo o inactivo del usuario
enum UserActive {
  /// Usuario activo
  active,

  /// Usuario inactivo
  inactive,
}

/// Modelo para el usuario
class UserModel extends ChangeNotifier {
  /// Nombre del usuario a mostrar en pantalla
  String name2show = '';

  /// Correo del usuario
  String? userName;

  /// Contraseña del usuario
  String? password;

  /// Bandera para indicar si contraseña es visible
  bool visiblePassword = false;

  /// Información del usuario actual en sesión
  User currentUser = User();

  /// Rol del usuario actual
  List<String> currentUserRole = <String>[];

  /// Estado actual de carga de usuario
  UserStatus status = UserStatus.idle;

  /// Datos del usuario en creación/modificación
  User tempUser = User();

  /// Rol actual seleccionado del usuario en creación/modificación
  String? tempRole;

  /// Empresa actual seleccionada para usuario en creación/modificación
  String? tempCompany;

  /// ID de empresa actual seleccionada para usuario en creación/modificación
  String? tempCompanyID;

  /// Tipo de documento del usuario en creación/modificación
  String? docType;

  /// Número de documento del usuario en creación/modificación
  String docNum = '';

  /// Bandera que me dice si el check esta presionado o no para la
  /// pantalla de ayuda actual
  bool helpScreen = false;

  /// Bandera para pantalla de ayuda Carga Masivas
  bool uploadingHelp = true;

  /// Bandera para pantalla de ayuda Conteo
  bool stocktakingHelp = true;

  /// Bandera para pantalla de ayuda indicadorGestion
  bool statisticsHelp = true;

  /// Bandera para pantalla de ayuda indicadorGestion
  bool printingHelp = true;

  /// Bandera para pantalla de ayuda gestion
  bool managementHelp = true;

  /// Bandera para pantalla de ayuda codificar
  bool encodingHelp = true;

  /// Bandera para pantalla de ayuda codificar
  bool configurationHelp = true;

  /// Lista completa de usuarios
  List<User> fullUsersList = <User>[];

  /// Lista de nombres de usuarios de la empresa actual
  List<String> localUsersList = <String>[];

  /// Tipos de documento posibles
  final List<String> documentType = [
    'Cédula de ciudadanía',
    'Cédula de extranjería',
    'Tarjeta de identidad'
  ];

  /// Estado activo o inactivo del usuario en edición
  UserActive tempUserActive = UserActive.active;

  /// Contraseña del usuario en edición
  String tempPassword = '';

  /// Mensaje a mostrar al recuperar contraseña
  String recoveryMessage = '';

  /// Variable para campo de texto de búsqueda
  String currentSearchField = '';

  /// Búsqueda por empresa
  String currentSearchCompany = 'Todas';

  /// Búsqueda por rol
  String currentSearchRole = 'Todos';

  /// Búsqueda por ID de empresa
  String? currentSearchCompanyID;

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    name2show = '';
    currentUser = User();
    currentUserRole.clear();
    status = UserStatus.idle;
    tempUser = User();
    tempRole = null;
    tempUserActive = UserActive.active;
    tempPassword = '';
    tempCompany = null;
    tempCompanyID = null;
    docType = null;
    docNum = '';
    currentSearchField = '';
    currentSearchCompany = 'Todas';
    currentSearchRole = 'Todos';
    currentSearchCompanyID = null;
    password = '';
    visiblePassword = false;
    fullUsersList = <User>[];
    localUsersList = <String>[];
    helpScreen = false;
    // Banderas de páginas de ayuda
    uploadingHelp = true;
    stocktakingHelp = true;
    statisticsHelp = true;
    printingHelp = true;
    managementHelp = true;
    encodingHelp = true;
    configurationHelp = true;
    recoveryMessage = '';
    notifyListeners();
  }

  /// Cambio de bandera de pantalla actual
  void changeHelp(dynamic value) {
    helpScreen = value as bool;
    notifyListeners();
  }

  /// Actualizar estado activo o inactivo
  void updateUserMode(UserActive newMode) {
    tempUserActive = newMode;
    notifyListeners();
  }

  /// Cambio de nombre del usuario actual
  void changeName(String newName) {
    name2show = newName;
    notifyListeners();
  }

  /// Cambio de bandera de visibilidad de contraseña
  void passwordVisibility(dynamic newValue) {
    visiblePassword = newValue as bool;
    notifyListeners();
  }

  /// Cambio de rol del usuario en creación
  void changeRole(String? newRole) {
    tempRole = newRole;
    notifyListeners();
  }

  /// Cambio de empresa del usuario en creación
  void changeCompany(String? newCompany) {
    tempCompany = newCompany;
    notifyListeners();
  }

  /// Cambio de documento del usuario en creación
  void changeDocType(String newType) {
    docType = newType;
    notifyListeners();
  }

  /// Actualizar campo de búsqueda de usuario
  void changeSearchField(String value) {
    currentSearchField = value;
    notifyListeners();
  }

  /// Búsqueda de usuario por empresa
  void changeSearchCompany(String company) {
    currentSearchCompany = company;
    notifyListeners();
  }

  /// Búsqueda de usuario por rol
  void changeSearchRole(String role) {
    currentSearchRole = role;
    notifyListeners();
  }

  /// Cambiar mensaje al recuperar contraseña
  void changeRecoveryMessage(String message) {
    recoveryMessage = message;
    notifyListeners();
  }

  /// Finalizó edición de elemento del inventario
  void editDone() {
    notifyListeners();
  }

  /// Método para filtrar usuarios en búsqueda
  List<User> filterUsers(String? value, List<User> initialList) {
    var _filteredList = <User>[];
    if (value != null && value != '') {
      // Acepta búsqueda por correo, nombre o documento
      _filteredList = initialList
          .where((user) =>
              user.userName!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()) ||
              (user.name!.givenName! +
                      user.name!.middleName! +
                      user.name!.familyName! +
                      user.name!.additionalFamilyNames!)
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()) ||
              user.externalId!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()))
          .toList();
    } else {
      _filteredList = initialList;
    }
    return _filteredList;
  }

  /// Carga de usuario
  Future<void> loadUser(String userInfo) async {
    status = UserStatus.loading;
    notifyListeners();
    final futureUserResult = await fetchUser(userInfo);
    if (futureUserResult == 'Usuario cargado') {
      status = UserStatus.loaded;
    } else if (futureUserResult == 'Contraseña incorrecta') {
      status = UserStatus.passwordError;
    } else if (futureUserResult == 'Usuario no encontrado') {
      status = UserStatus.userNotAuthorized;
    } else if (futureUserResult == 'Usuario inactivo') {
      status = UserStatus.userNotActive;
    } else {
      status = UserStatus.error;
    }
    notifyListeners();
  }

  /// Función para hacer petición POST y obtener datos del usuario
  Future<String> fetchUser(String userInfo) async {
    try {
      final response =
          await http.post(Uri.parse(Config.userLoginURL), body: userInfo);
      //print(response.body);

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        final dynamic temp = json.decode(response.body);
        if (temp is Map<String, dynamic>) {
          final userData = AuthenticationData.fromJson(temp);
          currentUser = userData.user ?? User();
          Config.userToken = userData.token ?? '';
          for (final itemUser in currentUser.helpScreens!) {
            if (itemUser.name == 'gestion') {
              managementHelp = itemUser.active!;
            } else if (itemUser.name == 'conteo') {
              stocktakingHelp = itemUser.active!;
            } else if (itemUser.name == 'impresion') {
              printingHelp = itemUser.active!;
            } else if (itemUser.name == 'informes') {
              statisticsHelp = itemUser.active!;
            } else if (itemUser.name == 'configuracion') {
              configurationHelp = itemUser.active!;
            } else if (itemUser.name == 'codificacion') {
              encodingHelp = itemUser.active!;
            } else if (itemUser.name == 'cargasMasivas') {
              uploadingHelp = itemUser.active!;
            }
          }
          name2show =
              '${currentUser.name!.givenName} ${currentUser.name!.familyName}';
          return 'Usuario cargado';
        } else {
          return 'Error obteniendo datos de usuario';
        }
      } else {
        //print(response.body);
        if (response.body == 'Usuario incorrecto') {
          return 'Usuario no encontrado';
        } else if (response.body == 'Error en las credenciales del usuario') {
          return 'Contraseña incorrecta';
        } else if (response.body == 'El usuario se encuentra inhabilitado') {
          return 'Usuario inactivo';
        } else {
          return 'Error del servidor';
        }
      }
    } on Exception {
      return 'Error obteniendo datos de usuario';
    }
  }

  /// Función para obtener roles del usuario
  void extractUserRoles(List<CompanyRole> companyRoles) {
    if (currentUser.roles != null) {
      currentUserRole.clear();
      for (final roleID in currentUser.roles!) {
        for (final role in companyRoles) {
          if (role.roleId == roleID) {
            currentUserRole.add(role.name!);
            break;
          }
        }
      }
    }
  }

  /// Función para obtener lista de usuarios
  Future<String> getUsersList() async {
    // Parámetros de solicitud GET
    const paramString = '?Authorization=Henutsen';
    try {
      final response = await http.get(
        Uri.parse(Config.fullUserDataURL + paramString),
        headers: Config.authorizationHeader(Config.userToken),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        final dynamic temp = json.decode(response.body);
        if (temp is List) {
          fullUsersList.clear();
          for (final item in temp) {
            final myUser = User.fromJson(item);
            fullUsersList.add(myUser);
          }
          return 'Listado recibido';
        } else {
          return 'Error obteniendo usuarios';
        }
      } else {
        return 'Error de petición';
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  /// Método para capturar usuarios de la empresa (y llenar
  ///  lista de responsables)
  Future<void> loadLocalUsers(String companyID) async {
    localUsersList.clear();
    // Obtener lista de usuarios
    await getUsersList();
    for (final element in fullUsersList) {
      if (element.company?.id == companyID) {
        final item2add =
            '${element.name?.givenName} ${element.name?.familyName} '
            '(${element.userName})';
        if (!localUsersList.contains(item2add)) {
          localUsersList.add(item2add);
        }
      }
    }
  }

  /// Método para actualizar visualización de pantallas de ayuda
  Future<String> loadHelpScreen(String screenName,
      {bool screenValue = false}) async {
    final headers = Config.authorizationHeader(Config.userToken);
    headers['Name'] = screenName;
    headers['Value'] = screenValue.toString();
    try {
      final response = await http.post(
        Uri.parse(Config.screenDataURL),
        body: userName,
        headers: headers,
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error';
      }
    } on Exception catch (e) {
      return 'Error: $e';
    }
  }

  /// Función para hacer petición POST y crear el usuario
  Future<String> newUser(
      List<PlatformFile> files2send, String thingToSend) async {
    // Armar la solicitud con la URL de la página y el parámetro
    //final response = await http.post(newUserURL, body: thingToSend);

    // Armar petición multiparte
    final url = Uri.parse(Config.newUserURL);
    final request = http.MultipartRequest('POST', url);
    // Armar la solicitud con los campos adecuados
    for (var i = 0; i < files2send.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
          'file$i', files2send[i].bytes!,
          filename: files2send[i].name));
    }
    // Campos adicionales
    request.fields['body'] = thingToSend;
    final customHeaders = Config.authorizationHeader(Config.userToken);
    request.headers.addAll(customHeaders);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      //print(response.body);

      // Se espera una respuesta 201 según el estándar
      if (streamedResponse.statusCode == 201) {
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is Map<String, dynamic>) {
          final fetchedUser = User.fromJson(fetchedData);
          if (fetchedUser.name != null) {
            //return response.body;
            return 'Ok';
          } else {
            return 'Error leyendo datos del recurso creado';
          }
        } else {
          return 'Error leyendo datos del recurso creado';
        }
      } else {
        // Proceder según respuesta
        if (response.body == 'Acceso inválido' ||
            response.body == 'Usuario ya registrado') {
          return response.body;
        } else {
          return 'Error leyendo datos del recurso creado';
        }
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  /// Función para hacer petición PUT y modificar usuario
  Future<String> modifyUser(
      List<PlatformFile> files2send, String thingToSend, String userId) async {
    // Armar petición multiparte
    final url = Uri.parse(Config.modifyUserURL + userId);
    final request = http.MultipartRequest('PUT', url);
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

      // Se espera una respuesta 200 según el estándar
      if (streamedResponse.statusCode == 200) {
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is Map<String, dynamic>) {
          final fetchedUser = User.fromJson(fetchedData);
          if (fetchedUser.name != null) {
            //return response.body;
            return 'Ok';
          } else {
            return 'Error leyendo datos del recurso modificado';
          }
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

  /// Función para hacer petición DELETE y eliminar el usuario
  Future<String> deleteUser(String userId) async {
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response = await http.delete(
        Uri.parse(Config.deleteUserURL + userId),
        headers: Config.authorizationHeader(Config.userToken),
      );

      // Se espera una respuesta 204 según el estándar
      if (response.statusCode == 204) {
        return 'Ok';
      } else {
        // Proceder según respuesta
        if (response.body.startsWith("'Error")) {
          return response.body;
        } else {
          return 'Error de petición';
        }
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  /// Función para enviar bienvenida por correo electrónico o recuperación
  /// de contraseña
  Future<String> sendEmail(String thingToSend) async {
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response =
          await http.post(Uri.parse(Config.emailReportURL), body: thingToSend);

      if (response.statusCode == 200) {
        return 'Ok';
      } else {
        return 'Error de petición';
      }
    } on Exception {
      return 'Error del servidor';
    }
  }

  /// Función para generar token para recuperación de contraseña
  String generateToken(String userId) {
    // Cadena base para codificar y decodificar los caracteres
    const tokenBase =
        'ABCDEFGHIJKL01234abcdefghijklMNOPQRSTUVWXYZ56789mnopqrstuvwxyz';

    // Función auxiliar para codificar una cadena
    String _encode(String data, int shift) {
      var result = '';
      for (var i = 0; i < data.length; i++) {
        final ind = tokenBase.indexOf(data[i]);
        if (ind != -1) {
          var newCharInd = ind + shift;
          if (newCharInd >= tokenBase.length) {
            newCharInd -= tokenBase.length;
          }
          result += tokenBase[newCharInd];
        } else {
          result += data[i];
        }
      }
      return result;
    }

    // Se definen diferentes factores de corrimiento aleatorios para los datos
    // a enviar codificados
    final dateEncodingShift = Random().nextInt(29) + 1;
    final hourEncodingShift = Random().nextInt(29) + 1;
    final userIdEncodingShift = Random().nextInt(29) + 1;

    // El token se construye con la fecha y hora actuales (para validez del
    // token) y el Id del usuario.
    var timeStamp = DateTime.now().toUtc().toString();
    timeStamp = timeStamp.substring(0, timeStamp.lastIndexOf(':'));
    timeStamp = timeStamp.replaceAll('-', '').replaceAll(':', '');
    final date = timeStamp.split(' ').first;
    final hour = timeStamp.split(' ').last;
    final _encodedDate = _encode(date, dateEncodingShift);
    final _encodedHour = _encode(hour.padLeft(8, '0'), hourEncodingShift);
    final _encodedId = _encode(userId, userIdEncodingShift);
    if (_encodedId.length != 24) {
      return 'Error';
    }
    final _encodedId1 = _encodedId.substring(0, 8);
    final _encodedId2 = _encodedId.substring(8, 16);
    final _encodedId3 = _encodedId.substring(16, 24);

    // Se arma una cadena con esta forma:
    // xxxxxxxx-aaaaaaaa-yyyyyyyy-bbbbbbbb-eeeeeeee-cccccccc-ffffffff-gggggggg
    // donde:
    // xxxxxxxx: Fecha codificada
    // yyyyyyyy: Hora codificada
    // aaaaaaaabbbbbbbbcccccccc: Id de usuario codificado
    // eeeeeeee: Corrimiento (shift) a aplicar a la fecha. No se codifica.
    // ffffffff: Corrimiento (shift) a aplicar a la hora. No se codifica.
    // gggggggg: Corrimiento (shift) a aplicar a id de usuario. No se codifica.
    // Los que no tengan 8 dígitos se rellenan antes con ceros a la izquierda

    final _dateShift = dateEncodingShift.toString().padLeft(8, '0');
    final _hourShift = hourEncodingShift.toString().padLeft(8, '0');
    final _userIdShift = userIdEncodingShift.toString().padLeft(8, '0');

    final chain = '$_encodedDate-$_encodedId1-$_encodedHour-$_encodedId2'
        '-$_dateShift-$_encodedId3-$_hourShift-$_userIdShift';
    return chain;
  }
}
