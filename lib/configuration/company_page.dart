// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -----------------Gestión de las empresas----------------
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
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:provider/provider.dart';

/// Clase principal
class CompanyManagement extends StatelessWidget {
  ///  Class Key
  const CompanyManagement({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.configuracion),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: CompanyList(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// --------------- Para mostrar las empresas ------------------
class CompanyList extends StatelessWidget {
  ///  Class Key
  CompanyList({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  // Opciones para menú desplegable de empresa activa
  final _activeFilter = ['Todas', 'Activas', 'Inactivas'];

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
    // Capturar modelo de empresa
    final company = context.watch<CompanyModel>();
    // Capturar el usuario actual
    final user = context.watch<UserModel>();
    final creatCompany =
        verifyResource(user.currentUser.roles!, company, 'CreateGroup');
    // Menú desplegable de estados de empresa
    final _listOfStatus = _activeFilter
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
    // Aplica para -estado de empresa
    Widget _filterField(String fieldName) {
      // Valor seleccionado a mostrar en el menú desplegable
      String? _fieldValue;
      if (fieldName == 'Estado de la empresa') {
        _fieldValue = company.currentSearchStatus;
      }
      // Función a ejecutar al cambiar opción
      void _onValueChange(String newValue) {
        if (fieldName == 'Estado de la empresa') {
          company.changeSearchStatus(newValue);
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
                items: _listOfStatus,
              ),
            ),
          ),
        ]),
      );
    }

    // Botón de limpiar búsqueda
    final _cleanButton = Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.reset();
            company
              ..currentSearchStatus = 'Todas'
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
                Text('Gestión de empresas',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Agregue, modifique o elimine empresas',
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
                        // Selección de estado de empresa
                        _filterField('Estado de la empresa'),
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
                            TextFieldCompany(
                                _searchBoxWidth, 'Buscar por nombre o NIT'),
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
                            // Selección de estado de empresa
                            _filterField('Estado de la empresa'),
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
                            TextFieldCompany(
                                _searchBoxWidth, 'Buscar por nombre o NIT'),
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
          if (creatCompany)
            // Botón de agregar
            IconButton(
              icon: Image.asset(
                'images/iconoAgregar.png',
                semanticLabel: 'Agregar',
              ),
              iconSize: 100,
              onPressed: () {
                // Iniciar con empresa nula
                company
                  ..tempCompany = Company(
                    addresses: [CompanyAddress()],
                  )
                  ..tempCompanyCountry = ''
                  ..tempCompanyRegion = null
                  ..tempCompanyTown = null;
                // Capturar modelo de imágenes
                final imageModel = context.read<ImageModel>();
                imageModel.imageArray.clear();
                imageModel.loadedImages.clear();
                Navigator.pushNamed(context, '/datos-empresa');
              },
            ),
          // Información de empresas
          const InfoToShow(),
        ],
      ),
    );
  }
}

/// Clase para devolver la información de empresas a mostrar
class InfoToShow extends StatelessWidget {
  /// Class Key
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Leemos cambios en el modelo de empresa
    final company = context.watch<CompanyModel>();
    final searchField = context.watch<ProviderSearch>();

    // Llenar la lista considerando filtros
    final initialCompaniesList = <Company>[];
    for (final item in company.fullCompanyList) {
      // Empresas activas o inactivas según filtro
      if ((company.currentSearchStatus == 'Activas' &&
              (item.active ?? false)) ||
          (company.currentSearchStatus == 'Inactivas' &&
              item.active == false) ||
          company.currentSearchStatus == 'Todas') {
        initialCompaniesList.add(item);
      }
    }
    // Considerar campo de búsqueda también
    final companies2show =
        company.filterCompanies(searchField.searchFilter, initialCompaniesList);

    // Presentamos lista de empresas
    if (companies2show.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        // Tabla de empresas
        child: PaginatedDataTable(
          source: DataTableItems(
              context: context,
              generalData: companies2show,
              modelSource: company,
              dataToPrint: DataToPrint.companies),
          header: const Text('Lista de Empresas'),
          columns: [
            const DataColumn(label: Text('No.')),
            const DataColumn(label: Text('Nombre de la empresa')),
            DataColumn(
                label: Expanded(
              child: Text('Total de empresas: ${companies2show.length}',
                  textAlign: TextAlign.center),
            )),
          ],
          columnSpacing: 50,
          horizontalMargin: 10,
          rowsPerPage: companies2show.length <= 10 ? companies2show.length : 10,
          showCheckboxColumn: false,
        ),
      );
    } else {
      return Container();
    }
  }
}
