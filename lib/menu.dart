// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// ------------------------Menú principal-------------------------------
// ---------------------------------------------------------------------

import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:provider/provider.dart';
import 'package:subscription/ViewPlan/save_plan.dart';

/// Clase principal
class MenuPage extends StatelessWidget {
  ///  Class Key
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            appBar: ApplicationBar.appBar(
              context,
              PageList.inicio,
              leavingBlock: true,
            ),
            endDrawer: MenuDrawer.drawer(context, PageList.inicio),
            body: const MyHomePage(),
            bottomNavigationBar: BottomBar.bottomBar(
                PageList.inicio, context, PageList.inicio,
                thisPage: true)),
      );

  // Método para confirmar salida de sesión
  Future<bool> _onBackPressed(BuildContext context) async {
    final goBack = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cierre de sesión'),
        content: const Text('¿Cerrar sesión y retornar a la\n'
            'pantalla inicial?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).highlightColor,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).popUntil((route) => route.isFirst);
              NavigationFunctions.resetVariables(context);
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
    return goBack ?? false;
  }
}

/// Clase para menú principal
class MyHomePage extends StatelessWidget {
  ///  Class Key
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar empresa
    final _currentCompany = context.select<CompanyModel, String>(
        (company) => company.currentCompany.name!);
    // Capturar usuario
    final _currentUser =
        context.select<UserModel, String>((user) => user.name2show);

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Text('Hola, $_currentUser.', textAlign: TextAlign.center),
              Text('Empresa: $_currentCompany.', textAlign: TextAlign.center),
            ],
          ),
        ),
        _MainStatisticsTable(),
      ],
    );
  }
}

