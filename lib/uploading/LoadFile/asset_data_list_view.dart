// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------------------------------
// ------------------Lista activos y mapeo de campos mapeados------------------
// ----------------------------------------------------------------------------

import 'package:csv_parser/csv_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/uploading/LoadFile/Model/decoded_asset.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/process_file.dart';
import 'package:provider/provider.dart';

import '../../provider/user_model.dart';

/// Clase para ver los datos precargados en listas
class AssetDataListView extends StatelessWidget {
  ///  Class Key
  const AssetDataListView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => _onBackPressed(context),
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.cargasMasivas,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.cargasMasivas),
          body: DataListView(),
          bottomNavigationBar: BottomBar.bottomBar(
            PageList.cargasMasivas,
            context,
            PageList.cargasMasivas,
            thisPage: true,
          ),
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

///Clase para ver la lista
// ignore: must_be_immutable
class DataListView extends StatelessWidget {
  ///  Class Key
  DataListView({Key? key}) : super(key: key);

  final _rowTitlesMap = <String, String>{};
  final _boxesText = <String>[];
  bool _titlesLoaded = false;
  final _verticalController = ScrollController();
  final _horizontalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Para manipular el nombre del archivo
    String simplifiedFileName;
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;

    final assetProvider = Provider.of<CsvParserProvider<CsvAsset>>(context);

    final fileName = (assetProvider.state != CsvParserState.idle)
        ? assetProvider.csvFile.fileName
        : 'Sin selección';
    if (fileName[0].toLowerCase() == 'c' && fileName[1] == ':') {
      simplifiedFileName = fileName.split('/').last;
    } else {
      simplifiedFileName = fileName;
    }

    final titlesList = assetProvider.rowsAsList[0];

