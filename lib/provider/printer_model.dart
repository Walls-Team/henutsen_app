// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Impresora para Provider------------
// ----------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:postek_plugin/printer_plugin_java.dart';

/// Modos de impresión
enum PrintMode {
  /// Tag RFID
  rfid,

  /// Código de barras
  barcode,

  /// Tag RFID + Código de barras
  rfidAndBarcode
}

/// Modelo para la impresora
// ignore: prefer_mixin
class PrinterModel with ChangeNotifier {
  /// Lista de selección de impresoras
  List<String> printers = [];

  /// Impresora seleccionada
  String? currentPrinter;

  /// Dirección del servidor de impresión
  String serverUrl = '';

  /// Perfil de etiqueta seleccionado
  String? tagProfile;

  /// Ancho de tag
  int? tagWidth;

  /// Altura de tag
  int? tagHeight;

  /// Espacio entre tags
  int? tagGap;

  /// Contraste de impresión
  int printDarkness = 15;

  /// Plugin para conectar con impresora
  PostekPlugin postek = PostekPlugin(http.Client())..apiURL = Config.postekURL;
  //PostekPlugin postek = PostekPlugin(http.Client());

  /// Lista de etiquetas de activos a imprimir
  List<List<String>> tags2print = [];

  /// Modo de impresión seleccionado
  PrintMode printMode = PrintMode.rfid;

  /// Etiqueta imprimiento actualmente
  int currentPrintingTag = 0;

  /// Status de impresión
  bool paused = false;

  /// Perfiles de etiqueta
  final tagSizes = ['50 x 30 x 5', 'Personalizado'];

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    printers = [];
    currentPrinter = null;
    serverUrl = '';
    tagProfile = null;
    tagWidth = null;
    tagHeight = null;
    tagGap = null;
    printDarkness = 15;
    postek = PostekPlugin(http.Client());
    tags2print = [];
    printMode = PrintMode.rfid;
    currentPrintingTag = 0;
    paused = false;
  }

  /// Cambio de impresora seleccionada
  void changePrinter(String? newPrinter) {
    currentPrinter = newPrinter;
    notifyListeners();
  }

  /// Cambio de perfil de etiqueta
  void changeTagProfile(String? newProfile) {
    tagProfile = newProfile;
    if (newProfile == '50 x 30 x 5') {
      tagWidth = 50 * printerRes;
      tagHeight = 30 * printerRes;
      tagGap = 5 * printerRes;
    } else if (newProfile == 'Personalizado') {
      tagWidth = null;
      tagHeight = null;
      tagGap = null;
    }
    notifyListeners();
  }

  /// Cambio de contraste de impresión
  void changeDarkness(int newDarkness) {
    printDarkness = newDarkness;
    notifyListeners();
  }

  /// Agregar impresora a la lista
  void addPrinter(String newPrinter) {
    printers.add(newPrinter);
    notifyListeners();
  }

  /// Agregar tag a la lista de impresión
  void addAsset(Asset asset) {
    // Para usar la clase AssetCode
    final assetCodeTemp = AssetCode()..uri = asset.assetCode!;
    // Lista de cinco posiciones, con URi en formato EPC y código de barras
    // (también incluye URI original, nombre del activo y serial)
    final _serial = asset.assetDetails?.serialNumber ?? '';
    final assetOutput = <String>[
      assetCodeTemp.asEpcHex,
      assetCodeTemp.asBarcode,
      assetCodeTemp.uri,
      asset.name!,
      _serial
    ];
    tags2print.add(assetOutput);
  }

  /// Actualizar modo de impresión
  void updatePrintMode(PrintMode mode) {
    printMode = mode;
    notifyListeners();
  }

  /// Actualizar tag siendo impreso
  void updatePrintedTag() {
    currentPrintingTag++;
    notifyListeners();
  }

  /// Pausar impresión
  void pausePrint() {
    paused = true;
    notifyListeners();
  }

  /// Continuar impresión
  void resumePrint() {
    paused = false;
    notifyListeners();
  }

  /// Actualizar dirección del servidor de impresión
  void updateURL(String address) {
    serverUrl = address;
    notifyListeners();
  }

  /// Método para imprimir tag RFID
  Future<bool> printRFIDTag(String tag) async {
    final result = await postek.writeRFID(tag);
    if (!result) {
      return false;
    } else {
      return true;
    }
  }

  /// Método para imprimir código de barras
  Future<bool> printBarcode(String tag, String name, String serial) async {
    const title = 'HENUTSEN';
    final result = await postek.printFullTag(tag, title, name, serial);
    if (!result) {
      return false;
    } else {
      return true;
    }
  }

  /// Método para imprimir tag RFID y código de barras
  Future<bool> printRFIDBarcode(
      String printedTag, String rfidTag, String name, String serial) async {
    const title = 'HENUTSEN';
    final result =
        await postek.writeFullRFIDTag(printedTag, rfidTag, title, name, serial);
    if (!result) {
      return false;
    } else {
      return true;
    }
  }
}
