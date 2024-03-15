// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// -------------------------------------------------------------------
// ------------------------Datos globales-----------------------------
// -------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ignore: avoid_classes_with_only_static_members
/// Clase para conexión a servicios
class Config {
  // Direcciones a cargar
  static Map<String, dynamic> _config = <String, dynamic>{};

  /// Cargar el archivo de configuración adecuado
  static const configFile = String.fromEnvironment('DEFINE_CONFIG_FILE',
      defaultValue: 'config/qa_config.json');

  /// Inicializa la carga del archivo correspondiente
  static Future<void> initialize() async {
    final configString = await rootBundle.loadString(configFile);
    _config = json.decode(configString) as Map<String, dynamic>;
  }

  /// Avatar por defecto de usuarios sin imagen cargada
  static String get defaultAvatar => 'images/Default-welcomer.png';

  /// Token obtenido al iniciar sesión
  static String userToken = '';

  /// Establecer encabezado de autenticación para HTTP
  static Map<String, String> authorizationHeader(String token) =>
      {'Authorization': 'Bearer $token'};

  /// URL de servicios (viene del archivo de configuración)
  static String get serviceURL => _config['serviceURL'] as String;

  /// URL de autenticación (viene del archivo de configuración)
  static String get serviceURLScim => _config['serviceURLScim'] as String;

  /// URL de redirección (viene del archivo de configuración)
  static String get apiManagementURL => _config['apiManagementURL'] as String;

  /// URL de envío de correos (viene del archivo de configuración)
  static String get sendGridURL => _config['sendGridURL'] as String;

  /// URL de suscripción (viene del archivo de configuración)
  static String get serviceURLSubscription =>
      _config['serviceURLSubscription'] as String;
  // ---------------------------------------------------
  // Funciones para trabajo con activos e inventarios
  // ---------------------------------------------------
  /// URL para capturar activos
  static String get inventoryDataURL => '${serviceURL}GetInventory';

  /// URL para enviar reporte de conteo
  static String get stocktakingURL => '${serviceURL}SaveStocktakingReport';

  /// URL para crear activo
  static String get newAssetURL => '${serviceURL}SaveNewAsset';

  /// URL para modificar activo
  static String get modifyAssetURL => '${serviceURL}ModifyAsset';

  /// URL para modificar varios activos
  static String get modifySeveralAssetsURL =>
      '${serviceURL}ModifySeveralAssets';

  /// URL para eliminar activo
  static String get deleteAssetURL => '${serviceURL}DeleteAsset';

  /// URL para obtener reportes de conteo
  static String get getStocktakingURL => '${serviceURL}GetStocktakingReports';

  /// URL para capturar movimientos de activos
  static String get getTransfersURL => '${serviceURL}GetTransfers';

  /// URL para capturar autorizaciones de traslado
  static String get getAuthorizationsURL => '${serviceURL}GetAuthorizations';

  /// URL para capturar autorizaciones de traslado
  static String get getPendientURL => '${serviceURL}GetPendient';

  /// URL para capturar hisotiral del activo
  static String get getHistory => '${serviceURL}GetHistory';

  /// URL para crear autorización de traslado
  static String get newAuthorizationURL =>
      '${serviceURL}CreateNewAuthorization';

  /// URL para crear autorización de traslado
  static String get newPendientURL => '${serviceURL}NewAuthorizationPendient';

  /// URL para crear autorización de traslado
  static String get newAuthorizationsURL => '${serviceURL}NewAuthorizations';

  /// URL para enviar correos electrónicos
  static String get sendEmail => '${sendGridURL}SendEmail';

  /// URL para modificar autorización
  static String get modifyAuthorizationURL =>
      '${serviceURL}ModifyAuthorization';

  /// URL para modificar autorización
  static String get modifyPendientURL => '${serviceURL}ModifyPendient';

  /// URL for delete authorization
  static String get deleteAuthorizationURL =>
      '${serviceURL}DeleteAuthorization';

  /// URL for delete authorization
  static String get deletePendientURL => '${serviceURL}DeletePendient';

  /// URL para modificar categoría
  static String get modifyCategoryURL => '${serviceURL}ModifyCategory';

  // ------------------------------------------------
  // Funciones para trabajo con usuario y empresa
  // ------------------------------------------------
  /// URL para capturar usuario en login
  //const String userLoginURL = '${serviceURL}LoadUserInfo';
  static String get userLoginURL => '${serviceURLScim}ValidateLogin';

  /// URL para crear usuario
  //const String newUserURL = '${serviceURLScim}SaveNewUser';
  static String get newUserURL => '${serviceURLScim}v2/Users/';

  /// URL para modificar usuario
  static String get modifyUserURL => '${serviceURLScim}v2/Users/';

  /// URL para eliminar usuario
  static String get deleteUserURL => '${serviceURLScim}v2/Users/';

  /// URL para capturar listado total de usuarios
  static String get fullUserDataURL => '${serviceURLScim}GetUsersList';