    return Column(
      children: [
        // Título página
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Vista previa',
              style: Theme.of(context).textTheme.headline3),
        ),
        Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  'Archivo: $simplifiedFileName',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  'Por favor asocie los campos',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
          // Botones
          Container(
            padding: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: (mediaSize.width < screenSizeLimit) ? 5 : 20),
            child: (mediaSize.width < screenSizeLimit)
                ?
                // Pantalla chica
                Column(children: [
                    // Botón de volver
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ElevatedButton(
                        onPressed: () async {
                          await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('¡Atención!'),
                              content: const Text(
                                  '¿Desea salir sin guardar cambios?'),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).highlightColor,
                                  ),
                                  onPressed: () {
                                    Navigator.popUntil(context,
                                        ModalRoute.withName('/cargar-archivo'));
                                  },
                                  child: const Text('Sí'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Volver'),
                      ),
                    ),
                    // Botón de aceptar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).highlightColor,
                        ),
                        onPressed: () async {
                          await _acceptButtonActions(
                              context, simplifiedFileName);
                        },
                        child: const Text('Aceptar'),
                      ),
                    ),
                  ])
                : // Pantalla grande
                Row(children: [
                    // Botón de volver
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('¡Atención!'),
                              content: const Text(
                                  '¿Desea salir sin guardar cambios?'),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).highlightColor,
                                  ),
                                  onPressed: () {
                                    Navigator.popUntil(context,
                                        ModalRoute.withName('/cargar-archivo'));
                                  },
                                  child: const Text('Sí'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Volver'),
                      ),
                    ),
                    // Botón de aceptar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).highlightColor,
                        ),
                        onPressed: () async {
                          await _acceptButtonActions(
                              context, simplifiedFileName);
                        },
                        child: const Text('Aceptar'),
                      ),
                    ),
                  ]),
          )
        ]),
        Flexible(
          child: Scrollbar(
            controller: _horizontalController,
            isAlwaysShown: kIsWeb,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: Scrollbar(
                controller: _verticalController,
                isAlwaysShown: kIsWeb,
                child: SingleChildScrollView(
                  controller: _verticalController,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DataTable(
                          sortColumnIndex: 0,
                          columns: _listNameColumns(context, titlesList),
                          rows: assetProvider.rowsAsList
                              .map((e) => DataRow(
                                  cells: e
                                      .map((lista) =>
                                          DataCell(Text(lista.toString())))
                                      .toList()))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Método para definir las acciones del botón "Aceptar"
  Future<void> _acceptButtonActions(
    BuildContext context,
    String fileName,
  ) async {
    final company = context.read<CompanyModel>();
    final user = context.read<UserModel>();
    final scrollController = ScrollController();

    // Banderas para indicar si ya se mapearon estos campos por parte
    // del usuario
    var _locationB = false;
    var _nameB = false;
    var _assetCodeLegacy1B = false;
    var _assetCodeLegacy2B = false;
    var _serialNumberB = false;

    // Indica si hay nuevas ubicaciones a guardar
    var _newLocations = 0;

    // Indica si hay usuarios que no se encuentran creados
    var _newUsers = 0;

    //variable del archivo CsvAsset
    final assetProvider =
        Provider.of<CsvParserProvider<CsvAsset>>(context, listen: false);

    // Información del archivo
    final fileInformation = Provider.of<DataFile>(context, listen: false);

    // Método para desplegar mensaje de advertencia
    void _showMessage(String textToShow) {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(textToShow)],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    // Verificación de campos mínimos requeridos y otros importantes
    _rowTitlesMap.forEach((key, value) {
      if (key == 'location') {
        _locationB = true;
      }
      if (key == 'name') {
        _nameB = true;
      }
      if (key == 'assetCodeLegacy1') {
        _assetCodeLegacy1B = true;
      }
      if (key == 'assetCodeLegacy2') {
        _assetCodeLegacy2B = true;
      }
      if (key == 'serialNumber') {
        _serialNumberB = true;
      }
    });
    // Verificar si la extensión de archivo es csv
    if (fileName.split('.').last != 'csv') {
      _showMessage('El archivo no tiene la extensión requerida (.csv).\n'
          'Por favor verifique y vuelva a intentar.');
      // Verificar si se mapeó el campo "Ubicación"
    } else if (!_locationB) {
      _showMessage(
          'El archivo no contiene la columna "Ubicación" y esta es requerida.\n'
          'Por favor verifique y vuelva a intentar');
      // Verificar si se mapeó el campo "Nombre"
    } else if (!_nameB) {
      _showMessage(
          'El archivo no contiene la columna "Nombre" y esta es requerida\n'
          'Por favor verifique y vuelva a intentar');
    } else {
      // Capturar inventario
      final inventory = context.read<InventoryModel>()
        // Cargar inventario
        ..initInventory();
      await inventory.loadInventory(company.currentCompany.companyCode!);
      // Objeto para cambiar el estado
      final fileData = Provider.of<DataFile>(context, listen: false);
      // Definir objeto csv
      final processData = CsvFile(
        fileInformation.fileName!,
        [0, 0],
        CsvAssetFactory(fieldsMap: _rowTitlesMap),
      );
      // Cargando la lista de objetos
      await assetProvider.load(processData);

      // Listas para códigos repetidos, si los hay
      var _repeatedCodes1 = [];
      var _repeatedCodes2 = [];
      var _repeatedSerials = [];
      var _repeatedSerialsDB = [];
      //List<String> _repeatedCodes1DB = [];
      //List<String> _repeatedCodes2DB = [];

      // Verificar si se mapeó el campo "Código de activo" 1 o 2
      // o "Número serial"
      if (_assetCodeLegacy1B || _assetCodeLegacy2B || _serialNumberB) {
        // Verificar si se mapeó el campo "Código de activo 1"
        if (_assetCodeLegacy1B) {
          // Verificar códigos no repetidos en archivo
          _repeatedCodes1 =
              fileData.codeNotUnique(assetProvider.objects, 'legacy');
          // Verificar códigos no repetidos contra base de datos
          //_repeatedCodes1DB = fileData.legacyCodeExists(
          //    assetProvider.objects, inventory.fullInventory, 1);
        }
        // Verificar si se mapeó el campo "Código de activo 2"
        if (_assetCodeLegacy2B) {
          // Verificar código no repetido en archivo
          _repeatedCodes2 =
              fileData.codeNotUnique(assetProvider.objects, 'legacy');
          // Verificar códigos no repetidos contra base de datos
          //_repeatedCodes2DB = fileData.legacyCodeExists(
          //    assetProvider.objects, inventory.fullInventory, 2);
        }
        // Verificar si se mapeó el campo "Número serial"
        if (_serialNumberB) {
          // Verificar código no repetido en archivo
          _repeatedSerials =
              fileData.codeNotUnique(assetProvider.objects, 'serial');
          // Verificar códigos no repetidos contra base de datos
          final _serialsLoaded = <String>[];
          for (final element in assetProvider.objects) {
            if (element.serialNumber != null && element.serialNumber != '') {
              _serialsLoaded.add(element.serialNumber!);
            }
          }
          _repeatedSerialsDB =
              inventory.uniqueCodeExists(_serialsLoaded, 'serial');
        }
      }

      // Verificar si TODOS los campos requeridos (Nombre y Ubicación)
      // tienen contenido válido
      if (!fileData.validRequiredFields(assetProvider.objects)) {
        _showMessage(
            'Todos los campos "Nombre" y "Ubicación" deben contener datos.\n'
            'Por favor verifique y vuelva a intentar');
        // Verificar si se están cargando códigos repetidos
      } else if (_repeatedCodes1.isNotEmpty || _repeatedCodes2.isNotEmpty) {
        _showMessage('Existen códigos heredados de activos repetidos en el '
            'archivo.\n$_repeatedCodes1\n'
            'Por favor verifique y vuelva a intentar.');
        // Verificar si se están cargando seriales repetidos
      } else if (_repeatedSerials.isNotEmpty) {
        _showMessage('Existen número seriales repetidos en el archivo.\n'
            '$_repeatedSerials\n'
            'Por favor verifique y vuelva a intentar.');
        // Verificar si se están cargando seriales ya existentes
      } else if (_repeatedSerialsDB.isNotEmpty) {
        _showMessage('Existen número seriales en el archivo que ya han sido '
            'cargados.\n'
            '$_repeatedSerialsDB\n'
            'Por favor verifique y vuelva a intentar.');
        /*
      // Verificar si se están cargando códigos ya existentes (1)
      } else if (_repeatedCodes1DB.isNotEmpty) {
        _showMessage('Existen códigos de activos ya registrados previamente.\n'
            '${_repeatedCodes1DB}\n'
            'Por favor verifique y vuelva a intentar.');
      // Verificar si se están cargando códigos ya existentes (2)
      } else if (_repeatedCodes2DB.isNotEmpty) {
        _showMessage('Existen códigos de activos ya registrados previamente.\n'
            '${_repeatedCodes2DB}\n'
            'Por favor verifique y vuelva a intentar.');
        */
      } else {
        await user.getUsersList();
        // Generar listado de códigos ya usados en el inventario de la empresa
        final _fullInventoryCodes = <String>[];
        for (final item in inventory.fullInventory) {
          if (item.assetCode != null) {
            if (item.assetCode!.isNotEmpty) {
              _fullInventoryCodes.add(item.assetCode!);
            }
          }
        }

        final _usersMissing =
            fileData.verifyCustody(user.fullUsersList, assetProvider.objects);
        if (_usersMissing.isNotEmpty) {
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (_) => AlertDialog(
              content: SingleChildScrollView(
                child: ListBody(
                  children: _usersMissing.map((e) {
                    _newUsers++;
                    if (_newUsers == 1) {
                      return Text(
                          'Estos usuario no están registrados en Henutsen: \n\n'
                          '${e.toString()}');
                    } else {
                      return Text(e.toString());
                    }
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.all(6),
                      child: const Text(
                        'Por favor primero cree los usuarios, y luego'
                        ' vuelva a intentar ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).highlightColor,
                      ),
                      child: const Text('Aceptar'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              ],
            ),
          );
          return;
        }
        // Verificar si hay nuevas ubicaciones no existentes aún en la empresa
        final _newPlacesBool =
            fileData.processLocations(assetProvider.objects, company.places);
        if (_newPlacesBool) {
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (_) => AlertDialog(
              content: SingleChildScrollView(
                child: ListBody(
                  children: fileData.newLocations.map((e) {
                    _newLocations++;
                    if (_newLocations == 1) {
                      return Text('Hay nuevas ubicaciones a crear: \n\n'
                          '${e.toString()}');
                    } else {
                      return Text(e.toString());
                    }
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.all(6),
                      child: const Text(
                        '¿Desea continuar?',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      width: 500,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            child: const Text(
                              'Cancelar',
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).highlightColor,
                            ),
                            child: const Text('Aceptar'),
                            onPressed: () {
                              fileData.processFileData(
                                assetProvider.objects,
                                _fullInventoryCodes,
                                company.currentCompany.companyCode!,
                              );
                              Navigator.popUntil(context,
                                  ModalRoute.withName('/cargar-archivo'));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        } else {
          fileData.processFileData(
            assetProvider.objects,
            _fullInventoryCodes,
            company.currentCompany.companyCode!,
          );
          Navigator.pop(context);
        }
      }
    }
  }

  // Devuelve el nombre de las columnas
  List<DataColumn> _listNameColumns(
      BuildContext context, List<dynamic> rowList) {
    final fieldMapping = Provider.of<FieldMappingModel>(context);

    final lisC = <DataColumn>[];

    for (var i = 0; i < rowList.length; i++) {
      //print('row $i: ${rowList[i]}');
      if (!_titlesLoaded) {
        // Asociar campos encontrados en el archivo con campos requeridos
        for (var y = 0; y < fieldMapping.columnNames.length; y++) {
          //print('prov $y: ${fieldMapping.columnNames[y]}');
          // Eliminar tildes y transformar a minúsculas
          final tit1 = rowList
              .elementAt(i)
              .toString()
              .toLowerCase()
              .replaceAll(RegExp('ó'), 'o')
              .replaceAll(RegExp('í'), 'i')
              .replaceAll(RegExp('é'), 'e')
              .replaceAll(RegExp('á'), 'a')
              .replaceAll(RegExp('ú'), 'u');
          final tit2 = fieldMapping.columnNames
              .elementAt(y)
              .toString()
              .toLowerCase()
              .replaceAll(RegExp('ó'), 'o')
              .replaceAll(RegExp('í'), 'i')
              .replaceAll(RegExp('é'), 'e')
              .replaceAll(RegExp('á'), 'a')
              .replaceAll(RegExp('ú'), 'u');

          if (tit1.replaceAll('.', '.') == tit2.replaceAll('.', '.')) {
            _boxesText.add(fieldMapping.columnNames.elementAt(y));
            final aux = _associateField(fieldMapping.columnNames[y]);
            if (_rowTitlesMap.containsKey(aux)) {
              _rowTitlesMap.update(aux, (value) => rowList[i]);
            } else {
              _rowTitlesMap[aux] = rowList[i];
            }
          }
        }
        // Si no se encontró campo para asociar, agregar "No cargar"
        if (_boxesText.length < i + 1) {
          _boxesText.add('No Cargar');
        }
      }

      final col = DataColumn(
        label: SizedBox(
          width: 150,
          height: 40,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(7)),
            ),
            child: DropdownButton<String>(
              value: _boxesText[i],
              elevation: 16,
              style: const TextStyle(fontSize: 11, color: Colors.brown),
              icon: Icon(Icons.arrow_downward,
                  color: Theme.of(context).highlightColor),
              onChanged: (newValue) {
                String? aux;
                // Si se seleccionó un valor diferente a "No cargar"
                if (newValue != 'No Cargar') {
                  for (var j = 0; j < _boxesText.length; j++) {
                    // Si ya estaba asignado, se reasigna el título de la otra
                    // columna a "No Cargar"
                    if (newValue == _boxesText[j]) {
                      _boxesText[j] = 'No Cargar';
                    }
                  }
                  aux = _associateField(newValue!);
                  // Actualizar mapa
                  _rowTitlesMap
                      .removeWhere((key, value) => value == rowList[i]);
                  _rowTitlesMap[aux] = rowList[i];
                  // Si se seleccionó "No cargar"
                } else {
                  if (_boxesText[i] != 'No cargar') {
                    aux = _associateField(_boxesText[i]);
                    _rowTitlesMap.remove(aux);
                  }
                }
                _boxesText[i] = newValue!;
                fieldMapping.updateFields();
              },
              items: fieldMapping.columnNames
                  .map<DropdownMenuItem<String>>(
                      (value) => DropdownMenuItem<String>(
                            value: value,
                            child: SizedBox(width: 100, child: Text(value)),
                          ))
                  .toList(),
            ),
          ),
        ),
      );
      lisC.add(col);
    }
    _titlesLoaded = true;
    return lisC;
  }

  // Retorna el campo asociado con el título de la columna recibido
  String _associateField(String text) {
    var result = '';
    if (text == 'Código Heredado 1') {
      result = 'assetCodeLegacy1';
    } else if (text == 'Código Heredado 2') {
      result = 'assetCodeLegacy2';
    } else if (text == 'Ubicación') {
      result = 'location';
    } else if (text == 'Nombre') {
      result = 'name';
    } else if (text == 'Descripción') {
      result = 'description';
    } else if (text == 'Categorias') {
      result = 'categories';
    } else if (text == 'Modelo') {
      result = 'model';
    } else if (text == 'Número Serial') {
      result = 'serialNumber';
    } else if (text == 'Fabricante') {
      result = 'make';
    } else if (text == 'Responsable') {
      result = 'custody';
    } else if (text == 'Estado') {
      result = 'status';
    } else if (text == 'Cantidad') {
      result = 'stock';
    }
    return result;
  }
}
