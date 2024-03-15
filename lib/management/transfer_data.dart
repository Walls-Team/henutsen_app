// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// --------Información de traslado de activos----------
// ----------------------------------------------------
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/pendient_Authorization.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class TransferDataPage extends StatelessWidget {
  ///  Class Key
  const TransferDataPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.gestion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: const TransferData(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

/// Datos del activo
class TransferData extends StatelessWidget {
  ///  Class Key
  const TransferData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Leemos cambios en el modelo de autorizaciones
    final transfer = context.watch<PendientModel>();
    // Capturar modelo de traslados y autorizaciones
    final authorization = context.watch<TransferModel>();
    // Capturar modelo de traslados y autorizaciones
    final company = context.watch<CompanyModel>();
    // Capturar modelo de traslados y autorizaciones
    final user = context.watch<UserModel>();
    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Autorizaciones solicitadas',
                style: Theme.of(context).textTheme.headline3),
          ),
          if (transfer.authorizationsList.length > 1)
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).highlightColor,
                ),
                onPressed: () async {
                  HttpHenutsenResponse _result;
                  var _dialogText = '';
                  var _success = false;
                  final listToSend = <Authorization>[];
                  // Guardar en lista para visualización
                  final transfers2show = transfer.authorizationsList;
                  var _number = authorization.authorizationsList.length;
                  for (var i = 0; i < transfers2show.length; i++) {
                    listToSend.add(Authorization(
                        assets: transfers2show[i].assets,
                        authorizedEndDate: transfers2show[i].authorizedEndDate,
                        authorizedStartDate:
                            transfers2show[i].authorizedStartDate,
                        companyCode: transfers2show[i].companyCode,
                        dateIssued: transfers2show[i].dateIssued,
                        id: transfers2show[i].id,
                        isPermanent: transfers2show[i].isPermanent,
                        number: _number + 1,
                        person: transfers2show[i].person,
                        revoked: transfers2show[i].revoked,
                        supervisor: '${user.currentUser.name?.givenName}'
                            ' ${user.currentUser.name?.familyName} '
                            '(${user.currentUser.userName})',
                        transferLocation: transfers2show[i].transferLocation));
                    _number++;
                  }

                  final jsonToSend = jsonEncode(listToSend);
                  //print(jsonToSend);
                  _result = await authorization.newAuthorizations(jsonToSend);
                  if (_result.statusCode == 201 && !_result.error!) {
                    _success = true;
                    _dialogText = _result.message!;
                  } else {
                    final _extraMessage =
                        _result.message ?? 'Error del servidor';
                    _dialogText = 'Error creando las autorizaciones.\n'
                        '$_extraMessage';
                  }

                  if (_dialogText.isNotEmpty) {
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: false,
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
                                await authorization.getAuthorizations(
                                    company.currentCompany.companyCode!);
                                authorization.editDone();
                                Navigator.popUntil(
                                  context,
                                  ModalRoute.withName('/traslado-activos'),
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
                },
                child: const Text('Aceptar todas'),
              ),
            ),

          const SizedBox(
            height: 10,
          ),
          const InfoToShow(),
          // Botones
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón de volver
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      NavigationFunctions.checkLeavingPage(
                          context, PageList.gestion);
                      Navigator.pop(context);
                    },
                    child: const Text('Volver'),
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

/// Clase para devolver la información de traslados de activos
class InfoToShow extends StatelessWidget {
  /// Class Key
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Leemos cambios en el modelo de autorizaciones
    final transfer = context.watch<PendientModel>();
    // Capturar modelo de inventario
    final inventory = context.watch<InventoryModel>();
    // Capturar modelo de traslados y autorizaciones
    final authorization = context.watch<TransferModel>();
    // Capturar modelo de traslados y autorizaciones
    final company = context.watch<CompanyModel>();

    // Capturar modelo de traslados y autorizaciones
    final user = context.watch<UserModel>();

