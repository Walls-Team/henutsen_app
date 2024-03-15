// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------
// ----------------Codificación de etiquetas----------------
// ---------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/configuration/widgetText.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/encoder_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class EncodingPage extends StatelessWidget {
  ///  Class Key
  const EncodingPage({Key? key}) : super(key: key);
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
          body: EncodeData(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.codificacion),
        ),
      );
}

/// ------------------- Para codificar ----------------------
class EncodeData extends StatelessWidget {
  ///  Class Key
  EncodeData({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    final user = context.watch<UserModel>();
    final searchField = context.watch<ProviderSearch>();

    final encode1 =
        verifyResource(user.currentUser.roles!, company, 'ViewEncode');

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

    // Capturar información de codificador
    final encoder = context.watch<EncoderModel>();
    // Capturar el inventario
    final inventory = context.watch<InventoryModel>();

    String _currentCategory;
    if (inventory.currentCategory == null) {
      _currentCategory = 'Todas';
      inventory.currentCategory = _currentCategory;
    } else {
      _currentCategory = inventory.currentCategory!;
    }
    // Menú desplegable de categorías
    final _listOfCategories =
        _fillListOfItems(inventory.categories, 'Todas', _menuWidth);

    String _currentAssetStatus;
    if (inventory.currentStatus == null) {
      _currentAssetStatus = 'Todos';
      inventory.currentStatus = _currentAssetStatus;
    } else {
      _currentAssetStatus = inventory.currentStatus!;
    }
    // Menú desplegable de estados
    final _listOfStatus =
        _fillListOfItems(inventory.conditions, 'Todos', _menuWidth);

    String _currentTagStatus;
    if (inventory.currentTagStatus == null) {
      _currentTagStatus = 'Todas';
      inventory.currentTagStatus = _currentTagStatus;
    } else {
      _currentTagStatus = inventory.currentTagStatus!;
    }
    // Menú desplegable de estados de etiquetas
    final _listOfTagStatus =
        _fillListOfItems(inventory.tagConditions, 'Todas', _menuWidth);

    // Menú desplegable de ubicaciones
    company.places.sort();
    final _listOfLocations = company.places
        .map<DropdownMenuItem<String>>(
          (value) => DropdownMenuItem<String>(
            value: value,
            child: SizedBox(
              width: _menuWidth,
              child: Text(value),
            ),
          ),
        )
        .toList();

    // ----Widgets----
    // Función plantilla para widgets de filtro
    // Aplica para -ubicación, -categoría, -estado
    Widget _filterField(String fieldName, List<DropdownMenuItem<String>> list) {
      // Valor seleccionado a mostrar en el menú desplegable
      String? _fieldValue;
      if (fieldName == 'Ubicación') {
        _fieldValue = company.currentLocation;
      } else if (fieldName == 'Categoría') {
        _fieldValue = _currentCategory;
      } else if (fieldName == 'Estado de activo') {
        _fieldValue = _currentAssetStatus;
      } else if (fieldName == 'Estado de etiqueta') {
        _fieldValue = _currentTagStatus;
      }
      // Función a ejecutar al cambiar opción
      void _onValueChange(String newValue) {
        if (fieldName == 'Ubicación') {
          company.changeLocation(newValue);
          inventory.extractLocalItems(newValue);
        } else if (fieldName == 'Categoría') {
          inventory.changeCategory(newValue);
        } else if (fieldName == 'Estado de activo') {
          inventory.changeStatus(newValue);
        } else if (fieldName == 'Estado de etiqueta') {
          inventory.changeTagStatus(newValue);
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: 70,
              child: Text(
                fieldName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: _menuBoxWidth,
            height: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: DropdownButton<String>(
                value: _fieldValue,
                icon: Icon(Icons.arrow_downward,
                    color: Theme.of(context).highlightColor),
                elevation: 16,
                style: const TextStyle(fontSize: 14, color: Colors.brown),
                onChanged: (newValue) => _onValueChange(newValue!),
                items: list,
              ),
            ),
          ),
        ]),
      );
    }

