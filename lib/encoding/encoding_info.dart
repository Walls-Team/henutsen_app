// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// ------------Información sobre la estación de codificación------------
// ---------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:provider/provider.dart';

/// Clase principal
class EncodingInfoPage extends StatelessWidget {
  ///  Class Key
  const EncodingInfoPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.codificacion),
          endDrawer: MenuDrawer.drawer(context, PageList.codificacion),
          body: const InfoPage(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.codificacion),
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
                'Codificación',
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
          child: const Text('Esta funcionalidad permite a los usuarios'
              ' grabar las etiquetas RFID de manera individual cuando'
              ' no sea posible hacerlo a través de impresión o cuando'
              ' el usuario así lo requiera.'),
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
          child: const Text('* Las etiquetas tendrán'
              ' el código EPC del activo.\n'
              '* El tipo de etiqueta debe ser el adecuado para el material '
              'sobre el cual se va a colocar.'),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50),
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
                    final request = await user.loadHelpScreen('codificacion');
                    if (request == 'Done') {
                      user.encodingHelp = false;
                    }
                  } else {
                    user.encodingHelp = true;
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
