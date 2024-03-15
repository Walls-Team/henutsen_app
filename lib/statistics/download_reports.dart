// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// --------------Descarga de reportes------------------
// ----------------------------------------------------

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/statistics/media_management/media_manager.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class DownloadReportsPage extends StatelessWidget {
  ///  Class Key
  const DownloadReportsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            appBar: ApplicationBar.appBar(context, PageList.informes),
            endDrawer: MenuDrawer.drawer(context, PageList.informes),
            body: const DownloadReports(),
            bottomNavigationBar: BottomBar.bottomBar(
                PageList.informes, context, PageList.informes,
                thisPage: true)),
      );
}

/// Descarga de reportes
class DownloadReports extends StatelessWidget {
  ///  Class Key
  const DownloadReports({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extensión de los reportes generados
    const fileExtension = '.xlsx';
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _menuWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.4 - 50
        : mediaSize.width * 0.3 - 50;
    final _checkboxWidth =
        (mediaSize.width < screenSizeLimit) ? mediaSize.width * 0.27 : 180.0;
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    final _currentLocation = company.currentLocation;
    // Capturar el inventario
    final inventory = context.watch<InventoryModel>();
    // Capturar estadísticas
    final statistics = context.watch<StatisticsModel>();

    // Lista de opciones de campos
    List<Widget> _optionsList(int offsetIndex, int quantity) {
      final _rows = <Row>[];
      Map.fromIterables(
        statistics.selectableFieldsList.keys.skip(offsetIndex).take(quantity),
        statistics.selectableFieldsList.values.skip(offsetIndex).take(quantity),
      ).forEach((key, value) {
        // "Nombre" siempre va
        var _alwaysTrue = false;
        if (key == 'Nombre') {
          _alwaysTrue = true;
        }
        final _myChoice = Checkbox(
          value: value,
          activeColor: _alwaysTrue ? Colors.grey : Colors.lightBlue,
          onChanged: (newValue) {
            if (!_alwaysTrue) {
              statistics.updateFieldSelection(key, newValue!);
            }
          },
        );
        final _myRow = Row(children: [
          SizedBox(
            width: _checkboxWidth,
            child: Text(key),
          ),
          _myChoice,
        ]);
        _rows.add(_myRow);
      });
      return _rows;
    }

    // Método para devolver cada fila
    TableRow _tableRow(String rowName) => TableRow(
          children: [
            // Texto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (rowName != 'Activos de la ubicación:')
                    ? [
                        Text(
                          rowName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ]
                    : [
                        Text(
                          rowName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: DropdownButton<String>(
                            value: _currentLocation,
                            icon: Icon(Icons.arrow_downward,
                                color: Theme.of(context).highlightColor),
                            elevation: 16,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.brown),
                            onChanged: (newValue) {
                              company.changeLocation(newValue);
                              inventory.extractLocalItems(newValue!);
                            },
                            items: company.places
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
                      ],
              ),
            ),
            // Botón de descargar
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).highlightColor,
                ),
                onPressed: () {
                  String _fileName;
                  switch (rowName) {
                    case 'Lista total de activos':
                      _fileName = 'inventario_'
                          '${company.currentCompany.name! + fileExtension}';
                      _produceExcel(
                          inventory.fullInventory, _fileName, context);
                      break;
                    case 'Activos de la ubicación:':
                      if (_currentLocation == null) {
                        HenutsenDialogs.showSnackbar(
                            'No se ha seleccionado ninguna ubicación', context);
                      } else {
                        final _fileName =
                            'inventario_${company.currentCompany.name}_'
                            '${_currentLocation + fileExtension}';
                        _produceExcel(
                            inventory.localInventory, _fileName, context);
                      }
                      break;
                    case 'Lista de activos faltantes':
                      final _fileName = 'inventarioPerdido_'
                          '${company.currentCompany.name! + fileExtension}';
                      _produceExcel(
                          statistics.allMissingAssetsList, _fileName, context);
                      break;
                    case 'Lista de activos dados de baja':
                      final _itemsOut = <Asset>[];
                      _itemsOut.addAll(inventory.fullInventory
                          .where((element) => element.status == 'De baja'));
                      _fileName = 'inventarioDeBaja_'
                          '${company.currentCompany.name! + fileExtension}';
                      _produceExcel(_itemsOut, _fileName, context);
                      break;
                    case 'Lista de activos fuera de su ubicación asignada':
                      final _itemsOut = <Asset>[];
                      _itemsOut.addAll(inventory.fullInventory
                          .where((element) => element.outOfLocation ?? false));
                      final _fileName = 'inventarioFuera_'
                          '${company.currentCompany.name! + fileExtension}';
                      _produceExcel(_itemsOut, _fileName, context);
                      break;
                    default:
                      break;
                  }
                },
                child: const Text('Descargar'),
              ),
            ),
          ],
        );

    return ListView(
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Descarga de reportes',
              style: Theme.of(context).textTheme.headline3),
        ),
        // Subtítulo
        const Padding(
          padding: EdgeInsets.only(left: 10, top: 20),
          child: Text('Seleccione los campos deseados en el reporte'),
        ),
        // Tabla de reportes disponibles
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _optionsList(0, 6),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _optionsList(6, 7),
              ),
            ],
          ),
        ),
        // Subtítulo
        const Padding(
          padding: EdgeInsets.only(left: 10, top: 20),
          child: Text('Descargue el reporte deseado'),
        ),
        // Tabla de reportes disponibles
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(3),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Total de activos
              _tableRow('Lista total de activos'),
              // División
              const TableRow(
                children: [
                  Divider(),
                  Divider(),
                ],
              ),
              // Activos por ubicación
              _tableRow('Activos de la ubicación:'),
              // División
              const TableRow(
                children: [
                  Divider(),
                  Divider(),
                ],
              ),
              // Activos faltantes
              _tableRow('Lista de activos faltantes'),
              // División
              const TableRow(
                children: [
                  Divider(),
                  Divider(),
                ],
              ),
              // Activos de baja
              _tableRow('Lista de activos dados de baja'),
              // División
              const TableRow(
                children: [
                  Divider(),
                  Divider(),
                ],
              ),
              // Activos marcados con "Salida"
              _tableRow('Lista de activos fuera de su ubicación asignada'),
            ],
          ),
        ),
        // Botones
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de cancelar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Volver'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Método para generar archivo xlsx para descarga
  Future<void> _produceExcel(
      List<Asset> assetsList, String fileName, BuildContext context) async {
    if (assetsList.isEmpty) {
      HenutsenDialogs.showSnackbar(
          'El reporte solicitado no contiene datos.\n'
          'No se generará archivo para descarga',
          context);
      return;
    }
    // Capturar estadísticas
    final statistics = context.read<StatisticsModel>();
    final rows = [];

    // Fila de títulos
    final titlesRow = [];
    statistics.selectableFieldsList.forEach((key, value) {
      if (value) {
        titlesRow.add(key);
      }
    });

    // Agregar la información de cada activo
    for (var i = 0; i < assetsList.length; i++) {
      final row = [];
      if (titlesRow.contains('Código de activo')) {
        row.add(assetsList[i].assetCode);
      }
      if (titlesRow.contains('Nombre')) {
        row.add(assetsList[i].name);
      }
      if (titlesRow.contains('Descripción')) {
        row.add(assetsList[i].description);
      }
      if (titlesRow.contains('Ubicación')) {
        row.add(assetsList[i].locationName);
      }
      if (titlesRow.contains('Estado')) {
        row.add(assetsList[i].status);
      }
      if (titlesRow.contains('Categoría')) {
        if (assetsList[i].categories!.isEmpty) {
          row.add('');
        } else {
          row.add(assetsList[i].categories?.first.value);
        }
      }
      if (titlesRow.contains('Fabricante')) {
        row.add(assetsList[i].assetDetails?.make);
      }
      if (titlesRow.contains('Modelo')) {
        row.add(assetsList[i].assetDetails?.model);
      }
      if (titlesRow.contains('Número serial')) {
        row.add(assetsList[i].assetDetails?.serialNumber);
      }
      if (titlesRow.contains('Responsable')) {
        row.add(assetsList[i].custody);
      }
      if (titlesRow.contains('Último conteo')) {
        row.add(assetsList[i].lastStocktaking!.findStatus);
      }
      if (titlesRow.contains('Último movimiento detectado')) {
        row.add(assetsList[i].lastTransferDate);
      }
      if (titlesRow.contains('Código heredado')) {
        row.add(assetsList[i].assetCodeLegacy?[0].value);
      }
      rows.add(row);
    }

    // Generar xlsx a grabar
    final excelFile = Excel.createExcel();
    final sheetObject = excelFile['Reporte'];
    // Eliminar hoja creada por defecto
    excelFile.delete('Sheet1');

    // Estilo para la fila de títulos
    final _cellStyle = CellStyle(bold: true);
    // Insertar títulos al archivo de excel
    for (var i = 0; i < titlesRow.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = titlesRow[i]
        ..cellStyle = _cellStyle;
    }

    // Insertar datos por filas al archivo de excel
    rows.forEach((element) => sheetObject.appendRow(element));

    // Codificar información
    final _encodedFile = excelFile.encode()!;
    final _bytes = Uint8List.fromList(_encodedFile);

    // Generación depende si es web o móvil
    if (await FileDownload.generateFile(_bytes, fileName) == null) {
      HenutsenDialogs.showSnackbar('Falló la descarga', context);
    } else {
      HenutsenDialogs.showSnackbar('Archivo descargado exitosamente', context);
    }
  }
}
