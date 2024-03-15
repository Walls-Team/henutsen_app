// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// -------------------Opciones de navegación----------------------------
// ---------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';

import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/provider/assetHistory_model.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/campus_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/encoder_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/location_model.dart';
import 'package:henutsen_cli/provider/printer_model.dart';
import 'package:henutsen_cli/provider/role_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/load_data.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/process_file.dart';
import 'package:henutsen_cli/uploading/ViewBulkUploads/bulk_load.dart';
import 'package:henutsen_cli/utils/verifyResources.dart';
import 'package:provider/provider.dart';
import 'package:subscription/config.dart' as subscription;

/// Enumeración de páginas en los menús de navegación
enum PageList {
  /// Inicio
  inicio,

  /// Informes
  informes,

  /// Cargas masivas
  cargasMasivas,

  /// Conteo
  conteo,

  /// Impresión
  impresion,

  /// Codificación
  codificacion,

  /// Gestión de activos
  gestion,

  /// Configuración
  configuracion
}

// ignore: avoid_classes_with_only_static_members
/// Clase para menú lateral
class MenuDrawer {
  /// Menú
  static Widget drawer(BuildContext context, PageList leavingFrom) {
    final company = context.watch<CompanyModel>();
    final user = context.watch<UserModel>();
    final device = context.watch<BluetoothModel>();
    final inventory = context.watch<InventoryModel>();
    //para conteo
    final conteo = verifyResource(
        user.currentUser.roles!, company, 'SaveStocktakingReport');
    //para impresora
    final print = verifyResource(user.currentUser.roles!, company, 'ViewPrint');

    //para cargas masivas
    final load = verifyResource(user.currentUser.roles!, company, 'FileLoad');
    final view =
        verifyResource(user.currentUser.roles!, company, 'ObtainLoads');
    final delete =
        verifyResource(user.currentUser.roles!, company, 'DeleteFile');

    //para reportes
    final filter =
        verifyResource(user.currentUser.roles!, company, 'FilterReports');
    final botonStatistics = verifyResource(
        user.currentUser.roles!, company, 'GetStocktakingReports');
    final download =
        verifyResource(user.currentUser.roles!, company, 'Reports3');
    final viewReport =
        verifyResource(user.currentUser.roles!, company, 'Reports0');
    //para activos
    final assets = verifyResourceAsset(user, company, context);
    //para configuracion
    final config = verifyResourceConfg(user, company, context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 100,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'MENÚ',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ),
          if (filter || botonStatistics || download || viewReport)
            // Informes
            ListTile(
              title: Text(
                'Informes',
                style: Theme.of(context).textTheme.headline4,
              ),
              onTap: () async {
                if (inventory.flagLoop) {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(children: const [
                          Text(
                              'Por favor detenga la lectura del'
                              ' lector para poder salir de la pantalla.',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)),
                        ]),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            primary: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                if (company.places.length > 1) {
                  await Provider.of<StatisticsModel>(context, listen: false)
                      .viewIndicator(company.currentCompany.companyCode!,
                          jsonEncode(company.places));
                } else {
                  await Provider.of<StatisticsModel>(context, listen: false)
                      .viewIndicator(company.currentCompany.companyCode!,
                          jsonEncode(company.places),
                          locationName: company.places.first);
                  Provider.of<StatisticsModel>(context, listen: false)
                      .asigneLocation(company.places.first);
                }

                await NavigationFunctions.checkLeavingPage(
                    context, leavingFrom);
                NavigationFunctions.goToReports(context);
              },
            ),
          if (filter || botonStatistics || download || viewReport)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
                  Divider(thickness: 1, color: Theme.of(context).primaryColor),
            ),
          if (load || view || delete)
            // Cargas Masivas
            ListTile(
              title: Text(
                'Carga Masiva',
                style: Theme.of(context).textTheme.headline4,
              ),
              onTap: () async {
                if (inventory.flagLoop) {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(children: const [
                          Text(
                              'Por favor detenga la lectura del'
                              ' lector para poder salir de la pantalla.',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)),
                        ]),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            primary: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                NavigationFunctions.checkLeavingPage(context, leavingFrom);
                NavigationFunctions.goToUploading(context);
              },
            ),
          if (load || view || delete)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
                  Divider(thickness: 1, color: Theme.of(context).primaryColor),
            ),
          if (conteo)
            // Conteo
            ListTile(
              title: Text(
                'Conteo',
                style: Theme.of(context).textTheme.headline4,
              ),
              onTap: () async {
                if (inventory.flagLoop) {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(children: const [
                          Text(
                              'Por favor detenga la lectura del'
                              ' lector para poder salir de la pantalla.',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)),
                        ]),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            primary: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                company.sortListLocations();
                NavigationFunctions.checkLeavingPage(context, leavingFrom);
                NavigationFunctions.goToStocktaking(context);
              },
            ),
          if (conteo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
                  Divider(thickness: 1, color: Theme.of(context).primaryColor),
            ),
          if (print)
            // Impresión
            ListTile(
              title: Text(
                'Impresión',
                style: Theme.of(context).textTheme.headline4,
              ),
              onTap: () async {
                final inventory = context.read<InventoryModel>();
                if (inventory.flagLoop) {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(children: const [
                          Text(
                              'Por favor detenga la lectura del'
                              ' lector para poder salir de la pantalla.',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)),
                        ]),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            primary: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                NavigationFunctions.checkLeavingPage(context, leavingFrom);
                // Capturar empresa
                final company = context.read<CompanyModel>();
                // Capturar usuario
                final user = context.read<UserModel>();
                // Capturar inventario

                inventory.initInventory();
                await inventory
                    .loadInventory(company.currentCompany.companyCode!);
                inventory.getCategories();
                Navigator.popUntil(context, ModalRoute.withName('/menu'));
                // Revisar si se quiere ver la ayuda
                if (!user.printingHelp) {
                  unawaited(Navigator.pushNamed(context, '/imprimir'));
                } else {
                  unawaited(Navigator.pushNamed(context, '/imprimir'));
                  unawaited(Navigator.pushNamed(context, '/imprimir-info'));
                }
              },
            ),
          if (print)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
                  Divider(thickness: 1, color: Theme.of(context).primaryColor),
            ),
          // Codificación
          ListTile(
            title: Text(
              'Codificación',
              style: Theme.of(context).textTheme.headline4,
            ),
            onTap: () async {
              final inventory = context.read<InventoryModel>();
              if (inventory.flagLoop) {
                await showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(children: const [
                        Text(
                            'Por favor detenga la lectura del'
                            ' lector para poder salir de la pantalla.',
                            style:
                                TextStyle(fontSize: 15, color: Colors.black)),
                      ]),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          primary: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                );
                return;
              }

              NavigationFunctions.checkLeavingPage(context, leavingFrom);
              // Capturar empresa
              final company = context.read<CompanyModel>();
              // Capturar usuario
              final user = context.read<UserModel>();
              // Capturar inventario
              inventory.initInventory();
              await inventory
                  .loadInventory(company.currentCompany.companyCode!);
              inventory.getCategories();
              Navigator.popUntil(context, ModalRoute.withName('/menu'));
              // Revisar si se quiere ver la ayuda
              if (!user.encodingHelp) {
                unawaited(Navigator.pushNamed(context, '/codificar'));
              } else {
                unawaited(Navigator.pushNamed(context, '/codificar'));
                unawaited(Navigator.pushNamed(context, '/codificar-info'));
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Divider(thickness: 1, color: Theme.of(context).primaryColor),
          ),
          if (assets)
            // Gestión de activos
            ListTile(
              title: Text(
                'Gestión de Activos',
                style: Theme.of(context).textTheme.headline4,
              ),
              onTap: () async {
                final inventory = context.read<InventoryModel>();
                if (inventory.flagLoop) {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(children: const [
                          Text(
                              'Por favor detenga la lectura del'
                              ' lector para poder salir de la pantalla.',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)),
                        ]),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            primary: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                await NavigationFunctions.checkLeavingPage(
                    context, leavingFrom);
                // Capturar empresa
                final company = context.read<CompanyModel>();
                // Capturar usuario
                final user = context.read<UserModel>();
                // Capturar inventario

                inventory.initInventory();
                await inventory
                    .loadInventory(company.currentCompany.companyCode!);
                inventory.getCategories();
                Navigator.popUntil(context, ModalRoute.withName('/menu'));
                // Revisar si se quiere ver la ayuda
                if (!user.managementHelp) {
                  unawaited(Navigator.pushNamed(context, '/gestion-activos'));
                } else {
                  unawaited(Navigator.pushNamed(context, '/gestion-activos'));
                  unawaited(Navigator.pushNamed(context, '/gestion-info'));
                }
              },
            ),
          if (assets)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
                  Divider(thickness: 1, color: Theme.of(context).primaryColor),
            ),
          if (config)
            // Configuración
            ListTile(
              title: Text(
                'Configuración',
                style: Theme.of(context).textTheme.headline4,
              ),
              onTap: () async {
                if (inventory.flagLoop) {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(children: const [
                          Text(
                              'Por favor detenga la lectura del'
                              ' lector para poder salir de la pantalla.',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)),
                        ]),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            primary: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                await NavigationFunctions.checkLeavingPage(
                    context, leavingFrom);
                NavigationFunctions.checkLeavingPage(context, leavingFrom);
                // Capturar información de usuario
                final user = context.read<UserModel>();
                Navigator.popUntil(context, ModalRoute.withName('/menu'));
                // Revisar si se quiere ver la ayuda
                if (!user.configurationHelp) {
                  Navigator.pushNamed(context, '/config');
                } else {
                  Navigator.pushNamed(context, '/config');
                  Navigator.pushNamed(context, '/config-info');
                }
              },
            ),
          if (config)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
                  Divider(thickness: 1, color: Theme.of(context).primaryColor),
            ),
          // Suscripción
          ListTile(
            title: Text(
              'Suscripción',
              style: Theme.of(context).textTheme.headline4,
            ),
            onTap: () async {
              ///Se establece configuración del proyecto subscription
              subscription.ConfigureService(Config.serviceURLSubscription,
                      Config.arrDescription, Config.arrCurrency)
                  .init();
              await Navigator.pushNamed(context, '/managementPlan'); //?
            },
          ),
        ],
      ),
    );
  }
}

