// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------
// -----------Impresión de etiquetas (parte 2)--------------
// ---------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/printer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class PrintingPage2 extends StatelessWidget {
  ///  Class Key
  const PrintingPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.impresion),
          endDrawer: MenuDrawer.drawer(context, PageList.impresion),
          body: const PrintTags(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.impresion),
        ),
      );
}

/// --------------- Para imprimir ------------------
class PrintTags extends StatelessWidget {
  ///  Class Key
  const PrintTags({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar información de impresora
    final printer = context.watch<PrinterModel>();
    final _numTags2print = printer.tags2print.length;
    final _numCurrentTag = printer.currentPrintingTag;

    int _myIndex;
    if (_numCurrentTag < _numTags2print) {
      _myIndex = _numCurrentTag;
    } else {
      _myIndex = _numTags2print - 1;
      _updateTagStatus(context);
    }

    Widget myData2show;

    if (_numTags2print == 1) {
      final asset2print = printer.tags2print[0];
      myData2show = Container(
        padding: const EdgeInsets.all(5),
        child: Column(children: [
          const Text('Etiqueta para: '),
          // Nombre del activo
          Text(asset2print[3]),
          // URI del activo
          Text(asset2print[2]),
        ]),
      );
      _updateTagStatus(context);
    } else if (_numTags2print > 1) {
      myData2show = Container(
        padding: const EdgeInsets.all(5),
        child: Column(children: [
          const Text('Etiqueta para: '),
          Text('$_numTags2print activos'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text('Imprimiendo etiqueta $_numCurrentTag '
                'de $_numTags2print.'),
          ),
          // Nombre del activo
          Text('Activo: ${printer.tags2print[_myIndex][3]}'),
        ]),
      );
      // Impresión
      _printSeveralTags(printer);
    } else {
      myData2show = Container();
    }

    return Container(
      padding: const EdgeInsets.all(2),
      child: ListView(
        children: [
          // Título página
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: const Text(
              'Etiqueta(s) enviada(s) a impresión',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          // Información de etiqueta
          myData2show,
          // Fila de botones 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Suspender impresión
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: (_numTags2print > 1 &&
                            !printer.paused &&
                            _numCurrentTag < _numTags2print)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                  onPressed: () {
                    if (_numTags2print > 1 &&
                        !printer.paused &&
                        _numCurrentTag < _numTags2print) {
                      HenutsenDialogs.showSnackbar(
                        'Impresión pausada',
                        context,
                      );
                      printer.pausePrint();
                    }
                  },
                  child: const Text('Suspender', textAlign: TextAlign.center),
                ),
              ),
              // Continuar impresión
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: (_numTags2print > 1 &&
                            printer.paused &&
                            _numCurrentTag < _numTags2print)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                  onPressed: () {
                    if (_numTags2print > 1 &&
                        printer.paused &&
                        _numCurrentTag < _numTags2print) {
                      HenutsenDialogs.showSnackbar(
                        'Impresión continúa',
                        context,
                      );
                      printer.resumePrint();
                    }
                  },
                  child: const Text('Continuar', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          // Fila de botones 1
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Volver
              Container(
                margin: const EdgeInsets.only(top: 20, right: 50),
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: () {
                    printer
                      ..paused = false
                      ..currentPrintingTag = 0;
                    Navigator.pop(context);
                  },
                  child: const Text('Volver', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método para impresión múltiple
  Future<bool> _printSeveralTags(PrinterModel printer) async {
    final _numTags2print = printer.tags2print.length;
    final _numCurrentTag = printer.currentPrintingTag;

    if (_numCurrentTag < _numTags2print) {
      if (!printer.paused) {
        // Imprimir tag según el modo seleccionado
        if (printer.printMode == PrintMode.rfid) {
          final result =
              await printer.printRFIDTag(printer.tags2print[_numCurrentTag][0]);
          if (!result) {
            return result;
          }
        } else if (printer.printMode == PrintMode.barcode) {
          final result = await printer.printBarcode(
              printer.tags2print[_numCurrentTag][1],
              printer.tags2print[_numCurrentTag][3],
              printer.tags2print[_numCurrentTag][4]);
          if (!result) {
            return result;
          }
        } else {
          final result = await printer.printRFIDBarcode(
              printer.tags2print[_numCurrentTag][1],
              printer.tags2print[_numCurrentTag][0],
              printer.tags2print[_numCurrentTag][3],
              printer.tags2print[_numCurrentTag][4]);
          if (!result) {
            return result;
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 800));
        // print('ici');
        printer.updatePrintedTag();
        // print('ici2');
      }
      return true;
    }
    return false;
  }

  // Método para actualizar estado de impresión de etiqueta
  Future<void> _updateTagStatus(BuildContext context) async {
    // Capturar información de impresora
    final printer = context.watch<PrinterModel>();
    // Capturar información de inventario
    final inventory = context.watch<InventoryModel>();
    // Capturar información de inventario
    final user = context.watch<UserModel>();
    // Capturar usuario
    final _currentUserName =
        context.select<UserModel, String>((user) => user.currentUser.userName!);

    // Actualizar estado de activos impresos en inventario
    final _assets2modify = <Asset>[];
    for (var i = 0; i < printer.tags2print.length; i++) {
      for (final item in inventory.fullInventory) {
        if (item.assetCode == printer.tags2print[i][2]) {
          if (item.tagEncoded == null || item.tagEncoded == false) {
            item.tagEncoded = true;
            _assets2modify.add(item);
          }
          break;
        }
      }
    }
    if (_assets2modify.isNotEmpty) {
      final _itemsToSend = <String, dynamic>{
        'AssetBase': _assets2modify,
        'UserName': _currentUserName,
      };
      final _encoded = jsonEncode(_itemsToSend);
      await inventory.modifySeveralAssets(
          _encoded,
          '${user.currentUser.name!.givenName}'
          ' ${user.currentUser.name!.familyName}'
          ' ${user.currentUser.userName}');
    }
  }
}