// Mostrar tabla de estadísticas
class _MainStatisticsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _plotSize = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.6
        : mediaSize.width * 0.17;
    final _tableWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.9
        : mediaSize.width * 0.7;

    final statistics = context.watch<StatisticsModel>();
    // Capturar info de empresa
    final _currentCompanyName = context.select<CompanyModel, String>(
        (company) => company.currentCompany.name!);
    final _currentCompanyCode = context.select<CompanyModel, String>(
        (company) => company.currentCompany.companyCode!);
    final _currentCompanyLocations =
        context.select<CompanyModel, int>((company) => company.places.length);
    final _currentPlaces =
        context.select<CompanyModel, List<String>>((company) => company.places);

    // Conteo de activos
    final _allAssetsCount =
        statistics.fullStatisticsLoad.totalAssetsNumber ?? 0;
    final _assetsNotFound = statistics.allMissingAssetsList.length;
    //final _assetsOut = statistics.allAssetsOut.length;
    final _assetsOut = statistics.allMissingAssetsList.length;
    //print("All assets count: " + _allAssetsCount.toString());

    // Cargar estadísticas
    Future<void> _loadIndicators() async {
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      if (_currentPlaces.length > 1) {
        await statistics.viewIndicator(
            _currentCompanyCode, jsonEncode(_currentPlaces));
      } else {
        await statistics.viewIndicator(
            _currentCompanyCode, jsonEncode(_currentPlaces),
            locationName: _currentPlaces.first);
      }
    }

    // Crea las graficas
    Widget _createGhraphics() => Flex(
          direction: (mediaSize.width < screenSizeLimit * 1.7)
              ? Axis.vertical
              : Axis.horizontal,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Estado de activos según último conteo\n',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'Encontrados',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 100, maxHeight: 100),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green[500],
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const SizedBox(
                                  width: 10,
                                  height: 10,
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'No encontrados',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 100, maxHeight: 100),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[200],
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const SizedBox(
                                  width: 10,
                                  height: 10,
                                )),
                          ],
                        ),
                      ]),
                  InfoPieChart(
                      _allAssetsCount, _assetsNotFound, 'conteo', _plotSize),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Estado de activos según detección por\nantenas\n',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'En su ubicación',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 100, maxHeight: 100),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green[500],
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const SizedBox(
                                  width: 10,
                                  height: 10,
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'Fuera de su ubicación',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 100, maxHeight: 100),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[200],
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const SizedBox(
                                  width: 10,
                                  height: 10,
                                )),
                          ],
                        ),
                      ]),
                  InfoPieChart(
                      _allAssetsCount, _assetsOut, 'detección', _plotSize),
                ],
              ),
            ),
          ],
        );

    // Retorna la información a mostrar
    Widget _infoToShow() {
      switch (statistics.mainStatisticsStatus) {
        case MainStatisticsStatus.idle:
          _loadIndicators();
          return Center(
            child: Column(
              children: const [
                Text('Cargando...\n'),
                CircularProgressIndicator(),
              ],
            ),
          );
        case MainStatisticsStatus.finished:
          return Flex(
            direction: (mediaSize.width < screenSizeLimit)
                ? Axis.vertical
                : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: mediaSize.width < screenSizeLimit,
                child: _createGhraphics(),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth((mediaSize.width < screenSizeLimit)
                        ? _tableWidth * 0.7
                        : _tableWidth * 0.2),
                    1: FixedColumnWidth((mediaSize.width < screenSizeLimit)
                        ? _tableWidth * 0.3
                        : _tableWidth * 0.3),
                  },
                  //defaultColumnWidth: FixedColumnWidth(),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: const Text(
                            'Total de activos',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Text(
                              statistics.fullStatisticsLoad.assetsNumber!
                                  .toString(),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: const Text(
                            'Activos faltantes',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Text(
                              statistics.fullStatisticsLoad.missingAssets!
                                  .toString(),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: const Text(
                            'Ubicaciones',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Text('$_currentCompanyLocations',
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: const Text(
                            'Último Inventario',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Text(
                              statistics.fullStatisticsLoad.lastInventory!,
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: const Text(
                            'Activos fuera de su ubicación',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Text(_assetsOut.toString(),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: mediaSize.width > screenSizeLimit,
                child: _createGhraphics(),
              ),
            ],
          );
        case MainStatisticsStatus.empty:
          return const Center(
            child: Text('Aún no tiene datos cargados'),
          );
        case MainStatisticsStatus.reload:
          return const Center(
            child: Text('Aún no tiene datos cargados'),
          );
        case MainStatisticsStatus.error:
          return const Center(
            child: Text('Error obteniendo informe'),
          );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 50),
          child: Text('Esta es la última información de $_currentCompanyName\n',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.black)),
        ),
        _infoToShow(),
      ],
    );
  }
}

/// Clase para la presentación de las gráficas
class InfoPieChart extends StatelessWidget {
  /// Constructor
  const InfoPieChart(
      this._totalAssets, this._assetsNotHere, this._plotType, this._plotSize,
      {Key? key})
      : super(key: key);

  final int _assetsNotHere;
  final int _totalAssets;
  final String _plotType;
  final double _plotSize;

  @override
  Widget build(BuildContext context) {
    final seriesList = _createDataSeries();
    final modal = AlertDialogModal(context: context);

    // Mostrar detalle de información de un gráfico
    void showDataGraphics(
        BuildContext context, String title, int chart, List<String> data) {
      modal.showDataModal(
          title: Text(title),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Text(
                      chart > 0
                          ? 'Activos fuera de su ubicación:'
                          : 'Activos no encontrados:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(data[1],
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        )),
                  ),
                  Container(
                      constraints:
                          const BoxConstraints(maxWidth: 100, maxHeight: 100),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.yellow[200],
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const SizedBox(
                        width: 15,
                        height: 15,
                      )),
                ]),
              ),
              Row(children: [
                Text(
                    chart > 0
                        ? 'Activos en su ubicación:'
                        : 'Activos encontrados:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(data[0],
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      )),
                ),
                Container(
                    constraints:
                        const BoxConstraints(maxWidth: 100, maxHeight: 100),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.green[500],
                      border: Border.all(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const SizedBox(
                      width: 15,
                      height: 15,
                    )),
              ])
            ],
          ),
          isBtnNegativeResponse: false);
    }

    return SizedBox(
      height: _plotSize,
      width: _plotSize * 1.5,
      child: Stack(
        children: [
          charts.PieChart(
            seriesList,
            animate: true,
            defaultRenderer: charts.ArcRendererConfig(arcRendererDecorators: [
              charts.ArcLabelDecorator(
                  labelPosition: charts.ArcLabelPosition.inside)
            ]),
          ),
          GestureDetector(
            onTap: () {
              if (_plotType == 'conteo') {
                showDataGraphics(
                    context, 'Estado de activos según último conteo', 0, [
                  (_totalAssets - _assetsNotHere).toString(),
                  _assetsNotHere.toString()
                ]);
              } else if (_plotType == 'detección') {
                showDataGraphics(context,
                    'Estado de activos según detección por antenas', 1, [
                  (_totalAssets - _assetsNotHere).toString(),
                  _assetsNotHere.toString()
                ]);
              }
            },
          )
        ],
      ),
    );
  }

  /// Crear serie con datos de estadísticas
  List<charts.Series<AssetPieInfo, int>> _createDataSeries() {
    var label1 = 0;
    var label2 = 0;
    if (_plotType == 'conteo') {
      label1 = 1;
      label2 = 2;
    } else if (_plotType == 'detección') {
      label1 = 3;
      label2 = 4;
    }

    final data = [
      AssetPieInfo(
        label1,
        _totalAssets - _assetsNotHere,
        _totalAssets,
        charts.MaterialPalette.green.shadeDefault,
      ),
      AssetPieInfo(
        label2,
        _assetsNotHere,
        _totalAssets,
        charts.MaterialPalette.yellow.shadeDefault.lighter,
      ),
    ];

    return [
      charts.Series<AssetPieInfo, int>(
        id: 'Activos',
        colorFn: (final segment, _) => segment.color!,
        domainFn: (final myData, _) => myData.labelNumber!,
        measureFn: (final myData, _) => myData.assetsPercentage,
        data: data,
        insideLabelStyleAccessorFn: (final segment, _) => charts.TextStyleSpec(
            color: AssetPieInfo(
          label2,
          _assetsNotHere,
          _totalAssets,
          charts.MaterialPalette.black,
        ).color),
        // Para las etiquetas de texto
        labelAccessorFn: (final row, _) {
          var _label = '';
          switch (row.labelNumber) {
            case 1:
              _label = '';
              break;
            case 2:
              _label = '';
              break;
            case 3:
              _label = '';
              break;
            case 4:
              _label = '';
              break;
            default:
              break;
          }
          return '$_label${row.assetsNumber}';
        },
      )
    ];
  }
}
