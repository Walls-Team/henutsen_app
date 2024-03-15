// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// ----------------Gestión de las ubicaciones--------------
// --------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/location_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:provider/provider.dart';

/// Clase principal
class LocationManagement extends StatelessWidget {
  ///  Class Key
  const LocationManagement({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.configuracion),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: LocationList(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// --------------- Para mostrar las ubicaciones ------------------
class LocationList extends StatelessWidget {
  ///  Class Key
  LocationList({Key? key}) : super(key: key);

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
    // Capturar modelo de ubicación
    final location = context.watch<LocationModel>();
    // Capturar modelo de empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de usuario
    final user = context.watch<UserModel>();
    final creatLocation =
        verifyResource(user.currentUser.roles!, company, 'SaveNewLocation');
    final _companyList = [];
    for (final item in company.fullCompanyList) {
      // Solo considerar empresas activas
      if (item.active ?? false) {
        _companyList.add(item.name);
      }
    }
    // Menú desplegable de empresas
    final _listOfCompanies = _companyList
        .map<DropdownMenuItem<String>>(
          (value) => DropdownMenuItem<String>(
            value: value,
            child: SizedBox(
              width: _menuWidth,
              child: Text(value),
            ),
          ),
        )
        .toList();

    // ----Widgets----
    // Función plantilla para widgets de filtro
    // Aplica para -empresa
    Widget _filterField(String fieldName, List<DropdownMenuItem<String>> list) {
      // Valor seleccionado a mostrar en el menú desplegable
      String? _fieldValue;
      if (fieldName == 'Empresa') {
        _fieldValue = location.currentSearchCompany.name;
      }
      // Función a ejecutar al cambiar opción
      void _onValueChange(String newValue) {
        var _newSelectedCompany = Company();
        // Cargar datos de esta empresa
        for (final item in company.fullCompanyList) {
          if (newValue == item.name) {
            _newSelectedCompany = item;
            break;
          }
        }
        location.changeSearchCompany(_newSelectedCompany);
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
              labelText: 'Buscar por nombre'),
          onChanged: location.changeSearchName,
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
            location.changeSearchName('');
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
                Text('Gestión de ubicaciones',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Agregue, modifique o elimine ubicaciones',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          // Filtros de búsqueda
          Container(
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
                        // Selección de empresa
                        _filterField('Empresa', _listOfCompanies),
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
                            _searchField,
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
                            // Selección de empresa
                            _filterField('Empresa', _listOfCompanies),
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
                            _searchField,
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
          if (creatLocation)
            // Botón de agregar
            IconButton(
              icon: Image.asset(
                'images/iconoAgregar.png',
                semanticLabel: 'Agregar',
              ),
              iconSize: 100,
              onPressed: () {
                // Iniciar con ubicación nula
                location
                  ..tempLocation = Location()
                  ..creationMode = true;
                Navigator.pushNamed(context, '/datos-ubicacion');
              },
            ),
          // Información de ubicaciones
          const InfoToShow(),
        ],
      ),
    );
  }
}

/// Clase para devolver la información de ubicaciones a mostrar
class InfoToShow extends StatelessWidget {
  /// Class Key
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar modelo de ubicación
    final location = context.watch<LocationModel>();
    final company = context.watch<CompanyModel>();

    if (location.currentSearchCompany.name == company.currentCompany.name) {
      location.currentSearchCompany.locations = [];
      location.currentSearchCompany.locations!.addAll(company.places);
    }

    // Presentamos lista de ubicaciones
    if (location.currentSearchCompany.locations!.isNotEmpty) {
      // Llenar la lista
      final locations2show = <String>[];
      for (final item in location.currentSearchCompany.locations!) {
        // Revisar filtros
        if (location.currentSearchName == '' ||
            item
                .trim()
                .toLowerCase()
                .contains(location.currentSearchName.trim().toLowerCase())) {
          locations2show.add(item);
        }
      }

      if (locations2show.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          // Tabla de ubicaciones
          child: PaginatedDataTable(
            source: DataTableItems(
                context: context,
                generalData: locations2show,
                modelSource: location,
                dataToPrint: DataToPrint.locations),
            header: const Text('Lista de Ubicaciones'),
            columns: [
              const DataColumn(label: Text('No.')),
              const DataColumn(label: Text('Ubicación')),
              DataColumn(
                  label: Expanded(
                child: Text('Total de Ubicaciones: ${locations2show.length}',
                    textAlign: TextAlign.center),
              )),
            ],
            columnSpacing: 50,
            horizontalMargin: 10,
            rowsPerPage:
                locations2show.length <= 10 ? locations2show.length : 10,
            showCheckboxColumn: false,
          ),
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }
}
