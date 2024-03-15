// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ------------------------------------------------------------
// ----------Codificación de etiquetas (contraseña)------------
// ------------------------------------------------------------

import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/material.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/encoder_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class PasswordPage extends StatelessWidget {
  ///  Class Key
  const PasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          await NavigationFunctions.checkLeavingPage(
            context,
            PageList.codificacion,
          );
          return true;
        },
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.codificacion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.codificacion),
          body: const ProtectTags(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.codificacion),
        ),
      );
}

/// --------------- Para proteger con contraseña ------------------
class ProtectTags extends StatelessWidget {
  ///  Class Key
  const ProtectTags({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar información de codificador
    final encoder = context.watch<EncoderModel>();

    // Estado actual del tag procesado
    Widget _tagStatus() {
      if (encoder.tagDetected) {
        if (!encoder.tagWritten) {
          return Column(
            children: [
              const Text('Etiqueta detectada'),
              Text(encoder.foundTag),
              const Text('\nMantenga la etiqueta cerca para escribir '
                  'contraseña')
            ],
          );
        } else {
          return Column(
            children: [
              const Text('Etiqueta detectada'),
              Text(encoder.foundTag),
              const Text('\nLa etiqueta ha sido protegida.')
            ],
          );
        }
      } else {
        return const Text('Etiqueta no detectada');
      }
    }

    return Container(
      padding: const EdgeInsets.all(2),
      child: ListView(children: [
        // Título página
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          child: const Text(
            'Etiqueta a proteger',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        // Información
        Container(
          padding: const EdgeInsets.all(5),
          child: const Text('Compruebe código de la etiqueta a proteger.\n'
              'Luego presione el botón de "proteger" para asignar contraseña'
              ' a la etiqueta.\n'
              '(La contraseña será generada automáticamente por Henutsen para'
              ' su empresa).'),
        ),
        // Fila de grabación
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Botones
            Column(children: [
              // Detectar tag
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: (encoder.tagDetected)
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).primaryColor),
                  onPressed: () async {
                    if (!encoder.tagDetected) {
                      // Rutina para Chainway
                      // Obtener potencia actual y bajarla al mínimo
                      final _currentPower = await r6_plugin.getPower();
                      const _lowPower = 5;
                      await r6_plugin.setPower(_lowPower);
                      final thisResponse = await r6_plugin.getTagEPC();
                      if (thisResponse != null) {
                        if (!thisResponse.startsWith('No hay')) {
                          encoder
                            ..foundTag = thisResponse
                            ..changeDetection(true);
                        } else {
                          encoder.changeDetection(false);
                        }
                      }
                      // Restablecer potencia original (o 20 por defecto)
                      await r6_plugin.setPower(_currentPower ?? 20);
                    }
                  },
                  child: const Text('Detectar\netiqueta',
                      textAlign: TextAlign.center),
                ),
              ),
              // Proteger tag
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: (encoder.tagDetected)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                  onPressed: () async {
                    if (encoder.tagDetected) {
                      // Capturar empresa
                      final company = context.read<CompanyModel>();
                      // Rutina para Chainway
                      // Generar contraseña para esta empresa
                      final _password = encoder
                          .getTagPassword(company.currentCompany.companyCode!);
                      // Obtener potencia actual y bajarla al mínimo
                      final _currentPower = await r6_plugin.getPower();
                      const _lowPower = 5;
                      await r6_plugin.setPower(_lowPower);
                      // Grabar nueva contraseña en memoria reservada
                      final result = await r6_plugin.writeTag(
                              _password, encoder.defaultPassword, 'Reserved') ??
                          '';
                      if (result.startsWith('Escritura exitosa')) {
                        encoder
                          ..changeWriting(true)
                          ..currentPassword = _password;
                        HenutsenDialogs.showSnackbar(
                            'Etiqueta escrita '
                            'exitosamente',
                            context);
                      } else {
                        encoder.changeWriting(false);
                        HenutsenDialogs.showSnackbar(
                            'Etiqueta no pudo ser '
                            'escrita',
                            context);
                      }
                      // Restablecer potencia original (o 20 por defecto)
                      await r6_plugin.setPower(_currentPower ?? 20);
                    }
                  },
                  child: const Text('Proteger\netiqueta',
                      textAlign: TextAlign.center),
                ),
              ),
            ]),
            SizedBox(
              width: 200,
              child: _tagStatus(),
            ),
          ],
        ),
        // Volver
        Container(
          margin: const EdgeInsets.only(top: 50),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                NavigationFunctions.checkLeavingPage(
                    context, PageList.codificacion);
                Navigator.pop(context);
              },
              child: const Text('Volver', textAlign: TextAlign.center),
            ),
          ),
        ),
      ]),
    );
  }
}
