// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// --------------Crear/modificar activo----------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs1/asset_code.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AssetDataPage extends StatelessWidget {
  ///  Class Key
  const AssetDataPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          await NavigationFunctions.checkLeavingPage(context, PageList.gestion);
          return true;
        },
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.gestion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: AssetData(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

/// Datos del activo
class AssetData extends StatelessWidget {
  ///  Class Key
  AssetData({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Capturar modelo de inventario
    final inventory = context.watch<InventoryModel>();
    // Capturar modelo de la empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de usuario
    final user = context.watch<UserModel>();
    // Capturar info de dispositivo Bluetooth
    final device = context.watch<BluetoothModel>();
    // Capturar modelo de imágenes
    final imageModel = context.watch<ImageModel>();
    var usershow = User();
    var usershowName = '';
    // Revisar integridad de los datos
    inventory.currentAsset.images ??= <AssetPhoto>[];
    if (inventory.currentAsset.custody == 'Sin Asignar') {
      inventory.currentAsset.custody = null;
    }
    if (inventory.currentAsset.status == '') {
      inventory.currentAsset.status = null;
    }
    if (inventory.currentAsset.categories == null) {
      inventory.currentAsset.categories = [AssetCategory(name: 'Category 1')];
    } else if (inventory.currentAsset.categories!.isEmpty) {
      inventory.currentAsset.categories?.add(AssetCategory(name: 'Category 1'));
    }
    // Valor inicial de códigos heredados
    var _legacyCode1 = '';
    var _legacyCode2 = '';
    var _serialNumber = '';
    if (inventory.currentAsset.assetCodeLegacy != null) {
      _legacyCode1 = inventory.currentAsset.assetCodeLegacy![0].value!;
      _legacyCode2 = inventory.currentAsset.assetCodeLegacy![1].value!;
    }
    _serialNumber = inventory.currentAsset.assetDetails?.serialNumber ?? '';
    if (inventory.currentAsset.custody != null &&
        inventory.currentAsset.custody != '') {
      if (!inventory.currentAsset.custody!.contains('(')) {
        for (var userfind in user.fullUsersList) {
          var aux = userfind.name!.givenName!;
          var aux1 = userfind.name!.middleName != ''
              ? ' ${userfind.name!.middleName!} '
              : ' ';
          var aux2 =
              userfind.name!.familyName != '' ? userfind.name!.familyName! : '';
          var aux3 = userfind.name!.additionalFamilyNames != ''
              ? userfind.name!.additionalFamilyNames!
              : '';
          final auxfind = aux + aux1 + aux2 + aux3;
          if (auxfind
                  .toLowerCase()
                  .replaceAll('í', 'i')
                  .replaceAll('ó', 'o')
                  .replaceAll('é', 'e')
                  .replaceAll('á', 'a') ==
              inventory.currentAsset.custody!
                  .toLowerCase()
                  .replaceAll('í', 'i')
                  .replaceAll('ó', 'o')
                  .replaceAll('é', 'e')
                  .replaceAll('á', 'a')) {
            usershow = userfind;
            break;
          }
        }
        if (usershow.name!.givenName != '') {
          for (var showU in user.localUsersList) {
            if (showU.contains(
                usershow.name!.givenName! + ' ' + usershow.name!.familyName!)) {
              usershowName = showU;
            }
          }
        }
      } else {
        for (var showU in user.localUsersList) {
          if (showU.contains(inventory.currentAsset.custody!)) {
            usershowName = showU;
          }
        }
      }
    }

    // Menú desplegable de categorías
    final _listOfCategories = _fillListOfCategories(inventory.categories);

    // Retorna fila de código (solo al modificar)
    TableRow _codeField() {
      if (inventory.currentAsset.id != null) {
        return TableRow(
          decoration: BoxDecoration(
            color: Colors.cyan[100],
          ),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Código del activo',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: inventory.currentAsset.assetCode != null
                  ? Text(inventory.currentAsset.assetCode!,
                      textAlign: TextAlign.left)
                  : const Text(
                      '(Activo sin código)',
                      textAlign: TextAlign.left,
                    ),
            ),
          ],
        );
      } else {
        return TableRow(children: [Container(), Container()]);
      }
    }

    // Retorna fila de cantidad de activos (solo al crear)
    TableRow _quantityField() {
      if (inventory.currentAsset.id == null) {
        return TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Cantidad (*)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: TextFormField(
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
                  FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                ],
                onChanged: (value) {
                  inventory.newAssetsQuantity = int.tryParse(value) ?? 1;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Ingrese dato';
                  } else {
                    if (int.tryParse(value)! > 100) {
                      return 'El número máximo de activos a crear\n'
                          'en una sola carga es 100.\n'
                          'Ingrese número válido.';
                    }
                    if (int.tryParse(value)! == 0) {
                      return 'Ingrese número válido.';
                    }
                  }
                  return null;
                },
              ),
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
            child: Text('Detalles del activo',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if ((imageModel.loadedImages.length <= 1 &&
                            imageModel.imageArray.isEmpty) ||
                        (imageModel.loadedImages.isEmpty &&
                            imageModel.imageArray.length <= 1))
                      Container()
                    else
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: (imageModel.photoIndex == 0)
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).highlightColor,
                        ),
                        tooltip: 'Atrás',
                        onPressed: () {
                          if (imageModel.photoIndex > 0) {
                            imageModel.decreaseIndex();
                          }
                        },
                      ),
                    imageModel.photoContents(context),
                    if ((imageModel.loadedImages.length <= 1 &&
                            imageModel.imageArray.isEmpty) ||
                        (imageModel.loadedImages.isEmpty &&
                            imageModel.imageArray.length <= 1))
                      Container()
                    else
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: (imageModel.photoIndex ==
                                  imageModel.allImages.length - 1)
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).highlightColor,
                        ),
                        tooltip: 'Adelante',
                        onPressed: () {
                          if (imageModel.photoIndex <
                              imageModel.allImages.length - 1) {
                            imageModel.increaseIndex();
                          }
                        },
                      ),
                  ],
                ),
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
                      child: Column(children: imageModel.myPictures(context)),
                    )
                  ],
                )
              ],
            ),
          ),
          // Nota de campos requeridos
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('Los campos con (*) son requeridos.'),
          ),
          // Tabla de detalles del activo
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
                  _codeField(),
                  // Fila de nombre
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Nombre del activo (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: inventory.currentAsset.name,
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
                            inventory.currentAsset.name = value.trim();
                          },
                          maxLength: 20,
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
                  // Fila de descripción
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Descripción (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue: inventory.currentAsset.description,
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
                            inventory.currentAsset.description = value.trim();
                          },
                          maxLength: 30,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Ingrese dato';
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                  // Fila de responsable
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Responsable',
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
                          value: usershowName == '' ? null : usershowName,
                          icon: Icon(Icons.arrow_downward,
                              color: Theme.of(context).highlightColor),
                          elevation: 16,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.brown),
                          onChanged: (newValue) {
                            inventory.changeAssetCustody(newValue!);
                            company.asigneLocations(user.fullUsersList
                                .where((element) =>
                                    element.userName ==
                                    newValue
                                        .split(' ')[2]
                                        .replaceAll('(', '')
                                        .replaceAll(')', ''))
                                .first);
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
                  if (inventory.currentAsset.custody != null &&
                      inventory.currentAsset.custody != '')
                    // Fila de ubicación
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Ubicación (*)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: inventory.currentAsset.locationName,
                            icon: Icon(Icons.arrow_downward,
                                color: Theme.of(context).highlightColor),
                            elevation: 16,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.brown),
                            onChanged: (newValue) {
                              inventory.changeAssetLocation(newValue!);
                            },
                            items: company.placesUser
                                .map<DropdownMenuItem<String>>((value) =>
                                    DropdownMenuItem<String>(
                                        value: value, child: Text(value)))
                                .toList(),
                          ),
                        ),
                      ],
                    ),

                  // Fila de estado
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Estado (*)',
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
                          value: inventory.currentAsset.status,
                          icon: Icon(Icons.arrow_downward,
                              color: Theme.of(context).highlightColor),
                          elevation: 16,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.brown),
                          onChanged: (newValue) {
                            inventory.changeAssetCondition(newValue!);
                          },
                          items: inventory.conditions
                              .map<DropdownMenuItem<String>>((value) =>
                                  DropdownMenuItem<String>(
                                      value: value, child: Text(value)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  if (inventory.currentAsset.status == 'De baja')
                    // Fila de estado
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Motivo por el cual se da de baja (*)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: TextFormField(
                            initialValue:
                                inventory.currentAsset.downAnotation ?? '',
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
                                  RegExp('[\n\t\r]'))
                            ],
                            onChanged: (value) {
                              inventory.currentAsset.downAnotation =
                                  value.trim();
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
                  // Fila de categoría
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Categoría',
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
                          value: inventory.currentAsset.categories?.first.value,
                          icon: Icon(Icons.arrow_downward,
                              color: Theme.of(context).highlightColor),
                          elevation: 16,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.brown),
                          onChanged: (newValue) async {
                            // Permite crear categoría nueva sobre la marcha
                            if (newValue == '--(Crear nueva categoría)--') {
                              // Llave para el formulario de captura de datos
                              final _internalFormKey = GlobalKey<FormState>();
                              var _internalFieldValue = inventory
                                  .currentAsset.categories?.first.value;
                              await showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Categoría'),
                                  content: SingleChildScrollView(
                                    child: Form(
                                      key: _internalFormKey,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          labelText: 'Categoría',
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.deny(
                                            RegExp('[\n\t\r]'),
                                          )
                                        ],
                                        onChanged: (value) {
                                          _internalFieldValue = value;
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
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (_internalFormKey.currentState!
                                            .validate()) {
                                          inventory.categories
                                              .add(_internalFieldValue!);
                                          Navigator.of(context).pop();
                                          inventory.changeAssetCategory(
                                              _internalFieldValue!);
                                        }
                                      },
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              inventory.changeAssetCategory(newValue!);
                            }
                          },
                          items: _listOfCategories,
                        ),
                      ),
                    ],
                  ),
                  // Fila de fabricante
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Fabricante',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: TextFormField(
                          initialValue:
                              inventory.currentAsset.assetDetails?.make,
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
                            inventory.currentAsset.assetDetails?.make =
                                value.trim();
                          },
                          maxLength: 20,
                        ),
                      ),
                    ],
                  ),
                  // Fila de serial
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Número serial (*)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Column(
                          children: [
                            // Valor del serial
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: (_serialNumber.isNotEmpty)
                                  ? TextFormField(
                                      initialValue: _serialNumber,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 5),
                                        labelText: 'Serial',
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[0-9-.A-Za-z]'))
                                      ],
                                      onChanged: (value) {
                                        inventory.currentAsset.assetDetails
                                            ?.serialNumber = value;
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Debe asignar un valor';
                                        } else if (value.isEmpty) {
                                          return 'Debe asignar un valor';
                                        }
                                      },
                                      maxLength: 30,
                                    )
                                  : TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 5),
                                        labelText: 'Serial',
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[0-9-.A-Za-z]'))
                                      ],
                                      onChanged: (value) {
                                        inventory.currentAsset.assetDetails
                                            ?.serialNumber = value;
                                      },
                                    ),
                            ),
                            // Botón de ingreso por lector
                            Container(
                              margin: const EdgeInsets.all(10),
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Se activa lectura de código "externo"
                                  device.unrelatedReading = true;
                                  final newFieldValue =
                                      await _readBarcode(context);
                                  // Actualizar valor mostrado en el campo
                                  if (newFieldValue.isNotEmpty) {
                                    inventory.currentAsset.assetDetails
                                        ?.serialNumber = newFieldValue;
                                  }
                                  // Se desactiva lectura de código "externo"
                                  device
                                    ..unrelatedReading = false
                                    ..newExternalcode('');
                                },
                                child: const Text('Usar lector'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Fila de Código heredado 1
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Código heredado 1',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Column(
                          children: [
                            // Descripción
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: TextFormField(
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
                                  labelText: 'Tipo de código',
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp('[\n\t\r]'))
                                ],
                                onChanged: (value) {
                                  inventory.currentAsset.assetCodeLegacy![0]
                                      .system = value;
                                },
                                validator: (value) {
                                  if (value!.isEmpty &&
                                      inventory.currentAsset.assetCodeLegacy![0]
                                          .value!.isNotEmpty) {
                                    return 'Ingrese dato';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Valor
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: (_legacyCode1.isNotEmpty)
                                  ? TextFormField(
                                      initialValue: _legacyCode1,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 5),
                                        labelText: 'Valor del código',
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp('[\n\t\r]'))
                                      ],
                                      onChanged: (value) {
                                        inventory.currentAsset
                                            .assetCodeLegacy![0].value = value;
                                      },
                                      validator: (value) {
                                        if (value!.isNotEmpty) {
                                          // Revisar si el código ya fue
                                          //registrado previamente
                                          if (inventory.uniqueCodeExists(
                                              [value], 'legacy').isNotEmpty) {
                                            return 'Este código ya fue '
                                                'registrado.';
                                          }
                                        }
                                        return null;
                                      },
                                    )
                                  : TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 5),
                                        labelText: 'Valor del código',
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp('[\n\t\r]'))
                                      ],
                                      onChanged: (value) {
                                        inventory.currentAsset
                                            .assetCodeLegacy![0].value = value;
                                      },
                                    ),
                            ),
                            // Botón de ingreso por lector
                            Container(
                              margin: const EdgeInsets.all(10),
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Se activa lectura de código "externo"
                                  device.unrelatedReading = true;
                                  final newFieldValue =
                                      await _readBarcode(context);
                                  // Actualizar valor mostrado en el campo
                                  if (newFieldValue.isNotEmpty) {
                                    inventory.currentAsset.assetCodeLegacy![0]
                                        .value = newFieldValue;
                                  }
                                  // Se desactiva lectura de código "externo"
                                  device
                                    ..unrelatedReading = false
                                    ..newExternalcode('');
                                },
                                child: const Text('Usar lector'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Fila de Código heredado 2
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Código heredado 2',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Column(
                          children: [
                            // Descripción
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: TextFormField(
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
                                  labelText: 'Tipo de código',
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp('[\n\t\r]'))
                                ],
                                onChanged: (value) {
                                  inventory.currentAsset.assetCodeLegacy![1]
                                      .system = value;
                                },
                                validator: (value) {
                                  if (value!.isEmpty &&
                                      inventory.currentAsset.assetCodeLegacy![1]
                                          .value!.isNotEmpty) {
                                    return 'Ingrese dato';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Valor
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: (_legacyCode2.isNotEmpty)
                                  ? TextFormField(
                                      initialValue: _legacyCode2,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 5),
                                        labelText: 'Valor del código',
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp('[\n\t\r]'))
                                      ],
                                      onChanged: (value) {
                                        inventory.currentAsset
                                            .assetCodeLegacy![1].value = value;
                                      },
                                      validator: (value) {
                                        if (value!.isNotEmpty) {
                                          // Revisar si el código ya fue
                                          // registrado previamente
                                          if (inventory.uniqueCodeExists(
                                              [value], 'legacy').isNotEmpty) {
                                            return 'Este código ya fue '
                                                'registrado.';
                                          }
                                        }
                                        return null;
                                      },
                                    )
                                  : TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 5),
                                        labelText: 'Valor del código',
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp('[\n\t\r]'))
                                      ],
                                      onChanged: (value) {
                                        inventory.currentAsset
                                            .assetCodeLegacy![1].value = value;
                                      },
                                    ),
                            ),
                            // Botón de ingreso por lector
                            Container(
                              margin: const EdgeInsets.all(10),
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Se activa lectura de código "externo"
                                  device.unrelatedReading = true;
                                  final newFieldValue =
                                      await _readBarcode(context);
                                  // Actualizar valor mostrado en el campo
                                  if (newFieldValue.isNotEmpty) {
                                    inventory.currentAsset.assetCodeLegacy![1]
                                        .value = newFieldValue;
                                  }
                                  // Se desactiva lectura de código "externo"
                                  device
                                    ..unrelatedReading = false
                                    ..newExternalcode('');
                                },
                                child: const Text('Usar lector'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Fila de cantidad
                  _quantityField(),
                  // Fila de cercanía a antena
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '¿Se encuentra en proximidades de una antena?',
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
                              value: NearAntenna.near,
                              groupValue: inventory.nearAntenna,
                              onChanged: (final value) {
                                inventory
                                    .updateNearAntenna(value! as NearAntenna);
                              },
                            ),
                          ),
                          ListTile(
                            dense: true,
                            title: const Text('No'),
                            leading: Radio(
                              value: NearAntenna.notNear,
                              groupValue: inventory.nearAntenna,
                              onChanged: (final value) {
                                inventory
                                    .updateNearAntenna(value! as NearAntenna);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Botones
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón de cancelar
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
                        if (inventory.currentAsset.locationName == null) {
                          HenutsenDialogs.showSnackbar(
                              'Seleccione una '
                              'ubicación',
                              context);
                        } else if (inventory.currentAsset.status == null) {
                          HenutsenDialogs.showSnackbar(
                              'Seleccione un '
                              'estado',
                              context);
                          // Si se carga serial, asegurar que solo se cree
                          // un activo
                        } else if (inventory
                                    .currentAsset.assetDetails?.serialNumber !=
                                null &&
                            inventory.currentAsset.assetDetails?.serialNumber !=
                                '' &&
                            inventory.newAssetsQuantity != 1) {
                          HenutsenDialogs.showSnackbar(
                              'No puede crear varios activos con el '
                              'mismo número serial. Por favor revise.',
                              context);
                          // Revisar si el código ya fue registrado previamente
                        } else if (inventory
                                    .currentAsset.assetDetails?.serialNumber !=
                                null &&
                            inventory.currentAsset.assetDetails?.serialNumber !=
                                '' &&
                            inventory.uniqueCodeExists([
                              inventory.currentAsset.assetDetails!.serialNumber!
                            ], 'serial').isNotEmpty) {
                          HenutsenDialogs.showSnackbar(
                              'Este código serial ya fue registrado. '
                              'Por favor revise.',
                              context);
                        } else if (inventory
                                    .currentAsset.assetDetails?.serialNumber ==
                                null ||
                            inventory.currentAsset.assetDetails?.serialNumber ==
                                '') {
                          HenutsenDialogs.showSnackbar(
                              'Debe asignar un código serial.', context);
                        } else {
                          // Modificar estado de cercanía de antena
                          if (inventory.nearAntenna == NearAntenna.near) {
                            inventory.currentAsset.isNearAntenna = true;
                          } else {
                            inventory.currentAsset.isNearAntenna = false;
                          }
                          // Acciones dependen de si se crea o modifica activo
                          // Si el id es nulo, se asume que estamos en creación
                          if (inventory.currentAsset.id == null) {
                            // Se espera confirmación del usuario
                            if (await HenutsenDialogs.confirmationMessage(
                                context,
                                '¿Confirma creación del activo:\n'
                                '${inventory.currentAsset.name}?')) {
                              // Capturar info adicional de empresa
                              final _cCode = company.currentCompany.companyCode;
                              final _companyData = company.currentCompany;
                              // Para usar la clase AssetCode
                              final _assetCode = AssetCode();
                              // Recopilar códigos existentes para generar
                              // los nuevos
                              final _fullInventoryCodes = <String>[];
                              for (final item in inventory.fullInventory) {
                                if (item.assetCode != null) {
                                  if (item.assetCode!.isNotEmpty) {
                                    _fullInventoryCodes.add(item.assetCode!);
                                  }
                                }
                              }
                              // Agregar datos restantes al activo a crear
                              inventory.currentAsset
                                ..companyCode = _cCode
                                ..downAnotation =
                                    inventory.currentAsset.downAnotation ?? ''
                                ..assetCode = null
                                ..images = []
                                ..outOfLocation = false
                                ..tagEncoded = false;
                              final _newCodesList = [];
                              // Capturar el usuario
                              final user = context.read<UserModel>();
                              // Mapa para recopilar información a enviar
                              final _itemsToSend = <String, dynamic>{
                                'AssetBase': '',
                                'Codes': '',
                                'UserName': user.userName
                              };
                              // Llenar lista de nuevos códigos por cada activo
                              // a crear
                              for (var j = 0;
                                  j < inventory.newAssetsQuantity;
                                  j++) {
                                final _newCode = _assetCode.newAssetCode(
                                    _fullInventoryCodes,
                                    _companyData.companyCode!);
                                _newCodesList.add(_newCode);
                                _fullInventoryCodes.add(_newCode);
                              }
                              // Cargar mapa a enviar
                              _itemsToSend['AssetBase'] =
                                  inventory.currentAsset;
                              _itemsToSend['Codes'] = _newCodesList;
                              final jsonToSend = jsonEncode(_itemsToSend);
                              //print(jsonToSend);
                              _result = await inventory.newAsset(
                                  imageModel.imageArray,
                                  jsonToSend,
                                  inventory.newAssetsQuantity,
                                  '${user.currentUser.name!.givenName}'
                                  ' ${user.currentUser.name!.familyName}'
                                  ' ${user.currentUser.userName}',
                                  user.name2show);
                              if (_result == 'Ok') {
                                _success = true;
                                _dialogText = 'Activo creado exitosamente';
                              } else {
                                _dialogText = 'Error creando activo.\n'
                                    '$_result.\n'
                                    'Revise e intente nuevamente.';
                              }
                            }
                            // Si el activo está bajo modificación
                          } else {
                            // Se espera confirmación del usuario
                            if (await HenutsenDialogs.confirmationMessage(
                                context,
                                '¿Confirma modificación del activo:\n'
                                '${inventory.currentAsset.name}?')) {
                              final myAsset = inventory.currentAsset;
                              final _itemsToSend = {
                                'AssetBase': myAsset,
                                'UserName': user.currentUser.userName
                              };
                              // Revisar si se eliminaron imágenes anteriores
                              if (myAsset.images!.length >
                                  imageModel.loadedImages.length) {
                                myAsset.images!.removeWhere((element) =>
                                    !imageModel.loadedImages
                                        .contains(element.picture));
                              }
                              final chain = jsonEncode(_itemsToSend);
                              //print(chain);
                              _result = await inventory.modifyAsset(
                                  chain,
                                  '${user.currentUser.name!.givenName}'
                                  ' ${user.currentUser.name!.familyName}'
                                  ' ${user.currentUser.userName}',
                                  files2send: imageModel.imageArray);
                              if (_result == 'Ok') {
                                _success = true;
                                _dialogText = 'Activo modificado exitosamente';
                              } else {
                                _dialogText = 'Error modificando activo.\n'
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
                                  child: Text(
                                    _dialogText,
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
                                      if (_success) {
                                        // Capturar empresa
                                        final company =
                                            context.read<CompanyModel>();
                                        // Actualizar inventario
                                        inventory.initInventory();
                                        await inventory.loadInventory(company
                                            .currentCompany.companyCode!);
                                        if (company.currentLocation != null) {
                                          inventory.extractLocalItems(
                                              company.currentLocation!);
                                        }
                                        // Capturar estadísticas
                                        context
                                            .read<StatisticsModel>()
                                            .clearStatus();
                                        Navigator.popUntil(
                                          context,
                                          ModalRoute.withName('/lista-activos'),
                                        );
                                        // Reiniciar estado de selector de
                                        // cercanía de antena
                                        inventory.nearAntenna =
                                            NearAntenna.notNear;
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
                    child: (inventory.currentAsset.id == null)
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

  // Método para desplegar ventana de lectura de códigos de barras
  Future<String> _readBarcode(BuildContext context) async {
    final reading = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // Capturar dispositivo BT
        final device = context.watch<BluetoothModel>();
        // Capturar información de inventario
        final inventory = context.read<InventoryModel>();
        // Capturar información de empresa
        final company = context.read<CompanyModel>();

        // Función llamada al presionar gatillo del lector
        Future<dynamic> _platformCallHandler(MethodCall call) async {
          switch (call.method) {
            case 'keyCallback1':
              if (device.loopFlag) {
                await inventory.stopInventory(device);
              } else {
                await inventory.startInventory(
                    device, company.currentCompany.companyCode!);
              }
              break;
            case 'keyCallback2':
              await inventory.readBarcode(device);
              break;
            default:
              throw MissingPluginException();
          }
        }

        // Revisar si ya hay dispositivo conectado y ya se asignó
        // callback de gatillo
        if (device.gotDevice && !device.callbackSet) {
          // Inicializar función DART llamada desde Android
          r6_plugin.initLocalCallback(_platformCallHandler);
          // Establecer evento de respuesta para gatillo del lector
          r6_plugin.setKeyEventCallback(1);
          device.callbackSet = true;
        }

        // Variable para lectura de código de barras
        final _barcode = device.externalCodeReading ?? '';
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Código leído:',
                  style: Theme.of(context).textTheme.headline3,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 100),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(5),
                  child: Text(_barcode, textAlign: TextAlign.center),
                ),
                Text(
                  (device.gotDevice)
                      ? '(Lector activo)'
                      : '(Configure primero el lector)',
                  style: (device.gotDevice)
                      ? const TextStyle(color: Colors.blue)
                      : const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/config-lector');
                        },
                        child: const Text('Configurar\nlector',
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: (_barcode != '')
                              ? Theme.of(context).highlightColor
                              : Theme.of(context).disabledColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          if (_barcode != '') {
                            Navigator.of(context).pop(_barcode);
                          }
                        },
                        child: const Text('Usar código'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
    return reading ?? '';
  }

  // Método para llenar listado de categorías
  List<DropdownMenuItem<String>> _fillListOfCategories(List<String> catList) {
    final categoryList = catList
        .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
              value: value,
              child: SizedBox(
                width: 180,
                child: Text(value),
              ),
            ))
        .toList()
      // Agregar opción "(Crear nueva categoría)" al final
      // del menú de categorías
      ..add(
        const DropdownMenuItem<String>(
          value: '--(Crear nueva categoría)--',
          child: SizedBox(
            width: 180,
            child: Text(
              '--(Crear nueva categoría)--',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    return categoryList;
  }
}
