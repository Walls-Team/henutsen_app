// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// ----------------Impresión de etiquetas--------------
// ----------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/printer_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class PrintingPage extends StatelessWidget {
  ///  Class Key
  const PrintingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          await NavigationFunctions.checkLeavingPage(
            context,
            PageList.impresion,
          );
          return true;
        },
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.impresion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.impresion),
          body: PrintData(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.impresion),
        ),
      );
}

/// --------------- Para imprimir ------------------
class PrintData extends StatelessWidget {
  ///  Class Key
  PrintData({Key? key}) : super(key: key);

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
    // Capturar información de impresora
    final printer = context.watch<PrinterModel>();
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

    company.places.sort();
    // Menú desplegable de ubicaciones
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
                Text('Imprimir etiquetas',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Imprima las etiquetas de sus activos',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          // Información de impresora
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Estado de impresora
              Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: printer.currentPrinter == null
                      ? [
                          const Icon(Icons.print),
                          const Text('Impresora no asociada')
                        ]
                      : [
                          const Icon(
                            Icons.print,
                            color: Colors.blueAccent,
                          ),
                          const Text('Impresora asociada'),
                          Text(printer.currentPrinter!)
                        ],
                ),
              ),
              // Botón de configuración
              Container(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/config-impresora');
                      if (printer.currentPrinter != null) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      }
                    },
                    child: const Text('Configurar impresora',
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
                        // Selección de estado de impresión de etiqueta
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
                            _searchField,
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
                            // Selección de estado de impresión de etiqueta
                            _filterField(
                              'Estado de etiqueta',
                              _listOfTagStatus,
                            ),
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
                            _searchField,
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
        ],
      ),
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
    // Capturar información de impresora
    final printer = context.watch<PrinterModel>();

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
          // Activos con el estado elegido
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
          inventory.currentSearchField, initialAssetsList, '');

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
                color: i.isEven ? Colors.white : Colors.grey[300],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'images/iconoImprimir.png',
                        width: 50,
                        height: 50,
                        semanticLabel: 'Gestión',
                      ),
                      onPressed: () {
                        if (assets2show[i].assetCode!.isEmpty) {
                          HenutsenDialogs.showSnackbar(
                              'El activo seleccionado no '
                              'tiene código asignado.',
                              context);
                        } else if (printer.currentPrinter != null) {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Confimación',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(),
                                    Text('Se imprimirá etiqueta con '
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
                                    printer
                                      ..tags2print.clear()
                                      ..currentPrintingTag = 0
                                      ..addAsset(assets2show[i]);
                                    Navigator.pushNamed(context, '/imprimir2');
                                    // Algunos datos para impresión
                                    final _name2print = assets2show[i].name!;
                                    final _serial2print = assets2show[i]
                                            .assetDetails!
                                            .serialNumber ??
                                        '';
                                    // Imprimir tag según el modo seleccionado
                                    if (printer.printMode == PrintMode.rfid) {
                                      printer.printRFIDTag(
                                          printer.tags2print[0][0]);
                                    } else if (printer.printMode ==
                                        PrintMode.barcode) {
                                      printer.printBarcode(
                                          printer.tags2print[0][1],
                                          _name2print,
                                          _serial2print);
                                    } else {
                                      printer.printRFIDBarcode(
                                          printer.tags2print[0][1],
                                          printer.tags2print[0][0],
                                          _name2print,
                                          _serial2print);
                                    }
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          HenutsenDialogs.showSnackbar(
                              'Debe asociar una '
                              'impresora.',
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(children: [
          // Tabla de activos
          Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [titlesRow, ...list2show]),
          // Fila de botones
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            // Impresión múltiple
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(5),
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: (printer.currentPrinter != null)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                  onPressed: () {
                    if (printer.currentPrinter != null) {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Confimación',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const Divider(),
                                  Text('Se imprimirán $_numItems etiqueta(s).'),
                                  const Text('¿Confirmar?'),
                                ]),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Volver'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                printer.tags2print.clear();
                                printer.currentPrintingTag = 0;
                                for (var j = 0; j < assets2show.length; j++) {
                                  if (assets2show[j].assetCode!.isNotEmpty) {
                                    printer.addAsset(assets2show[j]);
                                  }
                                }
                                Navigator.pushNamed(context, '/imprimir2');
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      HenutsenDialogs.showSnackbar(
                          'Debe asociar una '
                          'impresora.',
                          context);
                    }
                  },
                  child:
                      const Text('Imprimir todos', textAlign: TextAlign.center),
                ),
              ),
            ),
          ]),
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
