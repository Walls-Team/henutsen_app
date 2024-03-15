// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// ------------------Selección de activos------------------
// --------------------------------------------------------

import 'dart:convert';
import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/assets_modal.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/inventory_out.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AssetInternal extends StatelessWidget {
  ///  Class Key
  const AssetInternal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.gestion),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: CountPageBody(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.gestion,
              thisPage: true),
        ),
      );
}

/// --------------- Para mostrar los activos ------------------
class CountPageBody extends StatelessWidget {
  ///  Class Key
  CountPageBody({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _menuBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.5
        : mediaSize.width * 0.3;
    final _menuWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.5 - 50
        : mediaSize.width * 0.3 - 50;
    final _searchBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.7 - 20
        : mediaSize.width * 0.4 - 20;
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    // Capturar el inventario
    final inventory = context.watch<InventoryOutModel>();
    // Capturar dispositivo BT
    final device = context.watch<BluetoothModel>();
    // Capturar el usuario
    final user = context.watch<UserModel>();

    // Función llamada al presionar gatillo del lector
    Future<dynamic> _platformCallHandler(MethodCall call) async {
      switch (call.method) {
        case 'keyCallback1':
          if (device.loopFlag) {
            await inventory.stopInventory(device);
          } else {
            await inventory.startInventory(
                device, company.currentCompany.companyCode!);
          }
          break;
        case 'keyCallback2':
          await inventory.readBarcode(device);
          break;
        default:
          throw MissingPluginException();
      }
    }

    // Revisar si ya hay dispositivo conectado y ya se asignó
    // callback de gatillo
    if (device.gotDevice && !device.callbackSet) {
      // Inicializar función DART llamada desde Android
      r6_plugin.initLocalCallback(_platformCallHandler);
      // Establecer evento de respuesta para gatillo del lector
      r6_plugin.setKeyEventCallback(1);
      device.callbackSet = true;
    }

    // Método para definir los botones de conteo
    Widget _actionButton(String text) {
      // Definir el ícono
      IconData _myIcon;
      Function _myFunction;
      switch (text) {
        case 'Leer una etiqueta':
          _myIcon = Icons.repeat_one;
          _myFunction = () async {
            if (device.gotDevice) {
              String? thisResponse;
              switch (device.memBank) {
                case 0:
                  thisResponse = await r6_plugin.getTagEPC();
                  break;
                case 1:
                  thisResponse = await r6_plugin.getTagTID();
                  break;
                case 2:
                  thisResponse = await r6_plugin.getTagUser();
                  break;
              }
              if (thisResponse != null) {
                if (!thisResponse.startsWith('No hay')) {
                  inventory.addTagToList(
                      [thisResponse], company.currentCompany.companyCode!);
                }
              }
            } else {
              HenutsenDialogs.showSnackbar(
                  'No hay lector asociado. Vaya a'
                  ' "Configurar lector" y conéctese a un lector.',
                  context);
            }
          };
          break;
        case 'Lectura múltiple':
          _myIcon = Icons.repeat;
          _myFunction = () {
            if (device.gotDevice) {
              inventory.startInventory(
                  device, company.currentCompany.companyCode!);
            } else {
              HenutsenDialogs.showSnackbar(
                  'No hay lector asociado. Vaya a'
                  ' "Configurar lector" y conéctese a un lector.',
                  context);
            }
          };
          break;
        case 'Detener':
          _myIcon = Icons.pause;
          _myFunction = () {
            if (device.gotDevice) {
              inventory.stopInventory(device);
            }
          };
          break;
        case 'Borrar':
          _myIcon = Icons.cleaning_services;
          _myFunction = inventory.clearTagList;
          break;
        default:
          _myIcon = Icons.question_answer;
          _myFunction = () {};
          break;
      }
      return SizedBox(
        width: 65,
        child: InkWell(
          child: Column(children: [
            Icon(
              _myIcon,
              size: 40,
              color: (device.gotDevice) ? Colors.greenAccent : Colors.grey,
            ),
            Text(text, textAlign: TextAlign.center)
          ]),
          onTap: () {
            // ignore: avoid_dynamic_calls
            _myFunction();
          },
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      child: ListView(
        children: [
          // Título página
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
                'Agregar activos de la ubicación ${company.currentLocation}',
                style: Theme.of(context).textTheme.headline3),
          ),
          // Botones de acción
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón de lectura múltiple
                _actionButton('Lectura múltiple'),
                // Botón de detener lectura
                _actionButton('Detener'),
                // Botón de borrar lista de tags
                _actionButton('Borrar'),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón de configuración
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () async {
                        final curDevice = device.gotDevice;
                        await Navigator.pushNamed(context, '/config-lector');
                        if (curDevice != device.gotDevice) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        }
                      },
                      child: const Text('Configurar lector',
                          textAlign: TextAlign.center),
                    ),
                  ),
                  // Botón para agregar activos manual
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () async {
                        await showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            content: const SizedBox(
                              width: 400,
                              height: 400,
                              child: ModalAsset(),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).highlightColor),
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Agregar activos',
                          textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 07,
              ),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () async {
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        content: const SizedBox(
                          width: 100,
                          height: 50,
                          child: Text(
                            'Activos agregados con éxito.',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).highlightColor),
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Guardar cambios',
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 07,
          ),
          InfoToShow(),
        ],
      ),
    );
  }
}

/// Clase para devolver la información de activos a mostrar
class InfoToShow extends StatelessWidget {
  /// Class Key
  // ignore: prefer_const_constructors_in_immutables
  InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Leemos cambios en el modelo de inventario y extraemos los campos a usar
    final inventory = context.watch<InventoryOutModel>();
    final _tagCount = inventory.tagList.length;

    // Fila de título
    final titlesRow = TableRow(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
            ),
          ),
          child: const Text(
            'No.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          color: Theme.of(context).primaryColor,
          child: const Text(
            'Nombre del activo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
            ),
          ),
          child: Text(
            'Total de activos: ${_tagCount.toString()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );

    // Presentamos lista de activos de la ubicación
    if (inventory.tagList.isNotEmpty) {
      final list2show = <TableRow>[];
      for (var i = 0; i < inventory.tagList.length; i++) {
        // Fila de la tabla a presentar
        list2show.add(
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey[300],
            ),
            children: [
              Text((i + 1).toString(), textAlign: TextAlign.center),
              Text(inventory.tagList[i].name!),
              IconButton(
                  onPressed: () async {
                    inventory.deleteTag(inventory.tagList[i].assetCode!);
                  },
                  icon: const Icon(Icons.delete)),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Tabla de elementos
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              titlesRow,
              ...list2show,
            ],
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
