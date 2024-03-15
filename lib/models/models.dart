// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

// --------------------------Asset y asociadas--------------------------------
/// Clase Asset
@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class Asset {
  /// Constructor
  Asset(
      {this.id,
      this.assetCode,
      this.assetCodeLegacy,
      this.companyCode,
      this.locationName,
      this.name,
      this.description,
      this.categories,
      this.assetDetails,
      this.custody,
      this.status,
      this.lastStocktaking,
      this.outOfLocation,
      this.lastTransferDate,
      this.images,
      this.isNearAntenna,
      this.tagEncoded,
      this.downAnotation});

  /// ID en base de datos
  String? id;

  /// Código EPC del activo
  String? assetCode;

  /// Código antiguo del activo
  List<LegacyCode>? assetCodeLegacy;

  /// Identificador de la empresa
  String? companyCode;

  /// Sede de ubicación del activo
  String? locationName;

  /// Nombre del activo
  String? name;

  /// Descripción del activo
  String? description;

  /// Categoría del activo 1
  List<AssetCategory>? categories;

  /// Detalles del activo
  AssetDetails? assetDetails;

  /// Custodia
  String? custody;

  /// Estado actual
  String? status;

  /// Anotcación de activo dado de baja
  String? downAnotation;

  /// Lista de fotos
  List<AssetPhoto>? images;

  /// Último inventario asociado al activo
  LastStocktaking? lastStocktaking;

  /// ¿Se encuentra fuera de su ubicación asignada?
  bool? outOfLocation;

  /// Última detección de movimiento
  String? lastTransferDate;

  /// ¿Se encuentra en cercanías de una antena?
  bool? isNearAntenna;

  /// ¿Ya se imprimió o codificó su etiqueta?
  bool? tagEncoded;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetToJson(this);

  /// Crear copia del activo
  Asset copy() {
    // Tratamiento de objetos no estándar
    final legacyList = <LegacyCode>[];
    assetCodeLegacy?.forEach((element) {
      legacyList.add(element.copy());
    });
    final categoryList = <AssetCategory>[];
    categories?.forEach((element) {
      categoryList.add(element.copy());
    });
    final photoList = <AssetPhoto>[];
    images?.forEach((element) {
      photoList.add(element.copy());
    });
    return Asset(
        id: id,
        assetCode: assetCode,
        assetCodeLegacy: legacyList,
        companyCode: companyCode,
        locationName: locationName,
        name: name,
        description: description,
        categories: categoryList,
        assetDetails: assetDetails?.copy(),
        custody: custody,
        status: status,
        lastStocktaking: lastStocktaking,
        outOfLocation: outOfLocation,
        lastTransferDate: lastTransferDate,
        images: photoList,
        isNearAntenna: isNearAntenna,
        downAnotation: downAnotation,
        tagEncoded: tagEncoded);
  }
}

