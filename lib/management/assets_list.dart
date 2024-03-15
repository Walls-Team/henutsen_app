// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -----------------Gestión de los activos-----------------
// --------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/configuration/widgetText.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AssetsListPage extends StatelessWidget {
  ///  Class Key
  const AssetsListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          await NavigationFunctions.checkLeavingPage(context, PageList.gestion);
          return true;
        },
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.gestion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: AssetsList(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

/// --------------- Para mostrar los activos ------------------
class AssetsList extends StatelessWidget {
  ///  Class Key
  AssetsList({Key? key}) : super(key: key);

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
    final user = context.watch<UserModel>();
    // Capturar el inventario
    final inventory = context.watch<InventoryModel>();

    final create =
        verifyResource(user.currentUser.roles!, company, 'SaveNewAsset');
    final downAsset =
        verifyResource(user.currentUser.roles!, company, 'DownAsset');
    String _currentLocation;
    if (company.currentLocation == null) {
      _currentLocation = 'Todas';
    } else {
      _currentLocation = company.currentLocation!;
    }
    // Menú desplegable de ubicaciones
    company.places.sort();
    final _listOfLocations =
        _fillListOfItems(company.places, 'Todas', _menuWidth);

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

    String _currentStatus;
    if (inventory.currentStatus == null) {
      _currentStatus = 'Todos';
      inventory.currentStatus = _currentStatus;
    } else {
      _currentStatus = inventory.currentStatus!;
    }
    // Menú desplegable de estados
    final _listOfStatus =
        _fillListOfItems(inventory.conditions, 'Todos', _menuWidth);

    // ----Widgets----
    // Función plantilla para widgets de filtro
    // Aplica para -ubicación, -categoría, -estado
    Widget _filterField(String fieldName, List<DropdownMenuItem<String>> list) {
      // Valor seleccionado a mostrar en el menú desplegable
      String? _fieldValue;
      if (fieldName == 'Ubicación') {
        _fieldValue = _currentLocation;
      } else if (fieldName == 'Categoría') {
        _fieldValue = _currentCategory;
      } else if (fieldName == 'Estado') {
        _fieldValue = _currentStatus;
      }
      // Función a ejecutar al cambiar opción
      void _onValueChange(String newValue) {
        if (fieldName == 'Ubicación') {
          if (newValue == 'Todas') {
            company.changeLocation(null);
          } else {
            company.changeLocation(newValue);
            inventory.extractLocalItems(newValue);
          }
        } else if (fieldName == 'Categoría') {
          inventory.changeCategory(newValue);
        } else if (fieldName == 'Estado') {
          inventory.changeStatus(newValue);
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
              ..localInventory.clear()
              ..changeSearchField('');
            Provider.of<ProviderSearch>(context, listen: false).clear();
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
                Text('Lista de Activos',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Agregue, modifique o elimine activos de su inventario',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
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
                        _filterField('Estado', _listOfStatus),
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
                            TextFieldCompany(_searchBoxWidth,
                                'Buscar por nombre, serial o código de barras'),
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
                            _filterField('Estado', _listOfStatus),
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
                            TextFieldCompany(_searchBoxWidth,
                                'Buscar por nombre, serial o código de barras'),
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
          if (create)
            // Botón de agregar
            IconButton(
              icon: Image.asset(
                'images/iconoAgregar.png',
                semanticLabel: 'Agregar activo',
              ),
              iconSize: 100,
              onPressed: () async {
                // Comenzar creación con activo nulo
                inventory.currentAsset = Asset(
                  assetCodeLegacy: <LegacyCode>[
                    LegacyCode(system: '', value: ''),
                    LegacyCode(system: '', value: ''),
                  ],
                  assetDetails: AssetDetails(),
                  categories: <AssetCategory>[
                    AssetCategory(name: 'Category 1')
                  ],
                  images: <AssetPhoto>[],
                  status: 'Operativo',
                  lastStocktaking: LastStocktaking(),
                );
                if (!downAsset) {
                  inventory.removeStatus();
                }
                // Capturar modelo de imágenes
                final imageModel = context.read<ImageModel>();
                imageModel.imageArray.clear();
                imageModel.loadedImages.clear();
                // Llenar usuarios de la empresa
                // Capturar modelo de usuario
                final user = context.read<UserModel>();
                await user.loadLocalUsers(company.currentCompany.id!);
                await Navigator.pushNamed(context, '/datos-activo');
              },
            ),
          // Información de activos
          const InfoToShow(),
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
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Leemos cambios en el modelo del inventario
    final inventory = context.watch<InventoryModel>();
    // Leemos cambios en el modelo de la empresa
    final company = context.watch<CompanyModel>();

    ///
    final searchField = context.watch<ProviderSearch>();

    // Presentamos lista de activos de la ubicación
    if (company.currentLocation == null ||
        inventory.localInventory.isNotEmpty) {
      // Llenar la lista considerando filtros
      final initialAssetsList = <Asset>[];
      for (final item in inventory.fullInventory) {
        // Activos en la ubicación elegida
        if (item.locationName == company.currentLocation ||
            company.currentLocation == null) {
          final itemCategory = inventory.getAssetMainCategory(item.assetCode);
          // Activos de la categoría elegida
          if (itemCategory == inventory.currentCategory ||
              inventory.currentCategory == 'Todas') {
            // Activos con estado elegido
            if (item.status == inventory.currentStatus ||
                inventory.currentStatus == 'Todos') {
              initialAssetsList.add(item);
            }
          }
        }
      }
      // Considerar campo de búsqueda también
      final assets2show = inventory.filterAssets(
          searchField.searchFilter, initialAssetsList, '');

      if (assets2show.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          // Tabla de activos
          child: PaginatedDataTable(
            source: DataTableItems(
                context: context,
                generalData: assets2show,
                modelSource: inventory,
                otherSource: company,
                dataToPrint: DataToPrint.assets),
            header: const Text('Lista de Activos'),
            columns: [
              const DataColumn(label: Text('No.')),
              const DataColumn(label: Text('Nombre del activo')),
              const DataColumn(label: Text('Serial del activo')),
              const DataColumn(label: Text('Ubicación del activo')),
              const DataColumn(label: Text('Estado del activo')),
              const DataColumn(label: Text('Responsable del activo')),
              DataColumn(
                  label: Expanded(
                      child: Text(
                'Total de activos: ${assets2show.length}',
                textAlign: TextAlign.center,
              ))),
            ],
            columnSpacing: 50,
            horizontalMargin: 10,
            rowsPerPage: assets2show.length <= 10 ? assets2show.length : 10,
            showCheckboxColumn: false,
          ),
        );
      } else {
        return const Center(
          child: Text('No hay información...'),
        );
      }
    } else {
      return const Center(
        child: Text('No hay información...'),
      );
    }
  }
}