    // Campo de búsqueda
    final _searchField = SizedBox(
      width: _searchBoxWidth,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: TextFormField(
          decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              labelText: 'Buscar por nombre, serial o código de barras'),
          onChanged: inventory.changeSearchField,
          validator: (value) => null,
        ),
      ),
    );

    // Botón de limpiar búsqueda
    final _cleanButton = Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.reset();
            company.currentLocation = null;
            inventory
              ..currentCategory = null
              ..currentStatus = null
              ..currentTagStatus = null
              ..localInventory.clear()
              ..changeSearchField('');
            searchField.clear();
            FocusScope.of(context).unfocus();
          }
        },
        child: const Text('Limpiar'),
      ),
    );
    // ----Widgets---- FIN

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
                Text('Codificar etiquetas',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Codifique las etiquetas no imprimibles de sus activos',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          // Información de lector
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Estado de lector
              Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: encoder.currentEncoder == null
                      ? [
                          const Icon(Icons.online_prediction),
                          const Text('Codificador no asociado')
                        ]
                      : [
                          const Icon(
                            Icons.online_prediction,
                            color: Colors.blueAccent,
                          ),
                          const Text('Codificador asociado'),
                          Text(encoder.currentEncoder!)
                        ],
                ),
              ),
              if (encode1)
                // Botón de configuración
                Container(
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _deviceSelection(context);
                        if (encoder.currentEncoder != null) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        }
                      },
                      child: const Text('Configurar codificador',
                          textAlign: TextAlign.center),
                    ),
                  ),
                ),
            ],
          ),
          // Filtros de búsqueda
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: _formKey,
              // La organización depende del tamaño de la pantalla
              child: (mediaSize.width < screenSizeLimit)
                  ?
                  // Pantalla chica
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Flitrar por
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: const Text('Filtra por:'),
                        ),
                        // Selección de ubicación
                        _filterField('Ubicación', _listOfLocations),
                        // Selección de categoría
                        _filterField('Categoría', _listOfCategories),
                        // Selección de estado
                        _filterField('Estado de activo', _listOfStatus),
                        // Selección de estado de codificación de etiqueta
                        _filterField('Estado de etiqueta', _listOfTagStatus),
                        // Búsqueda genérica
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(children: [
                            // Texto "buscar"
                            const SizedBox(
                              width: 70,
                              child: Text('Buscar:'),
                            ),
                            // Campo de búsqueda
                            TextFieldCompany(_searchBoxWidth,
                                'Buscar por nombre, serial o código de barras'),
                          ]),
                        ),
                        // Botón de limpiar buscador
                        _cleanButton,
                      ],
                    )
                  :
                  // Pantalla grande
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Flitrar por
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: const Text('Filtra por:'),
                            ),
                            // Selección de ubicación
                            _filterField('Ubicación', _listOfLocations),
                            // Selección de categoría
                            _filterField('Categoría', _listOfCategories),
                            // Selección de estado
                            _filterField('Estado de activo', _listOfStatus),
                            // Selección de estado de codificación de etiqueta
                            _filterField(
                                'Estado de etiqueta', _listOfTagStatus),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Búsqueda genérica
                            // Texto "buscar"
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                width: 70,
                                child: Text('Buscar:'),
                              ),
                            ),
                            // Campo de búsqueda
                            TextFieldCompany(_searchBoxWidth,
                                'Buscar por nombre, serial o código de barras'),
                            // Botón de limpiar buscador
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: _cleanButton,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          // Información de activos
          InfoToShow(),
          // Protección de etiquetas
          const ProtectTag(),
        ],
      ),
    );
  }

  // Menú de selección de codificador
  Future<void> _deviceSelection(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        // Capturar información de codificador
        final encoder = context.watch<EncoderModel>();
        return AlertDialog(
          title: const Text('Dispositivo de escritura'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Dispositivo a usar
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    'Seleccione el dispositivo a utilizar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    //textAlign: TextAlign.left,
                  ),
                ),
                // Lista de opciones
                ListTile(
                  dense: true,
                  title: const Text('Portátil\n(Chainway)'),
                  leading: Radio(
                    value: EncoderType.handheld,
                    groupValue: encoder.encoderType,
                    onChanged: (value) {
                      encoder.updateencoderType(value! as EncoderType);
                    },
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Escritorio\n(Oppiot)'),
                  leading: Radio(
                    value: EncoderType.desktop,
                    groupValue: encoder.encoderType,
                    onChanged: (value) {
                      encoder.updateencoderType(value! as EncoderType);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (encoder.encoderType == EncoderType.handheld) {
                  await Navigator.pushNamed(context, '/config-lector');
                } else {
                  await Navigator.pushNamed(context, '/config-codificador');
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Método para llenar listado de categorías o estados
  List<DropdownMenuItem<String>> _fillListOfItems(
      List<String> initialList, String allChoices, double myWidth) {
    final itemsList = initialList
        .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
              value: value,
              child: SizedBox(
                width: myWidth,
                child: Text(value),
              ),
            ))
        .toList()
      // Agregar opción "Todas" o "Todos" al menú
      ..insert(
        0,
        DropdownMenuItem<String>(
          value: allChoices,
          child: SizedBox(
            width: myWidth,
            child: Text(
              allChoices,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    return itemsList;
  }
}

/// Clase para devolver la información de activos a mostrar
class InfoToShow extends StatelessWidget {
  /// Class Key
  // ignore: prefer_const_constructors_in_immutables
  InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Leemos cambios en el modelo del inventario
    final inventory = context.watch<InventoryModel>();
    // Capturar información de codificador
    final encoder = context.watch<EncoderModel>();
    final searchField = context.watch<ProviderSearch>();
    // Número de ítems
    var _numItems = 0;

    // Presentamos lista de activos de la ubicación
    if (inventory.localInventory.isNotEmpty) {
      final list2show = <TableRow>[];

      // Llenar la lista considerando filtros
      final initialAssetsList = <Asset>[];
      for (final item in inventory.localInventory) {
        final itemCategory = inventory.getAssetMainCategory(item.assetCode);
        // Activos de la categoría elegida
        if (itemCategory == inventory.currentCategory ||
            inventory.currentCategory == 'Todas') {
          // Activos del estado elegido
          // No se muestran activos "de baja" a menos que se soliciten
          // explícitamente
          if (item.status == inventory.currentStatus ||
              (inventory.currentStatus == 'Todos' &&
                  item.status != 'De baja')) {
            // Activos con estado de impresión de etiqueta elegido
            item.tagEncoded ??= false;
            if ((item.tagEncoded! &&
                    inventory.currentTagStatus == 'Impresas') ||
                (!item.tagEncoded! &&
                    inventory.currentTagStatus == 'No impresas') ||
                inventory.currentTagStatus == 'Todas') {
              initialAssetsList.add(item);
            }
          }
        }
      }
      // Considerar campo de búsqueda también
      final assets2show = inventory.filterAssets(
          searchField.searchFilter, initialAssetsList, '');

      for (var i = 0; i < assets2show.length; i++) {
        // Fila de la tabla a presentar
        list2show.add(
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey[300],
            ),
            children: [
              Text((i + 1).toString(), textAlign: TextAlign.center),
              Text(assets2show[i].name!),
              Container(
                padding: const EdgeInsets.all(1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón de guardar
                    IconButton(
                      icon: const Icon(Icons.settings_input_antenna),
                      color: !assets2show[i].tagEncoded!
                          ? Colors.red[300]
                          : Colors.green[300],
                      onPressed: () {
                        if (assets2show[i].assetCode!.isEmpty) {
                          HenutsenDialogs.showSnackbar(
                              'El activo seleccionado no '
                              'tiene código asignado.',
                              context);
                        } else if (encoder.currentEncoder != null) {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Confirmación',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(),
                                    Text('Se grabará etiqueta con '
                                        'EPC ${assets2show[i].assetCode}'),
                                    const Text('¿Confirmar?'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    encoder
                                      ..tag2write.clear()
                                      ..addAsset(assets2show[i]);
                                    Navigator.pushNamed(context, '/codificar2');
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          HenutsenDialogs.showSnackbar(
                              'Debe asociar un '
                              'codificador.',
                              context);
                        }
                      },
                    ),
                    PopupMenuButton<String>(
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
                              final assetInfo = assets2show[i];
                              // Para usar clase asset code
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
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(children: [
                                    const Text(
                                      'Información del activo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(),
                                    Table(children: [
                                      TableRow(children: [
                                        const Text(
                                          'Activo: ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          assetInfo.name!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        const Text(
                                          'Serial: ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          assetInfo.assetDetails!.serialNumber!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        const Text(
                                          'Descripción: ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          assetInfo.description!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ]),
                                    ]),
                                    const Text(
                                      'Código del activo',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Table(children: [
                                      TableRow(children: [
                                        const Text(
                                          'Código EPC\n(Base de datos): ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          assetInfo.assetCode!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        const Text(
                                          'Código EPC (RFID): ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          _epcRfid,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        const Text(
                                          'Código de barras: ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          _barcode,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ]),
                                    ]),
                                  ]),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        // Total de activos mostrados
        _numItems = assets2show.length;
      }

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
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: const Text(
                'Nombre del activo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'Total de activos: $_numItems',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ]);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(children: [
          // Tabla de activos
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [titlesRow, ...list2show],
          ),
        ]),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text(
          'No hay información. Seleccione una ubicación con '
          'activos asociados.',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}

/// Clase para protección de etiquetas
class ProtectTag extends StatelessWidget {
  /// Class Key
  const ProtectTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _textBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.4
        : mediaSize.width * 0.3;

    // Capturar información de codificador
    final encoder = context.watch<EncoderModel>();
    final company = context.watch<CompanyModel>();
    final user = context.watch<UserModel>();
    final encode2 =
        verifyResource(user.currentUser.roles!, company, 'ViewEncode1');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, top: 20),
          child: Text(
            'Proteger etiqueta',
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
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  width: _textBoxWidth,
                  child: const Text(
                    'Asigna contraseña a etiquetas ya codificadas para'
                    ' incrementar la seguridad de la aplicación',
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              if (encode2)
                // Botón de lectura
                Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: (encoder.currentEncoder != null)
                          ? Theme.of(context).highlightColor
                          : Theme.of(context).disabledColor,
                    ),
                    onPressed: () {
                      //Navigator.pushNamed(context, '/codificar-contrasena');
                      //*
                      if (encoder.currentEncoder != null) {
                        if (encoder.encoderType == EncoderType.handheld) {
                          Navigator.pushNamed(context, '/codificar-contrasena');
                        } else {
                          HenutsenDialogs.showSnackbar(
                              'Función permitida solo para codificador '
                              'Chainway.',
                              context);
                        }
                      } else {
                        HenutsenDialogs.showSnackbar(
                            'Debe asociar un '
                            'codificador.',
                            context);
                      }
                      //*/
                    },
                    child: const Text(
                      'Proteger\netiqueta',
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
}
