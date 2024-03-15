// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// --------------------Información sobre la carga-----------------------
// ---------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:provider/provider.dart';

/// Clase principal
class UploadingInfoPage extends StatelessWidget {
  ///  Class Key
  const UploadingInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.cargasMasivas),
          endDrawer: MenuDrawer.drawer(context, PageList.cargasMasivas),
          body: const InfoPage(),
          bottomNavigationBar: BottomBar.bottomBar(
            PageList.cargasMasivas,
            context,
            PageList.cargasMasivas,
            thisPage: true,
          ),
        ),
      );
}

/// Clase para presentar información
class InfoPage extends StatelessWidget {
  ///  Class Key
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>();

    return ListView(
      children: [
        // Título página
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(10),
          margin:
              const EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.help, color: Colors.yellow[200], size: 40),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Carga masiva',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ]),
        ),
        // Objetivo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text('Objetivo', style: Theme.of(context).textTheme.headline5),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: const Text('La funcionalidad de carga masiva de activos '
              'permite a los usuarios subir grandes volúmenes de contenido '
              'asociado a sus activos.'),
        ),
        // Características
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text('Características',
              style: Theme.of(context).textTheme.headline5),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: const Text('* Permite la carga desde una planilla con '
              'formato .CSV o .XLS.\n'
              '* Los campos del archivo deben coincidir o contener los campos '
              'definidos en el tipo de contenido.'),
        ),
        // Procedimiento
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text('Procedimiento',
              style: Theme.of(context).textTheme.headline5),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: const Text('1. Para hacer cargas masivas primero debe '
              'descargar la pantilla.\n'
              '2. Llene la plantilla según las instrucciones provistas.\n'
              '3. Una vez esté llena la plantilla con los campos especificados,'
              ' puede proceder a hacer la carga en la aplicación.\n'),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Column(children: [
            // No volver a mostrar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Checkbox(
                    value: user.helpScreen,
                    onChanged: (value) {
                      if (value!) {
                        user.changeHelp(value);
                      } else {
                        user.changeHelp(value);
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text('No volver a mostrar'),
                ),
              ]),
            ),
            // Botón de continuar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).highlightColor,
                ),
                onPressed: () async {
                  // Si no se quiere ver de nuevo la ayuda
                  if (user.helpScreen) {
                    final request = await user.loadHelpScreen('cargasMasivas');
                    if (request == 'Done') {
                      user.uploadingHelp = false;
                    }
                  } else {
                    user.uploadingHelp = true;
                  }
                  // Restaurar bandera general
                  user.helpScreen = false;
                  Navigator.pop(context);
                },
                child: const Text('Continuar',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
