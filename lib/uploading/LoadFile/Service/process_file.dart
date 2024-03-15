// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------------------------------
// -------Clase y métodos para procesar datos extraídos de archivo-------------
// ----------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/uploading/LoadFile/Model/decoded_asset.dart';
import 'package:intl/intl.dart';

import '../../../models/models.dart';

/// Posibles estados del proceso general de carga del archivo
enum GeneralFileStatus {
  /// No hay carga
  idle,

  /// Ir a mapeo de campos
  goToMappingButton,

  /// Los datos fueron validados
  validated,
}

///Data of file load
class DataFile extends ChangeNotifier {
  /// Nombre de archivo
  String? fileName;

  //Propiedades de archivo
  int _errorAssets = 0;
  int _repeatedAssets = 0;
  int _totalAssets = 0;

  /// Listado de activos duplicados
  List<CsvAsset> assetDuplicates = [];

  /// Listado de activos con errores
  List<CsvAsset> assetErrors = [];

  /// Listado total de activos a cargar
  List<CsvAsset> assetsTotal = [];

  /// Total de líneas de archivo a cargar (sin títulos)
  String? totalLines;

  /// Json de ubicaciones a cargar
  String? jsonLocations;

  /// Json de activos a cargar
  String dataToLoadJson = '';

  /// Status de carga de datos desde archivo
  GeneralFileStatus statusData = GeneralFileStatus.idle;

  /// Fecha de carga del archivo
  String? date;

  /// Nuevas ubicaciones a crear
  List<String> newLocations = [];

  /// Obtener total de activos
  String get totalInAsset => _totalAssets.toString();

  /// Obtener activos repetidos
  String get repeatedtotal => _repeatedAssets.toString();

  /// Obtener activos fallidos
  String get errorAsset => _errorAssets.toString();

  /// Reinicio de variables
  void _resetVariables() {
    assetErrors.clear();
    assetsTotal.clear();
    _errorAssets = 0;
    _repeatedAssets = 0;
    _totalAssets = 0;
    dataToLoadJson = '';
    totalLines = null;
  }

  /// Ir al estado "mapeando campos"
  void setFieldMappingStatus() {
    statusData = GeneralFileStatus.goToMappingButton;
    notifyListeners();
  }

  /// Limpiar estado completamente
  void clear() {
    _resetVariables();
    statusData = GeneralFileStatus.idle;
    date = null;
    fileName = null;
    notifyListeners();
  }

  // Verificar cantidad de elementos duplicados en el archivo cargado
  int _countDuplicates(List<CsvAsset> list) {
    final csvAssetNoRepeat = <CsvAsset>[];

    for (final datocsv in list) {
      final reponseSearchCsvAsset = csvAssetNoRepeat
          .where((e) => e.assetCodeLegacy1 == datocsv.assetCodeLegacy1)
          .where((e) => e.assetCodeLegacy2 == datocsv.assetCodeLegacy2)
          .where((e) => e.categories == datocsv.categories)
          .where((e) => e.custody == datocsv.custody)
          .where((e) => e.description == datocsv.description)
          .where((e) => e.location == datocsv.location)
          .where((e) => e.make == datocsv.make)
          .where((e) => e.model == datocsv.model)
          .where((e) => e.name == datocsv.name)
          .where((e) => e.serialNumber == datocsv.serialNumber)
          .where((e) => e.status == datocsv.status)
          .where((e) => e.stock == datocsv.stock);
      // Se valida que no esté el objeto iterado en el arreglo csvAssetNoRepeat
      if (reponseSearchCsvAsset.isEmpty) {
        csvAssetNoRepeat.add(datocsv);
      } else {
        assetDuplicates.add(datocsv);
      }
    }

    // Calculamos el total de repetidos
    final totalRepeat = list.length - csvAssetNoRepeat.length;

    return totalRepeat;
  }

  /// Verificar que haya contenido en los campos requeridos
  bool validRequiredFields(List<CsvAsset> assetProvider) {
    var validData = true;
    for (final data in assetProvider) {
      if (data.location == null ||
          data.location == '' ||
          data.name == null ||
          data.name == '') {
        validData = false;
        break;
      }
    }
    return validData;
  }

  /// Procesar ubicaciones de la empresa con las del archivo
  bool processLocations(List<CsvAsset> assetProvider, List<String> locations) {
    var hasNewLocations = false;

    ///Se organiza la lista
    assetProvider.sort((a, b) => a.location!
        .trim()
        .toLowerCase()
        .compareTo(b.location!.trim().toLowerCase()));

    newLocations.clear();
    for (final data in assetProvider) {
      if (data.location != null && data.location != '') {
        var foundMatch = false;
        for (final e in locations) {
          if (e.toLowerCase() == data.location!.toLowerCase()) {
            foundMatch = true;
            break;
          }
        }
        if (!foundMatch) {
          if (!newLocations.contains(data.location)) {
            newLocations.add(data.location!);
          }
        }
      }
    }
    newLocations.sort((first, second) =>
        first.trim().toLowerCase().compareTo(second.trim().toLowerCase()));
    if (newLocations.isNotEmpty) {
      hasNewLocations = true;
    }

    return hasNewLocations;
  }

  ///verificar si algun responsable no existe en Henutsen
  List<String> verifyCustody(List<User> users, List<CsvAsset> assetProvider) {
    ///llenar nombres faltantes para crear como usuarios
    final namesMissing = <String>[];
    var nameFinal = '';
    var search = false;
    for (final item in assetProvider) {
      if (item.custody != null && item.custody!.isNotEmpty) {
        final name = item.custody;
        for (final user in users) {
          final givenName = user.name?.givenName;
          final familyName = user.name?.familyName;
          nameFinal = '$givenName $familyName';
          if (name!.toLowerCase().contains(nameFinal.toLowerCase())) {
            search = true;
          }
        }
        if (!search) {
          if (!namesMissing.contains(name)) {
            namesMissing.add(name!);
          }
        }
      }
      if (search) {
        search = false;
      }
    }
    return namesMissing;
  }

