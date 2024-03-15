// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -------Conteo de ingreso para activos en préstamo------------
// --------------------------------------------------------

import 'dart:convert';
import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Clase principal
class StocktakingInPage extends StatelessWidget {
  ///  Class Key
  const StocktakingInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.conteo),
          endDrawer: MenuDrawer.drawer(context, PageList.conteo),
          body: CountInPage(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.conteo, context, PageList.conteo,
              thisPage: true),
        ),
      );
}

/// --------------- Para mostrar los activos ------------------
class CountInPage extends StatelessWidget {
  ///  Class Key
  CountInPage({Key? key}) : super(key: key);

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
    final inventory = context.watch<InventoryModel>();
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
              inventory
                ..startLoop()
                ..startInventory(device, company.currentCompany.companyCode!);
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
              inventory
                ..startLoop()
                ..stopInventory(device);
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
            child: Text('Conteo ${company.currentLocation}',
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
                // Botón de lectura sencilla
                _actionButton('Leer una etiqueta'),
                // Botón de lectura múltiple
                _actionButton('Lectura múltiple'),
                // Botón de detener lectura
                _actionButton('Detener'),
                // Botón de borrar lista de tags
                _actionButton('Borrar'),
              ],
            ),
          ),
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
              // Botón de envío de reporte
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () async {
                    var count = 0;
                    // Parar cualquier conteo existente si lo hay
                    if (device.gotDevice) {
                      await inventory.stopInventory(device);
                    }
                    await showDialog<void>(
                      context: context,
                      builder: (context) {
                        // Se revisa si no se ha acabado de enviar otro reporte
                        // y si el nuevo reporte está vacío
                        var _foundAssets = 0;
                        for (final element in inventory.assetsResult.assets!) {
                          if (element.findStatus == 'Encontrado') {
                            _foundAssets++;
                          }
                          if (element.findStatus == 'No Encontrado') {
                            count++;
                          }
                        }
                        //print(inventory.stocktakingRecentlyDone);
                        if (!inventory.stocktakingRecentlyDone ||
                            _foundAssets != 0) {
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: _foundAssets != 0
                                  ? const Text(
                                      '¿Confirma envío de este reporte de '
                                      'conteo?',
                                    )
                                  : const Text(
                                      '¡Atención! El conteo está vacío.\n\n'
                                      '¿Confirma envío de este reporte de '
                                      'conteo?',
                                    ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).highlightColor,
                                ),
                                onPressed: () async {
                                  // Capturar estadísticas
                                  final statistics =
                                      context.read<StatisticsModel>();
                                  // Para obtener la hora de Colombia (GMT-5)
                                  final localTime = DateTime.now()
                                      .toUtc()
                                      .add(const Duration(hours: -5));
                                  // Llenar el resto de datos para envío
                                  // del reporte
                                  inventory.assetsResult.companyCode =
                                      company.currentCompany.companyCode;
                                  inventory.assetsResult.locationName =
                                      company.currentLocation;
                                  inventory.assetsResult.timeStamp =
                                      DateFormat('yyyy-MM-ddTHH:mm:ss')
                                          .format(localTime);
                                  inventory.assetsResult.userName =
                                      user.name2show;
                                  inventory.assetsResult.origin = readerName;
                                  // Envío del reporte a la base de datos
                                  final jsonToSend =
                                      jsonEncode(inventory.assetsResult);
                                  //print(jsonToSend);
                                  final thisResponse =
                                      await inventory.sendReport(
                                          jsonToSend,
                                          company.currentCompany.companyCode!,
                                          count == 0 ? 'entrada' : 'conteo');
                                  if (!thisResponse.startsWith('Ok')) {
                                    HenutsenDialogs.showSnackbar(
                                        'Error enviando reporte.', context);
                                  } else {
                                    // Reporte exitoso
                                    HenutsenDialogs.showSnackbar(
                                        'Reporte enviado.', context);
                                    // Armar y enviar notificación
                                    final myReport = HenutsenReport(
                                        reportId: inventory.lastReportId,
                                        company: company.currentCompany.name,
                                        location:
                                            inventory.assetsResult.locationName,
                                        timeStamp:
                                            inventory.assetsResult.timeStamp,
                                        user: inventory.assetsResult.userName,
                                        assets1: inventory.assetsResult.assets);
                                    final emailReport = EmailToSend(
                                        to: [user.currentUser.userName!],
                                        from: originEmail,
                                        subject: 'Reporte Henutsen',
                                        body: sendGridReportTemplate,
                                        client: 'henutsen',
                                        henutsenReport: myReport);
                                    final jsonToSend = jsonEncode(emailReport);
                                    await inventory.sendEmail(jsonToSend);
                                    inventory
                                      ..clearTagList()
                                      ..stocktakingRecentlyDone = true;
                                    statistics.clearStatus();
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          );
                        } else {
                          return AlertDialog(
                            content: const SingleChildScrollView(
                              child: Text(
                                'No está permitido reenviar un reporte de '
                                'conteo vacío tras un conteo previo.',
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Volver'),
                              ),
                            ],
                          );
                        }
                      },
                    );
                  },
                  child:
                      const Text('Enviar reporte', textAlign: TextAlign.center),
                ),
              ),
            ],
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
    final inventory = context.watch<InventoryModel>();
    final _tagCount = inventory.tagList.length;
    final _tagList = inventory.tagList;

    // Cuenta de activos de la ubicación encontrados
    var _localAssetsFound = 0;
    // Cuenta de activos de OTRA ubicación encontrados
    var _foreignAssetsFound = 0;
    // Número de ítems sin código asignado
    var _numItemsNoEPC = 0;

    // Leemos cambios en el modelo de empresa
    final _location = context.select<CompanyModel, String>(
      (company) => company.currentLocation ?? '',
    );
    // Considerar campo de búsqueda también
    final filteredLocalInventory = inventory.localInventory;
    final _localAssetsTotal = filteredLocalInventory.length;

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
            'Tags leídos: ${_tagCount.toString()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );

    var counter = 0;
    var counterNofind = 0;

    // Verificar si el tag fue encontrado y pertenece a la ubicación actual
    for (final item in _tagList) {
      item.found = true;
    }

    // Presentamos lista de activos de la ubicación
    if (filteredLocalInventory.isNotEmpty) {
      final list2show = <TableRow>[];

      // Llenar la lista en este orden: tags de la ubicación por leer,
      // tags de la ubicación ya leídos, tags leídos de otras ubicaciones,
      // tags sin código
      final assets2show = <Asset>[];
      // Tags que hacen parte de la ubicación y aún no leídos
      for (final item in filteredLocalInventory) {
        var inBothLists = false;
        for (var k = 0; k < _tagList.length; k++) {
          // Si es código Henutsen
          if (item.assetCode == _tagList[k].assetCode) {
            inBothLists = true;
            // Si es código Legacy
          } else if (item.assetCodeLegacy![0].value == _tagList[k].assetCode ||
              item.assetCodeLegacy![1].value == _tagList[k].assetCode) {
            inBothLists = true;
          }
        }
        if (item.assetCode != null) {
          if (!inBothLists && item.assetCode != '') {
            assets2show.add(item);
          }
        }
      }
      // Tags leídos que hacen parte de la ubicación
      for (final item in _tagList) {
        if (item.found!) {
          for (var k = 0; k < filteredLocalInventory.length; k++) {
            if (item.assetCode == filteredLocalInventory[k].assetCode) {
              assets2show.add(filteredLocalInventory[k]);
              _localAssetsFound++;
              // Si es código Legacy
            } else if (item.assetCode ==
                    filteredLocalInventory[k].assetCodeLegacy![0].value ||
                item.assetCode ==
                    filteredLocalInventory[k].assetCodeLegacy![1].value) {
              assets2show.add(filteredLocalInventory[k]);
              _localAssetsFound++;
            }
          }
        }
      }
      // Tags leídos que NO hacen parte de la ubicación
      for (final item in _tagList) {
        if (!item.found!) {
          for (var k = 0; k < inventory.fullInventory.length; k++) {
            if (item.assetCode == inventory.fullInventory[k].assetCode) {
              assets2show.add(inventory.fullInventory[k]);
              _foreignAssetsFound++;
              // Si es código Legacy
            } else if (item.assetCode ==
                    inventory.fullInventory[k].assetCodeLegacy![0].value ||
                item.assetCode ==
                    inventory.fullInventory[k].assetCodeLegacy![1].value) {
              assets2show.add(inventory.fullInventory[k]);
              _foreignAssetsFound++;
            }
          }
        }
      }
      // Tags sin código
      for (final item in filteredLocalInventory) {
        if (item.assetCode == null) {
          assets2show.add(item);
          _numItemsNoEPC++;
        } else if (item.assetCode!.isEmpty) {
          assets2show.add(item);
          _numItemsNoEPC++;
        }
      }
      inventory.assetsResult.assets!.clear();
      for (var i = 0; i < assets2show.length; i++) {
        // Agregar al reporte final
        final myAsset = AssetStatus()
          ..assetId = assets2show[i].id
          ..assetName = assets2show[i].name
          ..serialNumber = assets2show[i].assetDetails?.serialNumber
          ..findStatus = 'No Encontrado';
        // Color a usar en los tags presentados
        Color? color2use;
        // Para tags sin código
        if (assets2show[i].assetCode == null ||
            assets2show[i].assetCode == '') {
          color2use = Colors.redAccent;
          myAsset.findStatus = 'Sin código';
        }
        // Para los encontrados
        for (var k = 0; k < _tagList.length; k++) {
          if (assets2show[i].assetCode == _tagList[k].assetCode ||
              (assets2show[i].assetCodeLegacy![0].value ==
                      _tagList[k].assetCode ||
                  assets2show[i].assetCodeLegacy![1].value ==
                      _tagList[k].assetCode)) {
            if (_tagList[k].found!) {
              color2use = Colors.lightGreen;
              myAsset.findStatus = 'Encontrado';
            }
            counter++;
          } else {
            counterNofind++;
          }
        }
        inventory.assetsResult.assets!.add(myAsset);
        // Fila de la tabla a presentar
        list2show.add(
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey[300],
            ),
            children: [
              Text((i + 1).toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(backgroundColor: color2use)),
              Text(assets2show[i].name!,
                  style: TextStyle(backgroundColor: color2use)),
              Container(
                padding: const EdgeInsets.all(1),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_horiz, color: Colors.blue[800]),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Info',
                      child: Text('Más información'),
                    ),
                  ],
                  offset: const Offset(-10, 10),
                  onSelected: (chosen) {
                    if (chosen == 'Info') {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          // Recopilar información del activo
                          final assetInfo = assets2show[i]
                            // Revisión de integridad de datos
                            ..description ??= '';
                          // Para usar clase Asset code
                          final _assetCode = AssetCode()
                            ..uri = assetInfo.assetCode!;
                          String _epcRfid;
                          String _barcode;
                          if (assetInfo.assetCode == null) {
                            _epcRfid = '';
                            _barcode = '';
                          } else {
                            if (assetInfo.assetCode == '') {
                              _epcRfid = '';
                              _barcode = '';
                            } else {
                              _epcRfid = _assetCode.asEpcHex;
                              _barcode = _assetCode.asBarcode;
                            }
                          }
                          // Parte de códigos en la tabla
                          Widget _codeTable;
                          if (assetInfo.assetCode == null) {
                            _codeTable = Table(children: const [
                              TableRow(children: [
                                Text('Este activo no ha sido codificado',
                                    style: TextStyle(fontSize: 14)),
                              ])
                            ]);
                          } else if (assetInfo.assetCode!.isEmpty) {
                            _codeTable = Table(children: const [
                              TableRow(children: [
                                Text('Este activo no ha sido codificado',
                                    style: TextStyle(fontSize: 14)),
                              ])
                            ]);
                          } else {
                            _codeTable = Table(children: [
                              TableRow(children: [
                                const Text('Código EPC\n(Base de datos): ',
                                    style: TextStyle(fontSize: 14)),
                                Text(assetInfo.assetCode!,
                                    style: const TextStyle(fontSize: 14)),
                              ]),
                              TableRow(children: [
                                const Text('Código EPC (RFID): ',
                                    style: TextStyle(fontSize: 14)),
                                Text(_epcRfid,
                                    style: const TextStyle(fontSize: 14)),
                              ]),
                              TableRow(children: [
                                const Text('Código de barras: ',
                                    style: TextStyle(fontSize: 14)),
                                Text(_barcode,
                                    style: const TextStyle(fontSize: 14)),
                              ]),
                            ]);
                          }
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const Text('Información del activo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const Divider(),
                                  Table(children: [
                                    TableRow(
                                      children: [
                                        const Text('Activo: ',
                                            style: TextStyle(fontSize: 14)),
                                        Text(assetInfo.name!,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const Text('Descripción: ',
                                            style: TextStyle(fontSize: 14)),
                                        Text(assetInfo.description!,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const Text(
                                          'Sede: ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          assetInfo.locationName!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const Text('Categoría: ',
                                            style: TextStyle(fontSize: 14)),
                                        Text(
                                          inventory.getAssetMainCategory(
                                              assetInfo.assetCode),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ]),
                                  const Text(
                                    'Código del activo',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // Parte de código EPC generada arriba
                                  _codeTable
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Volver'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  // Indicador de avance
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _localAssetsFound / _localAssetsTotal,
                      minHeight: 20,
                    ),
                  ),
                  // Texto de avance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Avance: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${((_localAssetsFound / _localAssetsTotal) * 100).round()} %',
                      ),
                    ],
                  ),
                ],
              ),
              if (counter > 0 && counter == _tagList.length)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      const Text(
                        'Aprobado el ingreso de activos.',
                        style: TextStyle(color: Colors.green),
                      ),
                      TextButton(
                        onPressed: () {
                          final device = context.read<BluetoothModel>()
                            ..unrelatedReading = false
                            ..newExternalcode('');
                          Navigator.pushNamed(context, '/solicitar-salida');
                        },
                        child: const Text('Volver',
                            style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                ),
              if (counter > 0 && counter != _tagList.length)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      const Text(
                        'Rechazado el ingreso de activos',
                        style: TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: () {
                          final device = context.read<BluetoothModel>()
                            ..unrelatedReading = false
                            ..newExternalcode('');
                          Navigator.pushNamed(context, '/solicitar-salida');
                        },
                        child: const Text('Volver',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),

              // Más información de la búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.insert_chart),
                      color: Colors.blue,
                      iconSize: 48,
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Progreso de la búsqueda',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const Divider(),
                                    Text('Total de activos: '
                                        '$_localAssetsTotal'),
                                    Text('Activos encontrados: '
                                        '$_localAssetsFound'),
                                    Text('Activos faltantes: '
                                        '${_localAssetsTotal - _localAssetsFound}'),
                                    Text('Activos de otra ubicación: '
                                        '$_foreignAssetsFound'),
                                    Text('Activos sin código: '
                                        '$_numItemsNoEPC'),
                                    const Divider(),
                                    const Text('Convenciones:'),
                                    Table(
                                        defaultColumnWidth:
                                            const IntrinsicColumnWidth(),
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: [
                                          TableRow(children: [
                                            Container(
                                              height: 20,
                                              width: 40,
                                              margin: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                border: Border.all(),
                                              ),
                                            ),
                                            const Text('Aún no leído'),
                                          ]),
                                          TableRow(children: [
                                            Container(
                                              height: 20,
                                              width: 40,
                                              margin: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                border: Border.all(),
                                                color: Colors.lightGreen,
                                              ),
                                            ),
                                            const Text('Encontrado'),
                                          ]),
                                          TableRow(children: [
                                            Container(
                                              height: 20,
                                              width: 40,
                                              margin: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                border: Border.all(),
                                                color: Colors.yellow,
                                              ),
                                            ),
                                            const Text('Encontrado - de otra '
                                                'ubicación'),
                                          ]),
                                        ])
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Volver'),
                                ),
                              ]),
                        );
                      },
                    ),
                    const Text('Más información'),
                  ],
                ),
              ),
            ],
          ),
          // Tabla de elementos
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              titlesRow,
              ...list2show,
            ],
          ),
          // Fila de nota (para "sin código")
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _numItemsNoEPC == 0
                ? [Container()]
                : [
                    Container(
                      color: Colors.red[300],
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: const Text('En rojo'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Activos sin código asignado'),
                    ),
                  ],
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
