// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// --------Selección y configuración de estación de codificación--------
// ---------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/encoder_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class EncoderConfig extends StatelessWidget {
  ///  Class Key
  const EncoderConfig({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.codificacion),
          endDrawer: MenuDrawer.drawer(context, PageList.codificacion),
          body: const EncodePage(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.codificacion),
        ),
      );
}

/// Opciones de codificación
class EncodePage extends StatelessWidget {
  ///  Class Key
  const EncodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _serverBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.7 - 20
        : mediaSize.width * 0.4 - 20;
    // Capturar información de codificador
    final encoder = context.watch<EncoderModel>();

    // Información del codificador asociado
    Widget _readerInfo() {
      if (encoder.currentEncoder != null) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(children: [
            const Text('Información del codificador asociado',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Table(children: [
              TableRow(children: [
                const Text('Dispositivo: ', style: TextStyle(fontSize: 14)),
                Text(encoder.info['Reader']!,
                    style: const TextStyle(fontSize: 14)),
              ]),
              TableRow(children: [
                const Text('Potencia: ', style: TextStyle(fontSize: 14)),
                Text(encoder.info['Power']!,
                    style: const TextStyle(fontSize: 14)),
              ]),
              TableRow(children: [
                const Text('Tiempo de escaneo: ',
                    style: TextStyle(fontSize: 14)),
                Text(encoder.info['ScanTime']!,
                    style: const TextStyle(fontSize: 14)),
              ]),
              TableRow(children: [
                const Text('Banda de frecuencia: ',
                    style: TextStyle(fontSize: 14)),
                Text(encoder.info['FrequencyBand']!,
                    style: const TextStyle(fontSize: 14)),
              ]),
              TableRow(children: [
                const Text('Frecuencia mínima: ',
                    style: TextStyle(fontSize: 14)),
                Text(encoder.info['MinFrequency']!,
                    style: const TextStyle(fontSize: 14)),
              ]),
              TableRow(children: [
                const Text('Frecuencia máxima: ',
                    style: TextStyle(fontSize: 14)),
                Text(encoder.info['MaxFrequency']!,
                    style: const TextStyle(fontSize: 14)),
              ]),
              TableRow(children: [
                const Text('Protocolos: ', style: TextStyle(fontSize: 14)),
                Text(encoder.info['Protocols']!,
                    style: const TextStyle(fontSize: 14)),
              ]),
            ]),
          ]),
        );
      } else {
        return Container();
      }
    }

    // Texto de nombre de codificador asociado
    Widget _myEncoder;
    if (encoder.currentEncoder != null) {
      _myEncoder = Text(encoder.currentEncoder!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
    } else {
      _myEncoder = const Text('No hay codificador\nasociado.',
          style: TextStyle(color: Colors.red));
    }

    // Campo de texto para ingreso de URL del servidor de impresión
    final _serverUrlField = SizedBox(
      width: _serverBoxWidth,
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          labelText: 'URL (Ej: https://dir.com)',
        ),
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[\n\t\r]'))],
        initialValue: encoder.serverUrl,
        onChanged: encoder.updateURL,
      ),
    );

    return ListView(
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Configuración\nde codificador',
              style: Theme.of(context).textTheme.headline3),
        ),
        // Texto de url
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          // La organización depende del tamaño de la pantalla
          child: (mediaSize.width < screenSizeLimit)
              ? Column(
                  children: [
                    const Text('URL del servidor de codificación:\n'),
                    _serverUrlField,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('URL del servidor\nde codificación:'),
                    _serverUrlField,
                  ],
                ),
        ),
        // Conexión al codificador
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('Codificador:'),
              _myEncoder,
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: (encoder.currentEncoder == null)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                  onPressed: () async {
                    if (encoder.currentEncoder == null &&
                        encoder.serverUrl.isNotEmpty) {
                      if (encoder.serverUrl.startsWith('https://') ||
                          encoder.serverUrl.startsWith('http://')) {
                        final request = await encoder.connectToServer();
                        if (request == 'Ok') {
                          final request2 = await encoder.getEncoderInfo();
                          if (!request2.startsWith('Error')) {
                            encoder.asignEncoder(encoder.info['Reader']);
                          } else {
                            await encoder.disconnectFromServer();
                          }
                        } else {
                          HenutsenDialogs.showSnackbar(request, context);
                        }
                      } else {
                        HenutsenDialogs.showSnackbar(
                            'Ingrese una dirección '
                            'válida',
                            context);
                      }
                    } else {
                      HenutsenDialogs.showSnackbar(
                          'Ingrese dirección del '
                          'servidor',
                          context);
                    }
                  },
                  child: const Text('Conectar')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: (encoder.currentEncoder != null)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                ),
                onPressed: () async {
                  if (encoder.currentEncoder != null &&
                      encoder.serverUrl.isNotEmpty) {
                    if (encoder.serverUrl.startsWith('https://') ||
                        encoder.serverUrl.startsWith('http://')) {
                      final request = await encoder.disconnectFromServer();
                      if (request == 'Ok') {
                        encoder.asignEncoder(null);
                      } else {
                        HenutsenDialogs.showSnackbar(request, context);
                      }
                    } else {
                      HenutsenDialogs.showSnackbar(
                          'Ingrese una dirección '
                          'válida',
                          context);
                    }
                  } else {
                    HenutsenDialogs.showSnackbar(
                        'Ingrese dirección del '
                        'servidor',
                        context);
                  }
                },
                child: const Text('Desconectar'),
              ),
            ],
          ),
        ),
        // Información de la estación
        _readerInfo(),
        // Botón de guardar
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              // Botón de continuar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar y volver'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