// --------------------------Asset y asociadas--------------------------------
/// Clase Asset
@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class AssetHistory {
  /// Constructor
  AssetHistory(
      {this.id,
      this.assetCode,
      this.assetCodeLegacy,
      this.companyCode,
      this.locationName,
      this.name,
      this.description,
      this.categories,
      this.assetDetails,
      this.custody,
      this.status,
      this.lastStocktaking,
      this.outOfLocation,
      this.lastTransferDate,
      this.images,
      this.isNearAntenna,
      this.tagEncoded,
      this.downAnotation,
      this.date,
      this.userName,
      this.idAsset});

  /// ID en base de datos
  String? id;

  /// ID de activo
  String? idAsset;

  /// Fecha
  String? date;

  /// Persona
  String? userName;

  /// Código EPC del activo
  String? assetCode;

  /// Código antiguo del activo
  List<LegacyCode>? assetCodeLegacy;

  /// Identificador de la empresa
  String? companyCode;

  /// Sede de ubicación del activo
  String? locationName;

  /// Nombre del activo
  String? name;

  /// Descripción del activo
  String? description;

  /// Categoría del activo 1
  List<AssetCategory>? categories;

  /// Detalles del activo
  AssetDetails? assetDetails;

  /// Custodia
  String? custody;

  /// Estado actual
  String? status;

  /// Anotcación de activo dado de baja
  String? downAnotation;

  /// Lista de fotos
  List<AssetPhoto>? images;

  /// Último inventario asociado al activo
  LastStocktaking? lastStocktaking;

  /// ¿Se encuentra fuera de su ubicación asignada?
  bool? outOfLocation;

  /// Última detección de movimiento
  String? lastTransferDate;

  /// ¿Se encuentra en cercanías de una antena?
  bool? isNearAntenna;

  /// ¿Ya se imprimió o codificó su etiqueta?
  bool? tagEncoded;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AssetHistory.fromJson(Map<String, dynamic> json) =>
      _$AssetHistoryFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetHistoryToJson(this);

  /// Crear copia del activo
  AssetHistory copy() {
    // Tratamiento de objetos no estándar
    final legacyList = <LegacyCode>[];
    assetCodeLegacy?.forEach((element) {
      legacyList.add(element.copy());
    });
    final categoryList = <AssetCategory>[];
    categories?.forEach((element) {
      categoryList.add(element.copy());
    });
    final photoList = <AssetPhoto>[];
    images?.forEach((element) {
      photoList.add(element.copy());
    });
    return AssetHistory(
        id: id,
        assetCode: assetCode,
        assetCodeLegacy: legacyList,
        companyCode: companyCode,
        locationName: locationName,
        name: name,
        description: description,
        categories: categoryList,
        assetDetails: assetDetails?.copy(),
        custody: custody,
        status: status,
        lastStocktaking: lastStocktaking,
        outOfLocation: outOfLocation,
        lastTransferDate: lastTransferDate,
        images: photoList,
        isNearAntenna: isNearAntenna,
        downAnotation: downAnotation,
        tagEncoded: tagEncoded);
  }
}

/// Clase LegacyCode, para el código antiguo del activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class LegacyCode {
  /// Constructor
  LegacyCode({this.system, this.value});

  /// Sistema de información
  String? system;

  /// Valor del código
  String? value;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory LegacyCode.fromJson(Map<String, dynamic> json) =>
      _$LegacyCodeFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$LegacyCodeToJson(this);

  /// Crear copia de este objeto
  LegacyCode copy() => LegacyCode(
        system: system,
        value: value,
      );
}

/// Clase Category, para categorizar el activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetCategory {
  /// Constructor
  AssetCategory({this.name, this.value});

  /// Nombre de la categoría
  String? name;

  /// Valor del campo
  String? value;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AssetCategory.fromJson(Map<String, dynamic> json) =>
      _$AssetCategoryFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetCategoryToJson(this);

  /// Crear copia de este objeto
  AssetCategory copy() => AssetCategory(
        name: name,
        value: value,
      );
}

/// Clase AssetDetails, para detalles del activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetDetails {
  /// Constructor
  AssetDetails({this.model, this.serialNumber, this.make});

  /// Modelo
  String? model;

  /// Número serial
  String? serialNumber;

  /// Fabricante
  String? make;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AssetDetails.fromJson(Map<String, dynamic> json) =>
      _$AssetDetailsFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetDetailsToJson(this);

  /// Crear copia de este objeto
  AssetDetails copy() =>
      AssetDetails(model: model, serialNumber: serialNumber, make: make);
}

/// Clase AssetPhoto, para las imágenes del activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetPhoto {
  /// Constructor
  AssetPhoto({this.picture, this.author, this.date});

  /// Ruta de la imagen
  String? picture;

  /// Autor de la imagen
  String? author;

  /// Fecha de la imagen
  String? date;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AssetPhoto.fromJson(Map<String, dynamic> json) =>
      _$AssetPhotoFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetPhotoToJson(this);

  /// Crear copia de este objeto
  AssetPhoto copy() => AssetPhoto(
        picture: picture,
        author: author,
        date: date,
      );
}

