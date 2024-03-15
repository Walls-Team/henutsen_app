// Clase para plataforma web

import 'dart:typed_data';
import 'package:universal_html/html.dart' as web_file;

/// Clase para descarga de archivo
class FileDownload {
  FileDownload._();

  /// Método para generar archivo
  static Future<String?> generateFile(
      Uint8List fileData, String fileName) async {
    final blob = web_file.Blob([fileData],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

    web_file.AnchorElement(
      href: web_file.Url.createObjectUrlFromBlob(blob).toString(),
    )
      ..setAttribute('download', fileName)
      ..click();

    return 'Ok';
  }
}
