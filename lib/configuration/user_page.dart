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
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:henutsen_cli/utils/verifyResources.dart';
import 'package:provider/provider.dart';

/// Clase principal
class UserManagement extends StatelessWidget {
  ///  Class Key
  const UserManagement({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.configuracion),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: UserList(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// --------------- Para mostrar los usuarios ------------------
class UserList extends StatelessWidget {
  ///  Class Key
  UserList({Key? key}) : super(key: key);

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
    final user = context.watch<UserModel>();
    // Capturar modelo de empresa
    final company = context.watch<CompanyModel>();
    final searchField = context.watch<ProviderSearch>();
    final createUser =
        verifyResource(user.currentUser.roles!, company, 'CreateUser');
    final _companyList = <String>[];
    for (final item in company.fullCompanyList) {
      // Solo considerar empresas activas
      if (item.active ?? false) {
        _companyList.add(item.name!);
      }
    }
    // Precargamos los roles de la empresa actual si no es un usuario "Vendedor"
    final _roles = <String>[];
    if (!user.currentUserRole.contains('Vendedor')) {
      // Cargar roles disponibles para esta empresa
      for (final item in company.fullCompanyList) {
        if (user.currentSearchCompany == item.name) {
          for (final subitem in item.roles!) {
            _roles.add(subitem.name!);
          }
        }
        break;
      }
    }
    // Menú desplegable de empresas
    final _listOfCompanies = user.currentUserRole.contains('Vendedor')
        ? _itemsList(_companyList, 'Todas', _menuWidth)
        : _companyList
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
    // Menú desplegable de roles
    final _listOfRoles = user.currentUserRole.contains('Vendedor')
        ? _itemsList(company.tempRoles, 'Todos', _menuWidth)
        : _itemsList(_roles, 'Todos', _menuWidth);

    // ----Widgets----
    // Función plantilla para widgets de filtro
    // Aplica para -empresa, -rol
    Widget _filterField(String fieldName, List<DropdownMenuItem<String>> list) {
      // Valor seleccionado a mostrar en el menú desplegable
      String? _fieldValue;
      if (fieldName == 'Empresa') {
        _fieldValue = user.currentSearchCompany;
      } else if (fieldName == 'Rol') {
        _fieldValue = user.currentSearchRole;
      }
      // Función a ejecutar al cambiar opción
      void _onValueChange(String newValue) {
        if (fieldName == 'Empresa') {
          // Cargar roles disponibles para esta empresa
          company.tempRoles.clear();
          for (final item in company.fullCompanyList) {
            if (newValue == item.name) {
              for (final subitem in item.roles!) {
                company.tempRoles.add(subitem.name!);
              }
              break;
            }
          }
          user
            ..currentSearchRole = 'Todos'
            ..changeSearchCompany(newValue);
          for (final item in company.fullCompanyList) {
            if (newValue == item.name) {
              user.currentSearchCompanyID = item.id;
              break;
            }
          }
        } else if (fieldName == 'Rol') {
          user.changeSearchRole(newValue);
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
              labelText: 'Buscar por correo, nombre o documento'),
          onChanged: user.changeSearchField,
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
            if (user.currentUserRole.contains('Vendedor')) {
              user.currentSearchCompany = 'Todas';
            }
            user
              ..currentSearchRole = 'Todos'
              ..changeSearchField('');
            company.tempRoles.clear();
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
                Text('Gestión de usuarios',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Agregue, modifique o elimine usuarios',
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
                        // Selección de rol
                        _filterField('Rol', _listOfRoles),
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
                                'Buscar por correo, nombre o documento'),
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
                            // Selección de rol
                            _filterField('Rol', _listOfRoles),
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
                                'Buscar por correo, nombre o documento'),
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
          if (createUser)
            // Botón de agregar
            IconButton(
              icon: Image.asset(
                'images/iconoAgregar.png',
                semanticLabel: 'Agregar',
              ),
              iconSize: 100,
              onPressed: () {
                // Iniciar con usuario nulo
                user
                  ..tempUser = User(
                    name: Name(),
                    photos: <Photo>[],
                    emails: <Email>[],
                    roles: [],
                    helpScreens: <HelpScreen>[],
                    company: CompanyID(),
                  )
                  ..docType = null
                  ..docNum = ''
                  ..tempRole = null
                  ..tempCompany = company.currentCompany.name
                  ..tempCompanyID = company.currentCompany.id
                  ..tempPassword = '';
                // Capturar modelo de imágenes
                final imageModel = context.read<ImageModel>();
                imageModel.imageArray.clear();
                imageModel.loadedImages.clear();
                Navigator.pushNamed(context, '/datos-usuario');
              },
            ),
          // Información de usuarios
          const InfoToShow(),
        ],
      ),
    );
  }

  // Método para llenar lista desplegable de empresas o roles
  List<DropdownMenuItem<String>> _itemsList(
      List<String> initialList, String allChoice, double width) {
    final extendedList = initialList
        .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
              value: value,
              child: SizedBox(
                width: width,
                child: Text(value),
              ),
            ))
        .toList()
      // Agregar opción "Todos" o "Todas" al menú
      ..insert(
        0,
        DropdownMenuItem<String>(
          value: allChoice,
          child: SizedBox(
            width: width,
            child: Text(
              allChoice,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    return extendedList;
  }
}

/// Clase para devolver la información de usuarios a mostrar
class InfoToShow extends StatelessWidget {
  /// Class Key
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar el modelo del usuario
    final user = context.watch<UserModel>();
    // Capturar modelo de empresa
    final company = context.watch<CompanyModel>();

    final searchField = context.watch<ProviderSearch>();

    // Llenar la lista considerando filtros
    final initialUsersList = <User>[];
    for (final item in user.fullUsersList) {
      // Usuarios que hacen parte de la empresa elegida
      if (item.company!.id == user.currentSearchCompanyID ||
          user.currentSearchCompany == 'Todas') {
        // Extraer nombre de rol
        String? _roleName;
        for (final comp in company.fullCompanyList) {
          if (item.company?.id == comp.id) {
            for (final cRole in comp.roles!) {
              if (item.roles!.contains(cRole.roleId)) {
                _roleName = cRole.name;
                break;
              }
            }
          }
          break;
        }
        // Usuarios que tienen el rol elegido
        if (_roleName == user.currentSearchRole ||
            user.currentSearchRole == 'Todos') {
          initialUsersList.add(item);
        }
      }
    }
    // Considerar campo de búsqueda también
    final users2show =
        user.filterUsers(searchField.searchFilter, initialUsersList);

    if (users2show.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        // Tabla de usuarios
        child: PaginatedDataTable(
          source: DataTableItems(
              context: context,
              generalData: users2show,
              modelSource: user,
              otherSource: company,
              dataToPrint: DataToPrint.users),
          header: const Text('Lista de Usuarios'),
          columns: [
            const DataColumn(label: Text('No.')),
            const DataColumn(label: Text('Nombre')),
            const DataColumn(label: Text('Usuario')),
            const DataColumn(label: Text('Cédula')),
            const DataColumn(label: Text('Rol')),
            DataColumn(
                label: Expanded(
              child: Text('Total de Usuarios: ${users2show.length}',
                  textAlign: TextAlign.center),
            )),
          ],
          columnSpacing: 50,
          horizontalMargin: 10,
          rowsPerPage: users2show.length <= 10 ? users2show.length : 10,
          showCheckboxColumn: false,
        ),
      );
    } else {
      return Container();
    }
  }
}
