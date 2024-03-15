// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Inventario colsubsidio para Provider----------
// ----------------------------------------------------

import 'dart:convert';
import 'dart:io';
import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/foundation.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:http/http.dart' as http;

/// Estados del inventario
enum StocktakingStatus {
  /// En espera
  idle,

  /// Cargando
  loading,

  /// Cargado
  loaded,

  /// Contando
  counting,

  /// Pausado
  paused,

  /// Finalizado
  finished,

  /// Cancelado
  canceled,

  /// Error
  error
}

/// Estado de cercanía de activo a antena
enum NearAntenna1 {
  /// Cerca a antena
  near,

  /// No cerca a antenta
  notNear,
}

/// Modelo para inventarios
class InventoryOutModel extends ChangeNotifier {
  /// Lista de inventarios completos de una empresa
  List<Asset> fullInventory = <Asset>[];

  /// Lista de inventarios en la ubicación actual
  List<Asset> localInventory = <Asset>[];

  /// Lista de tags encontrados
  List<AssetRead> tagList = [];

  /// Resultado del conteo
  Stocktaking assetsResult = Stocktaking();

  /// Estado actual de carga de inventarios
  StocktakingStatus status = StocktakingStatus.idle;

  /// Listado de categorías a mostrar
  List<String> categories = [];

  /// Categoría seleccionada
  String? currentCategory;

  /// Estado (de activo) seleccionado
  String? currentStatus;

  /// Estado de impresión/codificación de etiqueta seleccionado
  String? currentTagStatus;

  /// Código obtenido de: 0-rfid, 1-barras
  int codeSource = 0;

  /// Activo actual en visualización/edición
  Asset currentAsset = Asset();

  /// Cantidad de activos nuevos a crear
  int newAssetsQuantity = 1;

  /// Valores posibles para el estado de un activo
  final conditions = <String>['Operativo', 'En préstamo', 'De baja'];

  /// Valores posibles para el estado de la etiqueta de un activo
  final tagConditions = <String>['Impresas', 'No impresas'];

  /// Última ubicación donde se hizo conteo
  String? lastStockTakingLocation;

  /// Bandera para indicar que se acaba de hacer un conteo
  bool stocktakingRecentlyDone = false;

  /// Variable para campo de texto de búsqueda
  String currentSearchField = '';

  /// Id obtenido del reporte registrado
  String lastReportId = '';

  /// Estado cerca o no a antena
  NearAntenna1 nearAntenna = NearAntenna1.notNear;

  /// Bandera para búsqueda de activo particular
  bool searchSpecificItem = false;

  /// Bandera para indicar si el activo particular fue hallado
  bool itemWasFound = false;

  ///list
  List<Asset> locaUserAsset = [];