/// Clase LastStocktaking, para información de último conteo del activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class LastStocktaking {
  /// Constructor
  LastStocktaking(
      {this.stocktakingId = '',
      this.timeStamp = '',
      this.userName = '',
      this.currentLocationName = '',
      this.findStatus = ''});

  /// ID del conteo
  String stocktakingId;

  /// Estampa de tiempo
  String timeStamp;

  /// Autor del conteo
  String userName;

  /// Lugar del conteo
  String currentLocationName;

  /// Estado del activo
  String findStatus;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory LastStocktaking.fromJson(Map<String, dynamic> json) =>
      _$LastStocktakingFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$LastStocktakingToJson(this);

  /// Crear copia de este objeto
  LastStocktaking copy() => LastStocktaking(
        stocktakingId: stocktakingId,
        timeStamp: timeStamp,
        userName: userName,
        currentLocationName: currentLocationName,
        findStatus: findStatus,
      );
}

/// Clase AssetRead para procesar los activos leídos en el conteo
class AssetRead {
  /// Constructor
  AssetRead({this.assetCode, this.location, this.name, this.found});

  /// Código del activo
  String? assetCode;

  /// Sede
  String? location;

  /// Nombre
  String? name;

  /// Estado después del conteo
  bool? found;
}

/// Clase AssetsReport para obtener reportes y estadísticas de inventarios
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetsReport {
  /// Constructor
  AssetsReport(
      {this.totalAssetsNumber,
      this.locationsWithAssets,
      this.assetsNumber,
      this.missingAssets,
      this.lastInventory,
      this.missingAssetsList,
      this.outOfLocationAssetsList,
      this.inAutorizationAssetsList});

  ///activos en prestamo
  List<Asset>? inAutorizationAssetsList;

  /// Total de activos de la empresa
  final int? totalAssetsNumber;

  /// Número de activos en la ubicación solicitada
  final int? assetsNumber;

  /// Número de activos perdidos
  final int? missingAssets;

  /// Fecha de último inventario
  final String? lastInventory;

  /// Ubicaciones que tienen activos
  final int? locationsWithAssets;

  /// Lista de activos perdidos
  final List<Asset>? missingAssetsList;

  /// Lista de activos fuera de ubicación
  final List<Asset>? outOfLocationAssetsList;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AssetsReport.fromJson(Map<String, dynamic> json) =>
      _$AssetsReportFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetsReportToJson(this);
}

// ------------------Stocktaking y asociadas--------------------------------
/// Clase Stocktaking
@JsonSerializable(fieldRename: FieldRename.pascal)
class Stocktaking {
  /// Constructor
  Stocktaking(
      {this.id,
      this.companyCode,
      this.locationName,
      this.timeStamp,
      this.userName,
      this.origin,
      this.fileName,
      this.assets});

  /// ID en base de datos
  @JsonKey(ignore: true)
  String? id;

  /// Identificador de la empresa
  String? companyCode;

  /// Sede
  String? locationName;

  /// Estampa de tiempo
  String? timeStamp;

  /// Usuario que hizo el conteo
  String? userName;

  /// Origen del conteo
  String? origin;

  /// Nombre de archivo de carga masiva, cuando aplica
  String? fileName;

  /// Lista de activos encontrados
  List<AssetStatus>? assets;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Stocktaking.fromJson(Map<String, dynamic> json) =>
      _$StocktakingFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$StocktakingToJson(this);
}

/// Clase AssetStatus para procesar los activos leídos
/// en el conteo para enviar en el reporte
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetStatus {
  /// Constructor
  AssetStatus(
      {this.assetId, this.assetName, this.serialNumber, this.findStatus});

  /// Código del activo
  String? assetId;

  /// Nombre del activo
  String? assetName;

  ///Serial del activo
  String? serialNumber;

  /// Estado del activo después del conteo
  String? findStatus;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AssetStatus.fromJson(Map<String, dynamic> json) =>
      _$AssetStatusFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetStatusToJson(this);
}

// --------------------------User y asociadas-------------------------------
/// Clase User
@JsonSerializable(explicitToJson: true)
class User {
  /// Constructor
  User(
      {this.id,
      this.userName,
      this.name,
      this.externalId,
      this.password,
      this.photos,
      this.emails,
      this.active,
      this.company,
      this.roles,
      this.codeCarnet,
      this.helpScreens});

  /// ID en base de datos
  @JsonKey(name: 'id')
  String? id;

  /// Nombre virtual de usuario
  String? userName;

