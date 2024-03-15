// Clase para plataforma móvil

import 'dart:typed_data';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

/// Clase para descarga de archivo
class FileDownload {
  FileDownload._();

  /// Método para generar archivo
  static Future<String?> generateFile(
      Uint8List fileData, String fileName) async {
    final params = SaveFileDialogParams(data: fileData, fileName: fileName);
    return FlutterFileDialog.saveFile(params: params);
  }
}
