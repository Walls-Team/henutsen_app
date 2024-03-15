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
import 'package:henutsen_cli/provider/pendient_Authorization.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:henutsen_cli/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Clase principal
class PendientPage extends StatelessWidget {
  ///  Class Key
  const PendientPage({Key? key}) : super(key: key);
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
          body: PendientData(),
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
class PendientData extends StatelessWidget {
  ///  Class Key
  PendientData({Key? key}) : super(key: key);

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
    final _boxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.5
        : mediaSize.width * 0.4;
    // Capturar modelo de la empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de la empresa
    final user = context.watch<UserModel>();
    // Capturar modelo de traslados y autorizaciones
    final transfer = context.watch<PendientModel>();

    String _currentLocation;
    if (transfer.selectedLocation.isEmpty) {
      _currentLocation = 'Todas';
      transfer.selectedLocation = _currentLocation;
    } else {
      _currentLocation = transfer.selectedLocation;
    }
    company.places.sort();
    // Menú desplegable de ubicaciones
    final _listOfLocations =
        _fillListOfItems(company.placesUser, 'Todas', _menuWidth);

    String _currentCategory;
    if (transfer.selectedCategory.isEmpty) {
      _currentCategory = 'Todas';
      transfer.selectedCategory = _currentCategory;
    } else {
      _currentCategory = transfer.selectedCategory;
    }

    String _currentStatus;
    if (transfer.selectedState.isEmpty) {
      _currentStatus = 'Todos';
      transfer.selectedState = _currentStatus;
    } else {
      _currentStatus = transfer.selectedState;
    }

    // ----Widgets----
    // Función plantilla para widgets de filtro
    // Aplica para -ubicación, -categoría, -estado
    Widget _filterField(String fieldName, List<DropdownMenuItem<String>> list) {
      // Valor seleccionado a mostrar en el menú desplegable
      String? _fieldValue;
      if (fieldName == 'Ubicación') {
        _fieldValue = _currentLocation;
      } else if (fieldName == 'Categoría') {
        _fieldValue = _currentCategory;
      } else if (fieldName == 'Estado') {
        _fieldValue = _currentStatus;
      }
      // Función a ejecutar al cambiar opción
      void _onValueChange(String newValue) {
        switch (fieldName) {
          case 'Ubicación':
            transfer.changeLocation(newValue);
            break;
          case 'Categoría':
            transfer.changeCategory(newValue);
            break;
          case 'Estado':
            transfer.changeStatus(newValue);
            break;
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

    // ----Widgets---- FIN

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
                  // ¿Permiso permanente?
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '¿Permiso permanente?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Checkbox(
                        value: transfer.permanentAuthorization,
                        onChanged: (newValue) {
                          if (newValue!) {
                            transfer
                              ..startDate = '(Permiso permanente)'
                              ..endDate = '(Permiso permanente)'
                              ..currentAuthorization.authorizedStartDate = null
                              ..currentAuthorization.authorizedEndDate = null;
                          } else {
                            transfer
                              ..startDate = ''
                              ..endDate = '';
                          }
                          transfer.updatePermanentAuthorization(newValue);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Selección de activos
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Activos a trasladar',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          // Filtros de búsqueda
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: _formKeySearch,
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
                        // Selección de ubicación
                        _filterField('Ubicación', _listOfLocations),
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
                            // Selección de ubicación
                            _filterField('Ubicación', _listOfLocations),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          // Información de activos
          const InfoToShow(),
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
                          ModalRoute.withName('/traslado-activos'),
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
                        if (transfer.authorizedAssetsList.isEmpty) {
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
                          if (transfer.permanentAuthorization) {
                            transfer.currentAuthorization.authorizedStartDate =
                                '(Permiso permanente)';
                            transfer.currentAuthorization.authorizedEndDate =
                                '(Permiso permanente)';
                          }
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
                              ..assets = transfer.authorizedAssetsList
                              ..companyCode = _cCode
                              ..number = _newAuthNumber
                              ..person = '${user.currentUser.name?.givenName}'
                                  ' ${user.currentUser.name?.familyName} '
                                  '(${user.currentUser.userName})'
                              ..dateIssued = DateTime.now().toString()
                              ..status = 'Pendiente'
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
                                          transfer.editDone();
                                          Navigator.popUntil(
                                            context,
                                            ModalRoute.withName(
                                                '/traslado-activos'),
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
                      child: const Text('Solicitar autorización')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  // Método para llenar listado de categorías o estados
  List<DropdownMenuItem<String>> _fillListOfItems(
      List<String> initialList, String allChoices, double myWidth) {
    final itemsList = initialList
        .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
              value: value,
              child: SizedBox(
                width: myWidth,
                child: Text(value),
              ),
            ))
        .toList()
      // Agregar opción "Todas" o "Todos" al menú
      ..insert(
        0,
        DropdownMenuItem<String>(
          value: allChoices,
          child: SizedBox(
            width: myWidth,
            child: Text(
              allChoices,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    return itemsList;
  }
}

/// Clase para devolver la información de activos a mostrar
class InfoToShow extends StatelessWidget {
  /// Class Key
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Leemos cambios en el modelo del inventario
    final inventory = context.watch<InventoryModel>();
    // Leemos cambios en el modelo de traslados y autorizaciones
    final transfer = context.watch<PendientModel>();

    // Llenar la lista considerando filtros
    final initialAssetsList = <Asset>[];
    for (final item in inventory.locaUserAsset) {
      // Activos en la ubicación elegida
      if (item.locationName == transfer.selectedLocation ||
          transfer.selectedLocation == 'Todas') {
        final itemCategory = inventory.getAssetMainCategory(item.assetCode);
        // Activos de la categoría elegida
        if (itemCategory == transfer.selectedCategory ||
            transfer.selectedCategory == 'Todas') {
          // Activos con estado elegido
          if (item.status == transfer.selectedState ||
              transfer.selectedState == 'Todos') {
            initialAssetsList.add(item);
          }
        }
      }
    }
    // Considerar campo de búsqueda también
    final assets2show = inventory.filterAssets(inventory.currentSearchField,
        initialAssetsList, transfer.filterUserName);

    if (assets2show.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        // Tabla de activos
        child: PaginatedDataTable(
          source: DataTableItems(
              context: context,
              generalData: assets2show,
              modelSource: transfer,
              otherSource: inventory,
              type: '1',
              dataToPrint: DataToPrint.assetsToAuthorize),
          header: const Text('Lista de Activos'),
          columns: [
            const DataColumn(label: Text('No.')),
            const DataColumn(label: Text('Nombre del activo')),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Total de activos: ${assets2show.length}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          columnSpacing: 50,
          horizontalMargin: 10,
          rowsPerPage: assets2show.length <= 10 ? assets2show.length : 10,
          onSelectAll: (isSelectedAll) {
            if (isSelectedAll!) {
              for (final a in assets2show) {
                transfer.updateAuthorizationList(a.assetCode!, isSelectedAll);
              }
              //print(transfer.authorizedAssetsList.length);
            } else {
              transfer.clearAuthorizationList();
            }
          },
        ),
      );
    } else {
      return const Center(
        child: Text('No hay información...'),
      );
    }
  }
}
