// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------------Estadísticas avanzadas-----------------
// ----------------------------------------------------

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AdvancedStatisticsPage extends StatelessWidget {
  ///  Class Key
  const AdvancedStatisticsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            appBar: ApplicationBar.appBar(context, PageList.informes),
            endDrawer: MenuDrawer.drawer(context, PageList.informes),
            body: const AdvancedStatistics(),
            bottomNavigationBar: BottomBar.bottomBar(
                PageList.informes, context, PageList.informes,
                thisPage: true)),
      );
}

/// Estadísticas avanzadas
class AdvancedStatistics extends StatelessWidget {
  ///  Class Key
  const AdvancedStatistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar estadísticas
    final statistics = context.watch<StatisticsModel>();

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Estadísticas avanzadas',
                style: Theme.of(context).textTheme.headline3),
          ),
          // Lista de opciones
          Column(
            children: <Widget>[
              ListTile(
                dense: true,
                title: const Text('Pérdidas por conteo'),
                leading: Radio(
                  value: StatisticsMode.stocktaking,
                  groupValue: statistics.statisticsMode,
                  // ignore: avoid_types_on_closure_parameters
                  onChanged: (StatisticsMode? value) {
                    statistics.updateStatisticsMode(value!);
                  },
                ),
              ),
              ListTile(
                dense: true,
                title: const Text('Pérdidas por ubicación'),
                leading: Radio(
                  value: StatisticsMode.location,
                  groupValue: statistics.statisticsMode,
                  // ignore: avoid_types_on_closure_parameters
                  onChanged: (StatisticsMode? value) {
                    statistics.updateStatisticsMode(value!);
                  },
                ),
              ),
            ],
          ),
          // Información a mostrar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _infoToShow(context),
          ),
          // Botones
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón de cancelar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      ),
    );
  }

  // Información a mostrar en recuadro
  Widget _infoToShow(BuildContext context) {
    // Capturar estadísticas
    final statistics = context.watch<StatisticsModel>();
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    final _currentLocation = company.currentLocation;

    // Mostrar estadísticas según la opción seleccionada
    switch (statistics.statisticsMode) {
      case StatisticsMode.stocktaking:
        // Recopilar los datos de los últimos conteos
        const _numConteos = 5;
        List<Stocktaking> _lastReports;
        if (statistics.stocktakingList.length < _numConteos) {
          _lastReports = List.from(statistics.stocktakingList.reversed);
        } else {
          _lastReports = <Stocktaking>[];
          for (var i = statistics.stocktakingList.length - 1;
              i > statistics.stocktakingList.length - _numConteos;
              i--) {
            _lastReports.add(statistics.stocktakingList[i]);
          }
        }
        if (_lastReports.isEmpty) {
          return const Text('No se encontraron reportes de conteo de '
              'inventario.');
        } else {
          // Títulos
          final _titles = TableRow(
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text(
                  'Fecha de reporte',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text(
                  'Usuario que realizó reporte',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text(
                  'Ubicación',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text(
                  'Elementos no encontrados',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
          // Datos de cada conteo
          final _data = _lastReports.map<TableRow>((item) {
            // Contar ítems no encontrados en cada reporte
            var _notFoundNum = 0;
            for (var j = 0; j < item.assets!.length; j++) {
              if (item.assets![j].findStatus == 'No Encontrado') {
                _notFoundNum++;
              }
            }
            return TableRow(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    item.timeStamp!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    item.userName!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    item.locationName!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    _notFoundNum.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtítulo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('Pérdidas por conteo',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              // Subtítulo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('Información de los últimos conteos, empezando '
                    'por el más reciente.'),
              ),
              Table(
                //defaultColumnWidth: const IntrinsicColumnWidth(),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [_titles, ..._data],
              ),
            ],
          );
        }

      case StatisticsMode.location:
        // Recopilar los datos de los últimos conteos
        final _locationReports = <Stocktaking>[];
        if (_currentLocation != null && _currentLocation != '') {
          for (final item in statistics.stocktakingList.reversed) {
            if (item.locationName == _currentLocation) {
              _locationReports.add(item);
            }
          }
        }
        if (statistics.stocktakingList.isEmpty) {
          return const Text('No se encontraron reportes de conteo de '
              'inventario.');
        } else {
          // Títulos
          final _titles = TableRow(
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text(
                  'Fecha de reporte',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text(
                  'Elementos no encontrados',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
          // Datos de cada conteo
          final _data = _locationReports.map<TableRow>((item) {
            // Contar ítems no encontrados en cada reporte
            var _notFoundNum = 0;
            for (var j = 0; j < item.assets!.length; j++) {
              if (item.assets![j].findStatus == 'NoEncontrado') {
                _notFoundNum++;
              }
            }
            return TableRow(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    item.timeStamp!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    _notFoundNum.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }).toList();

          // Histograma de pérdidas por ubicación
          Widget _histogram() {
            final data = <LossesHistogram>[];
            statistics.lossesPerLocation(company.places).forEach((key, value) {
              final myColor = data.length.isEven ? Colors.red : Colors.green;
              data.add(LossesHistogram(key, value, myColor));
            });
            final series = [
              charts.Series<LossesHistogram, String>(
                id: 'Losses',
                domainFn: (final losses, _) => losses.location,
                measureFn: (final losses, _) => losses.losses,
                colorFn: (final losses, _) => losses.color,
                data: data,
              ),
            ];
            final chart = charts.BarChart(
              series,
              animate: true,
              domainAxis: const charts.OrdinalAxisSpec(
                renderSpec: charts.SmallTickRendererSpec(labelRotation: 25),
              ),
            );
            final chartWidget = Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: chart,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                        'Activos no encontrados por ubicación (según último '
                        'conteo registrado).'),
                  ),
                ],
              ),
            );
            return chartWidget;
          }

          // Datos promedio del año
          Widget _yearInfo() {
            final _localTime =
                DateTime.now().toUtc().add(const Duration(hours: -5));
            final _currentYear = _localTime.year.toString();
            final averageLossesXYear =
                statistics.averageLossesPerYear(_currentYear, company.places);
            var _companyAverageLosses = 0.0;
            for (final element in averageLossesXYear.values) {
              _companyAverageLosses += element;
            }
            // Títulos año
            final _yearTitles = TableRow(
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: const Text(
                    'Ubicación',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: const Text(
                    'Promedio de elementos\nno encontrados',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: const Text(
                    'Porcentaje promedio de\nelementos no encontrados',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
            // Lista de datos promedio de cada ubicación
            final _locationsData =
                averageLossesXYear.keys.map<TableRow>((item) {
              final _currentAVG = averageLossesXYear[item];
              final _currentAVGPercentage = (_companyAverageLosses == 0)
                  ? 0
                  : ((_currentAVG! / _companyAverageLosses) * 100).round();
              return TableRow(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text(
                      item,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text(
                      _currentAVG.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text(
                      '${_currentAVGPercentage.toString()} %',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }).toList();
            // Última fila
            final _lastRow = TableRow(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    _companyAverageLosses.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: const Text(
                    '100 %',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );

            return Column(
              children: [
                Container(
                  width: 400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [_yearTitles, ..._locationsData, _lastRow],
                  ),
                ),
                Text('Promedio de activos no encontrados por ubicación en el '
                    'año $_currentYear.'),
              ],
            );
          }

          // Datos a mostrar
          Widget _dataFromLocation() {
            if (_locationReports.isEmpty) {
              if (_currentLocation == null) {
                return Column(
                  children: [_histogram(), _yearInfo()],
                );
              } else {
                return Column(
                  children: [
                    const Text('No se encontraron reportes de conteo de '
                        'inventario para esta ubicación.'),
                    _histogram(),
                    _yearInfo()
                  ],
                );
              }
            } else {
              return Column(
                children: [
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [_titles, ..._data],
                  ),
                  _histogram(),
                  _yearInfo()
                ],
              );
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtítulo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('Pérdidas por ubicación',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              // Subtítulo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('Seleccione la ubicación:'),
              ),
              Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: DropdownButton<String>(
                  value: _currentLocation,
                  icon: Icon(Icons.arrow_downward,
                      color: Theme.of(context).highlightColor),
                  elevation: 16,
                  style: const TextStyle(fontSize: 14, color: Colors.brown),
                  onChanged: company.changeLocation,
                  items: company.places
                      .map<DropdownMenuItem<String>>(
                          (value) => DropdownMenuItem<String>(
                                value: value,
                                child: SizedBox(width: 100, child: Text(value)),
                              ))
                      .toList(),
                ),
              ),
              _dataFromLocation(),
            ],
          );
        }
    }
  }
}
