// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// --------------Crear/modificar usuario---------------
// ----------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class UserDataPage extends StatelessWidget {
  ///  Class Key
  const UserDataPage({Key? key}) : super(key: key);
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
          body: UserData(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// Datos del usuario
class UserData extends StatelessWidget {
  ///  Class Key
  UserData({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  // Arreglo para almacenar los roles
  final _roles = <String>[];

  @override
  Widget build(BuildContext context) {
    // Capturar el modelo del usuario
    final user = context.watch<UserModel>();
    // Capturar modelo de la empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de imágenes
    final imageModel = context.watch<ImageModel>();
    String? _companyToShow;
    // Llenar lista de empresas
    final _companyNames = <String>[];
    for (final item in company.fullCompanyList) {
      _companyNames.add(item.name!);
      // Capturar empresa actual del usuario
      if (user.tempCompanyID == item.id) {
        _companyToShow = item.name;
      }
    }

    // Cargar roles disponibles para esta empresa
    for (final item in company.fullCompanyList) {
      if (user.tempCompany == item.name) {
        _roles.clear();
        for (final subitem in item.roles!) {
          // Solo se pueden ver roles iguales o menores
          // al del usuario actual
          _roles.add(subitem.name!);
        }
        break;
      }
    }

    // Nombre a mostrar
    var _nameToShow = '';
    if (user.tempUser.name?.givenName != null &&
        user.tempUser.name?.givenName != '') {
      _nameToShow = user.tempUser.name!.givenName!;
    }
    if (user.tempUser.name?.middleName != null &&
        user.tempUser.name?.middleName != '') {
      _nameToShow += ' ${user.tempUser.name!.middleName!}';
    }
    // Apellido a mostrar
    var _lastNameToShow = '';
    if (user.tempUser.name?.familyName != null &&
        user.tempUser.name?.familyName != '') {
      _lastNameToShow = user.tempUser.name!.familyName!;
    }
    if (user.tempUser.name?.additionalFamilyNames != null &&
        user.tempUser.name?.additionalFamilyNames != '') {
      _lastNameToShow += ' ${user.tempUser.name!.additionalFamilyNames!}';
    }
    // Documento a mostrar
    if (user.tempUser.externalId != null) {
      if (user.tempUser.externalId!.contains('-')) {
        final _shortDocType = user.tempUser.externalId!.substring(
          0,
          user.tempUser.externalId!.indexOf('-'),
        );
        if (_shortDocType == 'CC') {
          user.docType = user.documentType[0];
        } else if (_shortDocType == 'CE') {
          user.docType = user.documentType[1];
        } else if (_shortDocType == 'TI') {
          user.docType = user.documentType[2];
        }
        user.docNum = user.tempUser.externalId!.substring(
          user.tempUser.externalId!.indexOf('-') + 1,
        );
      }
    }

    // Retorna fila de activación de empresa (solo al modificar)
    TableRow _activationField() {
      if (user.tempUser.id != null) {
        return TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '¿Usuario activo?',
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
                    value: UserActive.active,
                    groupValue: user.tempUserActive,
                    onChanged: (value) {
                      user.updateUserMode(value! as UserActive);
                    },
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('No'),
                  leading: Radio(
                    value: UserActive.inactive,
                    groupValue: user.tempUserActive,
                    onChanged: (value) {
                      user.updateUserMode(value! as UserActive);
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
            child: Text('Detalles del usuario',
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
                              // Para "usuario" solo aceptamos una imagen
                              // en el arreglo
                              imageModel.imageArray.clear();
                              imageModel.loadedImages.clear();
                              imageModel.allImages.clear();
                              imageModel.addPicture(PlatformFile.fromMap(data));
                            }
                          },
                        ),
                        const Text('Cargar imagen', textAlign: TextAlign.center)
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Column(
                        children: imageModel.myPictures(context),
                      ),
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
          // Tabla de detalles del usuario
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
                  // Fila de nombre
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Nombre(s) (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: _nameToShow,
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
                                RegExp('[0-9\n\t\r]'))
                          ],
                          onChanged: (value) {
                            // Separar nombres
                            if (value.contains(' ')) {
                              user.tempUser.name!.givenName = value.substring(
                                0,
                                value.indexOf(' '),
                              );
                              user.tempUser.name!.middleName = value.substring(
                                value.indexOf(' ') + 1,
                              );
                            } else {
                              user.tempUser.name!.givenName = value;
                              user.tempUser.name!.middleName = '';
                            }
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
                  // Fila de apellido
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Apellido(s) (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: _lastNameToShow,
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
                                RegExp('[0-9\n\t\r]'))
                          ],
                          onChanged: (value) {
                            // Separar apellidos
                            if (value.contains(' ')) {
                              user.tempUser.name!.familyName = value.substring(
                                0,
                                value.indexOf(' '),
                              );
                              user.tempUser.name!.additionalFamilyNames =
                                  value.substring(
                                value.indexOf(' ') + 1,
                              );
                            } else {
                              user.tempUser.name!.familyName = value;
                              user.tempUser.name!.additionalFamilyNames = '';
                            }
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
                  // Fila de tipo de documento
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Tipo de documento',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
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
                            value: user.docType,
                            icon: Icon(Icons.arrow_downward,
                                color: Theme.of(context).highlightColor),
                            elevation: 16,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.brown),
                            onChanged: (newValue) {
                              user.changeDocType(newValue!);
                            },
                            items: user.documentType
                                .map<DropdownMenuItem<String>>((value) =>
                                    DropdownMenuItem<String>(
                                        value: value, child: Text(value)))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Fila de documento
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Documento de identidad',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: user.docNum,
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
                                RegExp('[A-Za-z\n\t\r]'))
                          ],
                          onChanged: (value) {
                            user.docNum = value;
                          },
                          maxLength: 15,
                        ),
                      ),
                    ],
                  ),
                  // Fila de codigo carnet
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Código de carnet(*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: user.tempUser.codeCarnet ?? '',
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
                                RegExp('[A-Za-z\n\t\r]'))
                          ],
                          onChanged: (value) {
                            user.tempUser.codeCarnet = value;
                          },
                          maxLength: 15,
                        ),
                      ),
                    ],
                  ),
                  // Fila de correo electrónico
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Correo electrónico (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: (user.tempUser.id == null)
                              ? null
                              : Theme.of(context).disabledColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: TextFormField(
                          initialValue: user.tempUser.userName,
                          readOnly: user.tempUser.id != null,
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
                            user.tempUser.userName = value.toLowerCase();
                          },
                          maxLength: 50,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Ingrese dato';
                            } else if (!EmailValidator.validate(value)) {
                              return 'Ingrese un correo válido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  // Fila de contraseña
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Contraseña (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: user.tempPassword,
                          obscureText: !user.visiblePassword,
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
                            labelText: (user.tempUser.password == null)
                                ? ''
                                : 'Cambiar contraseña',
                            suffixIconConstraints: const BoxConstraints(),
                            suffixIcon: IconButton(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: user.visiblePassword
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                user.passwordVisibility(!user.visiblePassword);
                              },
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp('[\n\t\r]'))
                          ],
                          onChanged: (value) {
                            if (value.length >= 3) {
                              user.tempPassword = value;
                            } else {
                              user.tempPassword = '';
                            }
                          },
                          maxLength: 15,
                          validator: (value) {
                            if (value!.isEmpty && user.tempUser.id == null) {
                              return 'Ingrese dato';
                            } else if (value.isNotEmpty &&
                                (user.tempPassword.length < 3 ||
                                    user.tempPassword.length > 15)) {
                              return 'Ingrese contraseña de 3 a 15 caracteres';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  // Fila de empresa
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Empresa (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _companyToShow,
                          icon: Icon(Icons.arrow_downward,
                              color: Theme.of(context).highlightColor),
                          elevation: 16,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.brown),
                          onChanged: (newValue) {
                            var _validChange = true;
                            for (final item in company.fullCompanyList) {
                              if (newValue == item.name) {
                                user.tempCompanyID = item.id;
                                // Solo aceptar empresas activas
                                if (item.active != true) {
                                  _validChange = false;
                                }
                                break;
                              }
                            }
                            if (_validChange) {
                              user.changeCompany(newValue);
                            } else {
                              HenutsenDialogs.showSnackbar(
                                  'Solo puede asignar usuarios a '
                                  'empresas activas',
                                  context);
                            }
                          },
                          items: _companyNames
                              .map<DropdownMenuItem<String>>((value) =>
                                  DropdownMenuItem<String>(
                                      value: value, child: Text(value)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  // Fila de rol
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Rol (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: user.tempRole,
                          icon: Icon(Icons.arrow_downward,
                              color: Theme.of(context).highlightColor),
                          elevation: 16,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.brown),
                          onChanged: user.changeRole,
                          items: _roles
                              .map<DropdownMenuItem<String>>(
                                (value) => DropdownMenuItem<String>(
                                  value: value,
                                  child:
                                      SizedBox(width: 150, child: Text(value)),
                                ),
                              )
                              .toList(),
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
                        var _result = '';
                        var _dialogText = '';
                        var _success = false;
                        // Verificar si el usuario modificado es el mismo actual
                        var _isCurrentUser = false;
                        if (user.tempUser.userName ==
                            user.currentUser.userName) {
                          _isCurrentUser = true;
                        }
                        // Manipular documento
                        var _fullDoc = '';
                        if (user.docNum.isNotEmpty) {
                          if (user.docType == 'Cédula de ciudadanía') {
                            _fullDoc = 'CC-${user.docNum}';
                          } else if (user.docType == 'Cédula de extranjería') {
                            _fullDoc = 'CE-${user.docNum}';
                          } else if (user.docType == 'Tarjeta de identidad') {
                            _fullDoc = 'TI-${user.docNum}';
                          }
                        }
                        user.tempUser.externalId = _fullDoc;
                        // Acciones dependen de si se crea o modifica el usuario
                        // Si el id es nulo, se asume que estamos en creación
                        if (user.tempUser.id == null) {
                          // Se espera confirmación del usuario
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma creación del usuario '
                              '${user.tempUser.userName}?')) {
                            if (user.tempCompany == null) {
                              HenutsenDialogs.showSnackbar(
                                  'Seleccione una '
                                  'empresa',
                                  context);
                            } else if (user.tempRole == null) {
                              HenutsenDialogs.showSnackbar(
                                  'Seleccione un '
                                  'rol',
                                  context);
                            } else {
                              // Completar datos del usuario
                              user.tempUser
                                ..company = CompanyID(id: user.tempCompanyID)
                                ..photos = []
                                ..emails = [
                                  Email(
                                      value: user.tempUser.userName,
                                      type: 'work',
                                      primary: true),
                                ]
                                ..password = md5
                                    .convert(utf8.encode(user.tempPassword))
                                    .toString()
                                ..active = true
                                ..helpScreens = [];
                              // Asociar rol
                              for (final comp in company.fullCompanyList) {
                                if (user.tempUser.company?.id == comp.id) {
                                  for (final item in comp.roles!) {
                                    if (user.tempRole == item.name) {
                                      user.tempUser.roles = [item.roleId!];
                                      break;
                                    }
                                  }
                                }
                              }
                              final jsonToSend = jsonEncode(user.tempUser);
                              //print(jsonToSend);
                              _result = await user.newUser(
                                  imageModel.imageArray, jsonToSend);
                              if (_result == 'Ok') {
                                _success = true;
                                _dialogText = 'Usuario creado exitosamente';
                              } else {
                                _dialogText = 'Error creando usuario.\n'
                                    '$_result.\n'
                                    'Revise e intente nuevamente.';
                              }
                            }
                          }
                          // Si el id no es nulo, estamos en modificación
                        } else {
                          // Se espera confirmación del usuario
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma modificación del usuario '
                              '${user.tempUser.userName}?')) {
                            final myUser = user.tempUser;
                            // Modificar estado activo de usuario si procede
                            if (user.tempUserActive == UserActive.active) {
                              myUser.active = true;
                            } else {
                              myUser.active = false;
                            }
                            // Asignar contraseña si se cambió
                            if (user.tempPassword.isNotEmpty) {
                              user.tempUser.password = md5
                                  .convert(utf8.encode(user.tempPassword))
                                  .toString();
                            }
                            // Asignar correo
                            myUser.emails = [
                              Email(
                                  value: user.tempUser.userName,
                                  type: 'work',
                                  primary: true)
                            ];
                            myUser.company!.id = user.tempCompanyID;
                            if (myUser.roles!.isNotEmpty) {
                              myUser.roles?.first = user.tempRole!;
                            } else {
                              for (final comp in company.fullCompanyList) {
                                if (user.tempUser.company?.id == comp.id) {
                                  myUser.roles?.add(comp.roles!.first.name!);
                                }
                              }
                            }

                            // Asociar rol
                            for (final comp in company.fullCompanyList) {
                              if (user.tempUser.company?.id == comp.id) {
                                for (final item in comp.roles!) {
                                  if (user.tempRole == item.name) {
                                    myUser.roles?.first = item.roleId!;
                                    break;
                                  }
                                }
                              }
                            }
                            // Revisar si se eliminó avatar
                            if (myUser.photos!.isNotEmpty &&
                                imageModel.loadedImages.isEmpty) {
                              myUser.photos!.clear();
                            }
                            final chain = jsonEncode(myUser);
                            //print(chain);
                            _result = await user.modifyUser(
                                imageModel.imageArray, chain, myUser.id!);
                            if (_result == 'Ok') {
                              _success = true;
                              _dialogText = 'Usuario modificado exitosamente';
                            } else {
                              _dialogText = 'Error modificando usuario.\n'
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
                                    style:
                                        Theme.of(context).textTheme.headline3),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).highlightColor,
                                  ),
                                  onPressed: () async {
                                    if (_success) {
                                      // Obtener lista de usuarios
                                      await user.getUsersList();
                                      // Actualizar algunos campos adicionales
                                      // si se modificó el usuario actual
                                      if (_isCurrentUser) {
                                        for (var i = 0;
                                            i < user.fullUsersList.length;
                                            i++) {
                                          if (user.currentUser.id ==
                                              user.fullUsersList[i].id) {
                                            user
                                              ..currentUser =
                                                  user.fullUsersList[i]
                                              ..extractUserRoles(company
                                                  .currentCompany.roles!);
                                            final _n1 = user
                                                .currentUser.name!.givenName;
                                            final _n2 = user
                                                .currentUser.name!.familyName;
                                            final _newName2show = '$_n1 $_n2';
                                            user.changeName(_newName2show);
                                            break;
                                          }
                                        }
                                      }
                                      // Reiniciar rol asociado
                                      user
                                        ..changeRole(null)
                                        // Reiniciar empresa asociada
                                        ..changeCompany(null);
                                      // Armar y enviar bienvenida
                                      // (solo usuarios nuevos)
                                      if (_dialogText ==
                                          'Usuario creado exitosamente') {
                                        final _n1 =
                                            user.tempUser.name!.givenName;
                                        final _n2 =
                                            user.tempUser.name!.familyName;
                                        final myWelcome = HenutsenWelcome(
                                            company: _companyToShow,
                                            userName: user.tempUser.userName,
                                            fullName: '$_n1 $_n2');
                                        final welcomeEmail = EmailToSend(
                                            to: [user.tempUser.userName!],
                                            from: originEmail,
                                            subject: 'Bienvenida Henutsen',
                                            body: sendGridWelcomeTemplate,
                                            client: 'henutsen',
                                            henutsenWelcome: myWelcome);
                                        final jsonToSend =
                                            jsonEncode(welcomeEmail);
                                        unawaited(user.sendEmail(jsonToSend));
                                      }
                                      Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                            '/gestion-usuarios'),
                                      );
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                    // Contraseña no visible por defecto
                                    if (user.visiblePassword) {
                                      user.passwordVisibility(false);
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
                    child: (user.tempUser.id == null)
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