  ///lista de activos a agregar en la autorizacion
  List<String> assetsId = [];

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    assetsId = [];
    fullInventory = <Asset>[];
    localInventory = <Asset>[];
    locaUserAsset = [];
    tagList = [];
    assetsResult = Stocktaking();
    status = StocktakingStatus.idle;
    categories = [];
    currentCategory = null;
    currentStatus = null;
    currentTagStatus = null;
    codeSource = 0;
    currentAsset = Asset();
    newAssetsQuantity = 1;
    lastStockTakingLocation = null;
    stocktakingRecentlyDone = false;
    currentSearchField = '';
    lastReportId = '';
    nearAntenna = NearAntenna1.notNear;
    searchSpecificItem = false;
    itemWasFound = false;
  }

  /// Inicializar listas de inventarios
  void initInventory() {
    assetsResult.assets = <AssetStatus>[];
    fullInventory = <Asset>[];
    localInventory = <Asset>[];
  }

  ///
  void removeStatus() {
    conditions.remove('De baja');
    notifyListeners();
  }

  /// Agregar elemento a lista de tags leídos
  void addTag(AssetRead newItem) {
    tagList.add(newItem);
    notifyListeners();
  }

  ///
  void addAssetId(Asset value, dynamic valueBool) {
    final addOrDelete = valueBool as bool;
    if (addOrDelete) {
      assetsId.add(value.assetCode!);
      tagList.add(AssetRead(
          assetCode: value.assetCode,
          found: true,
          location: value.locationName,
          name: value.name));
    } else {
      assetsId.remove(value.assetCode);
      tagList.removeWhere((element) => element.assetCode == value.assetCode);
    }
    notifyListeners();
  }

  /// Limpiar lista de tags leídos
  void clearTagList() {
    deleteSeveral();
    notifyListeners();
  }

  /// Cambio de categoría seleccionada para filtrado
  void changeCategory(String? newCategory) {
    currentCategory = newCategory;
    notifyListeners();
  }

  /// Cambio de estado seleccionado para filtrado
  void changeStatus(String? newStatus) {
    currentStatus = newStatus;
    notifyListeners();
  }

  /// Cambio de estado de etiqueta seleccionado para filtrado
  void changeTagStatus(String? newStatus) {
    currentTagStatus = newStatus;
    notifyListeners();
  }

  /// Actualizar campo de búsqueda de usuario
  void changeSearchField(String value) {
    currentSearchField = value;
    notifyListeners();
  }

  /// Cambio de ubicación del activo en creación
  void changeAssetLocation(String newLocation) {
    currentAsset.locationName = newLocation;
    notifyListeners();
  }

  /// Cambio de la categoría de un activo en creación
  void changeAssetCategory(String category) {
    currentAsset.categories?[0].value = category;
    notifyListeners();
  }

  /// Cambio del estado de un activo en creación
  void changeAssetCondition(String status) {
    currentAsset.status = status;
    notifyListeners();
  }

  /// Cambio del responsable de un activo en edición
  void changeAssetCustody(String custody) {
    currentAsset.custody = custody;
    notifyListeners();
  }

  /// Actualizar estado de cercanía a antena
  void updateNearAntenna(NearAntenna1 newStatus) {
    nearAntenna = newStatus;
    notifyListeners();
  }

  /// Finalizó edición de elemento del inventario
  void editDone() {
    notifyListeners();
  }

  /// Método para extraer categorías de inventario
  void getCategories() {
    categories.clear();
    // Llenar listado de categorías diferentes y no vacías
    for (var i = 0; i < fullInventory.length; i++) {
      final itemCategory = getAssetMainCategory(fullInventory[i].assetCode);
      if (!categories.contains(itemCategory)) {
        if (itemCategory.isNotEmpty) {
          categories.add(itemCategory);
        }
      }
    }
  }

  /// Obtener categoría principal de un activo específico
  String getAssetMainCategory(String? assetCode) {
    var cat = '';
    for (final item in fullInventory) {
      if (item.assetCode == assetCode) {
        if (item.categories != null) {
          if (item.categories!.isNotEmpty) {
            if (item.categories?.first.value != null) {
              cat = item.categories![0].value!;
            }
          }
        }
        break;
      }
    }
    return cat;
  }

  /// Carga de inventario
  Future<void> loadInventory(String companyCode) async {
    status = StocktakingStatus.loading;
    notifyListeners();
    final _futureInventoryResult = await getInventory(companyCode);
    if (_futureInventoryResult == 'Inventario recibido') {
      status = StocktakingStatus.loaded;
    } else {
      status = StocktakingStatus.error;
    }
    notifyListeners();
  }

  /// Función para obtener inventario a través de HTTP
  Future<String> getInventory(String companyCode) async {
    // Parámetros de solicitud GET
    final paramString = '?CompanyCode=$companyCode';

    try {
      // Armar la solicitud GET/POST con la URL de la página y el parámetro
      final response = await http.get(
        Uri.parse(Config.inventoryDataURL + paramString),
        headers: Config.authorizationHeader(Config.userToken),
      );

      if (response.statusCode == 200) {
        //print(response.body);
        final dynamic tempList = json.decode(response.body);
        if (tempList is List) {
          final numAssets = tempList.length;
          fullInventory.clear();
          for (var i = 0; i < numAssets; i++) {
            final dynamic temp = tempList[i];
            if (temp is Map<String, dynamic>) {
              final asset = Asset.fromJson(temp);
              fullInventory.add(asset);
            }
          }
          return 'Inventario recibido';
        } else {
          return 'Error obteniendo inventarios (tipo de datos).';
        }
      } else {
        return 'Error obteniendo inventarios.';
      }
    } on Exception catch (e) {
      return 'Error del Servidor: $e';
    }
  }

  /// Método para filtrar activos en búsqueda (por nombre, serial,
  /// código de barras o fabricante)
  List<Asset> filterAssets(
      String? value, List<Asset> initialList, String valueCustody) {
    var _filteredList = <Asset>[];
    if (value != null && value != '') {
      _filteredList = initialList.where((asset) {
        // Revisar código de barras válido
        var barCodeFlag = false;
        if (asset.assetCode != null) {
          final assetCode = AssetCode()..uri = asset.assetCode!;
          if (assetCode.checkUriGIAI96()) {
            if (assetCode.asBarcode.startsWith(value)) {
              barCodeFlag = true;
            }
          }
        }
        // Revisar serial válido
        var serialFlag = false;
        if (asset.assetDetails!.serialNumber != null) {
          if (asset.assetDetails!.serialNumber!
              .trim()
              .startsWith(value.trim())) {
            serialFlag = true;
          }
        }
        // Revisar coincidencia con fabricante
        var manufacturerFlag = false;
        if (asset.assetDetails!.make != null) {
          if (asset.assetDetails!.make!
              .trim()
              .toLowerCase()
              .startsWith(value.trim().toLowerCase())) {
            manufacturerFlag = true;
          }
        }
        return asset.name!
                .trim()
                .toLowerCase()
                .contains(value.trim().toLowerCase()) ||
            serialFlag ||
            barCodeFlag ||
            manufacturerFlag;
      }).toList();
    } else {
      _filteredList = initialList;
    }
    if (valueCustody != '') {
      final aux = '${valueCustody.split(' ')[0]} ${valueCustody.split(' ')[1]}';
      _filteredList.removeWhere((e) => !e.custody!
          .toLowerCase()
          .replaceAll('é', 'e')
          .replaceAll('á', 'a')
          .replaceAll('ó', 'o')
          .replaceAll('í', 'i')
          .contains(aux
              .toLowerCase()
              .replaceAll('é', 'e')
              .replaceAll('á', 'a')
              .replaceAll('ó', 'o')
              .replaceAll('í', 'i')));
    }

    return _filteredList;
  }

  ///metodo para borrar un talg leido
  void deleteTag(String value) {
    tagList.removeWhere((element) => element.assetCode == value);
    assetsId.remove(value);
    notifyListeners();
  }

  ///metodo para limpiar los tags leidos
  void deleteSeveral() {
    tagList.clear();
    assetsId.clear();
  }

  ///metodo para eliminar activos que no sean del empleado
  void asigneAssetPendiet(String nameCustody) {
    final name = '${nameCustody.split(' ')[0]} ${nameCustody.split(' ')[1]}';
    locaUserAsset = <Asset>[...fullInventory];
    locaUserAsset.removeWhere(
        (e) => !e.custody!.toLowerCase().contains(name.toLowerCase()));
    notifyListeners();
  }

  /// Método para asignar inventarios a la sede seleccionada
  void extractLocalItems(String currentLocation) {
    localInventory.clear();
    localInventory =
        fullInventory.where((e) => e.locationName == currentLocation).toList();
  }

  /// Método para iniciar escaneo de tags
  Future<void> startInventory(BluetoothModel device, String companyCode) async {
    if (device.isRunning) {
      return;
    }
    final thisResponse = await r6_plugin.getAllTagsStart();
    try {
      if (thisResponse != null) {
        if (thisResponse) {
          device
            ..isRunning = true
            ..loopFlag = true
            ..isScanning = true
            ..isRunning = false;
        }
      }
      while (device.loopFlag) {
        List<String>? tagListHere;
        switch (device.memBank) {
          case 0:
            tagListHere = await r6_plugin.getTagEPCList();
            break;
          case 1:
            tagListHere = await r6_plugin.getTagTIDList();
            break;
          case 2:
            tagListHere = await r6_plugin.getTagUserList();
            break;
        }

        if (tagListHere == null) {
          sleep(const Duration(milliseconds: 1));
        } else if (tagListHere.isEmpty) {
          sleep(const Duration(milliseconds: 1));
        } else {
          // Acción depende si estamos en modo "conteo" o "búsqueda de activo"
          if (!searchSpecificItem) {
            addTagToList(tagListHere, companyCode);
          } else {
            checkSearchedAsset(tagListHere, companyCode);
            if (itemWasFound) {
              await stopInventory(device);
              searchSpecificItem = false;
            }
          }
        }
      }
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  /// Método para detener escaneo de tags
  Future<void> stopInventory(BluetoothModel device) async {
    device.loopFlag = false;
    final thisResponse = await r6_plugin.getAllTagsStop();
    try {
      if (thisResponse != null) {
        if (thisResponse) {
          if (device.isScanning) {
            device.isScanning = false;
          }
        }
      }
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  /// Método para agregar los EPC leídos a nuestra lista
  void addTagToList(List<String> myList, String companyCode) {
    // Para usar la clase AssetCode
    final assetCodeTemp = AssetCode();

    // Obtener base del código de la empresa
    var _baseCode = '0';
    if (companyCode.contains('-')) {
      _baseCode = companyCode.substring(0, companyCode.indexOf('-'));
    }

    // Repasar lista de tags leídos
    for (var k = 0; k < myList.length; k++) {
      if (myList[k] != '') {
        // Bandera de tag válido
        bool _validData;
        // Bandera de assetCodeLegacy
        var _isLegacyCode = false;
        // Opción tag RFID
        if (codeSource == 0 &&
            assetCodeTemp.checkEPCLength(myList[k]) &&
            assetCodeTemp.checkEPCGIAI96(myList[k]) &&
            assetCodeTemp.checkEPCHenutsen(myList[k], _baseCode)) {
          //Convertir a EPC Tag Uri
          assetCodeTemp.uri = assetCodeTemp.epcAsEPCTagUri(myList[k]);
          //print(assetCodeTemp.uri);
          _validData = true;
          // Opción código de barras
        } else if (codeSource == 1) {
          // Para códigos de barra asignados por Henutsen
          if (assetCodeTemp.checkBarcodeGIAI96(myList[k]) &&
              assetCodeTemp.checkBarcodeHenutsen(myList[k])) {
            //Convertir a EPC Tag Uri
            assetCodeTemp.uri = assetCodeTemp.barcodeAsEPCTagUri(myList[k]);
            //print(assetCodeTemp.uri);
            _validData = true;
            // Para otros códigos de barras preasignados, pero registrados
            // en Henutsen (como assetCodeLegacy)
          } else {
            _validData = false;
            // Verificar si el código leído es uno de los 'AssetCodeLegacy'
            // existentes
            for (final item in fullInventory) {
              if (myList[k] == item.assetCodeLegacy![0].value ||
                  myList[k] == item.assetCodeLegacy![1].value) {
                _validData = true;
                _isLegacyCode = true;
                break;
              }
            }
          }
        } else {
          _validData = false;
        }

        if (_validData) {
          // Revisar si aún no está incluido en la lista
          var alreadyRead = false;
          for (final item in tagList) {
            // Proceder según se haya encontrado un código Henutsen o un
            // Legacy en código de barras
            if (!_isLegacyCode && (item.assetCode == assetCodeTemp.uri)) {
              alreadyRead = true;
              break;
            } else if (_isLegacyCode && (item.assetCode == myList[k])) {
              alreadyRead = true;
              break;
            }
          }
          if (!alreadyRead) {
            // Recorrer el inventario total y verificar si el tag está
            for (final subitem in fullInventory) {
              // Proceder según se haya encontrado un código Henutsen o un
              // Legacy en código de barras
              if (!_isLegacyCode && (subitem.assetCode == assetCodeTemp.uri)) {
                addTag(AssetRead(
                    assetCode: subitem.assetCode,
                    location: subitem.locationName,
                    name: subitem.name,
                    found: false));
                assetsId.add(subitem.assetCode!);
                break;
              } else if (_isLegacyCode &&
                  (subitem.assetCodeLegacy![0].value == myList[k] ||
                      subitem.assetCodeLegacy![1].value == myList[k])) {
                addTag(AssetRead(
                    assetCode: myList[k],
                    location: subitem.locationName,
                    name: subitem.name,
                    found: false));
                assetsId.add(myList[k]);
                break;
              }
            }
          }
        }
      }
    }
  }

  /// Método para verificar si se encontró un activo específico buscado
  void checkSearchedAsset(List<String> myList, String companyCode) {
    // Para usar la clase AssetCode
    final assetCodeTemp = AssetCode();

    // Obtener base del código de la empresa
    var _baseCode = '0';
    if (companyCode.contains('-')) {
      _baseCode = companyCode.substring(0, companyCode.indexOf('-'));
    }

    // Repasar lista de tags leídos
    for (var k = 0; k < myList.length; k++) {
      if (myList[k] != '') {
        // Bandera de tag válido
        var _validData = false;
        // Verificar validez del código EPC
        if (codeSource == 0 &&
            assetCodeTemp.checkEPCLength(myList[k]) &&
            assetCodeTemp.checkEPCGIAI96(myList[k]) &&
            assetCodeTemp.checkEPCHenutsen(myList[k], _baseCode)) {
          //Convertir a EPC Tag Uri
          assetCodeTemp.uri = assetCodeTemp.epcAsEPCTagUri(myList[k]);
          //print(assetCodeTemp.uri);
          _validData = true;
        } else {
          _validData = false;
        }

        if (_validData) {
          // Revisar si aún no está incluido en la lista de leídos
          var alreadyRead = false;
          for (final item in tagList) {
            if (item.assetCode == assetCodeTemp.uri) {
              alreadyRead = true;
              break;
            }
          }
          if (!alreadyRead) {
            // Recorrer el inventario local y verificar si el tag está
            // (es decir, si es el que se está buscando)
            for (final subitem in localInventory) {
              // Proceder según se haya encontrado un código Henutsen o un
              // Legacy en código de barras
              if (subitem.assetCode == assetCodeTemp.uri) {
                addTag(AssetRead(
                    assetCode: subitem.assetCode,
                    location: subitem.locationName,
                    name: subitem.name,
                    found: true));
                itemWasFound = true;
                break;
              }
            }
          }
        }
      }
    }
  }

  /// Método para procesar lecturas de códigos de barras
  Future<void> readBarcode(BluetoothModel device,
      [String companyCode = '0']) async {
    // Temporalmente la fuente de datos es código de barras
    codeSource = 1;
    if (device.isRunning) {
      return;
    }
    device.isRunning = true;
    final thisResponse = await r6_plugin.scanBarcode();
    if (thisResponse != null && thisResponse.isNotEmpty) {
      // Se verifica si estamos realizando un conteo Henutsen o si solo
      // estamos leyendo un código de barras externo
      if (device.unrelatedReading) {
        device.newExternalcode(thisResponse);
      } else {
        addTagToList([thisResponse], companyCode);
      }
    }
    device.isRunning = false;
    // Volver al estado estándar (lectura de RFID)
    codeSource = 0;
  }

  /// Función para enviar reporte de conteo
  Future<String> sendReport(String thingToSend, String companyCode) async {
    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll(
          {'Content-Type': 'application/json', 'CompanyCode': companyCode});
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response = await http.post(Uri.parse(Config.stocktakingURL),
          body: thingToSend, headers: headers);

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response:
        if (response.body.startsWith('Se registró')) {
          // Capturar el Id que devolvió el BackEnd
          lastReportId = response.body.split(':')[1];
          return 'Ok';
        } else {
          return 'Error enviando reporte';
        }
      } else {
        return 'Error de petición';
      }
    } on Exception {
      return 'Error del servidor';
    }
  }

  /// Verificar la existencia de códigos repetidos ya cargados previamente
  /// en Henutsen y devolver lista si existen
  List<String> uniqueCodeExists(List<String> codesList, String codeType) {
    // Lista a retornar con códigos repetidos
    final repeatedCodes = <String>[];
    final _existingCodes = <String>[];
    // Proceder según código a verificar
    if (codeType == 'legacy') {
      for (final data in fullInventory) {
        if (data.assetCodeLegacy != null && data.assetCodeLegacy is List) {
          if (data.assetCodeLegacy!.length >= 2) {
            // Agregar "código preexistente 1" si es válido
            if (data.assetCodeLegacy![0].value != null &&
                data.assetCodeLegacy![0].value != '') {
              _existingCodes.add(data.assetCodeLegacy![0].value!);
            }
            // Agregar "código preexistente 2" si es válido
            if (data.assetCodeLegacy![1].value != null &&
                data.assetCodeLegacy![1].value != '') {
              _existingCodes.add(data.assetCodeLegacy![1].value!);
            }
          }
        }
      }
    } else if (codeType == 'serial') {
      for (final data in fullInventory) {
        if (data.assetDetails != null) {
          if (data.assetDetails?.serialNumber != null &&
              data.assetDetails?.serialNumber != '') {
            _existingCodes.add(data.assetDetails!.serialNumber!);
          }
        }
      }
    }
    // Buscar códigos ya existentes
    String tempItem;
    for (var i = 0; i < codesList.length; i++) {
      tempItem = codesList[i];
      for (var j = 0; j < _existingCodes.length; j++) {
        if (_existingCodes[j] == tempItem) {
          if (!repeatedCodes.contains(tempItem)) {
            repeatedCodes.add(tempItem);
          }
        }
      }
    }
    if (repeatedCodes.length == 1) {
      repeatedCodes.clear();
    }
    return repeatedCodes;
  }

  /// Función para enviar reporte por correo electrónico
  Future<String> sendEmail(String thingToSend) async {
    // Armar la solicitud con la URL de la página y el parámetro
    final response =
        await http.post(Uri.parse(Config.emailReportURL), body: thingToSend);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response:
      return 'Ok';
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Error del Servidor');
      return 'Error del servidor';
    }
  }
}
