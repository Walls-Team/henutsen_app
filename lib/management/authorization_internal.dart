// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// ------------Editar autorización de traslado---------
// ----------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/inventory_out.dart';
import 'package:henutsen_cli/provider/pendient_Authorization.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:henutsen_cli/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AuthorizationInternal extends StatelessWidget {
  ///  Class Key
  const AuthorizationInternal({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => _onBackPressed(context),
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.gestion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: BodyDataInternal(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );

  // Método para confirmar salida sin guardar cambios
  Future<bool> _onBackPressed(BuildContext context) async {
    final goBack = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Atención!'),
        content: const Text('¿Desea salir sin guardar cambios?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).highlightColor,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
    return goBack ?? false;
  }
}

/// Datos de autorización
class BodyDataInternal extends StatelessWidget {
  ///  Class Key
  BodyDataInternal({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKeyGen = GlobalKey<FormState>();
  final _formKeySearch = GlobalKey<FormState>();

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
    final _boxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.5
        : mediaSize.width * 0.4;
    // Capturar modelo de inventario
    final inventory = context.watch<InventoryOutModel>();
    // Capturar modelo de la empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de la empresa
    final user = context.watch<UserModel>();
    // Capturar modelo de traslados y autorizaciones
    final transfer = context.watch<TransferModel>();

    // Cuadro para establecer fecha de inicio de permiso
    Future<VoidCallback?> setStartDateTime(BuildContext context) async {
      final _today = DateTime.now();
      final _nextYear = _today.year + 1;
      final _pickedDate = await showDatePicker(
        context: context,
        initialDate: transfer.startDate.isEmpty
            ? _today
            : DateTime.parse(transfer.startDate),
        firstDate: transfer.startDate.isEmpty
            ? _today
            : DateTime.parse(transfer.startDate),
        lastDate: DateTime(_nextYear),
      );
      if (_pickedDate != null) {
        final _pickedTime = await showTimePicker(
            context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));

        if (_pickedTime != null) {
          final _selectedInitalDateTime = DateTime(
              _pickedDate.year,
              _pickedDate.month,
              _pickedDate.day,
              _pickedTime.hour,
              _pickedTime.minute);
          final _currentEndDateTime = transfer.endDate;
          if (_currentEndDateTime.isNotEmpty) {
            if (DateTime.parse(_currentEndDateTime)
                .isBefore(_selectedInitalDateTime)) {
              transfer.endDate = '';
            }
          }
          transfer
            ..permanentAuthorization = false
            ..changeStartDate(
                DateFormat('yyyy-MM-dd HH:mm').format(_selectedInitalDateTime));
          transfer.currentAuthorization.authorizedStartDate =
              transfer.startDate;
        }
      }
    }

    // Cuadro para establecer fecha de fin de permiso
    Future<VoidCallback?> setEndDateTime(BuildContext context) async {
      if (transfer.startDate.isEmpty) {
        HenutsenDialogs.showSnackbar(
            'Seleccione primero la fecha de inicio de '
            'la autorización',
            context);
      } else {
        final _today = DateTime.now();
        final _nextYear = _today.year + 1;
        final _pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(transfer.startDate),
          firstDate: DateTime.parse(transfer.startDate),
          lastDate: DateTime(_nextYear),
        );
        if (_pickedDate != null) {
          final _pickedTime = await showTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 9, minute: 0),
          );
          if (_pickedTime != null) {
            final _currentInitDateTime = DateTime.parse(transfer.startDate);
            if (_pickedTime.hour >= _currentInitDateTime.hour ||
                (_pickedTime.hour == _currentInitDateTime.hour &&
                    _pickedTime.minute >= _currentInitDateTime.minute) ||
                (_pickedDate.day == _currentInitDateTime.day &&
                    (_pickedTime.hour == _currentInitDateTime.hour ||
                        _pickedTime.hour > _currentInitDateTime.hour) &&
                    _pickedTime.minute > _currentInitDateTime.minute) ||
                _pickedDate.day != _currentInitDateTime.day) {
              final _selectedEndDateTime = DateTime(
                  _pickedDate.year,
                  _pickedDate.month,
                  _pickedDate.day,
                  _pickedTime.hour,
                  _pickedTime.minute);
              transfer
                ..permanentAuthorization = false
                ..changeEndDate(DateFormat('yyyy-MM-dd HH:mm')
                    .format(_selectedEndDateTime));
              transfer.currentAuthorization.authorizedEndDate =
                  transfer.endDate;
            } else {
              HenutsenDialogs.showSnackbar(
                  'Seleccione una hora mayor a la hora de inicio '
                  'de la autorización',
                  context);
            }
          }
        }
      }
    }

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Solicitar autorización',
                style: Theme.of(context).textTheme.headline3),
          ),
          // Nota de campos requeridos
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('Los campos con (*) son requeridos.'),
          ),
          // Tabla de detalles de la autorización
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: _formKeyGen,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Fecha de inicio (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: _boxWidth * 0.5,
                              child: Text(
                                transfer.startDate.isNotEmpty
                                    ? transfer.startDate
                                    : 'No se ha seleccionado una fecha',
                              ),
                            ),
                            IconButton(
                              onPressed: () async => setStartDateTime(context),
                              icon: const Icon(Icons.calendar_today),
                              color: Theme.of(context).primaryColor,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Fecha de finalización (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: _boxWidth * 0.5,
                              child: Text(
                                transfer.endDate.isNotEmpty
                                    ? transfer.endDate
                                    : 'No se ha seleccionado una fecha',
                              ),
                            ),
                            IconButton(
                              onPressed: () async => setEndDateTime(context),
                              icon: const Icon(Icons.calendar_today),
                              color: Theme.of(context).primaryColor,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  // Fila de ubicación adonde trasladar
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: 70,
                        child: Text(
                          'Ubicación adonde se trasladarán los activos',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _menuBoxWidth,
                      child: Container(
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
                          value: transfer.transferLocation,
                          icon: Icon(Icons.arrow_downward,
                              color: Theme.of(context).highlightColor),
                          elevation: 16,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.brown),
                          onChanged: (newValue) {
                            transfer.changeTransferLocation(newValue!);
                          },
                          items: company.currentCompany.locations!
                              .map<DropdownMenuItem<String>>(
                                  (value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: SizedBox(
                                          width: _menuWidth,
                                          child: Text(value),
                                        ),
                                      ))
                              .toList(),
                        ),
                      ),
                    ),
                  ]),
                  // Fila de responsable
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Responsable (*)',
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
                          value: transfer.currentAuthorization.person,
                          icon: Icon(Icons.arrow_downward,
                              color: Theme.of(context).highlightColor),
                          elevation: 16,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.brown),
                          onChanged: (newValue) {
                            transfer.changeCustody(newValue!);
                          },
                          items: user.localUsersList
                              .map<DropdownMenuItem<String>>((value) =>
                                  DropdownMenuItem<String>(
                                      value: value, child: Text(value)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
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
                      HenutsenDialogs().showAlertDialog(
                        context,
                        '¿Desea volver sin solicitar la autorización?',
                        () => Navigator.of(context).pop(),
                        () => Navigator.popUntil(
                          context,
                          ModalRoute.withName('/asset-internal'),
                        ),
                      );
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
                        if (inventory.assetsId.isEmpty) {
                          HenutsenDialogs.showSnackbar(
                              'No tiene activos asociados ', context);
                        } else if (!transfer.permanentAuthorization &&
                            (transfer.currentAuthorization
                                        .authorizedStartDate ==
                                    null ||
                                transfer.currentAuthorization
                                        .authorizedEndDate ==
                                    null ||
                                transfer.startDate.isEmpty ||
                                transfer.endDate.isEmpty)) {
                          HenutsenDialogs.showSnackbar(
                              'Seleccione un rango de fecha válido '
                              'para la autorización',
                              context);
                        } else {
                          // Si todo está bien
                          HttpHenutsenResponse _result;
                          var _dialogText = '';
                          var _success = false;
                          // Manejo de permiso permanente
                          transfer.currentAuthorization.isPermanent =
                              transfer.permanentAuthorization;
                          transfer.currentAuthorization.transferLocation =
                              transfer.transferLocation == 'No aplica'
                                  ? ''
                                  : transfer.transferLocation;
                          // Acciones dependen de si se crea o modifica
                          // la autorización.
                          // Si el id es nulo, se asume que estamos en creación
                          // Asignar número de autorización
                          final _numbersList = <int>[];
                          for (final item in transfer.authorizationsList) {
                            _numbersList.add(item.number!);
                          }
                          _numbersList.sort();
                          final _newAuthNumber = _numbersList.isNotEmpty
                              ? _numbersList.last + 1
                              : 1;
                          // Se espera confirmación del usuario
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma la solicitud de la autorización:\n'
                              '$_newAuthNumber?')) {
                            unawaited(Loading.showLoadingStatus(context));
                            // Capturar info adicional de empresa
                            final _cCode = company.currentCompany.companyCode;
                            // Agregar datos restantes al activo a crear
                            transfer.currentAuthorization
                              ..assets = inventory.assetsId
                              ..companyCode = _cCode
                              ..supervisor =
                                  '${user.currentUser.name?.givenName}'
                                      ' ${user.currentUser.name?.familyName} '
                                      '(${user.currentUser.userName})'
                              ..number = _newAuthNumber
                              ..person = transfer.currentAuthorization.person
                              ..dateIssued = DateTime.now().toString()
                              ..revoked = false;
                            final jsonToSend =
                                jsonEncode(transfer.currentAuthorization);
                            //print(jsonToSend);
                            _result =
                                await transfer.newAuthorization(jsonToSend);
                            if (_result.statusCode == 201 && !_result.error!) {
                              _success = true;
                              _dialogText = _result.message!;
                            } else {
                              final _extraMessage =
                                  _result.message ?? 'Error del servidor';
                              _dialogText = 'Error creando autorización.\n'
                                  '$_extraMessage';
                            }
                            Loading.closeLoading(context);
                            if (_dialogText.isNotEmpty) {
                              await showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  content: SingleChildScrollView(
                                    child: Text(
                                      _dialogText,
                                      style:
                                          Theme.of(context).textTheme.headline3,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary:
                                            Theme.of(context).highlightColor,
                                      ),
                                      onPressed: () async {
                                        if (_success) {
                                          transfer.clearAuthorizationList();
                                          inventory.clearTagList();
                                          inventory.assetsId.clear();
                                          await transfer.getAuthorizations(
                                              company
                                                  .currentCompany.companyCode!);
                                          transfer.editDone();
                                          Navigator.popUntil(
                                            context,
                                            ModalRoute.withName(
                                                '/asset-internal'),
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
                        }
                      },
                      child: const Text('Solicitar\nautorización')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
