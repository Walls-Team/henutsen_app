// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -----------Plantilla de cuadro de diálogo-----------
// ----------------------------------------------------

import 'package:flutter/material.dart';

/// Clase para cuadros de diálogo y mensajes
class HenutsenDialogs {
  /// Mostrar cuadro de diálogo con Aceptar y Cancelar
  Future<Widget> showAlertDialog(BuildContext context, String title,
          VoidCallback cancel, VoidCallback accept) async =>
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).highlightColor,
              ),
              onPressed: cancel,
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: accept,
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

  /// Mostrar cuadro de diálogo simple (solo con Aceptar)
  static Future<Widget> showSimpleAlertDialog(
          BuildContext context, String title) async =>
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

  /// Método para mostrar mensajes al usuario como sncakBar
  static void showSnackbar(String toShow, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toShow)));
  }

  /// Método para retornar mensaje de confirmación
  static Future<bool> confirmationMessage(
          BuildContext context, String text2show) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child:
                Text(text2show, style: Theme.of(context).textTheme.headline3),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).highlightColor,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ) ??
      false;
}