  /// Nombres del usuario
  Name? name;

  /// Documento de identidad
  String? externalId;

  /// Código de carnet
  String? codeCarnet;

  /// Contraseña del usuario
  String? password;

  /// Fotos del usuario
  List<Photo>? photos;

  /// Correos del usuario
  List<Email>? emails;

  /// ¿Está activo?
  bool? active;

  /// Empresa del usuario
  CompanyID? company;

  /// Roles
  List<String>? roles;

  /// Lista de pantallas de ayuda
  List<HelpScreen>? helpScreens;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  // ignore: sort_constructors_first
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// `toJson` is the convention for a class to declare support for
  /// serialization to JSON. The implementation simply calls the private,
  /// generated helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Crear copia del activo
  User copy() => User(
        id: id,
        userName: userName,
        name: name,
        externalId: externalId,
        password: password,
        photos: photos,
        emails: emails,
        active: active,
        company: company,
        roles: roles,
        codeCarnet: codeCarnet,
        helpScreens: helpScreens,
      );
}

/// Clase Name, para los nombres de usuario
@JsonSerializable()
class Name {
  /// Constructor
  Name(
      {this.givenName,
      this.middleName,
      this.familyName,
      this.additionalFamilyNames});

  /// Nombre inicial del usuario
  String? givenName;

  /// Nombres secundarios
  String? middleName;

  /// Apellido
  String? familyName;

  /// Otros apellidos
  String? additionalFamilyNames;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$NameToJson(this);
}

/// Clase Photo, para las imágenes del usuario
@JsonSerializable()
class Photo {
  /// Constructor
  Photo({this.value, this.type, this.primary});

  /// URL de la imagen
  String? value;

  /// Tipo de imagen
  String? type;

  /// ¿Primaria?
  bool? primary;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}

/// Clase CompanyID, para la empresa del usuario
//@JsonSerializable()
// Por el requerimiento de ID (en mayúsculas) para el envío únicamente no se
// pueden usar los métodos automáticos generados por JsonSerializable
class CompanyID {
  /// Constructor
  CompanyID({this.id});

  /// ID de la empresa
  String? id;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory CompanyID.fromJson(Map<String, dynamic> json) =>
      //_$CompanyIDFromJson(json);
      CompanyID(id: json['id'] as String?);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() =>
      //_$CompanyIDToJson(this);
      <String, dynamic>{'ID': id};
}

/// Clase Emails, para los correos electrónicos del usuario
@JsonSerializable()
class Email {
  /// Constructor
  Email({this.value, this.type, this.primary});

  /// Correo electrónico
  String? value;

  /// Tipo de correo
  String? type;

  /// ¿Primario?
  bool? primary;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$EmailToJson(this);
}

/// Clase ScreenHelp
@JsonSerializable()
class HelpScreen {
  /// Constructor
  HelpScreen({this.name, this.active});

  /// Nombre de la pantalla
  String? name;

  /// Bandera: ¿está activa?
  bool? active;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory HelpScreen.fromJson(Map<String, dynamic> json) =>
      _$HelpScreenFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$HelpScreenToJson(this);
}

/// Clase AuthenticationData para extraer datos de autenticación de un usuario
@JsonSerializable(explicitToJson: true)
class AuthenticationData {
  /// Constructor
  AuthenticationData({this.user, this.token});

  /// Usuario
  User? user;

  /// Token de JWT
  String? token;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AuthenticationData.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationDataFromJson(json);
}

// --------------------------Company y asociadas------------------------------
/// Clase Company
@JsonSerializable(explicitToJson: true)
class Company {
  /// Constructor
  Company({
    this.id,
    this.companyCode,
    this.name,
    this.addresses,
    this.externalId,
    this.locations,
    this.businessLines,
    this.logo,
    this.roles,
    this.active,
  });

  /// ID en base de datos
  @JsonKey(name: 'id')
  String? id;

  /// Identificador de la empresa
  String? companyCode;

  /// Nombre de la empresa
  String? name;

  /// Lista de direcciones
  List<CompanyAddress>? addresses;

  /// Identificador externo (NIT)
  String? externalId;

