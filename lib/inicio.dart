// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// -----------------------------Inicio----------------------------------
// ---------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:provider/provider.dart';

/// Clase principal
class PagInicio extends StatelessWidget {
  ///  Class Key
  const PagInicio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'images/logo_white.png',
                fit: BoxFit.contain,
              ),
            )
          ],
        ),
        body: LoginPage(),
      );
}

/// Clase para el login
class LoginPage extends StatelessWidget {
  ///  Class Key
  LoginPage({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  // Método para crear el formulario
  @override
  Widget build(BuildContext context) {
    // Capturar información de usuario
    final user = context.watch<UserModel>();

    // Limpiar contraseña al salir de sesión
    if (user.password == '') {
      Future<void>.delayed(const Duration(milliseconds: 50)).whenComplete(() {
        user
          ..password = null
          ..editDone();
      });
    }

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Image.asset(
              'images/logo.png',
              width: 180,
              fit: BoxFit.cover,
              semanticLabel: 'Logo',
            ),
          ),
        ),
        // Formulario
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                child: const Text(
                  'Inicio de sesión',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              // Nombre de usuario
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Correo electrónico'),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp('[\n\t\r]'))
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ingrese el correo';
                        } else if (!EmailValidator.validate(value.trim())) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        user.userName = value.toLowerCase().trim();
                      },
                    ),
                  )
                ]),
              ),
              // Contraseña
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.lock,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: (user.password != '')
                        ? TextFormField(
                            obscureText: !user.visiblePassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Contraseña',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: user.visiblePassword
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  user.passwordVisibility(
                                      !user.visiblePassword);
                                },
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp('[\n\t\r]'))
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Ingrese la contraseña';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              user.password = value.trim();
                            },
                          )
                        : TextField(
                            obscureText: !user.visiblePassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Contraseña',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: user.visiblePassword
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  user.passwordVisibility(
                                      !user.visiblePassword);
                                },
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp('[\n\t\r]'))
                            ],
                            onChanged: (value) {
                              user.password = value;
                            },
                          ),
                  ),
                ]),
              ),
              // Botón de ingreso
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                alignment: Alignment.centerRight,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).highlightColor,
                  ),
                  onPressed: () async {
                    // Validar
                    if (_formKey.currentState!.validate()) {
                      // Crear usuario temporal para login
                      final loginUser = User(
                        id: '',
                        userName: user.userName,
                        name: Name(),
                        password:
                            md5.convert(utf8.encode(user.password!)).toString(),
                        externalId: '',
                        photos: [],
                        emails: [],
                        active: false,
                        company: CompanyID(),
                        roles: [],
                        helpScreens: [],
                      );
                      FocusScope.of(context).unfocus();
                      user.passwordVisibility(false);
                      // Hacer login
                      //print(jsonEncode(loginUser));
                      await user.loadUser(jsonEncode(loginUser));
                    }
                  },
                  child: const Text('Ingresar'),
                ),
              ),
            ],
          ),
        ),
        // Mensajes de inicio de sesión
        Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: const Session(),
        ),
        // Recuperar contraseña
        Center(
          child: InkWell(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              child: const Text(
                'Olvidé mi contraseña',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
            onTap: () {
              user.recoveryMessage = '';
              _recoverPassword(context);
            },
          ),
        ),
        // Versión
        Container(
          constraints: const BoxConstraints(maxWidth: 500),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 50),
          child: (henutsenAppInfo.version.isNotEmpty)
              ? Text(
                  'Versión ${henutsenAppInfo.version}',
                  style: const TextStyle(fontSize: 18),
                )
              : const Text(
                  'Detectando versión...',
                  style: TextStyle(fontSize: 18),
                ),
        ),
      ],
    );
  }

  // Método para recuperar contraseña
  Future<void> _recoverPassword(BuildContext context) async {
    var _emailToUse = '';
    await showDialog<void>(
        context: context,
        builder: (context) {
          // Capturar información de usuario
          final user = context.watch<UserModel>();
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingrese su correo electrónico registrado:',
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Correo electrónico'),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp('[\n\t\r]'))
                          ],
                          onChanged: (value) {
                            if (user.recoveryMessage.isNotEmpty) {
                              user.changeRecoveryMessage('');
                            }
                            _emailToUse = value.trim();
                          },
                        ),
                      )
                    ]),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        user.recoveryMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const Text(
                    'Recibirá un mensaje con instrucciones '
                    'para recuperar su contraseña.\n\n'
                    '¿Desea proceder?',
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).highlightColor,
                ),
                onPressed: () async {
                  // Validar primero integridad del dato
                  if (_emailToUse.isEmpty ||
                      !EmailValidator.validate(_emailToUse.trim())) {
                    user.changeRecoveryMessage(
                        'Ingrese correo electrónico válido');
                  } else {
                    // Obtener lista de usuarios
                    final result = await user.getUsersList();
                    if (result == 'Listado recibido') {
                      var _userExists = false;
                      var _userId = '';
                      var _userFullName = '';
                      for (final item in user.fullUsersList) {
                        if (item.userName! == _emailToUse) {
                          _userExists = true;
                          _userId = item.id!;
                          _userFullName = '${item.name!.givenName!} '
                              '${item.name!.familyName!}';
                          break;
                        }
                      }
                      if (_userExists) {
                        final token = user.generateToken(_userId);
                        // Armar correo de recuperación de contraseña
                        final myRecovery = PasswordRecovery(
                            userName: _emailToUse,
                            fullName: _userFullName,
                            token: token);
                        final recoveryEmail = EmailToSend(
                            to: [_emailToUse],
                            from: originEmail,
                            subject: 'Henutsen - Recuperación '
                                'de contraseña',
                            body: sendGridRecoveryTemplate,
                            client: 'henutsen',
                            passwordRecovery: myRecovery);
                        final jsonToSend = jsonEncode(recoveryEmail);
                        //print(jsonToSend);
                        unawaited(user.sendEmail(jsonToSend));
                        Navigator.of(context).pop();
                        await showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                              'Se ha enviado mensaje con instrucciones para '
                              'restablecer la contraseña a su correo '
                              'electrónico registrado.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        user.changeRecoveryMessage(
                            'No se ha encontrado registrado el correo '
                            'electrónico.\n'
                            'Por favor revise e intente de nuevo');
                      }
                    } else {
                      user.changeRecoveryMessage(
                          'Operación no disponible en el momento. '
                          'Por favor intente más tarde');
                    }
                  }
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        });
  }
}

