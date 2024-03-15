// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -----------Tabla paginada de items varios-----------
// ----------------------------------------------------

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/provider/area_model.dart';
import 'package:henutsen_cli/provider/assetHistory_model.dart';
import 'package:henutsen_cli/provider/campus_model.dart';
import 'package:henutsen_cli/provider/category_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/inventory_out.dart';
import 'package:henutsen_cli/provider/location_model.dart';
import 'package:henutsen_cli/provider/pendient_Authorization.dart';
import 'package:henutsen_cli/provider/role_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Páginas donde se muestran tablas paginadas
enum DataToPrint {
  /// Tabla de activos
  assets,

  /// Tabla de empresas
  companies,

  /// Tabla de usuarios
  users,

  /// Tabla de ubicaciones
  locations,

  /// Tabla de roles
  roles,

  /// Tabla de autorizaciones
  authorizations,

  /// Tabla de activos a autorizar
  assetsToAuthorize,

  /// Tabla de activos a autorizar
  authorizationsInternal,

  /// Tabla de categorías
  categories,

  /// Tabla de activos para búsqueda RFID
  assetsToSearch,

  /// Tabla de linea de negociaciones
  businessLines,

  /// Tabla de sedes
  campus,

  /// Tabla de áreas
  areas
}

/// Tabla de datos multipropósito
class DataTableItems extends DataTableSource {
  /// Constructor
  DataTableItems(
      {this.context,
      this.generalData,
      this.modelSource,
      this.otherSource,
      this.nameCompany,
      this.type,
      this.dataToPrint});

  /// Contexto
  BuildContext? context;

  ///nombre de la empresa
  String? nameCompany;

  ///nombre de la empresa
  String? type;

  /// Datos a presentar
  List<dynamic>? generalData;

  /// Modelo de provider principal
  dynamic modelSource;

  /// Otro modelo requerido
  dynamic otherSource;

  /// Tipo de datos a imprimir en la tabla
  DataToPrint? dataToPrint;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => generalData!.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    final company = context!.watch<CompanyModel>();
    final user = context!.watch<UserModel>();
    //para activos normales
    final deleteAsset =
        verifyResource(user.currentUser.roles!, company, 'DeleteAsset');
    final modAsset =
        verifyResource(user.currentUser.roles!, company, 'ModAsset');
    final downAsset =
        verifyResource(user.currentUser.roles!, company, 'DownAsset');
    //para activos con autorizacion
    final modAuthorize =
        verifyResource(user.currentUser.roles!, company, 'ModifyAuthorization');
    final deleteAuthorize =
        verifyResource(user.currentUser.roles!, company, 'DeleteAuthorization');
    //para empresas
    final replaceCompany =
        verifyResource(user.currentUser.roles!, company, 'ReplaceGroup');
    //para usuarios
    final replaceUser =
        verifyResource(user.currentUser.roles!, company, 'ReplaceUser');
    final deleteUser =
        verifyResource(user.currentUser.roles!, company, 'DeleteUser');
    //para ubicaciones
    final replaceLocation =
        verifyResource(user.currentUser.roles!, company, 'ModifyLocation');
    final deleteLocation =
        verifyResource(user.currentUser.roles!, company, 'DeleteLocation');
    //para roles
    final modRole =
        verifyResource(user.currentUser.roles!, company, 'ModifyRole');
    final deleteRole =
        verifyResource(user.currentUser.roles!, company, 'DeleteRole');