  /// Lista de sedes
  List<String>? locations;

  /// Lista de lineas de negocio
  List<String>? businessLines;

  /// Logo
  String? logo;

  /// Lista de roles
  List<CompanyRole>? roles;

  /// ¿Empresa activa?
  bool? active;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$CompanyToJson(this);

  /// Copia de datos de la empresa
  Company copy() => Company(
      id: id,
      companyCode: companyCode,
      name: name,
      addresses: addresses,
      externalId: externalId,
      locations: locations,
      businessLines: businessLines,
      logo: logo,
      roles: roles,
      active: active);
}

/// Clase CompanyAddress, para las direcciones de la compañía
@JsonSerializable()
class CompanyAddress {
  /// Constructor
  CompanyAddress(
      {this.primary,
      this.streetAddress,
      this.locality,
      this.region,
      this.country});

  /// ¿Primaria?
  bool? primary;

  /// Dirección
  String? streetAddress;

  /// Municipio
  String? locality;

  /// Provincia
  String? region;

  /// País
  String? country;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory CompanyAddress.fromJson(Map<String, dynamic> json) =>
      _$CompanyAddressFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$CompanyAddressToJson(this);
}

/// Clase CompanyRole, para los roles de la compañía
@JsonSerializable()
class CompanyRole {
  /// Constructor
  CompanyRole({this.name, this.roleId, this.resources});

  /// Nombre del rol
  String? name;

  /// ID del rol
  String? roleId;

  /// Recursos del rol
  List<String>? resources;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory CompanyRole.fromJson(Map<String, dynamic> json) =>
      _$CompanyRoleFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$CompanyRoleToJson(this);

  /// Copia de datos del rol
  CompanyRole copy() =>
      CompanyRole(name: name, roleId: roleId, resources: resources);
}

/// Clase Location para la sedes y ubicaciones
@JsonSerializable(fieldRename: FieldRename.pascal)
class Location {
  /// Constructor
  Location(
      {this.name,
      this.address,
      this.city,
      this.department,
      this.country,
      this.images});

  /// Nombre de la sede
  String? name;

  /// Dirección
  String? address;

  /// Ciudad
  String? city;

  /// Departamento
  String? department;

  /// País
  String? country;

  /// Lista de imágenes
  List<String>? images;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

// ------------------------------------Otras-----------------------------------

/// Clase Authorization para autorizaciones de traslado
@JsonSerializable(fieldRename: FieldRename.pascal)
class Authorization {
  /// Constructor
  Authorization(
      {this.id,
      this.companyCode,
      this.number,
      this.dateIssued,
      this.authorizedStartDate,
      this.authorizedEndDate,
      this.assets,
      this.person,
      this.isPermanent,
      this.revoked,
      this.transferLocation,
      this.supervisor});

  /// ID de la autorización
  String? id;

  /// Identificador de la empresa
  String? companyCode;

  /// Número de autorización
  int? number;

  /// Fecha de emisión
  String? dateIssued;

  /// Fecha inicio de validez del permiso
  String? authorizedStartDate;

  /// Fecha final de validez del permiso
  String? authorizedEndDate;

  /// Lista de activos
  List<String>? assets;

  /// Persona autorizada
  String? person;

  /// Persona autorizada
  String? supervisor;

  /// ¿Es permanente?
  bool? isPermanent;

  /// ¿Ha sido revocada?
  bool? revoked;

  /// Ubicación de traslado
  String? transferLocation;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Authorization.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AuthorizationToJson(this);

  /// Crear copia de la autorización
  Authorization copy() => Authorization(
      id: id,
      companyCode: companyCode,
      number: number,
      dateIssued: dateIssued,
      authorizedStartDate: authorizedStartDate,
      authorizedEndDate: authorizedEndDate,
      assets: assets,
      person: person,
      isPermanent: isPermanent,
      revoked: revoked,
      transferLocation: transferLocation,
      supervisor: supervisor);
}

/// Clase Authorization para autorizaciones de traslado
@JsonSerializable(fieldRename: FieldRename.pascal)
class AuthorizationPendient {
  /// Constructor
  AuthorizationPendient(
      {this.id,
      this.companyCode,
      this.number,
      this.dateIssued,
      this.authorizedStartDate,
      this.authorizedEndDate,
      this.assets,
      this.person,
      this.isPermanent,
      this.revoked,
      this.transferLocation,
      this.status});

