// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// --------------------Selección de sede--------------------------------
// ---------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class StocktakingLocationPage extends StatelessWidget {
  ///  Class Key
  const StocktakingLocationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          await NavigationFunctions.checkLeavingPage(context, PageList.conteo);
          return true;
        },
        child: Scaffold(
            appBar: ApplicationBar.appBar(
              context,
              PageList.conteo,
              leavingBlock: true,
            ),
            endDrawer: MenuDrawer.drawer(context, PageList.conteo),
            body: LocationPage(),
            bottomNavigationBar: BottomBar.bottomBar(
                PageList.conteo, context, PageList.conteo,
                thisPage: true)),
      );
}

/// Clase para selección de usuario y empresa
class LocationPage extends StatelessWidget {
  /// Class Key
  // ignore: prefer_const_constructors_in_immutables
  LocationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _textBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.4
        : mediaSize.width * 0.3;
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    final _currentLocation = company.currentLocation;
    // Capturar el inventario
    final inventory = context.watch<InventoryModel>();

    if (inventory.status == StocktakingStatus.idle) {
      return const Center(child: Text('Cargando inventario'));
    } else if (inventory.status == StocktakingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (inventory.status == StocktakingStatus.loaded) {
      inventory.getCategories();
      return ListView(
        children: [
          // Título
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conteo de activos',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Realice el conteo de todos sus activos de forma automática',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          // Inventario por ubicación
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10, top: 20),
                child: Text(
                  'Conteo por ubicación',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Ubicación:',
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    width: 250,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: DropdownButton<String>(
                        value: _currentLocation,
                        icon: Icon(Icons.arrow_downward,
                            color: Theme.of(context).highlightColor),
                        elevation: 16,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.brown),
                        onChanged: (newValue) async {
                          company.changeLocation(newValue);
                          inventory
                            ..extractLocalItems(newValue!)
                            ..stocktakingRecentlyDone = false;
                        },
                        items: company.places
                            .map<DropdownMenuItem<String>>(
                                (value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: SizedBox(
                                        width: 200,
                                        child: Text(value),
                                      ),
                                    ))
                            .toList(),
                      ),
                    ),
                  ),
                  // Datos de sede seleccionada
                  const LocationInfo(),
                  // Botón de reiniciar conteo anterior
                  Container(
                    alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                    child: (inventory.lastStockTakingLocation != null &&
                            inventory.tagList.isNotEmpty)
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).highlightColor,
                            ),
                            onPressed: () {
                              company.changeLocation(
                                  inventory.lastStockTakingLocation);
                              inventory.extractLocalItems(
                                  inventory.lastStockTakingLocation!);
                              Navigator.pushNamed(context, '/conteo');
                            },
                            child: const Text('Retomar último conteo'),
                          )
                        : null,
                  ),
                ]),
              ),
            ],
          ),
          // Búsqueda de activo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10, top: 20),
                child: Text(
                  'Búsqueda de activo específico',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        width: _textBoxWidth,
                        child: const Text(
                          'Busque un activo específico utilizando el lector '
                          'RFID sin importar la ubicación.',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    // Botón de ir al módulo de buscar activo
                    Container(
                      margin: const EdgeInsets.all(10),
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/buscar-lista'),
                        child: const Text(
                          'Buscar\nactivo',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return const Center(
        child: Text('Error en carga de inventarios.\n'
            'Vuelva atrás e intente de nuevo.'),
      );
    }
  }
}

/// Clase para mostrar la información de las sedes capturadas
class LocationInfo extends StatelessWidget {
  ///  Class Key
  const LocationInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar datos de sede
    final company = context.watch<CompanyModel>();
    final _currentLocation = company.currentLocation;

    // Capturar el inventario
    final inventory = context.watch<InventoryModel>();
    final _numAssets = inventory.localInventory.length;

    if (_currentLocation != null) {
      return Column(
        children: [
          // Información de sede
          Container(
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Total de activos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(_numAssets.toString()),
                ),
              ],
            ),
          ),
          // Botón de iniciar conteo
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: (company.currentLocation != null)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor),
              onPressed: () {
                if (!kIsWeb) {
                  if (inventory.localInventory.isEmpty) {
                    HenutsenDialogs.showSnackbar(
                      'Esta ubicación no tiene activos asignados.\n'
                      'Para realizar un conteo ingrese a una ubicación que '
                      'tenga activos asignados.',
                      context,
                    );
                  } else {
                    inventory
                      ..tagList.clear()
                      ..assetsResult.assets = <AssetStatus>[];
                    Navigator.pushNamed(context, '/conteo');
                  }
                } else {
                  HenutsenDialogs.showSnackbar(
                    'Esta funcionalidad no está habilitada desde Web.\n'
                    'Por favor intente desde un móvil con conexión Bluetooth.',
                    context,
                  );
                }
              },
              child: const Text('Iniciar conteo'),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
