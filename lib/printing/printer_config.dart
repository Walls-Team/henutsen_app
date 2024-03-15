// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// ------Selección y configuración de impresora--------
// ----------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/printer_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class PrinterConfig extends StatelessWidget {
  ///  Class Key
  const PrinterConfig({Key? key}) : super(key: key);
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
          body: PrintPage(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.impresion),
        ),
      );
}

/// Opciones de impresión
class PrintPage extends StatelessWidget {
  ///  Class Key
  PrintPage({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _menuBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.4
        : mediaSize.width * 0.3;
    final _menuWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.4 - 50
        : mediaSize.width * 0.3 - 50;
    final _serverBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.7 - 20
        : mediaSize.width * 0.4 - 20;
    // Capturar información de impresora
    final printer = context.watch<PrinterModel>();

    // Campo de texto para ingreso de URL del servidor de impresión
    final _serverUrlField = SizedBox(
      width: _serverBoxWidth,
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          labelText: 'URL (Ej: https://dir.com)',
        ),
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[\n\t\r]'))],
        initialValue: printer.serverUrl,
        onChanged: printer.updateURL,
      ),
    );

    // Menú de perfil de etiqueta
    final _tagProfileMenu = SizedBox(
      width: _menuBoxWidth,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: DropdownButton<String>(
          value: printer.tagProfile,
          icon: const Icon(Icons.arrow_downward, color: Colors.blueAccent),
          elevation: 16,
          style: const TextStyle(fontSize: 14, color: Colors.brown),
          onChanged: printer.changeTagProfile,
          items: printer.tagSizes
              .map<DropdownMenuItem<String>>(
                (value) => DropdownMenuItem<String>(
                  value: value,
                  child: SizedBox(
                    width: _menuWidth,
                    child: Text(value),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    return ListView(
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Configuración de\nimpresora',
              style: Theme.of(context).textTheme.headline3),
        ),
        // Texto de url
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          // La organización depende del tamaño de la pantalla
          child: (mediaSize.width < screenSizeLimit)
              ? Column(
                  children: [
                    const Text('URL del servidor de impresión:\n'),
                    _serverUrlField,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('URL del servidor\nde impresión:'),
                    _serverUrlField,
                  ],
                ),
        ),
        // Impresora asociada
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de conectar al servidor
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: (printer.serverUrl.isNotEmpty)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                ),
                onPressed: () {
                  if (printer.serverUrl.isNotEmpty) {
                    if ((printer.serverUrl.startsWith('https://') &&
                            (printer.serverUrl.length > 8)) ||
                        (printer.serverUrl.startsWith('http://') &&
                            (printer.serverUrl.length > 7))) {
                      printer.postek.serverURL = printer.serverUrl;
                      printer.postek.serverURL =
                          '${printer.postek.serverURL}/postek/print';
                      _getPrinters(context);
                    } else {
                      HenutsenDialogs.showSnackbar(
                          'Ingrese una dirección '
                          'válida',
                          context);
                    }
                  }
                },
                child: const Text('Obtener\nimpresoras',
                    textAlign: TextAlign.center),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Impresora:'),
                  SizedBox(
                    width: _menuBoxWidth,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: DropdownButton<String>(
                        value: printer.currentPrinter,
                        icon: const Icon(Icons.arrow_downward,
                            color: Colors.blueAccent),
                        elevation: 16,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.brown),
                        onChanged: (newValue) async {
                          printer.changePrinter(newValue);
                          printer.postek.printerName = newValue!;
                        },
                        items: printer.printers
                            .map<DropdownMenuItem<String>>(
                                (value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: SizedBox(
                                        width: _menuWidth,
                                        child: Text(value),
                                      ),
                                    ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        // Título para tamaño de etiquetas
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Configuración de etiquetas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        // Perfil de etiqueta
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          // La organización depende del tamaño de la pantalla
          child: (mediaSize.width < screenSizeLimit)
              ? Column(
                  children: [
                    const Text(
                        'Seleccione un tamaño de etiqueta (o introduzca uno '
                        'nuevo):\n'),
                    _tagProfileMenu,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                        'Seleccione un tamaño de etiqueta\n(o introduzca uno '
                        'nuevo):'),
                    _tagProfileMenu,
                  ],
                ),
        ),
        // Configuración de tags
        Form(
          key: _formKey,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'Ancho',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'Alto',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'Espacio entre etiquetas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: SizedBox(
                      width: 100,
                      child: printer.tagProfile == 'Personalizado'
                          ? TextFormField(
                              initialValue: printer.tagWidth == null
                                  ? ''
                                  : (printer.tagWidth! / printerRes)
                                      .round()
                                      .toString(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                labelText: 'mm',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]'))
                              ],
                              onChanged: (value) {
                                final valueInt = int.tryParse(value) ?? 0;
                                printer.tagWidth = valueInt * printerRes;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Ingrese valor';
                                }
                                return null;
                              },
                            )
                          : Container(
                              height: 50,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(25, 30, 30, 30),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Text(
                                printer.tagWidth == null
                                    ? ''
                                    : '${(printer.tagWidth! / printerRes).round().toString()} mm',
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: SizedBox(
                      width: 100,
                      child: printer.tagProfile == 'Personalizado'
                          ? TextFormField(
                              initialValue: printer.tagHeight == null
                                  ? ''
                                  : (printer.tagHeight! / printerRes)
                                      .round()
                                      .toString(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                labelText: 'mm',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]'))
                              ],
                              onChanged: (value) {
                                final valueInt = int.tryParse(value) ?? 0;
                                printer.tagHeight = valueInt * printerRes;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Ingrese valor';
                                }
                                return null;
                              },
                            )
                          : Container(
                              height: 50,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(25, 30, 30, 30),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Text(
                                printer.tagHeight == null
                                    ? ''
                                    : '${(printer.tagHeight! / printerRes).round().toString()} mm',
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: SizedBox(
                      width: 100,
                      child: printer.tagProfile == 'Personalizado'
                          ? TextFormField(
                              initialValue: printer.tagGap == null
                                  ? ''
                                  : (printer.tagGap! / printerRes)
                                      .round()
                                      .toString(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                labelText: 'mm',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]'))
                              ],
                              onChanged: (value) {
                                final valueInt = int.tryParse(value) ?? 0;
                                printer.tagGap = valueInt * printerRes;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Ingrese valor';
                                }
                                return null;
                              },
                            )
                          : Container(
                              height: 50,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(25, 30, 30, 30),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Text(
                                printer.tagGap == null
                                    ? ''
                                    : '${(printer.tagGap! / printerRes).round().toString()} mm',
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        // Título para modo de impresión
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Modo de impresión',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        // Lista de opciones
        Column(
          children: <Widget>[
            ListTile(
              dense: true,
              title: const Text('Tag RFID'),
              leading: Radio(
                value: PrintMode.rfid,
                groupValue: printer.printMode,
                // ignore: avoid_types_on_closure_parameters
                onChanged: (PrintMode? value) {
                  printer.updatePrintMode(value!);
                },
              ),
            ),
            ListTile(
              dense: true,
              title: const Text('Código de barras'),
              leading: Radio(
                value: PrintMode.barcode,
                groupValue: printer.printMode,
                // ignore: avoid_types_on_closure_parameters
                onChanged: (PrintMode? value) {
                  printer.updatePrintMode(value!);
                },
              ),
            ),
            ListTile(
              dense: true,
              title: const Text('Tag RFID + Código de barras'),
              leading: Radio(
                value: PrintMode.rfidAndBarcode,
                groupValue: printer.printMode,
                // ignore: avoid_types_on_closure_parameters
                onChanged: (PrintMode? value) {
                  printer.updatePrintMode(value!);
                },
              ),
            ),
          ],
        ),
        // Título para contraste
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Contraste de impresión',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        // Contraste
        SizedBox(
          width: 800,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Slider(
                  value: printer.printDarkness.toDouble(),
                  max: 20,
                  divisions: 20,
                  label: printer.printDarkness.toString(),
                  onChanged: (value) => printer.changeDarkness(value.toInt())),
              Text(printer.printDarkness.toString()),
            ],
          ),
        ),
        // Fila de botones
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de cancelar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ),
              // Botón de guardar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).highlightColor,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Guardar parámetros de etiquetas
                      printer.postek.setTagData(
                          printer.tagWidth.toString(),
                          printer.tagHeight.toString(),
                          printer.tagGap.toString());
                      printer.postek.setPrintDarkness(printer.printDarkness);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Guardar\nconfiguración',
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

  // Inicializar impresoras
  Future<void> _getPrinters(BuildContext context) async {
    // Capturar información de impresora
    final printer = context.read<PrinterModel>();

    try {
      final printers = await printer.postek.fetchPrinter();
      if (printers.isNotEmpty) {
        for (var i = 0; i < printers.length; i++) {
          if (!printer.printers.contains(printers[i]['printName'].toString())) {
            printer.addPrinter(printers[i]['printName'].toString());
          }
        }
      } else {
        HenutsenDialogs.showSnackbar('No hay impresoras disponibles', context);
      }
    } on Exception {
      HenutsenDialogs.showSnackbar(
        'Error en conexión a servidor de impresión',
        context,
      );
      return;
    }
  }
}