// ignore: avoid_classes_with_only_static_members
/// Clase para menú inferior
class BottomBar {
  // myIndex: índice de la página a mostrar como "activa"
  // thisPage: indica si efectivamente queremos mostrar la página de "myIndex"
  // como seleccionada
  // leavingFrom: Página de la que estamos saliendo
  /// Menú inferior
  static Widget bottomBar(
      PageList myIndex, BuildContext context, PageList leavingFrom,
      {bool thisPage = false}) {
    final company = context.watch<CompanyModel>();
    var count = 0;
    var count1 = 0;
    var count2 = 0;
    final user = context.watch<UserModel>();
    final conteo = verifyResource(
        user.currentUser.roles!, company, 'SaveStocktakingReport');

    //para cargas masivas
    final load = verifyResource(user.currentUser.roles!, company, 'FileLoad');
    final view =
        verifyResource(user.currentUser.roles!, company, 'ObtainLoads');
    final delete =
        verifyResource(user.currentUser.roles!, company, 'DeleteFile');

    //para reportes
    final filter =
        verifyResource(user.currentUser.roles!, company, 'FilterReports');
    final botonStatistics = verifyResource(
        user.currentUser.roles!, company, 'GetStocktakingReports');
    final download =
        verifyResource(user.currentUser.roles!, company, 'Reports3');
    final viewReport =
        verifyResource(user.currentUser.roles!, company, 'Reports0');

    /* var aux = '';
    for (final item in company.currentCompany.roles!) {
      if (user.currentUser.roles!.first == item.roleId) {
        if (item.resources!.contains('Management-14')) {
          aux = item.name!;
        }
      }
    }*/

    if (!conteo) {
      count++;
    }
    if (!load && !view && !delete) {
      count1++;
    }
    if (!filter && !botonStatistics && !download && !viewReport) {
      count2++;
    }
    return BottomNavigationBar(
      onTap: (final index) async {
        if (index == 1) {
          if (company.places.length > 1) {
            await Provider.of<StatisticsModel>(context, listen: false)
                .viewIndicator(company.currentCompany.companyCode!,
                    jsonEncode(company.places));
          } else {
            await Provider.of<StatisticsModel>(context, listen: false)
                .viewIndicator(company.currentCompany.companyCode!,
                    jsonEncode(company.places),
                    locationName: company.places.first);
            Provider.of<StatisticsModel>(context, listen: false)
                .asigneLocation(company.places.first);
          }
        }
        // Este método solo devuelve enteros, en función del índice del botón
        // que se ha presionado
        _onTabTapped(index, context, leavingFrom);
      },
      currentIndex: myIndex.index,
      type: BottomNavigationBarType.fixed,
      unselectedFontSize: 14,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: (myIndex == PageList.inicio && thisPage)
              ? Image.asset(
                  'images/iconoGestionSel.png',
                  width: 50,
                  height: 50,
                )
              : Image.asset(
                  'images/iconoGestionNoSel.png',
                  width: 50,
                  height: 50,
                ),
          label: 'Inicio',
        ),
        if (filter || botonStatistics || download || viewReport)
          BottomNavigationBarItem(
            icon: (myIndex == PageList.informes && thisPage)
                ? Image.asset(
                    'images/iconoInformesSel.png',
                    width: 50,
                    height: 50,
                  )
                : Image.asset(
                    'images/iconoInformesNoSel.png',
                    width: 50,
                    height: 50,
                  ),
            label: 'Informes',
          ),
        if (load || view || delete)
          BottomNavigationBarItem(
            icon: (myIndex == PageList.cargasMasivas && thisPage)
                ? Image.asset(
                    'images/iconoCargaMasivaSel.png',
                    width: 50,
                    height: 50,
                  )
                : Image.asset(
                    'images/iconoCargaMasivaNoSel.png',
                    width: 50,
                    height: 50,
                  ),
            label: 'Carga Masiva',
          ),
        if (conteo)
          BottomNavigationBarItem(
            icon: (myIndex == PageList.conteo && thisPage)
                ? Image.asset(
                    'images/iconoConteoSel.png',
                    width: 50,
                    height: 50,
                  )
                : Image.asset(
                    'images/iconoConteoNoSel.png',
                    width: 50,
                    height: 50,
                  ),
            label: 'Conteo',
          ),
        if (count > 0)
          BottomNavigationBarItem(
            icon: Container(),
            label: '',
          ),
        if (count1 > 0)
          BottomNavigationBarItem(
            icon: Container(),
            label: '',
          ),
        if (count2 > 0)
          BottomNavigationBarItem(
            icon: Container(),
            label: '',
          ),
      ],
    );
  }

  // Método para ejecutar según botón seleccionado (barra horizontal)
  static void _onTabTapped(
      int index, BuildContext context, PageList leavingFrom) {
    final company = Provider.of<CompanyModel>(context, listen: false);

    final user = Provider.of<UserModel>(context, listen: false);
    final conteo = verifyResource(
        user.currentUser.roles!, company, 'SaveStocktakingReport');

    //para cargas masivas
    final load = verifyResource(user.currentUser.roles!, company, 'FileLoad');
    final view =
        verifyResource(user.currentUser.roles!, company, 'ObtainLoads');
    final delete =
        verifyResource(user.currentUser.roles!, company, 'DeleteFile');

    //para reportes
    final filter =
        verifyResource(user.currentUser.roles!, company, 'FilterReports');
    final botonStatistics = verifyResource(
        user.currentUser.roles!, company, 'GetStocktakingReports');
    final download =
        verifyResource(user.currentUser.roles!, company, 'Reports3');
    final viewReport =
        verifyResource(user.currentUser.roles!, company, 'Reports0');
    NavigationFunctions.checkLeavingPage(context, leavingFrom);
    switch (index) {
      // Inicio
      case 0:
        {
          Navigator.popUntil(context, ModalRoute.withName('/menu'));
        }
        break;
      // Informes
      case 1:
        {
          if (filter || botonStatistics || download || viewReport) {
            NavigationFunctions.goToReports(context);
          }
        }

        break;
      // Cargas masivas
      case 2:
        {
          if (load || view || delete) {
            NavigationFunctions.goToUploading(context);
          }
        }

        break;
      // Conteo
      case 3:
        {
          if (conteo) {
            NavigationFunctions.goToStocktaking(context);
          }
        }

        break;
      default:
        break;
    }
  }
}