  /// URL para crear empresa
  //const String newCompanyURL = '${serviceURLScim}SaveNewCompany';
  static String get newCompanyURL => '${serviceURLScim}v2/Groups/';

  /// URL para modificar empresa
  static String get modifyCompanyURL => '${serviceURLScim}v2/Groups/';

  /// URL para eliminar empresa
  static String get deleteCompanyURL => '${serviceURLScim}v2/Groups/';

  /// URL para capturar empresa
  //static String get companyDataURL => '${serviceURLScim}GetCompanyInfo';
  static String get companyDataURL => '${serviceURLScim}v2/Groups/';

  /// URL para capturar listado total de empresas
  static String get fullCompanyDataURL => '${serviceURLScim}GetCompanyList';
  // ------------------------------------------------
  // Otras
  // ------------------------------------------------
  /// URL para crear ubicación
  static String get newLocationURL => '${serviceURL}SaveNewLocation';

  /// URL para modificar ubicación
  static String get modifyLocationURL => '${serviceURL}ModifyLocation';

  /// URL para eliminar ubicación
  static String get deleteLocationURL => '${serviceURL}DeleteLocation';

  /// URL para cargar datos de la pantalla de ayuda
  static String get screenDataURL => '${serviceURL}LoadScreenHelp';

  /// URL para obtener estadísticas
  static String get statisticsURL => '${serviceURL}GetManagementIndicator';

  /// URL para crear rol
  static String get newRoleURL => '${serviceURL}SaveNewRole';

  /// URL para modificar rol
  static String get modifyRoleURL => '${serviceURL}ModifyRole';

  /// URL para eliminar rol
  static String get deleteRoleURL => '${serviceURL}DeleteRole';

  /// URL para enviar correo con información relevante
  static String get emailReportURL => '${sendGridURL}SendEmail';

  /// URL para crear linea de negocio
  static String get newBusinessURL => '${serviceURL}SaveNewBusiness';

  /// URL para modificar linea de negocio
  static String get modidyBusinessURL => '${serviceURL}ModifyBusinessLine';

  /// URL para eliminar linea de negocio
  static String get deleteBusinessURL => '${serviceURL}DeleteBussinesLine';

  /// URL para eliminar linea de negocio
  static String get getCampusListURL => '${serviceURL}GetCampusList';

  /// URL para eliminar linea de negocio
  static String get deleteCampusURL => '${serviceURL}DeleteCampus';

  /// URL para guardar una sede
  static String get saveCampusURL => '${serviceURL}SaveNewCampus';

  /// URL para modificar una sede
  static String get modifyCampusURL => '${serviceURL}ModifyCampus';

  /// URL para eliminar linea de negocio
  static String get deleteAreaURL => '${serviceURL}DeleteArea';

  /// URL para agregar un área
  static String get saveAreaURL => '${serviceURL}SaveNewArea';

  /// URL para modificar un área
  static String get modifyAreaURL => '${serviceURL}ModifyArea';

  /// URL de descarga de la plantilla
  static String get urlTemplateLoadAssets =>
      'https://henutsenapiqa.blob.core.windows.net/resources/PlantillaHenutsen.xlsx';

  /// URL para servicio de impresión
  static String get postekURL => '${apiManagementURL}postek';

  /// URL para servicio de asignación de códigos
  static String get oppiotURL => '${apiManagementURL}oppiot';

  /// DSN para envío de errores y excepciones a Sentry
  static String get sentryDSN =>
      'https://d3edbdeb40344b3da6f83fcf49bb1450@o498145.ingest.sentry.io/5575328';

  /// Descripción en unidades
  static List<String> get arrDescription =>
      ['--', 'Mensual', 'Anual', 'Activo', 'Incidente'];

  ///Arr de codigos ISO de monedas
  static List<String> get arrCurrency => ['--', 'USD', 'COP', 'EUR'];

  /// Origin email
  static String get originEmail => 'soporte@audisoft.com';

  /// Body template sendgrid
  static String get bodyTemplate => 'd-69321d2c005749498115ccacd1eb9251';
}

/// Resolución de la impresora (usar 8 para 203 dpi,
/// 12 para 300 dpi y 24 para 600 dpi)
const int printerRes = 8;

/// Nombre del lector RFID
const String readerName = 'Chainway';

/// Límite de píxeles para diferenciar pantallas pequeñas y grandes
const double screenSizeLimit = 750;

/// Correo electrónico de origen para envío de notificaciones
const String originEmail = 'soporte@audisoft.com';

/// Plantilla a usar (SendGrid - reportes)
const String sendGridReportTemplate = 'd-fa9d32bb881741d18606c6ae59e50336';

/// Plantilla a usar (SendGrid - bienvenida)
const String sendGridWelcomeTemplate = 'd-8a15a7d73b534370b06b86896d47d645';

/// Plantilla a usar (SendGrid - recuperación de contraseña)
const String sendGridRecoveryTemplate = 'd-82f6dce4760f439485847bd8a162d0a8';

/// Información del sistema
PackageInfo henutsenAppInfo =
    PackageInfo(packageName: '', appName: '', buildNumber: '', version: '');
