// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// --------------Crear/modificar linea de negocio-------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/location_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class BusinessDataPage extends StatelessWidget {
  ///  Class Key
  const BusinessDataPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.configuracion),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: BusinessData(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// Datos de ubicación
class BusinessData extends StatelessWidget {
  ///  Class Key
  BusinessData({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Capturar ubicación
    final location = context.watch<LocationModel>();
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de imágenes
    final imageModel = context.watch<ImageModel>();
    // Llenar lista de empresas
    final _companyNames = <String>[];
    // Llenar empresas según modo (creación o modificación)
    if (company.creationMode) {
      for (final item in company.fullCompanyList) {
        // Solo considerar empresas activas
        if (item.active ?? false) {
          _companyNames.add(item.name!);
        }
      }
    } else {
      _companyNames.add(company.auxCompany.name!);
    }

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Detalles de la linea de negocio',
                style: Theme.of(context).textTheme.headline3),
          ),
          // Nota de campos requeridos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.only(bottom: 10),
            child: const Text('Los campos con (*) son requeridos.'),
          ),
          // Formulario para nueva ubicación
          Form(
            key: _formKey,
            child: Table(
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    // Si solo hay una empresa, se deja el campo fijo
                    child: (_companyNames.length == 1)
                        ? SizedBox(
                            width: 200,
                            child: Text(
                              _companyNames[0],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        : SizedBox(
                            width: 200,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: company.auxCompany.name,
                                icon: Icon(Icons.arrow_downward,
                                    color: Theme.of(context).highlightColor),
                                elevation: 16,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.brown),
                                onChanged: (newValue) {
                                  var _newSelectedCompany = Company();
                                  // Cargar datos de esta empresa
                                  for (final item in company.fullCompanyList) {
                                    if (newValue == item.name) {
                                      _newSelectedCompany = item;
                                      break;
                                    }
                                  }
                                  company.asigneNewNameBusiness(
                                      newValue!, _newSelectedCompany);
                                },
                                items: _companyNames
                                    .map<DropdownMenuItem<String>>((value) =>
                                        DropdownMenuItem<String>(
                                            value: value, child: Text(value)))
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
                        'Nombre (*)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: TextFormField(
                        initialValue: company.modifyNameBusiness,
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
                          FilteringTextInputFormatter.deny(RegExp('[\n\t\r]'))
                        ],
                        onChanged: (value) {
                          company.modifyNameBusiness = value;
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
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                // Botón de crear
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).highlightColor,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Capturar el usuario
                        final user = context.read<UserModel>();
                        var _result = '';
                        var _success = false;
                        var _dialogText = '';
                        //print(chain);
                        // Acciones dependen si se crea o se modifica ubicación
                        if (company.creationMode) {
                          // Se espera confirmación del usuario
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma creación de la linea de negocio? '
                              '${company.modifyNameBusiness}?')) {
                            final _cCode = company.auxCompany.companyCode;
                            _result = await company.bussinesLineSave(
                                company.modifyNameBusiness, _cCode!, '');
                            if (_result.contains('agregada')) {
                              _success = true;
                              _dialogText =
                                  'Linea de negocio registrada exitosamente';
                            } else {
                              _dialogText =
                                  'Error registrando linea de negocio.\n'
                                  '$_result.\n'
                                  'Revise e intente nuevamente.';
                            }
                          }
                        } else {
                          // Se espera confirmación del usuario
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma modificación de la linea de negocio '
                              '${company.modifyNameBusiness}?')) {
                            final _cCode = company.auxCompany.companyCode;
                            _result = await company.bussinesLineSave(
                                company.modifyNameBusiness,
                                _cCode!,
                                company.olNameBusiness,
                                creationMode: false);
                            if (_result.contains('modificada')) {
                              _success = true;
                              _dialogText =
                                  'Linea de negocio modificada exitosamente';
                            } else {
                              _dialogText =
                                  'Error modificando la linea de negocio.\n'
                                  '$_result.\n'
                                  'Revise e intente nuevamente.';
                            }
                          }
                        }
                        if (_dialogText.isNotEmpty) {
                          await showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Text(
                                  _dialogText,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).highlightColor,
                                  ),
                                  onPressed: () async {
                                    if (_success) {
                                      // Actualizar datos de empresa actual si
                                      // ubicación se incluyó acá
                                      if (company.creationMode) {
                                        company.auxCompany.businessLines!
                                            .add(company.modifyNameBusiness);
                                      } else {
                                        company.auxCompany.businessLines!
                                            .remove(company.olNameBusiness);
                                        company.auxCompany.businessLines!
                                            .add(company.modifyNameBusiness);
                                      }

                                      for (var i = 0;
                                          i < company.fullCompanyList.length;
                                          i++) {
                                        if (company.fullCompanyList[i].id ==
                                            company.auxCompany.id) {
                                          company.fullCompanyList[i] =
                                              company.auxCompany;
                                          break;
                                        }
                                      }
                                      company.editDone();
                                      Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                            '/gestion-negocios'),
                                      );
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text('Aceptar'),
                                )
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: company.creationMode
                        ? const Text('Crear')
                        : const Text('Modificar'),
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
