// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decoded_asset.dart';

// **************************************************************************
// CsvSerializableGenerator
// **************************************************************************

// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).

/// Default [Map] between field names and CSV column titles.
const defaultCsvAssetFielsdMap = <String, String>{
  'assetCodeLegacy1': 'assetCodeLegacy1',
  'assetCodeLegacy2': 'assetCodeLegacy2',
  'location': 'location',
  'name': 'name',
  'description': 'description',
  'categories': 'categories',
  'model': 'model',
  'serialNumber': 'serialNumber',
  'make': 'make',
  'custody': 'custody',
  'status': 'status',
  'stock': 'stock',
};

/// Factory class for CsvAsset.
class CsvAssetFactory extends CsvObjectFactory {
  /// Creates a new [CsvAssetFactory].
  CsvAssetFactory({Map<String, String> fieldsMap = defaultCsvAssetFielsdMap})
      : super(fieldsMap);

  /// Creates an object from given [rowValues] read from a CSV file.
  @override
  CsvAsset fromList(List<dynamic> rowValues) {
    final instance = CsvAsset();
    int? columnIndex;
    columnIndex = columnIndexes['assetCodeLegacy1'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.assetCodeLegacy1 = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['assetCodeLegacy2'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.assetCodeLegacy2 = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['location'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.location = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['name'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.name = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['description'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.description = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['categories'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.categories = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['model'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.model = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['serialNumber'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.serialNumber = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['make'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.make = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['custody'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.custody = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['status'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.status = dynamicToString(rowValues[columnIndex]);
    }
    columnIndex = columnIndexes['stock'];
    if (columnIndex != null && columnIndex < rowValues.length) {
      instance.stock = dynamicToString(rowValues[columnIndex]);
    }
    return instance;
  }
}
