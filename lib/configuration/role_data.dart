// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------------Creación/edición de roles--------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/configuration/locationsRol.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/role_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class RoleDataPage extends StatelessWidget {
  ///  Class Key
  const RoleDataPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.configuracion),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: RoleData(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// Manejo de rol
class RoleData extends StatelessWidget {
  ///  Class Key
  RoleData({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    final _checkboxWidth =
        (mediaSize.width < screenSizeLimit) ? mediaSize.width * 0.27 : 180.0;
    // Capturar modelo de rol
    final role = context.watch<RoleModel>();

    final mapR = role.resourcesList['Configuración'] as Map<String, bool>;
    final buttonLocation = mapR['Ver ubicaciones'];
    // Capturar modelo de empresa
    final company = context.watch<CompanyModel>();
    // Llenar lista de empresas
    final _companyNames = <String>[];
    // Llenar empresas según modo (creación o modificación)
    if (role.creationMode) {
      for (final item in company.fullCompanyList) {
        // Solo considerar empresas activas
        if (item.active ?? false) {
          _companyNames.add(item.name!);
        }
      }
    } else {
      _companyNames.add(role.currentSearchCompany!);
    }

    // Lista de opciones de campos
    List<Widget> _optionsList(int offsetIndex, int quantity) {
      final _rows = <Row>[];
      Map.fromIterables(
        role.resourcesList.keys.skip(offsetIndex).take(quantity),
        role.resourcesList.values.skip(offsetIndex).take(quantity),
      ).forEach((key, value) {
        final _sectionTitle = Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 8),
          child: Text(
            key,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        value as Map<String, bool>;
        final _insideRows = <Row>[];
        Map.fromIterables(
          value.keys,
          value.values,
        ).forEach((subkey, subvalue) {
          final _myChoice = Checkbox(
            value: subvalue,
            activeColor: Colors.lightBlue,
            onChanged: (newValue) {
              role.updateResourceSelection(key, subkey, newValue!);
            },
          );
          final _myRow = Row(children: [
            SizedBox(
              width: _checkboxWidth,
              child: Text(subkey),
            ),
            _myChoice,
          ]);
          _insideRows.add(_myRow);
        });
        final _resourcesSection = Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle,
                ..._insideRows,
                const Divider(),
                if (buttonLocation! && key == 'Configuración')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (role.tempRole.roleId == null) {
                          role.tempRole.resources = [];
                        }
                        role.changeCompany(company.fullCompanyList
                            .where((element) =>
                                element.name == role.currentSearchCompany)
                            .first);
                        await showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            content: const SizedBox(
                              width: 400,
                              height: 400,
                              child: ModalLocations(),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).highlightColor),
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Asignar ubicaciones'),
                    ),
                  ),
              ],
            ),
          ],
        );
        _rows.add(_resourcesSection);
      });
      return _rows;
    }

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Detalles del rol',
                style: Theme.of(context).textTheme.headline3),
          ),
          // Nota para editar
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text('Ingrese o modifique la información correspondiente\n'
                'Los campos con (*) son requeridos.'),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Fila de empresa
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Empresa (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        // Si solo hay una empresa, se deja el campo fijo
                        child: (_companyNames.length == 1)
                            ? SizedBox(
                                width: 200,
                                child: Text(
                                  _companyNames[0],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : SizedBox(
                                width: 200,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: role.currentSearchCompany,
                                    icon: Icon(Icons.arrow_downward,
                                        color:
                                            Theme.of(context).highlightColor),
                                    elevation: 16,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.brown),
                                    onChanged: (newValue) {
                                      role.changeSearchCompany(newValue!);
                                    },
                                    items: _companyNames
                                        .map<DropdownMenuItem<String>>(
                                            (value) => DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value)))
                                        .toList(),
                                  ),
                                ),
                              ),
                      ),
                    ]),
                    // Fila de nombre
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Nombre del rol (*)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: TextFormField(
                            initialValue: role.tempRole.name,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp('[\n\t\r]'))
                            ],
                            onChanged: (value) {
                              role.tempRole.name = value;
                            },
                            maxLength: 30,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Ingrese dato';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Permisos
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    'Permisos para el rol',
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _optionsList(0, 5),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _optionsList(5, 2),
                      ),
                    ],
                  ),
                ),
                // Botones
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón de cancelar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            NavigationFunctions.checkLeavingPage(
                                context, PageList.configuracion);
                            role
                              ..resourceLocations.clear()
                              ..editDone();
                            Navigator.pop(context);
                          },
                          child: const Text('Volver'),
                        ),
                      ),
                      // Botón de crear/modificar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).highlightColor,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (buttonLocation! &&
                                  role.resourceLocations.isEmpty) {
                                await HenutsenDialogs.showSimpleAlertDialog(
                                  context,
                                  'Debes agregar al menos una ubicación',
                                );
                                return;
                              }
                              var _result = '';
                              var _dialogText = '';
                              var _success = false;
                              // Capturar modelo de usuario
                              final user = context.read<UserModel>();
                              // Extraer código de empresa a afectar
                              var _cCode = '';
                              for (final item in company.fullCompanyList) {
                                if (item.name == role.currentSearchCompany) {
                                  _cCode = item.companyCode!;
                                  break;
                                }
                              }
                              // Acciones dependen de si se crea o modifica rol
                              // Si el id es nulo, estamos en creación
                              if (role.tempRole.roleId == null) {
                                // Se espera confirmación del usuario
                                if (await HenutsenDialogs.confirmationMessage(
                                    context,
                                    '¿Confirma creación del rol '
                                    '${role.tempRole.name}?')) {
                                  // Completar datos del rol
                                  role.tempRole.resources =
                                      role.createResourcesList();
                                  role.tempRole.resources?.insert(0, 'Home-0');
                                  for (final item in role.resourceLocations) {
                                    if (!role.tempRole.resources!
                                        .contains(item)) {
                                      role.tempRole.resources?.add(item);
                                    }
                                  }
                                  // Mapa para recopilar información a enviar
                                  final _itemsToSend = <String, dynamic>{
                                    'UserName': user.name2show,
                                    'CompanyCode': _cCode,
                                    'RoleData': role.tempRole,
                                  };
                                  final jsonToSend = jsonEncode(_itemsToSend);
                                  //print(jsonToSend);
                                  _result = await role.saveNewRole(jsonToSend);
                                  if (_result == 'Ok') {
                                    _success = true;
                                    _dialogText = 'Rol creado exitosamente';
                                  } else {
                                    _dialogText = 'Error creando rol.\n'
                                        '$_result.\n'
                                        'Revise e intente nuevamente.';
                                  }
                                }
                                // Si el id no es nulo, estamos en modificación
                              } else {
                                // Se espera confirmación del usuario
                                if (await HenutsenDialogs.confirmationMessage(
                                    context,
                                    '¿Confirma modificación del rol '
                                    '${role.tempRole.name}?')) {
                                  role.tempRole.resources =
                                      role.createResourcesList();
                                  role.tempRole.resources?.insert(0, 'Home-0');
                                  for (final item in role.resourceLocations) {
                                    if (!role.tempRole.resources!
                                        .contains(item)) {
                                      role.tempRole.resources?.add(item);
                                    }
                                  }
                                  // Mapa para recopilar información a enviar
                                  final _itemsToSend = <String, dynamic>{
                                    'UserName': user.name2show,
                                    'CompanyCode': _cCode,
                                    'RoleData': role.tempRole,
                                  };
                                  final chain = jsonEncode(_itemsToSend);
                                  _result = await role.modifyRole(chain);
                                  if (_result == 'Ok') {
                                    _success = true;
                                    _dialogText = 'Rol modificado exitosamente';
                                  } else {
                                    _dialogText = 'Error modificando rol.\n'
                                        '$_result.\n'
                                        'Revise e intente nuevamente.';
                                  }
                                }
                              }
                              if (_dialogText.isNotEmpty) {
                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    content: SingleChildScrollView(
                                      child: Text(_dialogText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3),
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary:
                                              Theme.of(context).highlightColor,
                                        ),
                                        onPressed: () async {
                                          if (_success) {
                                            // Recargar roles disponibles para
                                            // la empresa seleccionada
                                            for (final item
                                                in company.fullCompanyList) {
                                              if (role.currentSearchCompany ==
                                                  item.name) {
                                                if (role.creationMode) {
                                                  item.roles
                                                      ?.add(role.tempRole);
                                                } else {
                                                  for (var subitem
                                                      in item.roles!) {
                                                    if (subitem.roleId ==
                                                        role.tempRole.roleId) {
                                                      subitem = role.tempRole;
                                                      break;
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                            // Actualizar datos de empresa
                                            // actual si rol se incluyó acá
                                            if (company.currentCompany.name ==
                                                role.currentSearchCompany) {
                                              if (!role.creationMode) {
                                                for (var item in company
                                                    .currentCompany.roles!) {
                                                  if (item.roleId ==
                                                      role.tempRole.roleId) {
                                                    item = role.tempRole;
                                                    break;
                                                  }
                                                }
                                              }
                                            }

                                            await company.loadCompanies();
                                            company.status = CompanyStatus.idle;

                                            role.resourceLocations.clear();
                                            role.editDone();
                                            Navigator.popUntil(
                                              context,
                                              ModalRoute.withName(
                                                  '/gestion-roles'),
                                            );
                                          } else {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: const Text('Aceptar'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          child: (role.tempRole.roleId == null)
                              ? const Text('Crear')
                              : const Text('Modificar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
