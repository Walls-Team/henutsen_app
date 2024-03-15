// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -----------------Búsqueda de activo---------------------
// --------------------------------------------------------

import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AssetSearchPage extends StatelessWidget {
  ///  Class Key
  const AssetSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.conteo),
          endDrawer: MenuDrawer.drawer(context, PageList.conteo),
          body: const AssetSearch(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.conteo, context, PageList.conteo,
              thisPage: true),
        ),
      );
}

/// --------------- Para mostrar resultado de la búsqueda ------------------
class AssetSearch extends StatelessWidget {
  ///  Llave
  const AssetSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    // Capturar el inventario
    final inventory = context.watch<InventoryModel>();
    // Capturar dispositivo BT
    final device = context.watch<BluetoothModel>();

    // Función llamada al presionar gatillo del lector
    Future<dynamic> _platformCallHandler(MethodCall call) async {
      switch (call.method) {
        case 'keyCallback1':
          if (device.loopFlag) {
            await inventory.stopInventory(device);
            inventory.searchSpecificItem = false;
          } else {
            inventory
              ..clearTagList()
              ..searchSpecificItem = true
              ..itemWasFound = false;
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
      r6_plugin.setKeyEventCallback(0);
      device.callbackSet = true;
    }

    // Método para definir los botones de conteo
    Widget _actionButton(String text) {
      // Definir el ícono
      IconData _myIcon;
      Function _myFunction;
      switch (text) {
        case 'Iniciar lectura':
          _myIcon = Icons.repeat;
          _myFunction = () {
            if (device.gotDevice) {
              inventory
                ..clearTagList()
                ..searchSpecificItem = true
                ..itemWasFound = false
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
                ..stopInventory(device)
                ..searchSpecificItem = false;
            }
          };
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
            child: Text('Buscar activo',
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
                // Botón de lectura
                _actionButton('Iniciar lectura'),
                // Botón de detener lectura
                _actionButton('Detener'),
              ],
            ),
          ),
          // Botón de configuración
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final curDevice = device.gotDevice;
                await Navigator.pushNamed(context, '/config-lector');
                if (curDevice != device.gotDevice) {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                }
              },
              child:
                  const Text('Configurar lector', textAlign: TextAlign.center),
            ),
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

    // Fila de título
    final titlesRow = TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: const Text(
            'No.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: const Text(
            'Nombre del activo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: const Text(
            'Estado de búsqueda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            'Tags encontrados: ${_tagCount.toString()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );

    // Presentamos lista de activos de la ubicación
    if (inventory.localInventory.isNotEmpty) {
      final list2show = <TableRow>[];

      // Considerar campo de filtrado (si hubiese)
      final filteredLocalInventory = inventory.localInventory;

      // Llenar la lista en este orden: tags de la ubicación por leer,
      // tags de la ubicación ya leídos, tags leídos de otras ubicaciones
      final assets2show = <Asset>[];
      // Tags aún no leídos
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
      // Tags leídos
      for (final item in _tagList) {
        if (item.found!) {
          for (var k = 0; k < filteredLocalInventory.length; k++) {
            if (item.assetCode == filteredLocalInventory[k].assetCode) {
              assets2show.add(filteredLocalInventory[k]);
              // Si es código Legacy
            } else if (item.assetCode ==
                    filteredLocalInventory[k].assetCodeLegacy![0].value ||
                item.assetCode ==
                    filteredLocalInventory[k].assetCodeLegacy![1].value) {
              assets2show.add(filteredLocalInventory[k]);
            }
          }
        }
      }
      for (var i = 0; i < assets2show.length; i++) {
        // Color a usar en los tags presentados
        Color? color2use;
        // Texto de estado de búsqueda
        var status2show = 'No encontrado';
        for (var k = 0; k < _tagList.length; k++) {
          if (assets2show[i].assetCode == _tagList[k].assetCode ||
              (assets2show[i].assetCodeLegacy![0].value ==
                      _tagList[k].assetCode ||
                  assets2show[i].assetCodeLegacy![1].value ==
                      _tagList[k].assetCode)) {
            color2use = Colors.lightGreen;
            status2show = 'Encontrado';
          }
        }
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
              Text(status2show, style: TextStyle(backgroundColor: color2use)),
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

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            titlesRow,
            ...list2show,
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