  /// Verificar la existencia de códigos repetidos (assetCodeLegacy o serial)
  ///  en la información ingresada y devolver lista si existen
  List<String> codeNotUnique(List<CsvAsset> assetProvider, String codeType) {
    final repeatedCodes = <String>[];
    final _existingCodes = <String>[];
    // Proceder según código a verificar
    if (codeType == 'legacy') {
      for (final data in assetProvider) {
        // Agregar "código preexistente 1" si es válido
        if (data.assetCodeLegacy1 != null && data.assetCodeLegacy1 != '') {
          _existingCodes.add(data.assetCodeLegacy1!);
        }
        // Agregar "código preexistente 2" si es válido
        if (data.assetCodeLegacy2 != null && data.assetCodeLegacy2 != '') {
          _existingCodes.add(data.assetCodeLegacy2!);
        }
      }
    } else if (codeType == 'serial') {
      for (final data in assetProvider) {
        if (data.serialNumber != null && data.serialNumber != '') {
          _existingCodes.add(data.serialNumber!);
        }
      }
    }

    // Buscar códigos repetidos
    String tempItem;
    for (var i = 0; i < _existingCodes.length; i++) {
      tempItem = _existingCodes[i];
      for (var j = i + 1; j < _existingCodes.length; j++) {
        if (_existingCodes[j] == tempItem) {
          if (!repeatedCodes.contains(tempItem)) {
            repeatedCodes.add(tempItem);
          }
        }
      }
    }
    return repeatedCodes;
  }

  /// Procesar el archivo para ser cargado
  void processFileData(
    List<CsvAsset> assetProvider,
    List<String> usedCodes,
    String companyCode,
  ) {
    //assert(assetProvider != null, 'Object FilePickerResult Not Null');
    //Se limpian variables
    _resetVariables();

    totalLines = assetProvider.length.toString();

    // Se organiza la lista por ubicación
    assetProvider.sort((a, b) => a.location!
        .trim()
        .toLowerCase()
        .compareTo(b.location!.trim().toLowerCase()));

    // Verificar que haya datos en los campos "Nombre" y "Ubicación"
    for (final element in assetProvider) {
      if (element.name == '' || element.location == '') {
        _errorAssets++;
        if (element.name == '') {
          element.name = 'Falta Nombre del Activo';
        }
        if (element.location == '') {
          element.location = 'Falta Ubicación del Activo';
        }
        assetErrors.add(element);
      }
    }

    _repeatedAssets = _countDuplicates(assetProvider);

    var currentLocation = '';
    final assetsPerLocation = <AssetsPerLocation>[];
    var assetsToLoad = <AssetToLoad>[];
    var assignedCodes = <String>[];

    for (final data in assetProvider) {
      var _status = '';

      if (data.status == null || data.status == '') {
        _status = 'Operativo';
      }
      if (data.status != null &&
          data.status != '' &&
          (data.status != 'Operativo' &&
              data.status != 'En préstamo' &&
              data.status != 'De baja')) {
        _status = 'Operativo';
      } else {
        _status = data.status!;
      }
      // Se carga la lista de activos al cambiar de ubicación
      if (data.location != currentLocation && currentLocation.isNotEmpty) {
        // Se genera el inventario por ubicación
        assetsPerLocation.add(
            AssetsPerLocation(assetsToLoad, currentLocation, assignedCodes));
        // Se crea nueva lista
        assetsToLoad = <AssetToLoad>[];
        assignedCodes = <String>[];
      }
      if (data.stock == null || data.stock == '' || data.stock == '0') {
        data.stock = '1';
      }
      if (data.status == null || data.status == '') {
        data.status = 'Operativo';
      } else {
        // Decodificar el estado proveniente del CSV
        final _codedData = _status.codeUnits.map((c) {
          // Por alguna razón, Excel asigna los espacios en "Estado" con
          // el caracter 160; hay que reemplazarlos por 32
          if (c == 160) {
            return 32;
          } else {
            return c;
          }
        }).toList();
        _status = String.fromCharCodes(_codedData);
      }
      // Se genera activo a cargar
      var stockCount = 0;
      if (data.location != null) {
        do {
          final nextAsset = AssetToLoad(
              data.assetCodeLegacy1,
              data.assetCodeLegacy2,
              data.name,
              data.description,
              data.categories,
              data.model,
              data.serialNumber,
              data.make,
              data.custody,
              _status,
              data.stock);
          assetsToLoad.add(nextAsset);
          assetsTotal.add(data);
          stockCount++;
          // Asignar código Henutsen
          final _assetCode = AssetCode();
          final _newCode = _assetCode.newAssetCode(usedCodes, companyCode);
          assignedCodes.add(_newCode);
          usedCodes.add(_newCode);
        } while (stockCount < int.parse(data.stock!));
        currentLocation = data.location!;
      }
    }
    // Se agrega último activo recorrido
    assetsPerLocation
      ..add(AssetsPerLocation(assetsToLoad, currentLocation, assignedCodes))
      ..forEach((eStocK) {
        _totalAssets += eStocK.assets.length;
      });
    final _fileDate = DateTime.now().toLocal();
    date = DateFormat('yyyy-MM-dd HH:mm').format(_fileDate);
    //print(date);
    dataToLoadJson = jsonEncode(assetsPerLocation);
    //print(dataToLoadJson);
    jsonLocations = jsonEncode(newLocations);
    //print(jsonLocations);

    statusData = GeneralFileStatus.validated;
    notifyListeners();
  }
}
