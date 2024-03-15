// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Bluetooth para Provider------------
// ----------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

/// Modelo para dispositivo Bluetooth
// ignore: prefer_mixin
class BluetoothModel with ChangeNotifier {
  /// Dispositivo bluetooth
  BluetoothDevice? connectedDevice;

  /// Bandera para indicar si actualmente se está escaneando tags
  bool isScanning = false;

  /// Banco de memoria a leer - 0:EPC, 1:TID, 2:User
  int memBank = 0;

  /// Bandera para indicar si ya tenemos un dispositivo conectado
  bool gotDevice = false;

  /// Bandera que indica si se está leyendo para evitar interrupciones
  bool isRunning = false;

  /// Bandera que indica si se está en un loop de lectura
  bool loopFlag = false;

  /// Bandera para indicar si ya se asignó callback de gatillo
  bool callbackSet = false;

  /// Bandera para indicar si se está haciendo lectura de código de barras
  /// externo (no Henutsen)
  bool unrelatedReading = false;

  /// Para guardar la lectura de un código externo (RFID o barras)
  String? externalCodeReading;

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    connectedDevice = null;
    isScanning = false;
    memBank = 0;
    gotDevice = false;
    isRunning = false;
    loopFlag = false;
    callbackSet = false;
    unrelatedReading = false;
    externalCodeReading = null;
  }

  /// Actualizar estado de conexión a true
  void setConnectionStatus() {
    gotDevice = true;
    notifyListeners();
  }

  /// Actualizar estado de conexión a false
  void unsetConnectionStatus() {
    gotDevice = false;
    notifyListeners();
  }

  /// Actualizar valor de lectura de código externo
  void newExternalcode(String value) {
    externalCodeReading = value;
    notifyListeners();
  }
}