    // Presentamos lista de traslados
    if (transfer.authorizationsList.isNotEmpty) {
      final list2show = <TableRow>[];

      // Guardar en lista para visualización
      final transfers2show = transfer.authorizationsList;

      for (var i = 0; i < transfers2show.length; i++) {
        // Color para diferenciar movimientos
        final _myColor = transfers2show[i].status == 'Pendiente'
            ? Colors.orange
            : Colors.red;
        // Fila de la tabla a presentar
        list2show.add(
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey[300],
            ),
            children: [
              Text(
                (i + 1).toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: _myColor),
              ),
              SizedBox(
                width: 150,
                child: Text(
                  transfers2show[i].person ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _myColor),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        content: SingleChildScrollView(
                          child: Column(
                            children: transfers2show[i].assets!.map((e) {
                              final viewNameAsset = inventory.fullInventory
                                  .where((a) => a.assetCode == e)
                                  .first;
                              return Text(
                                  'Nombre: ${viewNameAsset.name!}\n'
                                  'Descripción: ${viewNameAsset.description!}\n'
                                  'Fecha de inicio: ${transfers2show[i].authorizedStartDate!}\n '
                                  'Fecha fin: ${transfers2show[i].authorizedEndDate!}',
                                  style: const TextStyle(
                                      fontSize: 17, color: Colors.black));
                            }).toList(),
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              primary: Theme.of(context).primaryColor,
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    color: Theme.of(context).primaryColor,
                  )),
              IconButton(
                  onPressed: () async {
                    HttpHenutsenResponse _result;
                    var _dialogText = '';
                    var _success = false;
                    authorization.currentAuthorization = Authorization(
                        assets: transfers2show[i].assets,
                        authorizedEndDate: transfers2show[i].authorizedEndDate,
                        authorizedStartDate:
                            transfers2show[i].authorizedStartDate,
                        companyCode: transfers2show[i].companyCode,
                        dateIssued: transfers2show[i].dateIssued,
                        id: transfers2show[i].id,
                        isPermanent: transfers2show[i].isPermanent,
                        number: authorization.authorizationsList.length + 1,
                        person: transfers2show[i].person,
                        revoked: transfers2show[i].revoked,
                        supervisor: '${user.currentUser.name?.givenName}'
                            ' ${user.currentUser.name?.familyName} '
                            '(${user.currentUser.userName})',
                        transferLocation: transfers2show[i].transferLocation);
                    final jsonToSend =
                        jsonEncode(authorization.currentAuthorization);
                    //print(jsonToSend);
                    _result = await authorization.newAuthorization(jsonToSend);
                    if (_result.statusCode == 201 && !_result.error!) {
                      _success = true;
                      _dialogText = _result.message!;
                    } else {
                      final _extraMessage =
                          _result.message ?? 'Error del servidor';
                      _dialogText = 'Error creando autorización.\n'
                          '$_extraMessage';
                    }
                    if (_dialogText.isNotEmpty) {
                      await showDialog<void>(
                        context: context,
                        barrierDismissible: false,
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
                                  final _itemsToSend = <String, dynamic>{
                                    'AuthorizationId': transfers2show[i].id!,
                                    'UserName': user.currentUser.userName
                                  };
                                  final _encoded = jsonEncode(_itemsToSend);
                                  await authorization.getAuthorizations(
                                      company.currentCompany.companyCode!);
                                  await transfer.deleteAuthorization(_encoded);

                                  authorization.editDone();
                                  Navigator.popUntil(
                                    context,
                                    ModalRoute.withName('/traslado-activos'),
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
                  },
                  icon: Icon(
                    Icons.done,
                    color: Theme.of(context).primaryColor,
                  )),
              IconButton(
                  onPressed: () async {
                    if (await HenutsenDialogs.confirmationMessage(
                        context,
                        '¿Está seguro de rechazar la autorización:\n'
                        'del usuario ${transfers2show[i].person}?')) {
                      // Si todo está bien
                      HttpHenutsenResponse _result;
                      var _dialogText = '';
                      var _success = false;
                      transfers2show[i].status = 'Rechazada';
                      final jsonToSend = jsonEncode(transfers2show[i]);
                      _result = await transfer.modifyAuthorization(jsonToSend);
                      if (_result.statusCode == 200 && !_result.error!) {
                        _success = true;
                        _dialogText = _result.message!;
                      } else {
                        final _extraMessage =
                            _result.message ?? 'Error del servidor';
                        _dialogText = 'Error rechazando autorización.\n'
                            '$_extraMessage';
                      }
                      if (_dialogText.isNotEmpty) {
                        await showDialog<void>(
                          context: context,
                          barrierDismissible: false,
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
                                    // Actualizar autorizaciones
                                    await transfer.getAuthorizations(
                                        company.currentCompany.companyCode!);
                                    transfer.editDone();
                                    Navigator.of(context).pop();
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
                  icon: Icon(
                    Icons.close_outlined,
                    color: Theme.of(context).primaryColor,
                  )),
              IconButton(
                  onPressed: () async {
                    if (await HenutsenDialogs.confirmationMessage(
                        context,
                        '¿Está seguro de eliminar la autorización:\n'
                        'del usuario ${transfers2show[i].person}?')) {
                      // Si todo está bien
                      final _itemsToSend = <String, dynamic>{
                        'AuthorizationId': transfers2show[i].id!,
                        'UserName': user.currentUser.userName
                      };
                      final _encoded = jsonEncode(_itemsToSend);
                      await transfer.deleteAuthorization(_encoded);
                      await transfer.getAuthorizations(
                          company.currentCompany.companyCode!);
                      transfer.editDone();
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  )),
            ],
          ),
        );
      }

      // Fila de título
      final titlesRow = TableRow(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: const Text(
              'No.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: const Text(
              'Persona a cargo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: const Text(
              'Activo(s)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: const Text(
              'Aprobar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: const Text(
              'Rechazar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );

      return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          // Tabla de movimientos
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [titlesRow, ...list2show]),
          ));
    } else {
      return const Center(
        child: Text('No hay información de traslados.'),
      );
    }
  }

  /// Preparar correo de confirmación al autorizador
  Map<String, dynamic> makeEmailToSend(
      TransferModel transfer, String username) {
    final _selectedLocation = transfer.transferLocation == 'No aplica'
        ? 'de salida'
        : 'de traslado a ${transfer.transferLocation}';
    final _number = transfer.authorizationsList.isNotEmpty
        ? transfer.authorizationsList.length + 1
        : 1;
    final emailToSend = <String, dynamic>{
      'To': List.from([username]),
      'From': Config.originEmail,
      'Subject': 'Autorización de salida #$_number',
      'Body': Config.bodyTemplate,
      'Client': 'henutsen',
      'Authorization': {
        'Type': _selectedLocation,
        'Number': _number.toString(),
        'Items': transfer.authorizedAssetsList,
      }
    };
    return emailToSend;
  }

  /// Preparar correo de confirmación al autorizador
  Map<String, dynamic> makeEmailRejectToSend(
      TransferModel transfer, String username) {
    final _selectedLocation = transfer.transferLocation == 'No aplica'
        ? 'de salida'
        : 'de traslado a ${transfer.transferLocation}';
    final _number = transfer.authorizationsList.isNotEmpty
        ? transfer.authorizationsList.length + 1
        : 1;
    final emailToSend = <String, dynamic>{
      'To': List.from([username]),
      'From': Config.originEmail,
      'Subject': 'Rechazada la autorización #$_number',
      'Body': Config.bodyTemplate,
      'Client': 'henutsen',
      'Authorization': {
        'Type': _selectedLocation,
        'Number': _number.toString(),
        'Items': transfer.authorizedAssetsList,
      }
    };
    return emailToSend;
  }
}