  /// ID de la autorización
  String? id;

  /// Identificador de la empresa
  String? companyCode;

  /// Número de autorización
  int? number;

  /// Fecha de emisión
  String? dateIssued;

  /// Fecha inicio de validez del permiso
  String? authorizedStartDate;

  /// Fecha final de validez del permiso
  String? authorizedEndDate;

  /// Lista de activos
  List<String>? assets;

  /// Persona autorizada
  String? person;

  /// Estado de la autorizacion
  String? status;

  /// ¿Es permanente?
  bool? isPermanent;

  /// ¿Ha sido revocada?
  bool? revoked;

  /// Ubicación de traslado
  String? transferLocation;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AuthorizationPendient.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationPendientFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AuthorizationPendientToJson(this);

  /// Crear copia de la autorización
  AuthorizationPendient copy() => AuthorizationPendient(
      id: id,
      companyCode: companyCode,
      number: number,
      dateIssued: dateIssued,
      authorizedStartDate: authorizedStartDate,
      authorizedEndDate: authorizedEndDate,
      assets: assets,
      person: person,
      isPermanent: isPermanent,
      revoked: revoked,
      transferLocation: transferLocation,
      status: status);
}

/// Clase AuthenticationData para extraer datos de autenticación de un usuario
@JsonSerializable(explicitToJson: true)
class Campus {
  ///constructor
  Campus(
      {this.id,
      this.name,
      this.companyCode,
      this.logo,
      this.businessLine,
      this.addresses,
      this.areas});

  ///id de la sede
  String? id;

  /// codigo de la empresa a la que pertenece
  String? companyCode;

  /// nombre de la sede
  String? name;

  /// logo de la sede
  String? logo;

  /// linea de negocio a la que pertenece
  String? businessLine;

  /// ubicacion
  List<CompanyAddress>? addresses;

  ///lista de areas
  List<String>? areas;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory Campus.fromJson(Map<String, dynamic> json) => _$CampusFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$CampusToJson(this);

  ///copia de campus
  Campus copy() => Campus(
      id: id,
      addresses: addresses,
      businessLine: businessLine,
      companyCode: companyCode,
      logo: logo,
      name: name);
}

/// Clase AssetTransfer para procesar movimientos de activos
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetTransfer {
  /// Constructor
  AssetTransfer(
      {this.id,
      this.ePC,
      this.assetCode,
      this.name,
      this.companyCode,
      this.locationName,
      this.antenna,
      this.count,
      this.lastTimeStamp,
      this.lastTimeStamp1,
      this.lastTimeStamp2,
      this.lastTimeStamp3,
      this.lastTimeStamp4,
      this.antennaCount1,
      this.antennaCount2,
      this.antennaCount3,
      this.antennaCount4,
      this.status,
      this.alarmed});

  /// ID del traslado
  String? id;

  /// EPC del activo detectado
  String? ePC;

  /// Código Henutsen de la etiqueta detectada
  String? assetCode;

  /// Nombre del activo
  String? name;

  /// Identificador de la empresa
  String? companyCode;

  /// Ubicación del activo
  String? locationName;

  /// Antena de última lectura
  int? antenna;

  /// Conteo de detecciones
  int? count;

  /// Tiempo de última lectura general
  String? lastTimeStamp;

  /// Tiempo de última lectura antena 1
  String? lastTimeStamp1;

  /// Tiempo de última lectura antena 2
  String? lastTimeStamp2;

  /// Tiempo de última lectura antena 3
  String? lastTimeStamp3;

  /// Tiempo de última lectura antena 4
  String? lastTimeStamp4;

  /// Conteo de detecciones de antena 1
  int? antennaCount1;

  /// Conteo de detecciones de antena 2
  int? antennaCount2;

  /// Conteo de detecciones de antena 3
  int? antennaCount3;

  /// Conteo de detecciones de antena 4
  int? antennaCount4;

  /// Estado inferido del activo (ninguno, entra, sale, etc.)
  String? status;

  /// Bandera para estado de activo
  bool? alarmed;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory AssetTransfer.fromJson(Map<String, dynamic> json) =>
      _$AssetTransferFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetTransferToJson(this);
}

/// Clase Response para manejo de respuestas HTTP
@JsonSerializable(fieldRename: FieldRename.none)
class HttpHenutsenResponse {
  /// Constructor
  HttpHenutsenResponse(
      {this.statusCode, this.error, this.message, this.content});

