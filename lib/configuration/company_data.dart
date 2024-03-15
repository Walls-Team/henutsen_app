// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// --------------Crear/modificar empresa---------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/widgets/cdropdownlist.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class CompanyDataPage extends StatelessWidget {
  ///  Class Key
  const CompanyDataPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          await NavigationFunctions.checkLeavingPage(
            context,
            PageList.configuracion,
          );
          return true;
        },
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.configuracion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: CompanyData(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// Datos de empresa
class CompanyData extends StatelessWidget {
  ///  Class Key
  CompanyData({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de imágenes
    final imageModel = context.watch<ImageModel>();

    // Retorna campo de código GS1 (solo para creación)
    TableRow _gs1Field() {
      if (company.tempCompany.id == null) {
        return TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Código GS1',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.always,
                validator: company.validatorGs1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    RegExp('[\n\t\r]'),
                  )
                ],
                maxLength: 20,
                onChanged: (value) {
                  company.tempCompany.companyCode = value.trim();
                },
              ),
            ),
          ],
        );
      } else {
        return TableRow(children: [Container(), Container()]);
      }
    }

    // Retorna fila de activación de empresa (solo al modificar)
    TableRow _activationField() {
      if (company.tempCompany.id != null) {
        return TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '¿Empresa activa?',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            Column(
              children: [
                ListTile(
                  dense: true,
                  title: const Text('Sí'),
                  leading: Radio(
                    value: CompanyActive.active,
                    groupValue: company.tempCompanyActive,
                    onChanged: (final value) {
                      company.updateCompanyMode(value! as CompanyActive);
                    },
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('No'),
                  leading: Radio(
                    value: CompanyActive.inactive,
                    groupValue: company.tempCompanyActive,
                    onChanged: (final value) {
                      company.updateCompanyMode(value! as CompanyActive);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      } else {
        return TableRow(children: [Container(), Container()]);
      }
    }

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Datos de la empresa',
                style: Theme.of(context).textTheme.headline3),
          ),
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
          // Nota para editar
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text('Ingrese o modifique la información correspondiente\n'
                'Los campos con (*) son requeridos.'),
          ),
          // Tabla de detalles de la empresa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: _formKey,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Fila de código
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.cyan[100],
                    ),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Código de la empresa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: SizedBox(
                          width: 200,
                          child: Text(
                              company.tempCompany.companyCode ??
                                  '(Por asignar automáticamente)',
                              textAlign: TextAlign.left),
                        ),
                      ),
                    ],
                  ),
                  // Fila de nombre
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Nombre de la empresa (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: company.tempCompany.name,
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
                            company.tempCompany.name = value.trim();
                          },
                          maxLength: 50,
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
                  // Fila de NIT
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'NIT (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: company.tempCompany.externalId,
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
                            FilteringTextInputFormatter.allow(RegExp('[0-9-]'))
                          ],
                          onChanged: (value) {
                            company.tempCompany.externalId = value;
                          },
                          maxLength: 15,
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
                  // Fila de código GS1
                  _gs1Field(),
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
                              company.tempCompany.addresses?[0].streetAddress,
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
                            if (company.tempCompany.addresses!.isNotEmpty) {
                              company.tempCompany.addresses![0].streetAddress =
                                  value.trim();
                            } else {
                              company.tempCompany.addresses!.add(CompanyAddress(
                                  streetAddress: value.trim(), primary: true));
                            }
                          },
                          maxLength: 50,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                (company.tempCompanyCountry.isEmpty)
                                    ? 'Seleccione país'
                                    : company.tempCompanyCountry,
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: SingleChildScrollView(
                                      child: CountryCodePicker(
                                        showDropDownButton: true,
                                        padding: EdgeInsets.zero,
                                        onChanged: (country) {
                                          company.changeCountry(country.name!);
                                          if (company.tempCompany.addresses!
                                              .isNotEmpty) {
                                            company.tempCompany.addresses![0]
                                                .country = country.name;
                                          } else {
                                            company.tempCompany.addresses!
                                                .add(CompanyAddress(
                                              country: country.name,
                                              primary: true,
                                            ));
                                          }
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
                  // Fila de departmento
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: company.tempCompanyCountry != 'Colombia'
                            ? TextFormField(
                                initialValue: company.tempCompanyRegion,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp('[0-9\n\t\r]'))
                                ],
                                onChanged: (value) {
                                  company.tempCompanyRegion = value.trim();
                                },
                                maxLength: 50,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Ingrese dato';
                                  }
                                  return null;
                                },
                              )
                            : customDropDownList(
                                context,
                                company.changeRegion,
                                company.tempCompanyRegion,
                                company.loadRegions()),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: company.tempCompanyCountry != 'Colombia'
                            ? TextFormField(
                                initialValue: company.tempCompanyTown,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp('[0-9\n\t\r]'))
                                ],
                                onChanged: (value) {
                                  company.tempCompanyTown = value.trim();
                                },
                                maxLength: 50,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Ingrese dato';
                                  }
                                  return null;
                                },
                              )
                            : company.tempCompanyRegion != null
                                ? customDropDownList(
                                    context,
                                    company.changeTown,
                                    company.tempCompanyTown,
                                    company
                                        .loadTowns(company.tempCompanyRegion!),
                                  )
                                : TextFormField(
                                    decoration: InputDecoration(
                                      hintText: 'Seleccione departamento',
                                      fillColor:
                                          Theme.of(context).disabledColor,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                    ),
                                    readOnly: true,
                                  ),
                      ),
                    ],
                  ),
                  // Fila de activación
                  _activationField(),
                ],
              ),
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
                        if (company.tempCompanyCountry.isEmpty) {
                          HenutsenDialogs.showSnackbar(
                              'Escoja un país para la empresa', context);
                        } else if (company.tempCompanyRegion == null) {
                          HenutsenDialogs.showSnackbar(
                              'Escoja un departamento '
                              'para la empresa',
                              context);
                        } else if (company.tempCompanyTown == null) {
                          HenutsenDialogs.showSnackbar(
                              'Escoja un municipio para la empresa', context);
                        } else {
                          // Cargar departamento
                          if (company.tempCompany.addresses!.isNotEmpty) {
                            company.tempCompany.addresses![0].region =
                                company.tempCompanyRegion;
                          } else {
                            company.tempCompany.addresses!.add(CompanyAddress(
                                region: company.tempCompanyRegion,
                                primary: true));
                          }
                          // Cargar municipio
                          if (company.tempCompany.addresses!.isNotEmpty) {
                            company.tempCompany.addresses![0].locality =
                                company.tempCompanyTown;
                          } else {
                            company.tempCompany.addresses!.add(CompanyAddress(
                                locality: company.tempCompanyTown,
                                primary: true));
                          }
                          var _result = '';
                          var _dialogText = '';
                          var _success = false;
                          // Acciones dependen de si se crea o modifica empresa
                          // Si el id es nulo, se asume que estamos en creación
                          if (company.tempCompany.id == null) {
                            // Se espera confirmación del usuario
                            if (await HenutsenDialogs.confirmationMessage(
                                context,
                                '¿Confirma creación de la empresa '
                                '${company.tempCompany.name}?')) {
                              // Generar código para la empresa
                              final _cCode = getCompanyCode(
                                  context, company.tempCompany.companyCode);
                              if (_cCode == 'El código ya está registrado') {
                                HenutsenDialogs.showSnackbar(
                                    'El código GS1 ya '
                                    'está registrado',
                                    context);
                              } else {
                                // Completar datos faltantes
                                company.tempCompany
                                  ..companyCode = _cCode
                                  ..addresses![0].primary = true
                                  ..locations = []
                                  ..logo = ''
                                  ..roles = []
                                  ..active = true;
                                final jsonToSend =
                                    jsonEncode(company.tempCompany);
                                //print(jsonToSend);
                                _result = await company.newCompany(
                                    imageModel.imageArray, jsonToSend);
                                if (_result == 'Ok') {
                                  _success = true;
                                  _dialogText = 'Empresa creada exitosamente';
                                } else {
                                  _dialogText = 'Error creando empresa.\n'
                                      '$_result.\n'
                                      'Revise e intente nuevamente.';
                                }
                              }
                            }
                            // Con id no nulo, estamos en modificación
                          } else {
                            // Se espera confirmación del usuario
                            if (await HenutsenDialogs.confirmationMessage(
                                context,
                                '¿Confirma modificación de la empresa '
                                '${company.tempCompany.name}?')) {
                              final myCompany = company.tempCompany;
                              // Modificar estado activo o no si procede
                              if (company.tempCompanyActive ==
                                  CompanyActive.active) {
                                myCompany.active = true;
                              } else {
                                myCompany.active = false;
                              }
                              // Revisar que no existan empresas con mismo
                              // NIT o nombre
                              for (final item in company.fullCompanyList) {
                                if (item.name?.toLowerCase().trim() ==
                                        myCompany.name?.toLowerCase().trim() &&
                                    item.id != myCompany.id) {
                                  _result =
                                      'Ya existe otra empresa con ese nombre';
                                  break;
                                } else if (item.externalId ==
                                        myCompany.externalId &&
                                    item.id != myCompany.id) {
                                  _result =
                                      'Ya existe otra empresa con ese NIT';
                                  break;
                                }
                              }
                              // Revisar si se eliminó logo
                              if (myCompany.logo!.isNotEmpty &&
                                  imageModel.loadedImages.isEmpty) {
                                myCompany.logo = '';
                              }
                              // Si la modificación es válida, enviarla
                              if (_result.isEmpty) {
                                final chain = jsonEncode(myCompany);
                                //print(chain);
                                _result = await company.modifyCompany(
                                    imageModel.imageArray,
                                    chain,
                                    myCompany.id!);
                              }
                              if (_result == 'Ok') {
                                _success = true;
                                _dialogText = 'Empresa modificada exitosamente';
                              } else {
                                _dialogText = 'Error modificando empresa.\n'
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
                                      primary: Theme.of(context).highlightColor,
                                    ),
                                    onPressed: () async {
                                      if (_success) {
                                        // Refrescar lista de empresas
                                        await company.loadCompanies();
                                        // Refrescar datos si se afectó la
                                        // empresa actual
                                        for (var i = 0;
                                            i < company.fullCompanyList.length;
                                            i++) {
                                          if (company.fullCompanyList[i].id ==
                                              company.currentCompany.id) {
                                            company.currentCompany =
                                                company.fullCompanyList[i];
                                            break;
                                          }
                                        }
                                        company.status = CompanyStatus.idle;
                                        // ignore: use_build_context_synchronously
                                        Navigator.popUntil(
                                          context,
                                          ModalRoute.withName(
                                              '/gestion-empresas'),
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
                    child: (company.tempCompany.id == null)
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

  /// Método para generar código para la empresa
  String getCompanyCode(BuildContext context, String? gs1Field) {
    // Capturar la empresa
    final company = context.read<CompanyModel>();
    // Un código de empresa Henutsen tiene la forma xxx-yyy
    // Generar listado de consecutivos ya usados
    // Se obtiene la parte antes y después del guión por separado
    final _usedCodesX = <String>[];
    final _usedCodesY = <String>[];
    for (final item in company.fullCompanyList) {
      String _companyNumX;
      String _companyNumY;
      if (item.companyCode!.contains('-')) {
        _companyNumX = item.companyCode!.split('-').first;
        _companyNumY = item.companyCode!.split('-').last;
        _usedCodesX.add(_companyNumX);
      } else {
        _companyNumY = item.companyCode!;
      }
      _usedCodesY.add(_companyNumY);
    }
    //print(_usedCodesX);
    //print(_usedCodesY);
    // Objeto para usar la clase AssetCode
    final assetCode = AssetCode();
    _usedCodesX.add(assetCode.henutsenCompanyCode.toString());
    // Revisar si se ingresó consecutivo o no y si está efectivamente disponible
    if (gs1Field == null || gs1Field.isEmpty) {
      var _newConsecutive = 0;
      while (_usedCodesY.contains(_newConsecutive.toString())) {
        _newConsecutive++;
      }
      if (_newConsecutive > assetCode.maxCompaniesNumber - 1) {
        throw Exception('Número de empresas máximo excedido');
      }
      return '${assetCode.henutsenCompanyCode}-${_newConsecutive.toString()}';
    } else {
      if (_usedCodesX.contains(gs1Field.toString())) {
        return 'El código ya está registrado';
      } else {
        return '${gs1Field.toString()}-0';
      }
    }
  }
}
