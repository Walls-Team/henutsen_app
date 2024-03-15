// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// -------------------------------------------------------
// --------------------Subir archivo----------------------
// -------------------------------------------------------

import 'package:csv_parser/csv_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/uploading/LoadFile/Model/decoded_asset.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/load_data.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/process_file.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/// Carga de archivos
class UploadFilePage extends StatelessWidget {
  /// Class key
  const UploadFilePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.cargasMasivas),
          endDrawer: MenuDrawer.drawer(context, PageList.cargasMasivas),
          body: const BodyFileResponse(),
          bottomNavigationBar: BottomBar.bottomBar(
            PageList.cargasMasivas,
            context,
            PageList.cargasMasivas,
            thisPage: true,
          ),
        ),
      );
}

/// Clase para cargar el archivo csv
class BodyFileResponse extends StatelessWidget {
  /// Class key
  const BodyFileResponse({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final csvProviderResponse =
        Provider.of<CsvParserProvider<CsvAsset>>(context);
    final fileInformation = Provider.of<DataFile>(context);
    final fileInformationLoad = Provider.of<LoadDataProvider>(context);

    // Nombre del archivo cargado
    String fileValue;
    final fileName = (csvProviderResponse.state != CsvParserState.idle)
        ? csvProviderResponse.csvFile.fileName
        : 'Sin selección';
    if (fileName[0].toLowerCase() == 'c' && fileName[1] == ':') {
      fileValue = fileName.split('/').last;
    } else {
      fileValue = fileName;
    }

    return ListView(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                  child: Text(
                    'Cargar archivo',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.justify,
                  ),
                ),
                // Cuadro de carga de archivo
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await _selectButtonAction(context);
                          },
                          child: const Text('Seleccionar',
                              textAlign: TextAlign.center),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          color: Colors.white,
                          child: Text(fileValue, textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ),
                  // Botón de limpiar archivo cargado
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          csvProviderResponse.clear();
                          fileInformation.clear();
                          fileInformationLoad.clear();
                        },
                        child: Column(
                          children: const [
                            Icon(
                              Icons.clear,
                              size: 30,
                            ),
                            Text('Limpiar'),
                          ],
                        ),
                      ),
                    ],
                  )
                ]),
                const FileResponse(),
              ],
            ),
          ),
        )
      ],
    );
  }

  // Método para definir las acciones del botón "Seleccionar"
  Future<void> _selectButtonAction(BuildContext context) async {
    final csvProviderResponse =
        Provider.of<CsvParserProvider<CsvAsset>>(context, listen: false);
    final fileInformation = Provider.of<DataFile>(context, listen: false);
    final fileInformationLoad =
        Provider.of<LoadDataProvider>(context, listen: false);

    // Máximo número de ítems a cargar
    const maxLines = 501;

    csvProviderResponse.clear();
    fileInformation.clear();
    fileInformationLoad.clear();
    final dataFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );
    //Se obtiene respuesta de filePicker
    final platformFile = dataFile!.files.single;
    final proccesData = CsvFile(platformFile.name, platformFile.bytes!,
        CsvAssetFactory(fieldsMap: columnNames));
    final csvProvider =
        Provider.of<CsvParserProvider<CsvAsset>>(context, listen: false)
          ..loadAllLists(proccesData);
    fileInformation.fileName = platformFile.name;
    // Si se cargó algo
    if (csvProvider.rowsAsList.isNotEmpty) {
      // Crear una lista de los títulos de columnas encontrados
      final titlesList = csvProvider.rowsAsList[0];
      // Bandera para verificar presencia de números en las columnas
      var numberInTitles = false;
      for (var y = 0; y < titlesList.length; y++) {
        if (titlesList[y] is int) {
          numberInTitles = true;
        }
      }
      // No aceptar títulos numéricos
      if (numberInTitles) {
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Los títulos de las columnas del archivo no pueden '
                      'ser números.\n'
                      'Por favor verifique e intente de nuevo.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      } else if (csvProvider.rowsAsList.length > maxLines) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('El máximo número de activos a cargar con un solo '
                      'archivo es 500.\n'
                      'Por favor verifique e intente de nuevo.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      } else {
        fileInformation.setFieldMappingStatus();
        await Navigator.pushNamed(context, '/mapeo-campos');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vuelva a cargar el archivo'),
          action: SnackBarAction(
            label: 'Aceptar',
            onPressed: () {},
          ),
        ),
      );
    }
  }
}

/// Clase para respuesta del archivo
class FileResponse extends StatelessWidget {
  /// Key
  const FileResponse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileInformation = Provider.of<DataFile>(context);
    final responseLoadData = Provider.of<LoadDataProvider>(context);

