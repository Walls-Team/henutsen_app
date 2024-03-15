// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -----------------Gestión de los usuarios----------------
// --------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/configuration/widgetText.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/campus_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:henutsen_cli/utils/verifyResources.dart';
import 'package:provider/provider.dart';

/// Clase principal
class CampusManagement extends StatelessWidget {
  ///  Class Key
  const CampusManagement({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.configuracion),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: CampusList(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// --------------- Para mostrar los usuarios ------------------
class CampusList extends StatelessWidget {
  ///  Class Key
  CampusList({Key? key}) : super(key: key);

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
    // Capturar el modelo del usuario
    final campus = context.watch<CampusModel>();
    // Capturar modelo de empresa
    final company = context.watch<CompanyModel>();
    final searchField = context.watch<ProviderSearch>();

    // Botón de limpiar búsqueda
    final _cleanButton = Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.reset();
            campus.filterBusiness = 'Todas';
            searchField.clear();
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
                Text('Gestión de sedes',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Agregue, modifique o elimine sedes',
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
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(children: [
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: 70,
                                child: Text(
                                  'Empresa',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: _menuBoxWidth,
                              height: 40,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                ),
                                child: DropdownButton<String>(
                                  value: campus.filterCompany,
                                  icon: Icon(Icons.arrow_downward,
                                      color: Theme.of(context).highlightColor),
                                  elevation: 16,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.brown),
                                  onChanged: (newValue) {
                                    campus.changeNameC(
                                        newValue!,
                                        company.fullCompanyList
                                            .where((element) =>
                                                element.name == newValue)
                                            .first);
                                  },
                                  items: campus.filterNamesC
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
                            ),
                          ]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(children: [
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: 70,
                                child: Text(
                                  'Linea de negocio',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: _menuBoxWidth,
                              height: 40,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                ),
                                child: DropdownButton<String>(
                                  value: campus.filterBusiness,
                                  icon: Icon(Icons.arrow_downward,
                                      color: Theme.of(context).highlightColor),
                                  elevation: 16,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.brown),
                                  onChanged: (newValue) {
                                    campus.changeNameB(newValue!);
                                  },
                                  items: campus.filterNamesB
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
                            ),
                          ]),
                        ),
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
                                _searchBoxWidth, 'Buscar por nombre'),
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
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(children: [
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 70,
                                    child: Text(
                                      'Empresa',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: _menuBoxWidth,
                                  height: 40,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Theme.of(context).primaryColor),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                    ),
                                    child: DropdownButton<String>(
                                      value: campus.filterCompany,
                                      icon: Icon(Icons.arrow_downward,
                                          color:
                                              Theme.of(context).highlightColor),
                                      elevation: 16,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.brown),
                                      onChanged: (newValue) {
                                        campus.changeNameC(
                                            newValue!,
                                            company.fullCompanyList
                                                .where((element) =>
                                                    element.name == newValue)
                                                .first);
                                      },
                                      items: campus.filterNamesC
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
                                ),
                              ]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(children: [
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 70,
                                    child: Text(
                                      'Linea de negocio',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: _menuBoxWidth,
                                  height: 40,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Theme.of(context).primaryColor),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                    ),
                                    child: DropdownButton<String>(
                                      value: campus.filterBusiness,
                                      icon: Icon(Icons.arrow_downward,
                                          color:
                                              Theme.of(context).highlightColor),
                                      elevation: 16,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.brown),
                                      onChanged: (newValue) {
                                        campus.changeNameB(newValue!);
                                      },
                                      items: campus.filterNamesB
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
                                ),
                              ]),
                            ),
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
                                _searchBoxWidth, 'Buscar por nombre'),
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
          // Botón de agregar
          IconButton(
            icon: Image.asset(
              'images/iconoAgregar.png',
              semanticLabel: 'Agregar',
            ),
            iconSize: 100,
            onPressed: () {
              campus.campus.name = '';
              campus.campus.addresses = [
                CompanyAddress(
                    primary: true,
                    country: '',
                    locality: '',
                    region: '',
                    streetAddress: '')
              ];
              campus.asigneStatus(Status.creationMode);
              // Capturar modelo de imágenes
              final imageModel = context.read<ImageModel>();
              imageModel.imageArray.clear();
              imageModel.loadedImages.clear();
              Navigator.pushNamed(context, '/campus-data');
            },
          ),
          // Información de usuarios
          const InfoToShow(),
        ],
      ),
    );
  }
}

/// Clase para devolver la información de usuarios a mostrar
class InfoToShow extends StatelessWidget {
  /// Class Key
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final campus = context.watch<CampusModel>();
    // Capturar modelo de empresa
    final company = context.watch<CompanyModel>();

    final searchField = context.watch<ProviderSearch>();

    // Llenar la lista considerando filtros
    final initialUsersList = <Campus>[];
    for (final item in campus.campusList) {
      if (campus.filterCompanyCode == item.companyCode) {
        if (campus.filterBusiness == item.businessLine ||
            campus.filterBusiness == 'Todas') {
          initialUsersList.add(item);
        }
      }
    }
    // Considerar campo de búsqueda también
    final campus2show =
        campus.filterUsers(searchField.searchFilter, initialUsersList);

    if (campus2show.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        // Tabla de usuarios
        child: PaginatedDataTable(
          source: DataTableItems(
              context: context,
              generalData: campus2show,
              modelSource: campus,
              otherSource: company,
              dataToPrint: DataToPrint.campus),
          header: const Text('Lista de Sedes'),
          columns: [
            const DataColumn(label: Text('No.')),
            const DataColumn(label: Text('Nombre')),
            DataColumn(
                label: Expanded(
              child: Text('Total de Sedes: ${campus2show.length}',
                  textAlign: TextAlign.center),
            )),
          ],
          columnSpacing: 50,
          horizontalMargin: 10,
          rowsPerPage: campus2show.length <= 10 ? campus2show.length : 10,
          showCheckboxColumn: false,
        ),
      );
    } else {
      return Container();
    }
  }
}
