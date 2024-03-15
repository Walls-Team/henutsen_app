// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------------------------------
// ------------------Clases para el manejo de carga de archivos----------------
// ----------------------------------------------------------------------------

import 'package:csv_parser/csv_parser.dart';
import 'package:csv_serializable/csv_serializable.dart';
import 'package:flutter/foundation.dart';

// Attach file with generated code.
part 'decoded_asset.g.dart';

/// Map of factoryObject
Map<String, String> columnNames = <String, String>{
  'assetCodeLegacy1': 'AssetCodeLegacy1',
  'assetCodeLegacy2': 'AssetCodeLegacy2',
  'location': 'Location',
  'name': 'Name',
  'description': 'Description',
  'categories': 'Categories',
  'model': 'Model',
  'serialNumber': 'SerialNumber',
  'make': 'Make',
  'custody': 'Custody',
  'status': 'Status',
  'stock': 'Stock'
};

//CsvConfig get csvConfig => CsvConfig(columnNames);

/// Row of CsvAsset data obtained from a CSV file. Each field represents a
/// separate column within the file.
@csvSerializable // This annotation enables CSV loading.
class CsvAsset {
  /// Asset Code Legacy of the company
  String? assetCodeLegacy1;

  /// Asset Code Legacy of the company (2)
  String? assetCodeLegacy2;

  ///Location of the asset in the company
  String? location; //Required

  ///Name of asset of the company
  String? name; //Required
  ///Description of asset of the company
  String? description;

  ///Categories of asset of the company
  String? categories;

  //AssetDetails
  ///model of asset of the company
  String? model;

  ///SerialNumber of asset of the company
  String? serialNumber;

  ///Make of asset of the company
  String? make;

  ///Custody of asset of the company
  String? custody;

  ///Status of asset of the company
  String? status;

  ///Stock of asset of the company
  String? stock;
}

/// Clase para manejo de estado de campos de mapeo de columnas
class FieldMappingModel extends ChangeNotifier {
  /// Valores de columnas
  List<String> columnNames = [
    'Código Heredado 1',
    'Código Heredado 2',
    'Ubicación',
    'Nombre',
    'Descripción',
    'Categorias',
    'Modelo',
    'Número Serial',
    'Fabricante',
    'Responsable',
    'Estado',
    'Cantidad',
    'No Cargar'
  ];

  /// Actualizar mapeo
  void updateFields() {
    notifyListeners();
  }
}

/// Activo a cargarse en Henutsen después de procesar el archivo
class AssetToLoad {
  /// Constructor
  AssetToLoad(
      this.assetCodeLegacy1,
      this.assetCodeLegacy2,
      this.name,
      this.description,
      this.categories,
      this.model,
      this.serialNumber,
      this.make,
      this.custody,
      this.status,
      this.stock);

  /// Asset Code Legacy of the company
  final String? assetCodeLegacy1;

  /// Asset Code Legacy of the company (2)
  final String? assetCodeLegacy2;

  ///Name of asset of the company
  final String? name; //Required

  ///Description of asset of the company
  final String? description;

  ///Categories of asset of the company
  final String? categories;

  ///model of asset of the company
  final String? model;

  ///SerialNumber of asset of the company
  final String? serialNumber;

  ///Make of asset of the company
  final String? make; //Required

  ///Custody of asset of the company
  final String? custody;

  ///Status of asset of the company
  final String? status;

  ///Stock of asset of the company
  final String? stock;

  ///transform from class to json
  Map<String, dynamic> toJson() => {
        'AssetCodeLegacy1': assetCodeLegacy1,
        'AssetCodeLegacy2': assetCodeLegacy2,
        'Name': name,
        'Description': description,
        'Categories': categories,
        'Model': model,
        'SerialNumber': serialNumber,
        'Make': make,
        'Custody': custody,
        'Status': status,
        'Stock': stock
      };
}

/// Grupo de activos a cargar por ubicación
class AssetsPerLocation {
  /// Constructor
  AssetsPerLocation(this.assets, this.location, this.codes);

  /// Lista de activos
  final List<AssetToLoad> assets;

  /// Ubicación
  final String? location;

  /// Lista de códigos asignados a cada activo
  final List<String> codes;

  /// De clase a json
  Map<dynamic, dynamic> toJson() => {
        'assets': assets,
        'location': location,
        'codes': codes,
      };
}