    switch (dataToPrint!) {
      case DataToPrint.assets:
        final data = generalData as List<Asset>?;
        final source = modelSource as InventoryModel?;
        final additionalSource = otherSource as CompanyModel?;
        final _myColor =
            (data![index].status == 'De baja') ? Colors.grey : Colors.black;
        return DataRow(cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              (data[index].status != 'De baja')
                  ? data[index].name!
                  : '${data[index].name!}\n(De baja)',
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].assetDetails?.serialNumber ?? 'Sin serial',
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].locationName!,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].status ?? '',
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].custody ?? '',
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Modificar activo
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: modAsset
                          ? Theme.of(context!).highlightColor
                          : Colors.grey,
                    ),
                    onPressed: () async {
                      if (modAsset) {
                        source!.currentAsset = data[index].copy();
                        source.currentAsset.isNearAntenna ??= false;
                        if (source.currentAsset.isNearAntenna!) {
                          source.nearAntenna = NearAntenna.near;
                        } else {
                          source.nearAntenna = NearAntenna.notNear;
                        }
                        // Capturar modelo de imágenes
                        final imageModel = context!.read<ImageModel>();
                        imageModel.imageArray.clear();
                        // Cargar imágenes que haya en el servidor
                        final _imagesList = <String>[];
                        source.currentAsset.images ??= <AssetPhoto>[];
                        if (source.currentAsset.images!.isNotEmpty) {
                          for (final item in source.currentAsset.images!) {
                            _imagesList.add(item.picture!);
                          }
                        }
                        imageModel
                          ..resetAll()
                          ..preloadImageArray(_imagesList);
                        // Llenar usuarios de la empresa
                        // Capturar modelo de usuario
                        final user = context!.read<UserModel>();
                        await user.loadLocalUsers(
                            additionalSource!.currentCompany.id!);
                        if (source.currentAsset.custody != 'Sin Asignar') {
                          var usershow = User();
                          for (final userfind in user.fullUsersList) {
                            var aux = userfind.name!.givenName!;
                            var aux1 = userfind.name!.middleName != ''
                                ? ' ${userfind.name!.middleName!} '
                                : ' ';
                            var aux2 = userfind.name!.familyName != ''
                                ? userfind.name!.familyName!
                                : '';
                            var aux3 =
                                userfind.name!.additionalFamilyNames != ''
                                    ? userfind.name!.additionalFamilyNames!
                                    : '';
                            final auxfind = aux + aux1 + aux2 + aux3;
                            if (!source.currentAsset.custody!.contains('(')) {
                              if (auxfind
                                      .toLowerCase()
                                      .replaceAll('í', 'i')
                                      .replaceAll('ó', 'o')
                                      .replaceAll('é', 'e')
                                      .replaceAll('á', 'a') ==
                                  source.currentAsset.custody!
                                      .toLowerCase()
                                      .replaceAll('í', 'i')
                                      .replaceAll('ó', 'o')
                                      .replaceAll('é', 'e')
                                      .replaceAll('á', 'a')) {
                                usershow = userfind;
                                break;
                              }
                            }
                          }
                          if (!source.currentAsset.custody!.contains('(')) {
                            company.asigneLocations(usershow);
                          } else {
                            company.asigneLocalPlaces();
                          }
                        }
                        if (source.currentAsset.status != 'De baja' &&
                            !downAsset) {
                          source.removeStatus();
                        }
                        if (source.currentAsset.status == 'De baja') {
                          if (!source.conditions.contains('De baja')) {
                            source.conditions.add('De baja');
                          }
                        }
                        source.editDone();

                        await Navigator.pushNamed(context!, '/datos-activo');
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para modificar '
                          'activos.',
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.history_outlined,
                        color: Theme.of(context!).highlightColor),
                    onPressed: () async {
                      //capturar modelo de assetHistory
                      final assetH = context!.read<AssetHistoryModel>();
                      // ignore: cascade_invocations
                      assetH.asigneAsset(data[index]);
                      await assetH.getAssetHistory(data[index].id!);
                      await Navigator.pushNamed(context!, '/asset-history');
                    },
                  ),
                  // Eliminar activo
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: deleteAsset
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      if (deleteAsset) {
                        // Se espera confirmación del usuario
                        if (await HenutsenDialogs.confirmationMessage(
                          context!,
                          '¿Confirma eliminación del activo:\n'
                          '${data[index].name}?',
                        )) {
                          // Capturar el usuario
                          final user = context!.read<UserModel>();
                          final _userName = user.name2show;
                          // Capturar la empresa
                          final company = context!.read<CompanyModel>();
                          final _itemsToSend = {
                            'AssetId': data[index].id!,
                            'UserName': _userName
                          };
                          final _encoded = jsonEncode(_itemsToSend);
                          final result = await source!.deleteAsset(_encoded);
                          if (result == 'Ok') {
                            HenutsenDialogs.showSnackbar(
                              'Activo eliminado',
                              context!,
                            );
                            source.initInventory();
                            await source.loadInventory(
                                company.currentCompany.companyCode!);
                            if (company.currentLocation != null) {
                              source
                                  .extractLocalItems(company.currentLocation!);
                            }
                            // Capturar estadísticas
                            context!.read<StatisticsModel>().clearStatus();
                          }
                        }
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para eliminar '
                          'activos.',
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.companies:
        final data = generalData as List<Company>?;
        final source = modelSource as CompanyModel?;
        var _myColor = Colors.black;
        if (!data![index].active!) {
          _myColor = Colors.grey;
        }
        return DataRow(cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].active!
                  ? data[index].name!
                  : '${data[index].name!}\n(inactiva)',
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Modificar empresa
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: replaceCompany
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      if (replaceCompany) {
                        source!.tempCompany = data[index].copy();
                        // Capturar modelo de imágenes
                        final imageModel = context!.read<ImageModel>();
                        imageModel.imageArray.clear();
                        // Cargar imágenes que haya en el servidor
                        final _imagesList = <String>[];
                        if (source.tempCompany.logo!.isNotEmpty) {
                          _imagesList.add(source.tempCompany.logo!);
                        }
                        imageModel
                          ..resetAll()
                          ..preloadImageArray(_imagesList);
                        if (source.tempCompany.active!) {
                          source.updateCompanyMode(CompanyActive.active);
                        } else {
                          source.updateCompanyMode(CompanyActive.inactive);
                        }
                        source.tempCompanyCountry =
                            source.tempCompany.addresses![0].country!;
                        if (source.tempCompany.addresses![0].region == null ||
                            source.tempCompany.addresses![0].region == '') {
                          source.tempCompanyRegion = null;
                        } else {
                          source.tempCompanyRegion =
                              source.tempCompany.addresses![0].region;
                        }
                        if (source.tempCompany.addresses![0].locality == null ||
                            source.tempCompany.addresses![0].locality == '') {
                          source.tempCompanyTown = null;
                        } else {
                          source.tempCompanyTown =
                              source.tempCompany.addresses![0].locality;
                        }
                        await Navigator.pushNamed(context!, '/datos-empresa');
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para modificar '
                          'empresas.',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.users:
        final data = generalData as List<User>?;
        final source = modelSource as UserModel?;
        final additionalSource = otherSource as CompanyModel?;
        var _myColor = Colors.black;
        if (!data![index].active!) {
          _myColor = Colors.grey;
        }
        // Extraer nombre de rol
        final _roles = <String>[];
        for (final roleID in data[index].roles!) {
          for (final comp in additionalSource!.fullCompanyList) {
            if (data[index].company?.id == comp.id) {
              for (final item in comp.roles!) {
                if (roleID == item.roleId) {
                  _roles.add(item.name!);
                  break;
                }
              }
            }
          }
        }
        return DataRow(cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].userName == source!.currentUser.userName
                  ? '${data[index].name!.givenName}'
                      ' ${data[index].name!.familyName}\n(usuario actual)'
                  : '${data[index].name!.givenName}'
                      ' ${data[index].name!.familyName}',
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].userName == source.currentUser.userName
                  ? '${data[index].userName!}\n(usuario actual)'
                  : data[index].userName!,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].externalId!.isEmpty
                  ? ''
                  : data[index].externalId!.split('-')[1],
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              _roles[0],
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de modificar
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: replaceUser
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      if (replaceUser) {
                        // Pasar datos a usuario temporal
                        source.tempUser = data[index].copy();
                        if (source.tempUser.roles!.isEmpty) {
                          source.tempRole = null;
                        } else {
                          for (final comp
                              in additionalSource!.fullCompanyList) {
                            if (data[index].company?.id == comp.id) {
                              for (final item in comp.roles!) {
                                if (data[index].roles![0] == item.roleId) {
                                  source.tempRole = item.name;
                                  break;
                                }
                              }
                            }
                          }
                        }
                        // Capturar datos de empresa
                        final company = context!.read<CompanyModel>();
                        for (final item in company.fullCompanyList) {
                          if (data[index].company?.id == item.id) {
                            source
                              ..tempCompanyID = item.id
                              ..tempCompany = item.name;
                            break;
                          }
                        }
                        if (source.tempUser.active!) {
                          source.tempUserActive = UserActive.active;
                        } else {
                          source.tempUserActive = UserActive.inactive;
                        }
                        // Capturar modelo de imágenes
                        final imageModel = context!.read<ImageModel>();
                        imageModel.imageArray.clear();
                        // Cargar imágenes que haya en el servidor
                        final _imagesList = <String>[];
                        if (source.tempUser.photos!.isNotEmpty) {
                          for (final item in source.tempUser.photos!) {
                            _imagesList.add(item.value!);
                          }
                        }
                        imageModel
                          ..resetAll()
                          ..preloadImageArray(_imagesList);
                        source.tempPassword = '';
                        await Navigator.pushNamed(context!, '/datos-usuario');
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para modificar '
                          'usuarios.',
                        );
                      }
                    },
                  ),
                  // Botón de eliminar
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: deleteUser
                          ? data[index].userName == source.currentUser.userName
                              ? Colors.grey
                              : Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      if (!deleteUser) {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para modificar '
                          'usuarios.',
                        );
                        return;
                      }
                      if (data[index].userName != source.currentUser.userName) {
                        await showDialog<void>(
                          context: context!,
                          builder: (context) => AlertDialog(
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¿Confirma eliminación del usuario \n'
                                    '${data[index].userName}?',
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final result =
                                      await source.deleteUser(data[index].id!);
                                  if (result == 'Ok') {
                                    source.fullUsersList.remove(data[index]);
                                    source.editDone();
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        HenutsenDialogs.showSnackbar(
                            'No se puede eliminar '
                            'su propio usuario.',
                            context!);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.locations:
        final data = generalData as List<String>?;
        final source = modelSource as LocationModel?;
        return DataRow(cells: [
          DataCell(
            Text((index + 1).toString(), textAlign: TextAlign.center),
          ),
          DataCell(
            Text(data![index]),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de modificar
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: replaceLocation
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      if (replaceLocation) {
                        source!
                          ..tempLocation = Location(
                            name: data[index],
                          )
                          ..oldName = data[index]
                          ..creationMode = false;
                        await Navigator.pushNamed(context!, '/datos-ubicacion');
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para modificar '
                          'ubicaciones.',
                        );
                      }
                    },
                  ),
                  // Botón de eliminar
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: deleteLocation
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      if (!deleteLocation) {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para eliminar '
                          'ubicaciones.',
                        );
                        return;
                      }
                      // Se espera confirmación del usuario
                      if (await HenutsenDialogs.confirmationMessage(
                          context!,
                          '¿Confirma eliminación de la ubicación\n'
                          '${data[index]}?')) {
                        source!.tempLocation = Location();
                        // Capturar modelo de empresa
                        final company = context!.read<CompanyModel>();
                        // Capturar modelo de usuario
                        final user = context!.read<UserModel>();
                        source.tempLocation?.name = data[index];
                        final chain = jsonEncode(source.tempLocation);
                        final result = await source.deleteLocation(
                            chain,
                            source.currentSearchCompany.companyCode!,
                            user.name2show);
                        await showDialog<void>(
                          context: context!,
                          barrierDismissible: false,
                          builder: (context) {
                            var _success = false;
                            var _dialogText = '';
                            if (result == 'Ok') {
                              _success = true;
                              _dialogText = 'Ubicación eliminada exitosamente';
                            } else {
                              _dialogText = 'Error eliminando ubicación.\n'
                                  '$result.\n'
                                  'Revise e intente nuevamente.';
                            }
                            return AlertDialog(
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
                                      // Actualizar datos de empresa actual si
                                      // ubicación se incluyó acá
                                      if (company.currentCompany ==
                                          source.currentSearchCompany) {
                                        company.currentCompany.locations!
                                            .remove(source.tempLocation!.name);
                                        company.places
                                            .remove(source.tempLocation!.name);
                                      } else {
                                        source.currentSearchCompany.locations!
                                            .remove(source.tempLocation!.name);
                                      }
                                      source.editDone();
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.roles:
        final data = generalData as List<CompanyRole>?;
        final source = modelSource as RoleModel?;
        return DataRow(cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              textAlign: TextAlign.center,
            ),
          ),
          DataCell(
            Text(
              data![index].name!,
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de modificar
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: modRole
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      if (modRole) {
                        source?.creationMode = false;
                        // Pasar datos a rol temporal
                        source?.tempRole = data[index].copy();
                        source?.clearResourceSelection();
                        source
                            ?.loadSelectedResources(source.tempRole.resources!);
                        source?.asigneResourcesL(
                            source.tempRole.resources!,
                            company.fullCompanyList
                                .where((element) => element.name == nameCompany)
                                .first);
                        await Navigator.pushNamed(context!, '/datos-rol');
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para modificar '
                          'roles.',
                        );
                      }
                    },
                  ),
                  // Botón de eliminar
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: deleteRole
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      if (!deleteRole) {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para eliminar '
                          'roles.',
                        );
                        return;
                      }
                      await showDialog<void>(
                        context: context!,
                        builder: (context) => AlertDialog(
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Confirma eliminación del rol \n'
                                  '${data[index].name}?',
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Capturar modelo de empresa
                                final company = context.read<CompanyModel>();
                                // Capturar modelo de usuario
                                final user = context.read<UserModel>();
                                // Extraer código de empresa a afectar
                                var _cCode = '';
                                for (final item in company.fullCompanyList) {
                                  if (item.name ==
                                      source!.currentSearchCompany) {
                                    _cCode = item.companyCode!;
                                    break;
                                  }
                                }
                                // Mapa para recopilar información a enviar
                                final _itemsToSend = <String, dynamic>{
                                  'UserName': user.name2show,
                                  'CompanyCode': _cCode,
                                  'RoleToDelete': data[index],
                                };
                                final result = await source!
                                    .deleteRole(jsonEncode(_itemsToSend));
                                if (result == 'Ok') {
                                  // Recargar roles disponibles para
                                  // la empresa seleccionada
                                  for (final item in company.fullCompanyList) {
                                    if (source.currentSearchCompany ==
                                        item.name) {
                                      item.roles!.removeWhere((element) =>
                                          element.roleId ==
                                          source.tempRole.roleId);
                                    }
                                  }
                                  // Actualizar datos de empresa
                                  // actual si rol estaba acá
                                  if (company.currentCompany.name ==
                                      source.currentSearchCompany) {
                                    company.currentCompany.roles!.removeWhere(
                                        (element) =>
                                            element.roleId ==
                                            source.tempRole.roleId);
                                  }
                                  if (user.currentUserRole
                                      .contains('Vendedor')) {
                                    await company.loadCompanies();
                                    company.status = CompanyStatus.idle;
                                  }
                                  source.editDone();
                                }
                                Navigator.of(context).pop();
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.authorizations:
        final data = generalData as List<Authorization>?;
        final source = modelSource as TransferModel;
        // Capturar modelo de usuario
        final user = context?.watch<UserModel>();
        final inventory = context?.watch<InventoryModel>();
        // Se captura el rol. Solo el coordinador (o más) puede
        // modificar o eliminar autorizaciones
        //final _userRole = user?.currentUserRole;
        /*var _validRole = false;
        if (_userRole!=null&& _userRole != 'Analista') {
          _validRole = true;
        }*/
        // Establecer estado de la autorización
        String _status;
        if (data![index].revoked!) {
          _status = 'Revocada';
        } else if (data[index].authorizedStartDate != '(Permiso permanente)' &&
            DateTime.parse(data[index].authorizedEndDate!)
                .isBefore(DateTime.now())) {
          _status = 'Vencida';
        } else {
          _status = 'Vigente';
        }
        final showAsset = <Asset>[];
        for (final itemA in inventory!.fullInventory) {
          for (final itemAssetId in data[index].assets!) {
            if (itemAssetId == itemA.assetCode) {
              showAsset.add(itemA);
            }
          }
        }
        // Color para diferenciar autorizaciones
        final _myColor = _status == 'Vigente' ? Colors.black : Colors.grey;
        return DataRow(cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].number!.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].person!,
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () async {
              var i = 0;
              await showDialog<void>(
                context: context!,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  content: SingleChildScrollView(
                    child: Column(
                      children: showAsset.map((e) {
                        i++;
                        final serial = e.assetDetails!.serialNumber == null
                            ? 'sin serial'
                            : e.assetDetails!.serialNumber!.isEmpty
                                ? 'sin serial'
                                : e.assetDetails!.serialNumber;
                        return Column(
                          children: [
                            Text(
                                '$i) Nombre: ${e.name!}\n'
                                'Serial: $serial',
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black)),
                            const SizedBox(
                              height: 06,
                            )
                          ],
                        );
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
          )),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Modificar autorización
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: modAuthorize
                          ? Theme.of(context!).highlightColor
                          : Theme.of(context!).disabledColor,
                    ),
                    onPressed: () async {
                      if (modAuthorize) {
                        source
                          ..currentAuthorization = data[index].copy()
                          ..startDate =
                              source.currentAuthorization.authorizedStartDate!
                          ..endDate =
                              source.currentAuthorization.authorizedEndDate!
                          ..transferLocation =
                              source.currentAuthorization.transferLocation == ''
                                  ? 'No aplica'
                                  : source
                                      .currentAuthorization.transferLocation!
                          ..permanentAuthorization =
                              source.currentAuthorization.isPermanent!
                          ..revokeAuthorization =
                              source.currentAuthorization.revoked!
                          ..authorizedAssetsList.clear()
                          ..authorizedAssetsList
                              .addAll(source.currentAuthorization.assets!);
                        // Llenar usuarios de la empresa
                        // Capturar modelo de usuario
                        final user = context!.read<UserModel>();
                        // Capturar modelo de empresa
                        final company = context!.read<CompanyModel>();
                        await user.loadLocalUsers(company.currentCompany.id!);
                        company.asigneLocations(user.fullUsersList.isNotEmpty
                            ? user.fullUsersList
                                .where((element) =>
                                    element.userName ==
                                    source.currentAuthorization.person!
                                        .split(' ')[2]
                                        .replaceAll('(', '')
                                        .replaceAll(')', ''))
                                .first
                            : user.currentUser);
                        if (source.currentAuthorization.person!
                            .contains(user.currentUser.userName!)) {
                          source.asigneStatus(status.edit);
                        }
                        if (source.currentAuthorization.supervisor!
                            .contains(user.currentUser.userName!)) {
                          source.asigneStatus(status.idle);
                        }
                        await Navigator.pushNamed(context!, '/datos-autorizar');
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para modificar '
                          'autorizaciones.',
                        );
                      }
                    },
                  ),

                  // Eliminar autorización
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: deleteAuthorize
                          ? data[index]
                                  .copy()
                                  .person!
                                  .contains(user!.currentUser.userName!)
                              ? Theme.of(context!).disabledColor
                              : Theme.of(context!).highlightColor
                          : Theme.of(context!).disabledColor,
                    ),
                    onPressed: () async {
                      if (data[index]
                          .copy()
                          .person!
                          .contains(user!.currentUser.userName!)) {
                        return;
                      }
                      if (deleteAuthorize) {
                        // Se espera confirmación del usuario
                        if (await HenutsenDialogs.confirmationMessage(
                          context!,
                          '¿Confirma eliminación de la autorización:\n'
                          '${data[index].number ?? data[index].id}?',
                        )) {
                          // Capturar el usuario
                          final user = context!.read<UserModel>();
                          final _userName = user.name2show;
                          // Capturar la empresa
                          final company = context!.read<CompanyModel>();
                          final _itemsToSend = <String, dynamic>{
                            'AuthorizationId': data[index].id!,
                            'UserName': _userName
                          };
                          final _encoded = jsonEncode(_itemsToSend);
                          final result =
                              await source.deleteAuthorization(_encoded);
                          if (result == 'Ok') {
                            await showDialog<void>(
                              context: context!,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: SingleChildScrollView(
                                  child: Text(
                                    'Autorización eliminada correctamente',
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).highlightColor,
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                            await source.getAuthorizations(
                                company.currentCompany.companyCode!);
                            source.editDone();
                          }
                        }
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para eliminar '
                          'autorizaciones.',
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.assetsToAuthorize:
        final data = generalData as List<Asset>?;
        var source1;
        if (type == '1') {
          source1 = modelSource as PendientModel?;
        } else {
          source1 = modelSource as TransferModel?;
        }

        final source = source1;

        final additionalSource = otherSource as InventoryModel?;
        final _myColor =
            (data![index].status == 'De baja') ? Colors.grey : Colors.black;
        return DataRow(
            selected: source!.authorizedAssetsList
                .where((a) => a == data[index].assetCode)
                .isNotEmpty,
            onSelectChanged: (isSelected) {
              //print(isSelected);
              source.updateAuthorizationList(
                  data[index].assetCode!, isSelected!);
              //print(source.authorizedAssetsList);
            },
            cells: [
              DataCell(
                Text(
                  (index + 1).toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _myColor),
                ),
              ),
              DataCell(
                Text(
                  (data[index].status != 'De baja')
                      ? data[index].name!
                      : '${data[index].name!}\n(De baja)',
                  style: TextStyle(color: _myColor),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.all(1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Más información
                      Container(
                        padding: const EdgeInsets.all(1),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_horiz, color: Colors.blue[800]),
                          itemBuilder: (context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Info',
                              child: Text('Más información'),
                            ),
                          ],
                          offset: const Offset(-10, 10),
                          onSelected: (chosen) {
                            if (chosen == 'Info') {
                              showDialog<void>(
                                context: context!,
                                builder: (context) {
                                  // Recopilar información del activo
                                  final assetInfo = data[index]
                                    // Revisión de integridad de datos
                                    ..description ??= '';
                                  // Parte de códigos en la tabla
                                  Widget _codeTable;
                                  if (assetInfo.assetCode == null) {
                                    _codeTable = Table(children: const [
                                      TableRow(children: [
                                        Text(
                                            'Este activo no ha sido codificado',
                                            style: TextStyle(fontSize: 14)),
                                      ])
                                    ]);
                                  } else if (assetInfo.assetCode!.isEmpty) {
                                    _codeTable = Table(children: const [
                                      TableRow(children: [
                                        Text(
                                            'Este activo no ha sido codificado',
                                            style: TextStyle(fontSize: 14)),
                                      ])
                                    ]);
                                  } else {
                                    _codeTable = Table(children: [
                                      TableRow(children: [
                                        const Text(
                                            'Código EPC\n(Base de datos): ',
                                            style: TextStyle(fontSize: 14)),
                                        Text(assetInfo.assetCode!,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ]),
                                    ]);
                                  }
                                  return AlertDialog(
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Información del activo',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Divider(),
                                          Table(children: [
                                            TableRow(
                                              children: [
                                                const Text(
                                                  'Activo: ',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  assetInfo.name!,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const Text(
                                                  'Descripción: ',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  assetInfo.description!,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const Text(
                                                  'Sede: ',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  assetInfo.locationName!,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const Text(
                                                  'Categoría: ',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  additionalSource!
                                                      .getAssetMainCategory(
                                                          assetInfo.assetCode),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ]),
                                          const Text(
                                            'Código del activo',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // Parte de código EPC generada arriba
                                          _codeTable
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Volver'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]);
      case DataToPrint.categories:
        final data = generalData as List<String>?;
        final source = modelSource as CategoryModel?;
        return DataRow(cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          DataCell(
            Text(
              data![index],
              style: const TextStyle(color: Colors.black),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Modificar categoría
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: Theme.of(context!).highlightColor,
                    ),
                    onPressed: () async {
                      source!
                        ..tempCategory = AssetCategory(
                          name: 'Category 1',
                          value: data[index],
                        )
                        ..oldName = data[index]
                        ..creationMode = false;
                      await Navigator.pushNamed(context!, '/datos-categoria');
                    },
                  ),
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.assetsToSearch:
        final data = generalData as List<Asset>?;
        final source = modelSource as InventoryModel;
        final _myColor =
            (data![index].status == 'De baja') ? Colors.grey : Colors.black;
        return DataRow(cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              (data[index].status != 'De baja')
                  ? data[index].name!
                  : '${data[index].name!}\n(De baja)',
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              alignment: Alignment.center,
              // Botón de búsqueda
              child: IconButton(
                icon: Icon(
                  Icons.speaker_phone,
                  color: Theme.of(context!).highlightColor,
                ),
                onPressed: () {
                  // Activo actual como objeto a buscar
                  source.localInventory
                    ..clear()
                    ..add(data[index]);
                  source.tagList.clear();
                  Navigator.pushNamed(context!, '/buscar-activo');
                },
              ),
            ),
          ),
        ]);
      case DataToPrint.businessLines:
        final data = generalData as List<String>?;
        final source = modelSource as CompanyModel?;
        return DataRow(cells: [
          DataCell(
            Text((index + 1).toString(), textAlign: TextAlign.center),
          ),
          DataCell(
            Text(data![index]),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de modificar
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: replaceLocation
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      source!
                        ..creationMode = false
                        ..olNameBusiness = data[index]
                        ..modifyNameBusiness = data[index]
                        ..editDone();
                      await Navigator.pushNamed(context!, '/data-business');
                    },
                  ),
                  // Botón de eliminar
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: /*deleteLocation*/
                            Theme.of(context!).highlightColor
                        /*: Colors.grey[400],*/
                        ),
                    onPressed: () async {
                      /* if (!deleteLocation) {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para eliminar '
                          'ubicaciones.',
                        );
                        return;
                      }*/
                      // Se espera confirmación del usuario
                      if (await HenutsenDialogs.confirmationMessage(
                          context!,
                          '¿Confirma eliminación de la linea de negocio\n'
                          '${data[index]}?')) {
                        // Capturar modelo de empresa
                        final company = context!.read<CompanyModel>();
                        // Capturar modelo de usuario
                        final result = await company.deleteBussinesLine(
                            data[index], source!.auxCompany.companyCode!);
                        await showDialog<void>(
                          context: context!,
                          barrierDismissible: false,
                          builder: (context) {
                            var _success = false;
                            var _dialogText = '';
                            if (result.contains('eliminada')) {
                              _success = true;
                              _dialogText =
                                  'Linea de negocio eliminada exitosamente';
                            } else {
                              _dialogText =
                                  'Error eliminando Linea de negocio.\n'
                                  '$result.\n'
                                  'Revise e intente nuevamente.';
                            }
                            return AlertDialog(
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
                                      // Actualizar datos de empresa actual si
                                      source.auxCompany.businessLines!
                                          .remove(data[index]);
                                      for (var i = 0;
                                          i < source.fullCompanyList.length;
                                          i++) {
                                        if (source.fullCompanyList[i].id ==
                                            source.auxCompany.id) {
                                          source.fullCompanyList[i] =
                                              source.auxCompany;
                                          break;
                                        }
                                      }
                                      source.editDone();
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.campus:
        final data = generalData as List<Campus>?;
        final source = modelSource as CampusModel?;
        return DataRow(cells: [
          DataCell(
            Text((index + 1).toString(), textAlign: TextAlign.center),
          ),
          DataCell(
            Text(data![index].name!),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de modificar
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: replaceLocation
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      source!.campus = data[index].copy();
                      // Capturar modelo de imágenes
                      final imageModel = context!.read<ImageModel>();
                      imageModel.imageArray.clear();
                      // Cargar imágenes que haya en el servidor
                      final _imagesList = <String>[];
                      if (source.campus.logo != null &&
                          source.campus.logo!.isNotEmpty) {
                        _imagesList.add(source.campus.logo == null
                            ? ''
                            : source.campus.logo!);
                      }
                      imageModel
                        ..resetAll()
                        ..preloadImageArray(_imagesList);
                      source
                        ..asigneStatus(Status.editMode)
                        ..asigneFilterBusiness(source.campus.businessLine!);
                      await Navigator.pushNamed(context!, '/campus-data');
                    },
                  ),
                  // Botón de eliminar
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: /*deleteLocation*/
                            Theme.of(context!).highlightColor
                        /*: Colors.grey[400],*/
                        ),
                    onPressed: () async {
                      if (await HenutsenDialogs.confirmationMessage(
                          context!,
                          '¿Confirma eliminación de la sede\n'
                          '${data[index].name!}?')) {
                        final result =
                            await source!.deleteCampus(data[index].id!);
                        await showDialog<void>(
                          context: context!,
                          barrierDismissible: false,
                          builder: (context) {
                            var _success = false;
                            var _dialogText = '';
                            if (result.contains('eliminada')) {
                              _success = true;
                              _dialogText = 'Sede eliminada exitosamente';
                            } else {
                              _dialogText = 'Error eliminando Sede.\n'
                                  '$result.\n'
                                  'Revise e intente nuevamente.';
                            }
                            return AlertDialog(
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
                                      source.campusList.remove(data[index]);
                                      source.editDone();
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.areas:
        final data = generalData as List<String>?;
        final source = modelSource as AreaModel?;
        return DataRow(cells: [
          DataCell(
            Text((index + 1).toString(), textAlign: TextAlign.center),
          ),
          DataCell(
            Text(data![index]),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de modificar
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: replaceLocation
                          ? Theme.of(context!).highlightColor
                          : Colors.grey[400],
                    ),
                    onPressed: () async {
                      source!
                        ..statusCreation = StatusArea.editMode
                        ..createName = data[index]
                        ..oldName = data[index]
                        ..editDone();
                      await Navigator.pushNamed(context!, '/area-data');
                    },
                  ),
                  // Botón de eliminar
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: /*deleteLocation*/
                            Theme.of(context!).highlightColor
                        /*: Colors.grey[400],*/
                        ),
                    onPressed: () async {
                      if (await HenutsenDialogs.confirmationMessage(
                          context!,
                          '¿Confirma eliminación del área\n'
                          '${data[index]}?')) {
                        final campus = context!.read<CampusModel>();
                        final result = await source!
                            .deleteArea(data[index], source.campus.id!);
                        await showDialog<void>(
                          context: context!,
                          barrierDismissible: false,
                          builder: (context) {
                            var _success = false;
                            var _dialogText = '';
                            if (result.contains('eliminada')) {
                              _success = true;
                              _dialogText = 'Area eliminada exitosamente';
                            } else {
                              _dialogText = 'Error eliminando área.\n'
                                  '$result.\n'
                                  'Revise e intente nuevamente.';
                            }
                            return AlertDialog(
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
                                      // Actualizar datos de empresa actual si
                                      source.campus.areas!.remove(data[index]);

                                      for (var i = 0;
                                          i < campus.campusList.length;
                                          i++) {
                                        if (campus.campusList[i].id ==
                                            source.campus.id) {
                                          campus.campusList[i] = source.campus;
                                          break;
                                        }
                                      }
                                      source.editDone();
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ]);
      case DataToPrint.authorizationsInternal:
        final data = generalData as List<Authorization>?;
        final source = modelSource as TransferModel;
        // Capturar modelo de usuario
        final user = context?.watch<UserModel>();
        final inventory = context?.watch<InventoryModel>();
        // Se captura el rol. Solo el coordinador (o más) puede
        // modificar o eliminar autorizaciones
        // Establecer estado de la autorización
        String _status;
        if (data![index].revoked!) {
          _status = 'Revocada';
        } else if (data[index].authorizedStartDate != '(Permiso permanente)' &&
            DateTime.parse(data[index].authorizedEndDate!)
                .isBefore(DateTime.now())) {
          _status = 'Vencida';
        } else {
          _status = 'Vigente';
        }
        final showAsset = <Asset>[];
        for (final itemA in inventory!.fullInventory) {
          for (final itemAssetId in data[index].assets!) {
            if (itemAssetId == itemA.assetCode) {
              showAsset.add(itemA);
            }
          }
        }
        // Color para diferenciar autorizaciones
        final _myColor = _status == 'Vigente' ? Colors.black : Colors.grey;
        return DataRow(cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].number!.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(
            Text(
              data[index].person!,
              textAlign: TextAlign.center,
              style: TextStyle(color: _myColor),
            ),
          ),
          DataCell(IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () async {
              var i = 0;
              await showDialog<void>(
                context: context!,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  content: SingleChildScrollView(
                    child: Column(
                      children: showAsset.map((e) {
                        i++;
                        final serial = e.assetDetails!.serialNumber == null
                            ? 'sin serial'
                            : e.assetDetails!.serialNumber!.isEmpty
                                ? 'sin serial'
                                : e.assetDetails!.serialNumber;
                        return Text(
                            '$i)Nombre: ${e.name!}\n'
                            'Serial: $serial',
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
          )),
          DataCell(
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Modificar autorización
                  IconButton(
                    icon: Icon(
                      Icons.article,
                      color: modAuthorize
                          ? Theme.of(context!).highlightColor
                          : Theme.of(context!).disabledColor,
                    ),
                    onPressed: () async {
                      final inventory = context!.read<InventoryOutModel>();
                      if (modAuthorize) {
                        source
                          ..currentAuthorization = data[index].copy()
                          ..startDate =
                              source.currentAuthorization.authorizedStartDate!
                          ..endDate =
                              source.currentAuthorization.authorizedEndDate!
                          ..transferLocation =
                              source.currentAuthorization.transferLocation == ''
                                  ? 'No aplica'
                                  : source
                                      .currentAuthorization.transferLocation!
                          ..permanentAuthorization =
                              source.currentAuthorization.isPermanent!
                          ..revokeAuthorization =
                              source.currentAuthorization.revoked!
                          ..authorizedAssetsList.clear()
                          ..authorizedAssetsList
                              .addAll(source.currentAuthorization.assets!);
                        // Llenar usuarios de la empresa
                        // Capturar modelo de usuario
                        final user = context!.read<UserModel>();
                        // ignore: prefer_final_in_for_each, prefer_foreach
                        for (var item in source.currentAuthorization.assets!) {
                          for (final itemI in inventory.fullInventory) {
                            if (item == itemI.assetCode) {
                              inventory.assetsId.add(item);
                              inventory.addTag(AssetRead(
                                  assetCode: item,
                                  found: true,
                                  location: itemI.locationName,
                                  name: itemI.name));
                            }
                          }
                        }
                        // Capturar modelo de empresa
                        final company = context!.read<CompanyModel>();
                        await user.loadLocalUsers(company.currentCompany.id!);
                        company.asigneLocations(user.fullUsersList.isNotEmpty
                            ? user.fullUsersList
                                .where((element) =>
                                    element.userName ==
                                    source.currentAuthorization.person!
                                        .split(' ')[2]
                                        .replaceAll('(', '')
                                        .replaceAll(')', ''))
                                .first
                            : user.currentUser);
                        if (source.currentAuthorization.person!
                            .contains(user.currentUser.userName!)) {
                          source.asigneStatus(status.edit);
                        }
                        if (source.currentAuthorization.supervisor!
                            .contains(user.currentUser.userName!)) {
                          source.asigneStatus(status.idle);
                        }

                        await Navigator.pushNamed(context!, '/internal-data');
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para modificar '
                          'autorizaciones.',
                        );
                      }
                    },
                  ),

                  // Eliminar autorización
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: deleteAuthorize
                          ? data[index]
                                  .copy()
                                  .person!
                                  .contains(user!.currentUser.userName!)
                              ? Theme.of(context!).disabledColor
                              : Theme.of(context!).highlightColor
                          : Theme.of(context!).disabledColor,
                    ),
                    onPressed: () async {
                      if (data[index]
                          .copy()
                          .person!
                          .contains(user!.currentUser.userName!)) {
                        return;
                      }
                      if (deleteAuthorize) {
                        // Se espera confirmación del usuario
                        if (await HenutsenDialogs.confirmationMessage(
                          context!,
                          '¿Confirma eliminación de la autorización:\n'
                          '${data[index].number ?? data[index].id}?',
                        )) {
                          // Capturar el usuario
                          final user = context!.read<UserModel>();
                          final _userName = user.name2show;
                          // Capturar la empresa
                          final company = context!.read<CompanyModel>();
                          final _itemsToSend = <String, dynamic>{
                            'AuthorizationId': data[index].id!,
                            'UserName': _userName
                          };
                          final _encoded = jsonEncode(_itemsToSend);
                          final result =
                              await source.deleteAuthorization(_encoded);
                          if (result == 'Ok') {
                            await showDialog<void>(
                              context: context!,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: SingleChildScrollView(
                                  child: Text(
                                    'Autorización eliminada correctamente',
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).highlightColor,
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                            await source.getAuthorizations(
                                company.currentCompany.companyCode!);
                            source.editDone();
                          }
                        }
                      } else {
                        await HenutsenDialogs.showSimpleAlertDialog(
                          context!,
                          'Su rol actual no tiene permisos para eliminar '
                          'autorizaciones.',
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ]);
    }
  }
}
