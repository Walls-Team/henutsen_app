// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -------------------Widget de carga----------------------
// --------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ignore: avoid_classes_with_only_static_members
/// Clase para widget de carga
class Loading {
  /// Mostrar estado de carga
  static Future<void> showLoadingStatus(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SpinKitRing(
                    color: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Cargando...',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ));

  /// Cerrar estado de carga
  static void closeLoading(BuildContext context) => Navigator.of(context).pop();
}