    switch (fileInformation.statusData) {
      case GeneralFileStatus.idle:
        return const Text('Por favor cargue un archivo.\n'
            'Asegúrese de que la extensión sea únicamente .csv.\n'
            'Recuerde que el máximo número de elementos a cargar es 500; si '
            'su archivo supera este número, divídalo adecuadamente.');
      case GeneralFileStatus.goToMappingButton:
        return SizedBox(
          width: 330,
          height: 100,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Por favor cargue un nuevo archivo o regrese '
                    'a la carga del actual.'),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).highlightColor,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/mapeo-campos');
                  },
                  child: const Text('Retomar carga'),
                ),
              ]),
        );
      case GeneralFileStatus.validated:
        return Column(children: [
          Center(child: dataExplorer(context)),
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: const Text(
              'Cuadro resumen',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.start,
            ),
          ),
          DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Descripción',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Total',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows: [
              DataRow(
                cells: <DataCell>[
                  DataCell(ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    child: const Text('Filas encontradas',
                        style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      responseLoadData.changeSummary(0);
                      Navigator.pushNamed(context, '/resumen-carga');
                    },
                  )),
                  DataCell(
                    Text(fileInformation.totalLines == null
                        ? '--'
                        : fileInformation.totalLines!),
                  )
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      child: const Text('Total activos',
                          style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        responseLoadData.changeSummary(3);
                        Navigator.pushNamed(context, '/resumen-carga');
                      },
                    ),
                  ),
                  DataCell(Text(fileInformation.totalInAsset))
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      child: const Text('Duplicados',
                          style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        responseLoadData.changeSummary(2);
                        Navigator.pushNamed(context, '/resumen-carga');
                      },
                    ),
                  ),
                  DataCell(Text(fileInformation.repeatedtotal))
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      child: const Text('Errores',
                          style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        responseLoadData.changeSummary(1);
                        Navigator.pushNamed(context, '/resumen-carga');
                      },
                    ),
                  ),
                  DataCell(Text(fileInformation.errorAsset))
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      responseLoadData.changeSummary(0);
                      Navigator.pushNamed(context, '/resumen-carga');
                    },
                    child: const Text('Ver detalles'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).highlightColor,
                    ),
                    onPressed: () async {
                      await _loadButtonActions(context);
                    },
                    child: const Text('Cargar'),
                  ),
                ],
              ),
            ),
          )
        ]);
    }
  }

  // Método que define las acciones a realizar con el botón "Cargar"
  Future<void> _loadButtonActions(BuildContext context) async {
    final fileInformation = Provider.of<DataFile>(context, listen: false);

    // Verificar condiciones del archivo
    if (fileInformation.dataToLoadJson.trim().isEmpty) {
      _onCustomAnimationAlertPressed(context, 'Debe seleccionar un archivo');
    } else if (int.parse(fileInformation.totalInAsset) == 0) {
      _onCustomAnimationAlertPressed(
          context,
          'El archivo no contiene información. '
          'Seleccione un archivo con información de activos válida.');
    } else if (int.parse(fileInformation.errorAsset) > 0) {
      _onCustomAnimationAlertPressed(
          context,
          'No se puede cargar el archivo con errores. '
          'Revise e intente de nuevo tras corregirlos.');
    } else if (int.parse(fileInformation.repeatedtotal) > 0) {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¡Atención!\n'
                    'Tiene ${fileInformation.repeatedtotal} activos '
                    'duplicados ¿Está segura(o)?'),
              ],
            ),
          ),
          actions: <Widget>[
            // Botón de "Cancelar"
            _cancelButton(context),
            // Botón de "Aceptar"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).highlightColor,
              ),
              child:
                  const Text('Aceptar', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.pop(context);
                await _loadButtonConfirmationActions(context);
              },
            ),
          ],
        ),
      );
    } else {
      await _loadButtonConfirmationActions(context);
    }
  }

  // Método que define las acciones a realizar al dar "confirmar" después de
  // presionar el botón "Cargar"
  Future<void> _loadButtonConfirmationActions(BuildContext context) async {
    final fileInformation = Provider.of<DataFile>(context, listen: false);
    final responseLoadData =
        Provider.of<LoadDataProvider>(context, listen: false);

    final configureService = ConfigureService(Config.serviceURL);
    // Capturar empresa
    final company = context.read<CompanyModel>();

    // Obtener el nombre del archivo a cargar
    String simplifiedFileName;
    if (fileInformation.fileName![0].toLowerCase() == 'c' &&
        fileInformation.fileName![1] == ':') {
      simplifiedFileName = fileInformation.fileName!.split('/').last;
    } else {
      simplifiedFileName = fileInformation.fileName!;
    }

    // Revisar si ya se cargó antes el mismo archivo
    final request = await responseLoadData.reviewFile(
      configureService,
      simplifiedFileName,
      company.currentCompany.companyCode!,
    );
    if (request == 'Ya cargado') {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('¡Atención!\n'
                    'Ya hay un archivo cargado con este nombre. '
                    'Por favor elimine la carga anterior antes de proceder, '
                    'o bien, cambie el nombre del archivo.'),
              ],
            ),
          ),
          actions: <Widget>[
            // Botón de "Cancelar"
            _cancelButton(context),
          ],
        ),
      );
    } else {
      var proceed = true;
      // Si hay nuevas ubicaciones, se guardan
      if (fileInformation.newLocations.isNotEmpty) {
        final locationsLoaded = await _saveNewLocations(context);
        if (!locationsLoaded) {
          _onCustomAnimationAlertPressed(
              context,
              'Problema al cargar nuevas '
              'ubicaciones. Intente nuevamente.');
          proceed = false;
        }
      }
      // Cargar el archivo
      if (proceed) {
        await _loadFileData(context, simplifiedFileName);
      }
    }
  }

  // Devuelve el botón de "Cancelar" y sus acciones asociadas
  Widget _cancelButton(BuildContext context) {
    final responseLoadData =
        Provider.of<LoadDataProvider>(context, listen: false);
    return ElevatedButton(
      child: const Text('Volver'),
      onPressed: () {
        // Canceló la sobreescritura
        responseLoadData.cancelFile();
        Navigator.pop(context);
      },
    );
  }

  // Método para cargar nuevas ubicaciones
  Future<bool> _saveNewLocations(BuildContext context) async {
    final fileInformation = Provider.of<DataFile>(context, listen: false);
    final responseLoadData =
        Provider.of<LoadDataProvider>(context, listen: false);

    final configureService = ConfigureService(Config.serviceURL);
    // Capturar empresa
    final company = context.read<CompanyModel>();

    final result = await responseLoadData.sendLocations(configureService,
        fileInformation.jsonLocations!, company.currentCompany.companyCode!);
    if (result == 'Guardadas nuevas ubicaciones') {
      company.loadLocations(fileInformation.newLocations);
      return true;
    } else {
      responseLoadData.statusLoadData = DataFileStatus.error;
      return false;
    }
  }

  // Método para cargar archivo
  Future<void> _loadFileData(BuildContext context, String fileName) async {
    final csvProviderResponse =
        Provider.of<CsvParserProvider<CsvAsset>>(context, listen: false);
    final fileInformation = Provider.of<DataFile>(context, listen: false);
    final responseLoadData =
        Provider.of<LoadDataProvider>(context, listen: false);

    final configureService = ConfigureService(Config.serviceURL);
    // Capturar empresa
    final company = context.read<CompanyModel>();
    // Capturar usuario
    final user = context.read<UserModel>();

    //print(fileInformation.dataToLoadJson);
    // Invocar función y esperar respuesta
    await responseLoadData.sendFormattedData(
        configureService,
        fileInformation.dataToLoadJson,
        user.name2show,
        company.currentCompany.companyCode!,
        fileName,
        fileInformation.date!);
    csvProviderResponse.clear();
    fileInformation.clear();
    responseLoadData.clear();
    // Capturar estadísticas
    context.read<StatisticsModel>().clearStatus();
    _onCustomAnimationAlertPressed(context, 'Archivo cargado exitosamente');
  }

  /// Despliega ESTADO del archivo
  Widget dataExplorer(BuildContext context) {
    final responseLoadData = Provider.of<LoadDataProvider>(context);
    switch (responseLoadData.statusLoadData) {
      case DataFileStatus.prepared:
        return Dialog(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              Text('Cargando...'),
            ],
          ),
        );
      case DataFileStatus.error:
        return Container(
          margin: const EdgeInsets.all(12),
          color: Colors.red[200],
          child: const Text('Error procesando archivo'),
        );
      case DataFileStatus.finished:
        return Container(
          color: Colors.green[200],
          child: const Text('Archivo procesado con éxito'),
        );
      case DataFileStatus.cancel:
        return Container(
          color: Colors.green[200],
          child: const Text('No se sobreescribió el archivo'),
        );
      case DataFileStatus.idle:
        return Container();
    }
  }

  // Modal de mensaje
  void _onCustomAnimationAlertPressed(context, String dataResponse) {
    Alert(
      context: context,
      title: 'Henutsen',
      desc: dataResponse,
      alertAnimation: fadeAlertAnimation,
      buttons: [
        DialogButton(
          radius: BorderRadius.circular(20),
          color: Theme.of(context).highlightColor,
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Aceptar',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  /// Para animación
  Widget fadeAlertAnimation(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      Align(
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
}