// ignore: avoid_classes_with_only_static_members
/// Clase para datos de usuario
class RightUserInfo {
  /// Datos de usuario
  static Widget drawer(BuildContext context) {
    // Capturar usuario
    final user = context.read<UserModel>();
    // Capturar empresa
    final company = context.read<CompanyModel>();

    String _imgLink;

    // Si no hay avatar se asigna imagen por defecto
    if (user.currentUser.photos == null) {
      _imgLink = Config.defaultAvatar;
    } else if (user.currentUser.photos!.isEmpty) {
      _imgLink = Config.defaultAvatar;
    } else {
      _imgLink = user.currentUser.photos!.first.value!;
    }

    return Stack(children: <Widget>[
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Image.network(
                      _imgLink,
                      errorBuilder: (context, exception, stackTrace) =>
                          Image.asset(
                        Config.defaultAvatar,
                        width: 100,
                        height: 90,
                      ),
                      width: 100,
                      height: 90,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        '${user.name2show}\n',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        user.userName!,
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        user.currentUserRole.join(', '),
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        company.currentCompany.name!,
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        company.currentCompany.companyCode!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(thickness: 1, color: Colors.blue),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar cierre de sesión'),
                      content: const Text(
                          '¿Cerrar sesión y retornar a la\npantalla inicial?'),
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
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            NavigationFunctions.resetVariables(context);
                          },
                          child: const Text('Sí'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

// ignore: avoid_classes_with_only_static_members
/// Clase para información de ayuda
class HelpCard {
  /// Opción de ayuda
  static Widget drawer(BuildContext context, PageList currentPage) {
    // Si estamos en la página inicial, mostrar una ayuda "genérica"
    if (currentPage == PageList.inicio) {
      return Builder(
        builder: (context) => GestureDetector(
          child: const Icon(Icons.help),
          onTap: () async {
            await showDialog<void>(
              context: context,
              builder: (context) => Align(
                alignment: const Alignment(0.5, -0.75),
                child: SizedBox(
                  height: 200,
                  child: Stack(children: <Widget>[
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          children: <Widget>[
                            const Text(
                              'Acceda a esta opción de ayuda desde '
                              'cada\nuno de los módulos para conocer su '
                              'funcionamiento.',
                              style: TextStyle(color: Colors.black),
                            ),
                            const Divider(thickness: 1, color: Colors.blue),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          // Retornamos la ayuda solo en páginas que no sean de ayuda
          if (ModalRoute.of(context)!.settings.name != null) {
            if (!ModalRoute.of(context)!.settings.name!.contains('-info')) {
              switch (currentPage) {
                case PageList.informes:
                  Navigator.pushNamed(context, '/reportes-info');
                  break;
                case PageList.cargasMasivas:
                  Navigator.pushNamed(context, '/subida-info');
                  break;
                case PageList.conteo:
                  Navigator.pushNamed(context, '/conteo-info');
                  break;
                case PageList.impresion:
                  Navigator.pushNamed(context, '/imprimir-info');
                  break;
                case PageList.codificacion:
                  Navigator.pushNamed(context, '/codificar-info');
                  break;
                case PageList.gestion:
                  Navigator.pushNamed(context, '/gestion-info');
                  break;
                case PageList.configuracion:
                  Navigator.pushNamed(context, '/config-info');
                  break;
                case PageList.inicio:
                  break;
              }
            }
          }
        },
        child: const Icon(Icons.help),
      );
    }
  }
}

// ignore: avoid_classes_with_only_static_members
/// Clase para mostrar AppBar
class ApplicationBar {
  /// AppBar
  // Recibe de parámetros el contexto actual, la página actual y una bandera
  // que indica si al ir hacia atrás se estaría abandonando el módulo completo
  static PreferredSize appBar(BuildContext context, PageList currentPage,
      {bool leavingBlock = false}) {
    final _company = context.watch<CompanyModel>();
    final _companyImage = _company.currentCompany.logo ?? '';
    final _companyName = _company.currentCompany.name ?? '';
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: AppBar(
        title: _companyImage.isEmpty
            ? Text(
                _companyName,
                style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.white),
              )
            : Image.network(
                _companyImage,
                errorBuilder: (context, exception, stackTrace) =>
                    Text(_companyName),
                height: 40,
              ),
        leading: GestureDetector(
          onTap: () async {
            final device = context.read<InventoryModel>();
            if (device.flagLoop) {
              await showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  content: SingleChildScrollView(
                    child: Column(children: const [
                      Text(
                          'Por favor detenga la lectura del'
                          ' lector para poder salir de la pantalla.',
                          style: TextStyle(fontSize: 15, color: Colors.black)),
                    ]),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        primary: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              );
              return;
            }
            if (currentPage == PageList.inicio) {
              await showDialog(
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
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        NavigationFunctions.resetVariables(context);
                      },
                      child: const Text('Sí'),
                    ),
                  ],
                ),
              );
            } else {
              var goBack = true;
              // Revisar si estamos saliendo del módulo completo
              if (leavingBlock) {
                // Se ejecutan la operaciones de "limpieza"
                unawaited(
                    NavigationFunctions.checkLeavingPage(context, currentPage));
                // Esta parte solo se hace si estamos saliendo de:
                // "Mapeo"
                // "Autorizaciones"
                if (ModalRoute.of(context)!.settings.name == '/mapeo-campos' ||
                    ModalRoute.of(context)!.settings.name ==
                        '/datos-autorizar') {
                  goBack = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('¡Atención!'),
                          content: const Text('¿Desea salir sin guardar '
                              'cambios?'),
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
                              },
                              child: const Text('Sí'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                }
              }
              if (goBack) {
                Navigator.of(context).pop();
              }
            }
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'images/logo_white.png',
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (context) => Align(
                      alignment: const Alignment(0.5, -0.75),
                      child: SizedBox(
                        height: 200,
                        child: RightUserInfo.drawer(context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: HelpCard.drawer(context, currentPage),
          ),
          // Para incluir un menú a la derecha
          Builder(
            builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip:
                    MaterialLocalizations.of(context).openAppDrawerTooltip),
          ),
        ],
      ),
    );
  }
}

//-----------------------
// Funciones adicionales
//-----------------------

// ignore: avoid_classes_with_only_static_members
/// Funciones de navegación
class NavigationFunctions {
  /// Método para ir a "Informes"
  static void goToReports(BuildContext context) {
    // Capturar información de estadísticas
    context.read<StatisticsModel>().clearStatus();
    // Capturar información de usuario
    final user = context.read<UserModel>();
    Navigator.popUntil(context, ModalRoute.withName('/menu'));
    // Revisar si se quiere ver la ayuda
    if (!user.statisticsHelp) {
      Navigator.pushNamed(context, '/reportes');
    } else {
      Navigator.pushNamed(context, '/reportes');
      Navigator.pushNamed(context, '/reportes-info');
    }
  }

  /// Método para ir a "Cargas Masivas"
  static void goToUploading(BuildContext context) {
    // Capturar usuario
    final user = context.read<UserModel>();
    Navigator.popUntil(context, ModalRoute.withName('/menu'));
    // Revisar si se quiere ver la ayuda
    if (!user.uploadingHelp) {
      Navigator.pushNamed(context, '/subida');
    } else {
      Navigator.pushNamed(context, '/subida');
      Navigator.pushNamed(context, '/subida-info');
    }
  }

  /// Método para ir a "Conteo"
  static void goToStocktaking(BuildContext context) {
    final i = context.read<InventoryModel>();
    // Capturar empresa
    final company = context.read<CompanyModel>();
    // Capturar usuario
    final user = context.read<UserModel>();
    if (i.out) {
      i.out = false;
    }
    // Capturar inventario
    context.read<InventoryModel>()
      ..initInventory()
      ..loadInventory(company.currentCompany.companyCode!);
    Navigator.popUntil(context, ModalRoute.withName('/menu'));
    // Revisar si se quiere ver la ayuda
    if (!user.stocktakingHelp) {
      Navigator.pushNamed(context, '/conteo-sede');
    } else {
      Navigator.pushNamed(context, '/conteo-sede');
      Navigator.pushNamed(context, '/conteo-info');
    }
  }

  /// Método para verificar acciones al abandonar cada página
  static Future<void> checkLeavingPage(
      BuildContext context, PageList leavingFrom) async {
    switch (leavingFrom) {
      // 0: inicio
      case PageList.inicio:
        break;
      // 1: informes
      case PageList.informes:
        context.read<StatisticsModel>().currentLocation = 'Todas';
        break;
      // 2: cargas masivas
      case PageList.cargasMasivas:
        break;
      // 3: conteo
      case PageList.conteo:
        // Capturar información de empresa
        final company = context.read<CompanyModel>();
        // Capturar información de inventario
        final inventory = context.read<InventoryModel>();
        // Capturar información de Bluetooth
        final device = context.read<BluetoothModel>();
        inventory.lastStockTakingLocation = company.currentLocation;
        inventory.stocktakingRecentlyDone = false;
        company.currentLocation = null;
        device.callbackSet = false;
        break;
      // 4: impresión
      case PageList.impresion:
        // Capturar información de impresora
        final printer = context.read<PrinterModel>();
        if (printer.tagWidth == null ||
            printer.tagHeight == null ||
            printer.tagGap == null) {
          printer.changePrinter(null);
        }
        // Esta parte solo se hace si estamos saliendo de "Imprimir"
        if (ModalRoute.of(context)!.settings.name == '/imprimir') {
          // Capturar información de empresa
          context.read<CompanyModel>().currentLocation = null;
        }
        break;
      // 5: codificación
      case PageList.codificacion:
        // Capturar información de empresa
        context.read<CompanyModel>().currentLocation = null;
        // Capturar información de Bluetooth
        final device = context.read<BluetoothModel>();
        // Capturar información de codificador
        final encoder = context.read<EncoderModel>()
          ..changeDetection(false)
          ..changeWriting(false)
          ..isProtected = false
          ..foundTag = '';
        // Esta parte solo se hace si no estamos saliendo de "Codificar2"
        if (ModalRoute.of(context)!.settings.name != '/codificar2') {
          // Desconectar encoder si es necesario (solo para Oppiot)
          if (encoder.currentEncoder != null && !device.gotDevice) {
            final request = await encoder.disconnectFromServer();
            if (request == 'Ok') {
              encoder.asignEncoder(null);
            }
          }
        }
        break;
      // 6: gestión
      case PageList.gestion:
        // Capturar información de activo temporal
        // y resetearlo al volver atrás
        context.read<InventoryModel>()
          ..currentAsset = Asset()
          ..currentSearchField = ''
          ..currentCategory = null;
        // Capturar información de empresa temporal
        // y resetear al volver atrás
        context.read<CompanyModel>().currentLocation = null;
        // Capturar información de imágenes y resetear al volver atrás
        context.read<ImageModel>().imageArray.clear();
        break;
      // 7: configuración
      case PageList.configuracion:
        // Capturar información de usuario temporal
        // y resetearlo al volver atrás
        context.read<UserModel>()
          ..tempUser = User(
            name: Name(),
            photos: <Photo>[],
            emails: <Email>[],
            roles: [],
            helpScreens: <HelpScreen>[],
          )
          ..docType = null
          ..docNum = ''
          ..tempRole = null
          ..tempCompany = null
          ..visiblePassword = false
          ..currentSearchField = '';
        // Capturar información de empresa temporal
        // y resetear al volver atrás
        context.read<CompanyModel>()
          ..tempCompany = Company(addresses: [CompanyAddress()])
          ..currentLocation = null
          ..currentSearchField = '';
        // Capturar información de ubicación temporal
        // y resetear al volver atrás
        context.read<LocationModel>()
          ..currentSearchCompany = Company(addresses: [CompanyAddress()])
          ..tempLocation = Location()
          ..currentSearchName = '';
        // Capturar información de imágenes y resetear al volver atrás
        context.read<ImageModel>().imageArray.clear();
        break;
    }
  }

  /// Método para reiniciar las variables claves al cerrar sesión
  static Future<void> resetVariables(BuildContext context) async {
    // Capturar usuario
    final user = context.read<UserModel>();
    // Capturar empresa
    final company = context.read<CompanyModel>();
    // Capturar inventario
    final inventory = context.read<InventoryModel>();
    // Capturar dispositivo BT
    final device = context.read<BluetoothModel>();
    // Capturar información de impresora
    final printer = context.read<PrinterModel>();
    // Capturar información de codificador
    final encoder = context.read<EncoderModel>();
    // Capturar información de reportes
    final statistics = context.read<StatisticsModel>();
    // Capturar información de ubicaciones
    final location = context.read<LocationModel>();
    // Capturar información de roles
    final role = context.read<RoleModel>();
    // Capturar información de imágenes
    final images = context.read<ImageModel>();
    // Capturar información de visualizador de cargas masivas
    final bulkLoadProvider = context.read<BulkLoad>();
    // Capturar información de información de archivo de cargas masivas
    final fileInformation = context.read<LoadDataProvider>();
    // Capturar información de información de archivo de cargas masivas
    final fileInformationData = context.read<DataFile>();
    // Capturar información de información de archivo de cargas masivas
    final transfer = context.read<TransferModel>();
    // Capturar información de Sedes
    final campus = context.read<CampusModel>();
    // Capturar información de Sedes
    final history = context.read<AssetHistoryModel>();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Desconectar lector bluetooth si aplica
    if (device.gotDevice) {
      await r6_plugin.disconnect();
      await device.connectedDevice!.disconnect();
      device.unsetConnectionStatus();
    }

    // Limpiar token de autenticación
    Config.userToken = '';

    // Limpiar todos los Provider
    user.resetAll();
    company.resetAll();
    inventory.resetAll();
    device.resetAll();
    history.resetAll();
    printer.resetAll();
    encoder.resetAll();
    statistics.resetAll();
    location.resetAll();
    role.resetAll();
    images.resetAll();
    bulkLoadProvider.resetAll();
    fileInformation.clear();
    fileInformationData.clear();
    transfer.resetAll();
    campus.resetAll();
  }
}
