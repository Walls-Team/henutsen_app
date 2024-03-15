// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ------------------------------------------------------
// --------------------Carga masiva----------------------
// ------------------------------------------------------

import 'package:file_download/file_download.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase para página de cargas masivas
class UploadPage extends StatelessWidget {
  /// Key
  const UploadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: ApplicationBar.appBar(context, PageList.cargasMasivas),
        endDrawer: MenuDrawer.drawer(context, PageList.cargasMasivas),
        body: const Options(),
        bottomNavigationBar: BottomBar.bottomBar(
          PageList.cargasMasivas,
          context,
          PageList.cargasMasivas,
          thisPage: true,
        ),
      );
}

/// Clase para selección de opciones de carga
class Options extends StatelessWidget {
  ///  Class Key
  const Options({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final company = context.watch<CompanyModel>();
    final user = context.watch<UserModel>();
    final load = verifyResource(user.currentUser.roles!, company, 'FileLoad');
    final view =
        verifyResource(user.currentUser.roles!, company, 'ObtainLoads');
    return Center(
      child: ListView(
        children: [
          // Título
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carga Masiva',
                  style: Theme.of(context).textTheme.headline2,
                ),
                Text(
                  'Descargue la plantilla y cargue su listado de activos '
                  'existente',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          // Primera fila de opciones
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Descargar plantilla
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Image.asset(
                        'images/iconoPlantilla.png',
                        height: 100,
                        semanticLabel: 'Plantilla',
                        color: !view ? Colors.grey.withAlpha(50) : null,
                      ),
                      Text('Plantilla',
                          style: Theme.of(context).textTheme.headline5),
                    ]),
                  ),
                  onTap: () {
                    if (view) {
                      final downloadConfiguration = FileDownloadConfiguration(
                          Config.urlTemplateLoadAssets);
                      //Load file
                      Provider.of<FileDownload>(context, listen: false)
                          .downloadFile(downloadConfiguration);
                    } else {
                      HenutsenDialogs.showSnackbar(
                          'Su rol actual no tiene permisos para acceder ',
                          context);
                    }
                  },
                ),
                // Cargar archivo
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Image.asset('images/iconoCargar.png',
                          height: 100,
                          semanticLabel: 'Cargar',
                          color: !load ? Colors.grey.withAlpha(50) : null),
                      Text('Cargar',
                          style: Theme.of(context).textTheme.headline5),
                    ]),
                  ),
                  onTap: () {
                    if (load) {
                      Navigator.of(context).pushNamed('/cargar-archivo');
                    } else {
                      HenutsenDialogs.showSnackbar(
                          'Su rol actual no tiene permisos para acceder ',
                          context);
                    }
                  },
                ),
              ],
            ),
          ),
          // Segunda fila de opciones
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Visualizar cargas
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Image.asset(
                        'images/iconoVisualizar.png',
                        height: 100,
                        semanticLabel: 'Visualizar',
                        color: !view ? Colors.grey.withAlpha(50) : null,
                      ),
                      Text('Visualizar',
                          style: Theme.of(context).textTheme.headline5),
                    ]),
                  ),
                  onTap: () {
                    if (view) {
                      Navigator.of(context).pushNamed('/ver-cargas');
                    } else {
                      HenutsenDialogs.showSnackbar(
                          'Su rol actual no tiene permisos para acceder ',
                          context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
