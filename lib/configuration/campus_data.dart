// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// --------------Crear/modificar sedes------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/campus_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/location_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class CampusData extends StatelessWidget {
  ///  Class Key
  const CampusData({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.configuracion),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: CampusBody(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// Datos de ubicación
class CampusBody extends StatelessWidget {
  ///  Class Key
  CampusBody({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //capturar sede
    final campus = context.watch<CampusModel>();
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de imágenes
    final imageModel = context.watch<ImageModel>();

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Ver fotos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Fotos cargadas
                imageModel.photoContents(context),
                // Cargar fotos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'images/iconoEditarFoto.png',
                            width: 80,
                            height: 80,
                            semanticLabel: 'Editar foto',
                          ),
                          onPressed: () async {
                            final dataFileResult =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['png', 'jpg', 'jpeg'],
                              withData: true,
                            );
                            // Se obtiene respuesta de filePicker
                            if (dataFileResult != null) {
                              final data = {};
                              final dataFile = dataFileResult.files.single;
                              //print("nombre: ${dataFile.name} ");
                              if (dataFile.name[0].toLowerCase() == 'c' &&
                                  dataFile.name[1] == ':') {
                                data['name'] = dataFile.name.split('/').last;
                              } else {
                                data['name'] = dataFile.name;
                              }
                              data['path'] = dataFile.path;
                              data['bytes'] = dataFile.bytes;
                              data['size'] = dataFile.size;
                              // Para "empresa" solo aceptamos una imagen
                              // en el arreglo
                              imageModel.imageArray.clear();
                              imageModel.loadedImages.clear();
                              imageModel.allImages.clear();
                              imageModel.addPicture(PlatformFile.fromMap(data));
                            }
                          },
                        ),
                        const Text('Cargar imagen\nde logo',
                            textAlign: TextAlign.center),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Column(children: imageModel.myPictures(context)),
                    )
                  ],
                )
              ],
            ),
          ),
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Detalles de la sede',
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
                        initialValue: campus.campus.name ?? '',
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
                          campus.campus.name = value;
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
                // Fila de país
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'País (*)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 5, bottom: 15, left: 10, right: 10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              (campus.campus.addresses!.first.country!.isEmpty)
                                  ? 'Seleccione país'
                                  : campus.campus.addresses!.first.country!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    'Seleccione país',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SingleChildScrollView(
                                    child: CountryCodePicker(
                                      showDropDownButton: true,
                                      padding: EdgeInsets.zero,
                                      onChanged: (country) {
                                        campus.campus.addresses!.first.country =
                                            country.name;
                                        campus.editDone();
                                        Navigator.of(context).pop();
                                      },
                                      //initialSelection: 'CO',
                                      showCountryOnly: true,
                                      favorite: const ['CO'],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Volver'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(Icons.arrow_downward,
                                color: Theme.of(context).highlightColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Fila de departamento
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Departamento (*)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: TextFormField(
                        initialValue:
                            campus.campus.addresses!.first.region ?? '',
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
                          campus.campus.addresses!.first.region = value;
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
                // Fila de municipio
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Municipio (*)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: TextFormField(
                        initialValue:
                            campus.campus.addresses!.first.locality ?? '',
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
                          campus.campus.addresses!.first.locality = value;
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
                // Fila de dirección
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Dirección (*)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: TextFormField(
                        initialValue:
                            campus.campus.addresses!.first.streetAddress ?? '',
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
                          campus.campus.addresses!.first.streetAddress = value;
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
                    child: (campus.filterNamesC.length == 1)
                        ? SizedBox(
                            width: 200,
                            child: Text(
                              campus.filterNamesC[0],
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
                                    .map<DropdownMenuItem<String>>((value) =>
                                        DropdownMenuItem<String>(
                                            value: value, child: Text(value)))
                                    .toList(),
                              ),
                            ),
                          ),
                  ),
                ]),
                // Fila de empresa
                TableRow(children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Linea de negocio (*)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    // Si solo hay una empresa, se deja el campo fijo
                    child: (campus.filterNamesB.length == 1)
                        ? SizedBox(
                            width: 200,
                            child: Text(
                              campus.filterNamesB[0],
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
                                    .map<DropdownMenuItem<String>>((value) =>
                                        DropdownMenuItem<String>(
                                            value: value, child: Text(value)))
                                    .toList(),
                              ),
                            ),
                          ),
                  ),
                ]),
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
                      campus
                        ..filterBusiness = 'Todas'
                        ..editDone();
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
                        if (campus.filterBusiness == 'Todas') {
                          HenutsenDialogs.showSnackbar(
                              'Escoja una linea de negocio', context);
                        } else if (campus
                            .campus.addresses!.first.country!.isEmpty) {
                          HenutsenDialogs.showSnackbar(
                              'Escoja un país para la empresa', context);
                        } else {
                          var _result = '';
                          var _dialogText = '';
                          var _success = false;
                          if (campus.statusCreation == Status.editMode) {
                            // Revisar si se eliminó logo
                            if (campus.campus.logo != null &&
                                campus.campus.logo!.isNotEmpty &&
                                imageModel.loadedImages.isEmpty) {
                              campus.campus.logo = '';
                            }
                          }
                          campus.campus.companyCode = campus.filterCompanyCode;
                          campus.campus.businessLine = campus.filterBusiness;
                          _result = await campus.saveCampus(
                              campus.campus, imageModel.imageArray,
                              creation:
                                  // ignore: avoid_bool_literals_in_conditional_expressions
                                  campus.statusCreation == Status.creationMode
                                      ? true
                                      : false);

                          if (campus.statusCreation == Status.creationMode) {
                            if (_result.contains('creada')) {
                              _success = true;
                              _dialogText = 'Sede creada exitosamente';
                            } else {
                              _dialogText = 'Error creando la sede.\n'
                                  '$_result.\n'
                                  'Revise e intente nuevamente.';
                            }
                          } else {
                            if (_result.contains('modificada')) {
                              _success = true;
                              _dialogText = 'Sede modificada exitosamente';
                            } else {
                              _dialogText = 'Error modificando la sede.\n'
                                  '$_result.\n'
                                  'Revise e intente nuevamente.';
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
                                      primary: Theme.of(context).highlightColor,
                                    ),
                                    onPressed: () async {
                                      if (_success) {
                                        campus.filterBusiness = 'Todas';
                                        // Refrescar lista de empresas
                                        await campus.getListCampus();

                                        campus
                                            .asigneStatus(Status.creationMode);
                                        // ignore: use_build_context_synchronously
                                        Navigator.popUntil(
                                          context,
                                          ModalRoute.withName('/campus-page'),
                                        );
                                      } else {
                                        company.tempCompany.companyCode = null;
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: campus.statusCreation == Status.creationMode
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