/// Clase para procesar la sesión
class Session extends StatelessWidget {
  ///  Class Key
  const Session({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar usuario
    final user = context.watch<UserModel>();

    switch (user.status) {
      case UserStatus.idle:
        return Container();
      case UserStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case UserStatus.passwordError:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Error de contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Por favor revise sus credenciales de ingreso.')
            ],
          ),
        );
      case UserStatus.userNotAuthorized:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Usuario no autorizado.\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Por favor revise sus credenciales de ingreso.')
            ],
          ),
        );
      case UserStatus.userNotActive:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Usuario no se encuentra activo.\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Por favor revise sus credenciales de ingreso.')
            ],
          ),
        );
      case UserStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Error del servidor\n',
                textAlign: TextAlign.center,
              ),
              Text(
                'Intente de nuevo más tarde o \n'
                'contacte al administrador del sitio.',
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      case UserStatus.loaded:
        return const SessionData();
    }
  }
}

/// Clase para procesar la sesión y cargar datos restantes
class SessionData extends StatelessWidget {
  ///  Class Key
  const SessionData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    // Capturar usuario
    final user = context.watch<UserModel>();

    // Verificar si los datos del usuario ya han sido cargados
    if (user.status == UserStatus.loaded) {
      final _myCompanyId = user.currentUser.company!.id;
      company.loadCompany(_myCompanyId!);
      user.status = UserStatus.idle;
    }

    switch (company.status) {
      case CompanyStatus.idle:
        return const Center(child: Text('Cargando datos de empresa'));
      case CompanyStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CompanyStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Error del servidor\n',
                textAlign: TextAlign.center,
              ),
              Text(
                'Intente de nuevo más tarde o \n'
                'contacte al administrador del sitio.',
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      case CompanyStatus.loaded:
        if (company.currentCompany.name == null) {
          company.status = CompanyStatus.idle;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'No se encuentran datos de la empresa de este usuario.\n',
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Intente de nuevo más tarde o \n'
                  'contacte al administrador del sitio.',
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
        } else {
          // Pequeño delay
          _waitAndMove(context);
          // Obtener la información de la empresa
          user.extractUserRoles(company.currentCompany.roles!);
          _getLocations(context);
          if (company.currentCompany.locations!.isEmpty) {
            Timer(const Duration(seconds: 2), () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Información'),
                  content: Text('La empresa ${company.currentCompany.name} no'
                      ' tiene ubicaciones asociadas. Por favor créelas.'),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              );
            });
          }
          company.status = CompanyStatus.idle;
          return const Center(child: Text('Cargando menú...'));
        }
    }
  }

  /// Método para extraer sedes de la empresa seleccionada
  void _getLocations(BuildContext context) {
    // Capturar empresa
    final company = context.watch<CompanyModel>();
    // Capturar usuario
    final user = context.watch<UserModel>();
    if (company.currentCompany.locations == null) {
      return;
    }

    final listLocations = <String>[];

    for (final rolID in user.currentUser.roles!) {
      for (final rol in company.currentCompany.roles!) {
        if (rol.roleId == rolID) {
          for (final resource in rol.resources!) {
            if (company.currentCompany.locations!.contains(resource)) {
              listLocations.add(resource);
            }
          }
        }
      }
    }

    for (var i = 0; i < listLocations.length; i++) {
      if (!company.places.contains(listLocations[i])) {
        company.places.add(listLocations[i].toString());
      }
    }
  }

  // Método para pasar a la siguiente página tras un delay
  Future _waitAndMove(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await Navigator.pushNamed(context, '/menu');
  }
}
