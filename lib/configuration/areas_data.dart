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
import 'package:henutsen_cli/provider/area_model.dart';
import 'package:henutsen_cli/provider/campus_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/location_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AreaData extends StatelessWidget {
  ///  Class Key
  const AreaData({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.configuracion),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: AreaBody(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// Datos de ubicación
class AreaBody extends StatelessWidget {
  ///  Class Key
  AreaBody({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final areas = context.watch<AreaModel>();
    final campus = context.watch<CampusModel>();
    // Capturar empresa
    final company = context.watch<CompanyModel>();

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Detalles del área',
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
                if (areas.statusCreation == StatusArea.editMode)
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        areas.nameC,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ]),
                if (areas.statusCreation == StatusArea.creationMode)
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
                      child: (areas.companyName.length == 1)
                          ? SizedBox(
                              width: 200,
                              child: Text(
                                areas.companyName[0],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: areas.nameC,
                                  icon: Icon(Icons.arrow_downward,
                                      color: Theme.of(context).highlightColor),
                                  elevation: 16,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.brown),
                                  onChanged: (newValue) {
                                    final c = company.fullCompanyList
                                        .where((element) =>
                                            element.name == newValue)
                                        .first;
                                    areas
                                      ..asingeNewNames(campus.campusList
                                          .where((element) =>
                                              element.companyCode ==
                                              c.companyCode)
                                          .toList())
                                      ..changeNameC(newValue!);
                                  },
                                  items: areas.companyName
                                      .map<DropdownMenuItem<String>>((value) =>
                                          DropdownMenuItem<String>(
                                              value: value, child: Text(value)))
                                      .toList(),
                                ),
                              ),
                            ),
                    ),
                  ]),
                if (areas.statusCreation == StatusArea.editMode)
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Sede (*)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        areas.campus.name!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ]),
                if (areas.statusCreation == StatusArea.creationMode)
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Sede (*)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        areas.campus.name!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      // Si solo hay una empresa, se deja el campo fijo
                      child: SizedBox(
                        width: 200,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: areas.campus.name,
                            icon: Icon(Icons.arrow_downward,
                                color: Theme.of(context).highlightColor),
                            elevation: 16,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.brown),
                            onChanged: (newValue) {
                              areas.asigneCampus(campus.campusList
                                  .where((element) => element.name == newValue)
                                  .first);
                            },
                            items: areas.campusName
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
                        initialValue: areas.createName,
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
                          areas.createName = value;
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
                      areas
                        ..asingeNewNames(campus.campusList
                            .where((element) =>
                                element.companyCode ==
                                company.currentCompany.companyCode)
                            .toList())
                        ..changeNameC(company.currentCompany.name!);
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
                        var _result = '';
                        var _success = false;
                        var _dialogText = '';
                        //print(chain);
                        // Acciones dependen si se crea o se modifica ubicación
                        if (areas.statusCreation == StatusArea.creationMode) {
                          // Se espera confirmación del usuario
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma creación del área '
                              '${areas.createName}?')) {
                            _result = await areas.saveArea(
                                areas.createName, areas.campus.id!, '');
                            if (_result.contains('agregada')) {
                              _success = true;
                              _dialogText = 'Área registrada exitosamente';
                            } else {
                              _dialogText = 'Error registrando área.\n'
                                  '$_result.\n'
                                  'Revise e intente nuevamente.';
                            }
                          }
                        } else {
                          // Se espera confirmación del usuario
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma modificación del área '
                              '${areas.createName}?')) {
                            _result = await areas.saveArea(areas.createName,
                                areas.campus.id!, areas.oldName,
                                creationMode: false);
                            if (_result.contains('modificada')) {
                              _success = true;
                              _dialogText = 'Área modificada exitosamente';
                            } else {
                              _dialogText = 'Error modificando Área.\n'
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
                                      if (areas.statusCreation ==
                                          StatusArea.creationMode) {
                                        areas.campus.areas!
                                            .add(areas.createName);
                                      } else {
                                        areas.campus.areas!
                                            .remove(areas.oldName);
                                        areas.campus.areas!
                                            .add(areas.createName);
                                      }

                                      for (var i = 0;
                                          i < campus.campusList.length;
                                          i++) {
                                        if (campus.campusList[i].id ==
                                            areas.campus.id) {
                                          campus.campusList[i] = areas.campus;
                                          break;
                                        }
                                      }
                                      campus.editDone();
                                      Navigator.popUntil(
                                        context,
                                        ModalRoute.withName('/area-page'),
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
                    child: areas.statusCreation == StatusArea.creationMode
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
