// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------------------------------
// ------------------Página resumen de activos a cargar------------------------
// ----------------------------------------------------------------------------

import 'package:csv_parser/csv_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/uploading/LoadFile/Model/decoded_asset.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/load_data.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/process_file.dart';
import 'package:provider/provider.dart';

/// Clase para ver los datos precargados en listas
class AssetDataViewPage extends StatelessWidget {
  ///  Class Key
  const AssetDataViewPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.cargasMasivas),
          endDrawer: MenuDrawer.drawer(context, PageList.cargasMasivas),
          body: AssetDataView(),
          bottomNavigationBar: BottomBar.bottomBar(
            PageList.cargasMasivas,
            context,
            PageList.cargasMasivas,
            thisPage: true,
          ),
        ),
      );
}

///clase para mostrar los datos cargados
class AssetDataView extends StatelessWidget {
  ///  Class Key
  AssetDataView({Key? key}) : super(key: key);

  /// Opciones del menú de selección
  static final options = [
    'Todos',
    'Errores',
    'Duplicados',
    'Activos Totales',
    'Ver Activos por Ubicación',
  ];
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // AssetProvider for file csv
    final assetProvider = Provider.of<CsvParserProvider<CsvAsset>>(context);
    // assetProvider.objects.removeWhere((e) => e.assetCodeLegacy == null);
    final fileInformation = Provider.of<DataFile>(context);
    final fileInformationData = Provider.of<LoadDataProvider>(context);
    final _summary = fileInformationData.summary;

    String _title;
    if (_summary == 1) {
      _title = 'Errores';
    } else if (_summary == 2) {
      _title = 'Duplicados';
    } else if (_summary == 3) {
      _title = 'Activos Totales';
    } else if (_summary == 4) {
      _title = 'Ver Activos por Ubicación';
    } else {
      _title = 'Todos';
    }

    // Información a mostrar
    Widget infoToShow(int option) {
      // Ícono a usar según activo
      Icon _iconToUse(icon, {String? name, String? location}) {
        switch (icon) {
          case 1:
            // Ícono para activos duplicados
            return const Icon(Icons.control_point_duplicate,
                color: Colors.yellow);
          case 2:
            // Ícono para activos con errores
            return const Icon(Icons.error, color: Colors.red);
          default:
            if (name!.isNotEmpty && location!.isNotEmpty) {
              return const Icon(Icons.done, color: Colors.green);
            }
            return const Icon(Icons.error, color: Colors.red);
        }
      }

      // Tabla de datos
      Widget _dataTable(List<CsvAsset> myRows) {
        var index = 0;
        return DataTable(
          sortColumnIndex: 5,
          columns: _listNameColumns(),
          rows: myRows
              .map((e) => DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                        (final states) {
                      if (e.location!.trim().isEmpty ||
                          e.name!.trim().isEmpty) {
                        return Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15);
                      }
                      return null;
                    }),
                    cells: [
                      DataCell(_iconToUse(_summary,
                          name: e.name, location: e.location)),
                      DataCell(
                        Text('${index += 1}'),
                      ),
                      DataCell(
                        Text(e.name!),
                      ),
                      DataCell(
                        Text(e.location!),
                      ),
                      DataCell(
                        Text(e.stock!),
                      ),
                      DataCell(
                        Text(e.status!),
                      ),
                    ],
                  ))
              .toList(),
        );
      }

      switch (option) {
        // Ver por ubicaciones
        case 4:
          // Armar listado de ubicaciones
          final _locations = <String>[];
          for (final item in fileInformation.assetsTotal) {
            if (item.location != null) {
              if (!_locations.contains(item.location)) {
                _locations.add(item.location!);
              }
            }
          }
          // Armar tabla por ubicación
          final _segmentedData = <Widget>[];
          for (final loc in _locations) {
            final assetsList = <CsvAsset>[];
            for (final item in fileInformation.assetsTotal) {
              if (item.location == loc) {
                assetsList.add(item);
              }
            }
            final data2show =
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 30, right: 20),
                    child: Row(children: [
                      const Text(
                        'Ubicación: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(loc),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 20),
                    child: Row(children: [
                      const Text(
                        'No. de activos: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(assetsList.length.toString()),
                    ]),
                  ),
                ],
              ),
              _dataTable(assetsList),
            ]);
            _segmentedData.add(data2show);
          }
          return Column(
            children: _segmentedData,
          );
        default:
          List<CsvAsset> _rowsToUse;
          if (option == 1) {
            _title = 'Errores';
            _rowsToUse = fileInformation.assetErrors;
          } else if (option == 2) {
            _title = 'Duplicados';
            _rowsToUse = fileInformation.assetDuplicates;
          } else if (option == 3) {
            _title = 'Activos Totales';
            _rowsToUse = fileInformation.assetsTotal;
          } else {
            _title = 'Todos';
            _rowsToUse = assetProvider.objects;
          }
          return _dataTable(_rowsToUse);
      }
    }

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      controller: _verticalController,
      child: ListView(
        controller: _verticalController,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              'Previsualización',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Scrollbar(
            isAlwaysShown: kIsWeb,
            controller: _horizontalController,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButton<String>(
                          value: _title,
                          elevation: 16,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.brown),
                          icon: Icon(Icons.arrow_downward,
                              color: Theme.of(context).highlightColor),
                          onChanged: (newValue) async {
                            var aux = 0;
                            if (newValue == 'Todos') {
                              aux = 0;
                            } else if (newValue == 'Errores') {
                              aux = 1;
                            } else if (newValue == 'Duplicados') {
                              aux = 2;
                            } else if (newValue == 'Activos Totales') {
                              aux = 3;
                            } else if (newValue ==
                                'Ver Activos por Ubicación') {
                              aux = 4;
                            }
                            fileInformationData.changeSummary(aux);
                          },
                          items: options
                              .map<DropdownMenuItem<String>>(
                                  (value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: SizedBox(
                                            width: 180, child: Text(value)),
                                      ))
                              .toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          _title,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ],
                  ),
                  infoToShow(_summary)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Columnas de la lista
  List<DataColumn> _listNameColumns() => const [
        DataColumn(
          label: Text('Estado'),
          tooltip: 'Estado',
        ),
        DataColumn(
          label: Text('Línea'),
          tooltip: 'Linea del documento',
        ),
        DataColumn(
          label: Text('Nombre activo'),
          tooltip: 'Name',
        ),
        DataColumn(
          label: Text('Ubicación'),
          tooltip: 'Location',
        ),
        DataColumn(
          label: Text('Cantidad'),
          tooltip: 'Stock',
        ),
        DataColumn(
          label: Text('Estado activo'),
          tooltip: 'Status',
        ),
      ];
}