  /// Status code
  int? statusCode;

  /// Exist error in the response
  bool? error;

  /// Message of the response
  String? message;

  /// Content of the response
  dynamic content;

  /// Convert from json to class
  // ignore: sort_constructors_first
  factory HttpHenutsenResponse.fromJson(Map<String, dynamic> json) =>
      _$HttpHenutsenResponseFromJson(json);

  /// Convert from class to json
  Map<String, dynamic> toJson() => _$HttpHenutsenResponseToJson(this);
}

/// Clase EmailToSend para enviar correo electrónico
@JsonSerializable(fieldRename: FieldRename.pascal)
class EmailToSend {
  /// Constructor
  EmailToSend(
      {this.to,
      this.from,
      this.subject,
      this.body,
      this.client,
      this.henutsenReport,
      this.henutsenWelcome,
      this.passwordRecovery});

  /// Lista de destinatarios
  List<String>? to;

  /// Correo de origen
  String? from;

  /// Asunto
  String? subject;

  /// Plantilla del mensaje
  String? body;

  /// API a usar
  String? client;

  /// Reporte a enviar
  HenutsenReport? henutsenReport;

  /// Bienvenida a enviar
  HenutsenWelcome? henutsenWelcome;

  /// Recuperación de contraseña a enviar
  PasswordRecovery? passwordRecovery;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory EmailToSend.fromJson(Map<String, dynamic> json) =>
      _$EmailToSendFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$EmailToSendToJson(this);
}

/// Clase HenutsenReport para enviar reporte por correo electrónico
@JsonSerializable(fieldRename: FieldRename.pascal)
class HenutsenReport {
  /// Constructor
  HenutsenReport(
      {this.reportId,
      this.company,
      this.location,
      this.timeStamp,
      this.user,
      this.nofoundAssets,
      this.foundAssets,
      this.otherLocationAssets,
      this.assets1});

  /// ID en base de datos
  String? reportId;

  /// Nombre de la empresa
  String? company;

  /// Sede
  String? location;

  /// Estampa de tiempo
  String? timeStamp;

  /// Usuario que hizo el conteo
  String? user;

  /// activos no encontrados
  String? nofoundAssets;

  /// activos encontrados
  String? foundAssets;

  /// activos fuerda de su ubicacion
  String? otherLocationAssets;

  /// Lista de activos encontrados
  List<AssetStatus>? assets1;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory HenutsenReport.fromJson(Map<String, dynamic> json) =>
      _$HenutsenReportFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$HenutsenReportToJson(this);
}

/// Clase HenutsenWelcome para enviar bienvenida por correo electrónico
@JsonSerializable(fieldRename: FieldRename.pascal)
class HenutsenWelcome {
  /// Constructor
  HenutsenWelcome({this.company, this.userName, this.fullName});

  /// Nombre de la empresa
  String? company;

  /// Usuario registrado
  String? userName;

  /// Nombre completo de usuario registrado
  String? fullName;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory HenutsenWelcome.fromJson(Map<String, dynamic> json) =>
      _$HenutsenWelcomeFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$HenutsenWelcomeToJson(this);
}

/// Clase PasswordRecovery para recuperar contraseña
@JsonSerializable(fieldRename: FieldRename.pascal)
class PasswordRecovery {
  /// Constructor
  PasswordRecovery({this.userName, this.fullName, this.token});

  /// Usuario registrado
  String? userName;

  /// Nombre completo de usuario registrado
  String? fullName;

  /// Token generado
  String? token;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory PasswordRecovery.fromJson(Map<String, dynamic> json) =>
      _$PasswordRecoveryFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$PasswordRecoveryToJson(this);
}
