// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// --------------------Estadisticas basicas del conteo------------------
// ---------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:provider/provider.dart';

/// Clase para ver estadísticas
class ViewMainStatistics extends StatelessWidget {
  ///  Class Key
  const ViewMainStatistics({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            appBar: ApplicationBar.appBar(context, PageList.informes),
            endDrawer: MenuDrawer.drawer(context, PageList.informes),
            body: _IndicatorLoadDataTable(),
            bottomNavigationBar: BottomBar.bottomBar(
                PageList.informes, context, PageList.informes,
                thisPage: true)),
      );
}

// Mostrar tabla de estadísticas
class _IndicatorLoadDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final company = context.watch<CompanyModel>();
    final user = context.watch<UserModel>();
    final filter =
        verifyResource(user.currentUser.roles!, company, 'FilterReports');
    final botonStatistics = verifyResource(
        user.currentUser.roles!, company, 'GetStocktakingReports');
    final download =
        verifyResource(user.currentUser.roles!, company, 'Reports3');

    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _menuBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.7
        : mediaSize.width * 0.5;
    final _menuWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.7 - 50
        : mediaSize.width * 0.5 - 50;
    // Modelo de estadísticas
    final mainStatisticsStatusProvider = Provider.of<StatisticsModel>(context);
    // Capturar info de empresa (ubicaciones)
    final _currentCompanyPlaces =
        context.select<CompanyModel, List<String>>((company) => company.places);
    final _currentCompanyCode = context.select<CompanyModel, String>(
        (company) => company.currentCompany.companyCode!);

    /*
    final _assetsOutList = inventory.fullInventory
        .where((element) => element.outOfLocation ?? false);
    mainStatisticsStatusProvider.allAssetsOut = List<Asset>.of(_assetsOutList);
    */
    ///
    final notFind = <Asset>[];
    final out = <Asset>[];
    final inAuthorization = <Asset>[];
    for (final item in mainStatisticsStatusProvider.allMissingAssetsList) {
      if (item.status == mainStatisticsStatusProvider.currentStatus ||
          mainStatisticsStatusProvider.currentStatus == 'Todos') {
        notFind.add(item);
      }
    }
    for (final item
        in mainStatisticsStatusProvider.allOutOfLocationAssetsList) {
      if (item.status == mainStatisticsStatusProvider.currentStatus ||
          mainStatisticsStatusProvider.currentStatus == 'Todos') {
        out.add(item);
      }
    }
    for (final item in mainStatisticsStatusProvider.inAutorizationAsset) {
      if (item.status == mainStatisticsStatusProvider.currentStatus ||
          mainStatisticsStatusProvider.currentStatus == 'Todos') {
        inAuthorization.add(item);
      }
    }

    // Run viewIndicator
    Future<void> _executeViewIndicator() async {
      if (_currentCompanyPlaces.length > 1) {
        await mainStatisticsStatusProvider.viewIndicator(
            _currentCompanyCode, jsonEncode(_currentCompanyPlaces));
      }
      if (_currentCompanyPlaces.length < 2) {
        await mainStatisticsStatusProvider.viewIndicator(
            _currentCompanyCode, jsonEncode(_currentCompanyPlaces),
            locationName: _currentCompanyPlaces.first);
        mainStatisticsStatusProvider
            .asigneLocation(_currentCompanyPlaces.first);
      }
    }

    // Método para llenar lista desplegable de ubicaciones
    List<DropdownMenuItem<String>> _locationList() {
      final locationList = _currentCompanyPlaces
          .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
                value: value,
                child: SizedBox(
                  width: _menuWidth,
                  child: Text(value),
                ),
              ))
          .toList();
      // Agregar opción "Todas" al menú de ubicaciones
      if (_currentCompanyPlaces.length > 1) {
        locationList.insert(
          0,
          DropdownMenuItem<String>(
            value: 'Todas',
            child: SizedBox(
              width: _menuWidth,
              child: const Text(
                'Todas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }

      return locationList;
    }

    // Botón de recargar
    ElevatedButton _reloadDataButton(String buttonText) => ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).highlightColor,
          ),
          onPressed: () {
            mainStatisticsStatusProvider.currentLocation = 'Todas';
            _executeViewIndicator();
          },
          child: Text(buttonText),
        );

    // Tabla de datos de la ubicación seleccionada
    DataTable _dataTable() {
      final myDatatable = DataTable(
        columns: const <DataColumn>[
          // Tabla sin títulos
          DataColumn(
            label: Text(''),
          ),
          DataColumn(
            label: Text(''),
          ),
        ],
        rows: [
          DataRow(
            color: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(238, 237, 237, 30)),
            cells: <DataCell>[
              DataCell(Text(
                'Total de activos',
                style: Theme.of(context).textTheme.bodyText1,
              )),
              DataCell(
                Center(
                  child: Text(
                    mainStatisticsStatusProvider
                        .fullStatisticsLoad.assetsNumber!
                        .toString(),
                  ),
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Activos faltantes según conteo',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              DataCell(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      notFind.length.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.double,
                          decorationColor: Colors.black),
                    ),
                    IconButton(
                      onPressed: () {
                        mainStatisticsStatusProvider.changeFilterAsset(notFind);
                        Navigator.pushNamed(context, '/activos-faltantes');
                      },
                      icon: Image.asset(
                        'images/iconoBuscar.png',
                        width: 25,
                        height: 25,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          DataRow(
            color: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(238, 237, 237, 30)),
            cells: <DataCell>[
              DataCell(
                Text('Último Inventario',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              DataCell(
                Center(
                  child: Text(
                    mainStatisticsStatusProvider
                        .fullStatisticsLoad.lastInventory!,
                  ),
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Activos fuera de su ubicación',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              DataCell(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      out.length.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.double,
                          decorationColor: Colors.black),
                    ),
                    IconButton(
                      onPressed: () {
                        _showAssetsOutInfo(context, out);
                      },
                      icon: Image.asset(
                        'images/iconoBuscar.png',
                        width: 25,
                        height: 25,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Activos en prestamo',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              DataCell(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      inAuthorization.length.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.double,
                          decorationColor: Colors.black),
                    ),
                    IconButton(
                      onPressed: () {
                        _showAssetsAutoInfo(context, inAuthorization);
                      },
                      icon: Image.asset(
                        'images/iconoBuscar.png',
                        width: 25,
                        height: 25,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      );
      // Si se está mostrando la información de todas las ubicaciones,
      // se agrega una línea más
      if (mainStatisticsStatusProvider.currentLocation == 'Todas') {
        myDatatable.rows.add(
          DataRow(
            color: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(238, 237, 237, 30)),
            cells: <DataCell>[
              DataCell(
                Text('Ubicaciones (ubicaciones con activos)',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              DataCell(
                Center(
                  child: Text('${_currentCompanyPlaces.length} '
                      '(${mainStatisticsStatusProvider.fullStatisticsLoad.locationsWithAssets})'),
                ),
              ),
            ],
          ),
        );
      }
      return myDatatable;
    }

    // Retorna la información a mostrar
    Widget _infoToShow() {
      switch (mainStatisticsStatusProvider.mainStatisticsStatus) {
        case MainStatisticsStatus.idle:
          return Center(
            child: Column(
              children: const [
                Text('Cargando...\n'),
                CircularProgressIndicator(),
              ],
            ),
          );
        case MainStatisticsStatus.finished:
          return Column(
            children: [
              if (filter)
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Text(
                    'Filtrar por ubicación',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              if (filter)
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  width: _menuBoxWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none),
                      value: mainStatisticsStatusProvider.currentLocation,
                      icon: Icon(Icons.arrow_downward,
                          color: Theme.of(context).highlightColor),
                      elevation: 10,
                      autofocus: true,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      onChanged: (newValue) async {
                        mainStatisticsStatusProvider.currentLocation =
                            newValue!;
                        if (newValue != 'Todas') {
                          await mainStatisticsStatusProvider.viewIndicator(
                              _currentCompanyCode,
                              jsonEncode(_currentCompanyPlaces),
                              locationName: newValue);
                        } else {
                          await _executeViewIndicator();
                        }
                      },
                      items: _locationList(),
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Text(
                  'Filtrar por estado de activo',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                width: _menuBoxWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none),
                    value: mainStatisticsStatusProvider.currentStatus,
                    icon: Icon(Icons.arrow_downward,
                        color: Theme.of(context).highlightColor),
                    elevation: 10,
                    autofocus: true,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    onChanged: (newValue) async {
                      mainStatisticsStatusProvider
                          .changeCurrentStatus(newValue!);
                    },
                    items: ['Todos', 'Operativo', 'En préstamo', 'De baja']
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
              // Tabla de datos
              _dataTable(),
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (botonStatistics)
                    // Botón de estadísticas avanzadas
                    Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      margin: (mediaSize.width < screenSizeLimit)
                          ? const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 5)
                          : const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 50),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Capturar datos de conteos de inventario
                          await mainStatisticsStatusProvider
                              .getStocktakingReports(_currentCompanyCode);
                          await Navigator.pushNamed(
                              context, '/reportes-avanzados');
                        },
                        child: const Text('Estadísticas\navanzadas',
                            textAlign: TextAlign.center),
                      ),
                    ),
                  if (download)
                    // Botón de descargar reportes
                    Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      margin: (mediaSize.width < screenSizeLimit)
                          ? const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 5)
                          : const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).highlightColor,
                        ),
                        onPressed: () async {
                          // Capturar inventario
                          final inventory = context.read<InventoryModel>()
                            ..initInventory();
                          await inventory.loadInventory(_currentCompanyCode);
                          await Navigator.pushNamed(
                              context, '/descarga-reportes');
                        },
                        child: const Text('Descargar\nreportes',
                            textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            ],
          );
        case MainStatisticsStatus.empty:
          return Center(
            child: Column(
              children: [
                Text(
                  'Aún no tiene datos cargados',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                _reloadDataButton('Volver a intentar'),
              ],
            ),
          );
        case MainStatisticsStatus.reload:
          mainStatisticsStatusProvider.currentLocation = 'Todas';
          mainStatisticsStatusProvider.clearStatus();
          _executeViewIndicator();
          break;
        case MainStatisticsStatus.error:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error obteniendo informe',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                _reloadDataButton('Volver a intentar'),
              ],
            ),
          );
      }
      return Column(
        children: const [Text('Error...')],
      );
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informes',
                      style: Theme.of(context).textTheme.headline2),
                  Text(
                    'Informe de activos',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
            _infoToShow(),
          ],
        ),
      ),
    );
  }

  // Método para desplegar ventana de información de activos fuera de ubicación
  Future<void> _showAssetsOutInfo(BuildContext context, List<Asset> out) async {
    // Preparar lista de activos fuera de la ubicación
    final list2show = <TableRow>[
      TableRow(
        decoration: BoxDecoration(
          color: Colors.grey[400],
        ),
        children: const [
          Text('Activo', style: TextStyle(fontSize: 14)),
          Text('Detección de salida', style: TextStyle(fontSize: 14)),
        ],
      )
    ];

    //for (final element in statistics.allAssetsOut) {
    for (final element in out) {
      list2show.add(TableRow(
        children: [
          Text(element.name!, style: const TextStyle(fontSize: 14)),
          Text(element.lastTransferDate ?? 'Sin fecha',
              style: const TextStyle(fontSize: 14)),
        ],
      ));
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(children: [
            const Text('Información de activos fuera de ubicación',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Table(children: list2show),
          ]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  // Método para desplegar ventana de información de activos fuera de ubicación
  Future<void> _showAssetsAutoInfo(
      BuildContext context, List<Asset> inAuthorization) async {
    // Preparar lista de activos fuera de la ubicación
    final list2show = <TableRow>[
      TableRow(
        decoration: BoxDecoration(
          color: Colors.grey[400],
        ),
        children: const [
          Text('Activo', style: TextStyle(fontSize: 14)),
          Text('Responsable', style: TextStyle(fontSize: 14)),
        ],
      )
    ];

    //for (final element in statistics.allAssetsOut) {
    for (final element in inAuthorization) {
      list2show.add(TableRow(
        children: [
          Text(element.name!, style: const TextStyle(fontSize: 14)),
          Text(element.custody ?? '', style: const TextStyle(fontSize: 14)),
        ],
      ));
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(children: [
            const Text('Información de activos fuera de ubicación',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Table(children: list2show),
          ]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
