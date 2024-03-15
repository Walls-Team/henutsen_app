import 'dart:async';
import 'dart:convert';
import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/pendient_Authorization.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:henutsen_cli/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Clase principal
class IntAssets extends StatelessWidget {
  ///  Class Key
  const IntAssets({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.gestion),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: InBody(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

// ignore: use_key_in_widget_constructors, public_member_api_docs
class InBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    var datos = <String, dynamic>{};
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
    final _boxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.5
        : mediaSize.width * 0.4;
    // Capturar modelo de inventario
    final inventory = context.watch<InventoryModel>();
    // Capturar modelo de la empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de la empresa
    final user = context.watch<UserModel>();
    // Capturar modelo de traslados y autorizaciones
    final transferM = context.watch<TransferModel>();
    // Capturar modelo de traslados y autorizaciones
    final pendients = context.watch<PendientModel>();

    // Capturar dispositivo BT
    final device = context.watch<BluetoothModel>();
    // ignore: cascade_invocations
    //device.externalCodeReading = '1001247785';
    if (device.externalCodeReading != null &&
        device.externalCodeReading != '') {
      datos = searchUserAuthorization(
          user.fullUsersList,
          device.externalCodeReading!,
          transferM.authorizationsList,
          company.fullCompanyList,
          pendients.authorizationsList);
    }
    return Scrollbar(
      isAlwaysShown: true,
      child: ListView(
        children: [
          // Título
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingreso de activos en préstamo.',
                    style: Theme.of(context).textTheme.headline2),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Mediante un lector, obtenga el valor del código de barras'
                  ' del carnet del empleado, y verifique sus activos.',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Asegurese de tener el lector conectado a su dispositivo.',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Ingrese el código del carnet.',
                  style: Theme.of(context).textTheme.headline5,
                ),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 200,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 05),
                            child: TextFormField(
                              initialValue: device.externalCodeReading ?? '',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]'))
                              ],
                              onChanged: (value) {
                                device.externalCodeReading = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Ingrese dato';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 1,
                              primary: Theme.of(context).primaryColor,
                            ),
                            onPressed: inventory.editDone,
                            child: const Text('Buscar'),
                          ),
                        ),
                        const SizedBox(
                          height: 08,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 1,
                              primary: Theme.of(context).primaryColor,
                            ),
                            onPressed: () async {
                              // Se activa lectura de código "externo"
                              device.unrelatedReading = true;
                              await _readBarcode(context);
                              // Se desactiva lectura de código "externo"
                            },
                            child: const Text('Usar lector'),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          if (device.externalCodeReading == null)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No se ha revisado ningún código del usuario a autorizar'
                      ' la salida.',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              ),
            ),
          if (device.externalCodeReading != null &&
              device.externalCodeReading != '')
            Center(
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Datos de ingreso.',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nombre del usuario a cargo:',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      'Nombre de activo(s) a procesar:',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 05,
                                    ),
                                    Text(
                                      datos['User'].toString(),
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    IconButton(
                                        splashRadius: 01,
                                        onPressed: () async {
                                          await showDialog<void>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => AlertDialog(
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  children: (datos['ValueAsset']
                                                          as List<String>)
                                                      .map((e) {
                                                    final viewNameAsset =
                                                        inventory.fullInventory
                                                            .where((a) =>
                                                                a.assetCode ==
                                                                e)
                                                            .first;
                                                    return Text(
                                                        'Nombre: ${viewNameAsset.name!}\n'
                                                        'Descripción: ${viewNameAsset.description!}',
                                                        style: const TextStyle(
                                                            fontSize: 17,
                                                            color:
                                                                Colors.black));
                                                  }).toList(),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 2,
                                                    primary: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Aceptar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.remove_red_eye_outlined,
                                          size: 20,
                                          color: Colors.black,
                                        )),
                                  ]),
                            ],
                          ),
                          Center(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.white),
                                onPressed: () {
                                  company.currentLocation =
                                      (datos['Locations'] as List<String>)
                                          .first;
                                  inventory
                                    ..asigneAssetVerify(datos['ValueAsset'])
                                    ..tagList.clear()
                                    ..assetsResult.assets = <AssetStatus>[];
                                  Navigator.pushNamed(
                                      context, '/conteo-ingreso');
                                },
                                child: const Text(
                                  'Verificar activos',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )))
        ],
      ),
    );
  }

  // Método para desplegar ventana de lectura de códigos de barras
  Future<String> _readBarcode(BuildContext context) async {
    final reading = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // Capturar dispositivo BT
        final device = context.watch<BluetoothModel>();
        // Capturar información de inventario
        final inventory = context.read<InventoryModel>();
        // Capturar información de empresa
        final company = context.read<CompanyModel>();

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

        // Variable para lectura de código de barras
        final _barcode = device.externalCodeReading ?? '';
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Código leído:',
                  style: Theme.of(context).textTheme.headline3,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 100),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(5),
                  child: Text(_barcode, textAlign: TextAlign.center),
                ),
                Text(
                  (device.gotDevice)
                      ? '(Lector activo)'
                      : '(Configure primero el lector)',
                  style: (device.gotDevice)
                      ? const TextStyle(color: Colors.blue)
                      : const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/config-lector');
                        },
                        child: const Text('Configurar\nlector',
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          device
                            ..unrelatedReading = false
                            ..newExternalcode('');
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: (_barcode != '')
                              ? Theme.of(context).highlightColor
                              : Theme.of(context).disabledColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          if (_barcode != '') {
                            Navigator.of(context).pop(_barcode);
                          }
                        },
                        child: const Text('Usar código'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
    return reading ?? '';
  }
}

/// asociar usuario con su código de carnet y autorización
Map<String, dynamic> searchUserAuthorization(
    List<User> users,
    String codeCarnet,
    List<Authorization> authorizations,
    List<Company> companys,
    List<AuthorizationPendient> authorizationsP) {
  var aux1 = '';
  var aux5 = <String>[];
  var aux6 = <String>[];

  //para capturar usuario dependiendo su código de carnet
  var user = User();
  //buscar usuario asociado al código de carnet que salga del codigo de barras
  for (final itemU in users) {
    if (itemU.codeCarnet != null && itemU.codeCarnet != '') {
      if (itemU.codeCarnet == codeCarnet) {
        user = itemU;
        break;
      }
    }
  }
  final auxList1 = <String>[];
  // si se encontro el usuario, buscar si tiene una autorizacion
  if (user.userName != null && user.userName != '') {
    for (final itemA in authorizations) {
      if (itemA.person!.contains(user.userName!)) {
        aux1 = '${user.name?.givenName}'
            ' ${user.name?.familyName} '
            '(${user.userName})';
        // ignore: prefer_foreach
        for (final asset in itemA.assets!) {
          auxList1.add(asset);
        }
        aux5 = auxList1;
      }
    }
  }
  final auxList = <String>[];
  if (user.userName != null && user.userName != '') {
    for (final itemC in companys) {
      if (itemC.id == user.company!.id) {
        for (final rol in itemC.roles!) {
          if (user.roles!.first == rol.roleId) {
            for (final itemL in itemC.locations!) {
              if (rol.resources!.contains(itemL)) {
                auxList.add(itemL);
              }
            }
          }
        }
      }
    }
  }

  aux6 = auxList;
  var flag = false;
  if (aux1.isEmpty) {
    aux1 = '${user.name?.givenName}'
        ' ${user.name?.familyName} '
        '(${user.userName})';
    flag = true;
  }

  final auxMap = <String, dynamic>{
    'User': aux1,
    'ValueAsset': aux5,
    'Locations': aux6
  };
  return auxMap;
}
