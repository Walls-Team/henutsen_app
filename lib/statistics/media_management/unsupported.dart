// Clase para plataforma no soportada

import 'dart:typed_data';

/// Clase para descarga de archivo
class FileDownload {
  FileDownload._();

  /// Método para generar archivo
  static Future<String?> generateFile(Uint8List fileData, String fileName) {
    throw Exception('Platform Not Supported');
  }
}
