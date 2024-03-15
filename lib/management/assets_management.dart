// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -----------------Gestión de los activos-----------------
// --------------------------------------------------------

import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/inventory_out.dart';
import 'package:henutsen_cli/provider/pendient_Authorization.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AssetsManagementPage extends StatelessWidget {
  ///  Class Key
  const AssetsManagementPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          await NavigationFunctions.checkLeavingPage(context, PageList.gestion);
          return true;
        },
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.gestion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: const AssetsManagement(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

/// --------------- Para mostrar los activos ------------------
class AssetsManagement extends StatelessWidget {
  ///  Class Key
  const AssetsManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>();
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _textBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.4
        : mediaSize.width * 0.3;
    // Capturar empresa
    final company = context.watch<CompanyModel>();

    //para activos
    final deleteAsset =
        verifyResource(user.currentUser.roles!, company, 'DeleteAsset');
    final modAsset =
        verifyResource(user.currentUser.roles!, company, 'ModAsset');
    final saveAsset =
        verifyResource(user.currentUser.roles!, company, 'SaveNewAsset');
    final viewInventory =
        verifyResource(user.currentUser.roles!, company, 'LoadInventory');
    final internalAsset =
        verifyResource(user.currentUser.roles!, company, 'InternalAutho');
    final inAsset = verifyResource(user.currentUser.roles!, company, 'InAsset');

    //para leer etiqueta
    final readEtiquete =
        verifyResource(user.currentUser.roles!, company, 'ReadEtiquete');

    //para traslados y autorizaciones
    final viewAuthorization =
        verifyResource(user.currentUser.roles!, company, 'GetAuthorizations');
    final newPendient =
        verifyResource(user.currentUser.roles!, company, 'NewPendient');
    final getPendient =
        verifyResource(user.currentUser.roles!, company, 'GetPendient');
    final outPendient =
        verifyResource(user.currentUser.roles!, company, 'OutPendient');

    //para categorias
    final modCategory =
        verifyResource(user.currentUser.roles!, company, 'ModifyCategory');
    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gestión de Activos',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Maneje los activos de su inventario',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          if (deleteAsset || viewInventory || modAsset || saveAsset)
            // Lista de activos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    'Lista de activos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          width: _textBoxWidth,
                          child: const Text(
                            'Obtenga el listado completo de los activos de su '
                            'empresa, vea o modifique su información asociada, '
                            'cree nuevos activos o elimine aquellos que no '
                            'necesite.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      // Botón de ir al módulo de inventario
                      Container(
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            final inventory = context.read<InventoryModel>()
                              ..initInventory();
                            await inventory.loadInventory(
                                company.currentCompany.companyCode!);
                            inventory.getCategories();
                            Navigator.pushNamed(context, '/lista-activos');
                          },
                          child: const Text(
                            'Ir al\nlistado',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (readEtiquete)
            // Lectura de etiqueta
            const ReadTag(),
          if (outPendient)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    'Salida de activos fuera de las instalaciones',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          width: _textBoxWidth,
                          child: const Text(
                            'Obtenga información de los activos y la persona a'
                            ' cargo antes de salir fuera de las instalaciones.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      // Botón de ir al módulo de seguimiento
                      Container(
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            final transfer = context.read<TransferModel>();
                            final pendients = context.read<PendientModel>();
                            final device = context.read<BluetoothModel>();
                            device
                              ..unrelatedReading = false
                              ..newExternalcode('');
                            await user.getUsersList();
                            await company.getCompanyList();
                            await transfer.getAuthorizations('Todas');
                            await pendients.getAuthorizations(
                                company.currentCompany.companyCode!);
                            transfer.editDone();
                            Navigator.pushNamed(context, '/solicitar-salida');
                          },
                          child: const Text(
                            'Ir al\nmódulo',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (inAsset)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    'Ingreso de activos fuera de las instalaciones',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          width: _textBoxWidth,
                          child: const Text(
                            'Obtenga información de los activos y la persona a'
                            ' cargo de los activos que ingresan fuera de las '
                            ' instalaciones.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      // Botón de ir al módulo de seguimiento
                      Container(
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            final transfer = context.read<TransferModel>();
                            final pendients = context.read<PendientModel>();
                            final device = context.read<BluetoothModel>();
                            // ignore: cascade_invocations
                            device
                              ..unrelatedReading = false
                              ..newExternalcode('');
                            await user.getUsersList();
                            await company.getCompanyList();
                            await transfer.getAuthorizations('Todas');
                            await pendients.getAuthorizations(
                                company.currentCompany.companyCode!);
                            transfer.editDone();
                            Navigator.pushNamed(context, '/ingreso-activos');
                          },
                          child: const Text(
                            'Ir al\nmódulo',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (internalAsset)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    'Préstamo interno de activos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          width: _textBoxWidth,
                          child: const Text(
                            'Realice autorizaciones para el préstamo interno '
                            ' de activos.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      // Botón de ir al módulo de seguimiento
                      Container(
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            final outInventory =
                                context.read<InventoryOutModel>();
                            final outPendient = context.read<TransferModel>();
                            // ignore: cascade_invocations
                            outPendient
                              ..resetAll()
                              ..transferLocation =
                                  company.currentCompany.locations!.first;
                            company.currentLocation = company.places.first;
                            await outInventory.loadInventory(
                                company.currentCompany.companyCode!);
                            await user
                                .loadLocalUsers(company.currentCompany.id!);
                            outPendient.authorizationsList.clear();
                            await outPendient.getAuthorizations(
                                company.currentCompany.companyCode!);
                            Navigator.pushNamed(context, '/asset-internal');
                          },
                          child: const Text(
                            'Ir al\nmódulo',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          if (viewAuthorization || newPendient || getPendient)
            // Seguimiento de activos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    'Control de activos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          width: _textBoxWidth,
                          child: const Text(
                            'Obtenga registro de de entrada y salida '
                            'de activos de sus ubicaciones y realice '
                            'autorizaciones de traslado.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      // Botón de ir al módulo de seguimiento
                      Container(
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Leemos cambios en el modelo de autorizaciones
                            final transfer = context.read<TransferModel>();
                            transfer.authorizationsList.clear();
                            await transfer.getAuthorizations(
                                company.currentCompany.companyCode!);
                            await Navigator.pushNamed(
                                context, '/traslado-activos');
                          },
                          child: const Text(
                            'Ir al\nmódulo',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (modCategory)
            // Gestión de categorías
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    'Gestión de categorías',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          width: _textBoxWidth,
                          child: const Text(
                            'Visualice y modifique las categorías que maneja '
                            'su empresa para el inventario de activos.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      // Botón de ir al módulo de categorías
                      Container(
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/gestion-categorias'),
                          child: const Text(
                            'Ir al\nmódulo',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Clase para lectura de etiquetas ya impresas / codificadas
class ReadTag extends StatelessWidget {
  /// Class Key
  const ReadTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _textBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.4
        : mediaSize.width * 0.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, top: 20),
          child: Text(
            'Leer etiqueta',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  width: _textBoxWidth,
                  child: const Text(
                    'Lea la información de etiquetas ya impresas o codificadas',
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              // Botón de lectura
              Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    // Capturar info de dispositivo Bluetooth
                    final device = context.read<BluetoothModel>()
                      // Se activa lectura de código "externo"
                      ..unrelatedReading = true;
                    await _readSingleTag(context);
                    // Se desactiva lectura de código "externo"
                    device
                      ..unrelatedReading = false
                      ..newExternalcode('');
                  },
                  child: const Text(
                    'Leer\netiqueta',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Método para desplegar ventana de lectura de etiqueta
  Future<void> _readSingleTag(BuildContext context) async {
    // Información del activo en lectura
    Asset? _readAsset;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // Capturar dispositivo BT
        final device = context.watch<BluetoothModel>();
        // Capturar información de inventario
        final inventory = context.watch<InventoryModel>();
        // Capturar información de empresa
        final company = context.read<CompanyModel>();

        // Verificar si se ha capturado un activo válido
        var _isHenutsenAsset = false;
        if (_readAsset != null) {
          if (_readAsset?.name != null && _readAsset?.name != '') {
            _isHenutsenAsset = true;
          }
        }

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
              if (device.externalCodeReading != null &&
                  device.externalCodeReading != '') {
                _readAsset = _verifySingleTag(
                    context, device.externalCodeReading!, 'Barras');
                // Para actualizar vista
                inventory.editDone();
              } else {
                _readAsset = Asset();
              }
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
        final _capturedcode = device.externalCodeReading ?? '';

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
                  child: Text(_capturedcode, textAlign: TextAlign.center),
                ),
                Text(
                  (device.gotDevice)
                      ? '(Lector activo)'
                      : '(Configure primero el lector)',
                  style: (device.gotDevice)
                      ? const TextStyle(color: Colors.blue)
                      : const TextStyle(color: Colors.red),
                ),
                // Botones de lectura
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      // Código de barras
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: (device.gotDevice)
                                ? Theme.of(context).highlightColor
                                : Theme.of(context).disabledColor,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                          ),
                          onPressed: () async {
                            if (device.gotDevice) {
                              await inventory.readBarcode(device);
                              if (device.externalCodeReading != null &&
                                  device.externalCodeReading != '') {
                                _readAsset = _verifySingleTag(context,
                                    device.externalCodeReading!, 'Barras');
                                // Para actualizar vista
                                inventory.editDone();
                              } else {
                                _readAsset = Asset();
                              }
                            }
                          },
                          child: const Text(
                            'Leer código\nde barras',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      // RFID
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: (device.gotDevice)
                                ? Theme.of(context).highlightColor
                                : Theme.of(context).disabledColor,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                          ),
                          onPressed: () async {
                            // Obtener potencia actual y bajarla al mínimo
                            final _currentPower = await r6_plugin.getPower();
                            const _lowPower = 5;
                            await r6_plugin.setPower(_lowPower);
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
                                  _readAsset = _verifySingleTag(
                                      context, thisResponse, 'RFID');
                                  device.newExternalcode(thisResponse);
                                }
                              } else {
                                _readAsset = Asset();
                              }
                            }
                            // Restablecer potencia original (o 20 por defecto)
                            await r6_plugin.setPower(_currentPower ?? 20);
                          },
                          child: const Text(
                            'Leer código\nRFID',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Información inicial de activo
                Container(
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: _readAsset != null
                      ? Text(
                          _isHenutsenAsset
                              ? 'Código corresponde al activo:\n'
                                  '${_readAsset?.name}\n'
                                  'registrado en Henutsen'
                              : 'Etiqueta leída no corresponde a un activo '
                                  'registrado en Henutsen',
                        )
                      : null,
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: _isHenutsenAsset
                              ? Theme.of(context).highlightColor
                              : Theme.of(context).disabledColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () async {
                          // Si el activo está en Henutsen
                          if (_isHenutsenAsset) {
                            inventory.currentAsset = _readAsset!;
                            final imageModel = context.read<ImageModel>();
                            // Capturar modelo de imágenes
                            imageModel.imageArray.clear();
                            // Cargar imágenes que haya en el servidor
                            final _imagesList = <String>[];
                            inventory.currentAsset.images ??= <AssetPhoto>[];
                            if (inventory.currentAsset.images!.isNotEmpty) {
                              for (final item
                                  in inventory.currentAsset.images!) {
                                _imagesList.add(item.picture!);
                              }
                            }
                            imageModel.preloadImageArray(_imagesList);

                            await showDialog<void>(
                              context: context,
                              builder: (context) {
                                // Recopilar información del activo
                                final assetInfo = inventory.currentAsset
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
                                      const Text(
                                          'Código EPC\n(Base de datos): ',
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
                                    child: SizedBox(
                                      width: 300,
                                      height: 270,
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
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                Text(assetInfo.name!,
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const Text('Descripción: ',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                Text(assetInfo.description!,
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const Text(
                                                  'Sede: ',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  assetInfo.locationName!,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const Text(
                                                  'Serial: ',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  assetInfo.assetDetails
                                                          ?.serialNumber ??
                                                      'Sin serial',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            if (assetInfo.assetCodeLegacy![0]
                                                        .value !=
                                                    null &&
                                                assetInfo.assetCodeLegacy![0]
                                                        .value !=
                                                    '')
                                              TableRow(
                                                children: [
                                                  const Text(
                                                    'Código heredado 1: ',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  Text(
                                                    assetInfo
                                                        .assetCodeLegacy![0]
                                                        .value!,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            TableRow(
                                              children: [
                                                const Text('Categoría: ',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                Text(
                                                  inventory
                                                      .getAssetMainCategory(
                                                          assetInfo.assetCode),
                                                  style: const TextStyle(
                                                      fontSize: 14),
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
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Volver'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text(
                          'Ver detalles\nde activo',
                          textAlign: TextAlign.center,
                        ),
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
  }

  // Método para verificar existencia de código leído en Henutsen
  // y devolver información del activo correspondiente
  Asset _verifySingleTag(BuildContext context, String reading, String source) {
    // Capturar información de inventario
    final inventory = context.read<InventoryModel>();

    // Crear elemento para trabajar con clase AssetCode
    final assetCodeObject = AssetCode();

    // Elemento Asset para guardar datos del activo encontrado
    var foundAsset = Asset();

    for (final item in inventory.fullInventory) {
      assetCodeObject.uri = item.assetCode ?? '';
      if (source == 'RFID') {
        if (assetCodeObject.asEpcHex == reading) {
          foundAsset = item.copy();
        }
      } else if (source == 'Barras') {
        if (assetCodeObject.asBarcode == reading) {
          foundAsset = item.copy();
        }
      }
    }

    return foundAsset;
  }
}
