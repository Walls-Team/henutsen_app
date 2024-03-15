// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ------------------------------------------------------------
// -----------Codificación de etiquetas (parte 2)--------------
// ------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/material.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/encoder_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class EncodingPage2 extends StatelessWidget {
  ///  Class Key
  const EncodingPage2({Key? key}) : super(key: key);

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
          body: const EncodeTags(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.codificacion),
        ),
      );
}

/// --------------- Para imprimir ------------------
class EncodeTags extends StatelessWidget {
  ///  Class Key
  const EncodeTags({Key? key}) : super(key: key);

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
              const Text('\nMantenga la etiqueta cerca para escribir')
            ],
          );
        } else {
          return Column(
            children: [
              const Text('Etiqueta detectada'),
              Text(encoder.foundTag),
              const Text('\nLa etiqueta ha sido grabada.')
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
            'Etiqueta a grabar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        // Información de etiqueta
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(children: [
            const Text('Etiqueta para: '),
            // Nombre del activo
            Text(encoder.tag2write[2]),
            // URI del activo
            Text(encoder.tag2write[1]),
          ]),
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
                      // Rutina depende si se usa Chainway o Oppiot
                      if (encoder.encoderType == EncoderType.desktop) {
                        // Leer tag RFID
                        final result = await encoder.readTag();
                        if (!result.startsWith('Error')) {
                          encoder
                            ..foundTag = result
                            ..changeDetection(true);
                        } else {
                          encoder.changeDetection(false);
                        }
                      } else {
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
                    }
                  },
                  child: const Text('Detectar\netiqueta',
                      textAlign: TextAlign.center),
                ),
              ),
              // Escribir tag
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
                      // Rutina depende si se usa Chainway o Oppiot
                      if (encoder.encoderType == EncoderType.desktop) {
                        // Grabar tag RFID
                        final result =
                            await encoder.writeTag(encoder.tag2write[0]);
                        if (!result.startsWith('Error')) {
                          encoder
                            ..changeWriting(true)
                            ..foundTag = encoder.tag2write[0];
                          unawaited(_updateTagStatus(context));
                          HenutsenDialogs.showSnackbar(
                              'Etiqueta escrita exitosamente', context);
                        } else {
                          encoder.changeWriting(false);
                          HenutsenDialogs.showSnackbar(
                              'Etiqueta no pudo ser '
                              'escrita',
                              context);
                        }
                      } else {
                        // Obtener potencia actual y bajarla al mínimo
                        final _currentPower = await r6_plugin.getPower();
                        const _lowPower = 5;
                        await r6_plugin.setPower(_lowPower);
                        // Grabar tag RFID en memoria EPC
                        final _passwordToUse = encoder.isProtected
                            ? encoder.currentPassword
                            : encoder.defaultPassword;
                        final result = await r6_plugin.writeTag(
                                encoder.tag2write[0], _passwordToUse, 'EPC') ??
                            '';
                        if (result.startsWith('Escritura exitosa')) {
                          encoder
                            ..changeWriting(true)
                            ..foundTag = encoder.tag2write[0];
                          unawaited(_updateTagStatus(context));
                          HenutsenDialogs.showSnackbar(
                              'Etiqueta escrita exitosamente', context);
                        } else {
                          encoder.changeWriting(false);
                          HenutsenDialogs.showSnackbar(
                              'Etiqueta no pudo '
                              'ser escrita',
                              context);
                        }
                        // Restablecer potencia original (o 20 por defecto)
                        await r6_plugin.setPower(_currentPower ?? 20);
                      }
                    }
                  },
                  child: const Text('Escribir\netiqueta',
                      textAlign: TextAlign.center),
                ),
              ),
            ]),
            _tagStatus()
          ],
        ),
        // Selección de etiqueta protegida
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            const SizedBox(
              width: 200,
              child: Text('La etiqueta está protegida con contraseña'),
            ),
            Checkbox(
              value: encoder.isProtected,
              activeColor: Colors.lightBlue,
              onChanged: (newValue) {
                // Capturar empresa
                final company = context.read<CompanyModel>();
                encoder.changeProtectionLevel(
                    newValue!, company.currentCompany.companyCode!);
              },
            ),
          ]),
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

  // Método para actualizar estado de codificación de etiqueta
  Future<void> _updateTagStatus(BuildContext context) async {
    // Capturar información de codificador
    final encoder = context.watch<EncoderModel>();
    // Capturar información de inventario
    final inventory = context.watch<InventoryModel>();
    final user = context.watch<UserModel>();
    // Capturar usuario
    final _currentUserName =
        context.select<UserModel, String>((user) => user.currentUser.userName!);

    // Actualizar estado de activo codificado en inventario
    for (final item in inventory.fullInventory) {
      if (item.assetCode == encoder.tag2write[1]) {
        if (item.tagEncoded == null || item.tagEncoded == false) {
          item.tagEncoded = true;
          final _itemsToSend = {
            'AssetBase': item,
            'UserName': _currentUserName,
          };
          final chain = jsonEncode(_itemsToSend);
          //print(chain);
          await inventory.modifyAsset(
              chain,
              '${user.currentUser.name!.givenName}'
              ' ${user.currentUser.name!.familyName}'
              ' ${user.currentUser.userName}');
          break;
        }
      }
    }
  }
}
