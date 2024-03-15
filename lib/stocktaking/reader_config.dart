// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// -----------------------------------------------------------------------------
// ------------------Conexión al lector y configuración-------------------------
// -----------------------------------------------------------------------------

import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/encoder_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class ReaderConfigPage extends StatelessWidget {
  ///  Class Key
  const ReaderConfigPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Iniciar librería UHF
    r6_plugin.initUHFDevice();
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: ApplicationBar.appBar(context, PageList.conteo),
        endDrawer: MenuDrawer.drawer(context, PageList.conteo),
        body: Connect(),
        bottomNavigationBar: BottomBar.bottomBar(
            PageList.conteo, context, PageList.conteo,
            thisPage: true),
      ),
    );
  }
}

/// Clase para conexión Bluetooth
class Connect extends StatelessWidget {
  ///  Class Key
  Connect({Key? key}) : super(key: key);

  /// Instancia de dispositivo
  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  @override
  Widget build(BuildContext context) {
    // Capturar dispositivo BT
    final device = context.watch<BluetoothModel>();

    return ListView(
      children: [
        // Título sección bluetooth
        Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          child: const Text('Conexión Bluetooth',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Botón de buscar
            ElevatedButton(
              onPressed: () async {
                try {
                  final thisResponse = await r6_plugin.checkConnection();
                  if (thisResponse != null) {
                    if (device.isScanning) {
                      HenutsenDialogs.showSnackbar(
                          'Detenga la '
                          'lectura',
                          context);
                    } else if (thisResponse == 'Connecting') {
                      HenutsenDialogs.showSnackbar('Conectando', context);
                    } else {
                      await showBluetoothDevice(context);
                    }
                  }
                } on Exception {
                  HenutsenDialogs.showSnackbar(
                      'Bluetooth no '
                      'disponible',
                      context);
                }
              },
              child: const Text(
                'Buscar\ndispositivos',
                textAlign: TextAlign.center,
              ),
            ),
            // Botón de Desconectar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: (device.gotDevice)
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
              ),
              onPressed: () async {
                // Capturar información de codificador
                final encoder = context.read<EncoderModel>();
                if (device.gotDevice) {
                  HenutsenDialogs.showSnackbar('Desconectando', context);
                  await r6_plugin.disconnect();
                  await device.connectedDevice!.disconnect();
                  device.unsetConnectionStatus();
                  // Desasociar también en modo escritura si la opción
                  // está activada
                  if (encoder.encoderType == EncoderType.handheld) {
                    encoder.asignEncoder(null);
                  }
                }
              },
              child: const Text('Desconectar'),
            ),
          ],
        ),
        // Texto de confirmación de conexión
        Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          child: Text(
            (device.gotDevice) ? 'Conectado a' : 'Esperando conexión',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        // Dispositivo conectado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: (device.gotDevice)
              ? [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dispositivo: ${device.connectedDevice!.name}'),
                      Text('Dirección: '
                          '${device.connectedDevice!.id.toString()}'),
                    ],
                  ),
                ]
              : [],
        ),
        // Mostrar campos de configuración
        Container(child: (device.gotDevice) ? const ReaderConfig() : null),
        // Botón de volver
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).highlightColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Volver'),
          ),
        ),
      ],
    );
  }

  /// Método para mostrar dispositivos Bluetooth
  Future<void> showBluetoothDevice(BuildContext context) async {
    bool isAvailable;
    bool isEnabled;
    try {
      isAvailable = await _flutterBlue.isAvailable;
      isEnabled = await _flutterBlue.isOn;
    } on Exception {
      isAvailable = false;
      isEnabled = false;
    }
    // Capturar dispositivo BT
    final device = context.read<BluetoothModel>();

    if (!isAvailable) {
      HenutsenDialogs.showSnackbar('Bluetooth no disponible', context);
      return;
    }
    if (!isEnabled) {
      HenutsenDialogs.showSnackbar(
          'Por favor habilite la conexión Bluetooth del teléfono.', context);
    } else {
      final redraw = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Debe seleccionarse alguna opción
          builder: (context) => DeviceList(flutterBlue: _flutterBlue));
      if (redraw != null) {
        if (redraw) {
          final conn = await r6_plugin.connect(device.connectedDevice!);
          if (conn == 'Connected') {
            await Future<void>.delayed(const Duration(milliseconds: 1000));
            device.setConnectionStatus();
          }
        }
      }
    }
  }
}

// --------------------------------------------------------
/// ------------ Lista de dispositivos ---------------------
class DeviceList extends StatefulWidget {
  /// Constructor
  const DeviceList({Key? key, this.flutterBlue}) : super(key: key);

  /// Instancia de dispositivo
  final FlutterBlue? flutterBlue;

  @override
  _DeviceListState createState() => _DeviceListState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<FlutterBlue>('flutterBlue', flutterBlue));
  }
}

class _DeviceListState extends State<DeviceList> {
  //Lista de dispositivos disponibles
  final _devicesList = <BluetoothDevice>[];

  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    widget.flutterBlue!.connectedDevices.asStream().listen((devices) {
      devices.forEach(_addDeviceTolist);
    });
    widget.flutterBlue!.scanResults.listen((results) {
      for (final result in results) {
        if (result.device.name.contains('Chainway') ||
            result.device.name.length == 12) {
          _addDeviceTolist(result.device);
        }
      }
    });
    widget.flutterBlue!.startScan();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        titlePadding: const EdgeInsets.all(10),
        title: const Text(
          'Seleccione el dispositivo',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        content: SingleChildScrollView(
          child: _buildListViewOfDevices(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              widget.flutterBlue!.stopScan();
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
        ],
      );

  // Llenar lista de dispositivos disponibles
  void _addDeviceTolist(final BluetoothDevice device) {
    if (!_devicesList.contains(device)) {
      setState(() {
        _devicesList.add(device);
      });
    }
  }

  // Lista de dispositivos bluetooth
  Column _buildListViewOfDevices() {
    final containers = <Container>[];

    // Capturar dispositivo BT
    final myDevice = context.watch<BluetoothModel>();

    for (final device in _devicesList) {
      containers.add(
        // ignore: sized_box_for_whitespace
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    // Capturar información de codificador
                    final encoder = context.read<EncoderModel>();
                    await widget.flutterBlue!.stopScan();
                    try {
                      await device.connect();
                    } on Exception catch (e) {
                      if (e.toString() != 'already_connected') {
                        rethrow;
                      }
                    }
                    setState(() {
                      _connectedDevice = device;
                      // Asociar también en modo escritura si la opción
                      // está activada
                      if (encoder.encoderType == EncoderType.handheld) {
                        encoder.asignEncoder(_connectedDevice?.name);
                      }
                    });
                    myDevice.connectedDevice = _connectedDevice;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text(
                    'Conectar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      //padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }
}

/// Clase para configuración de parámetros del lector
class ReaderConfig extends StatefulWidget {
  ///  Class Key
  const ReaderConfig({Key? key}) : super(key: key);

  @override
  _ReaderConfigState createState() => _ReaderConfigState();
}

class _ReaderConfigState extends State<ReaderConfig> {
  // Listas de selección
  final _frecuencias = [
    'China estándar1 (840~845MHz)',
    'China estándar2 (920~925MHz)',
    'Europa estándar (865~868MHz)',
    'EEUU (902-928MHz)',
    'Corea (917~923MHz)',
    'Japón (952~953MHz)'
  ];
  final _potencias = [
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30'
  ];
  final _protocolos = ['ISO 18000-6C', 'GB/T 29768', 'GJB 7377.1'];
  final _memorias = ['EPC', 'TID', 'User'];
  // Valores iniciales de cada campo de selección
  String? _currentFreq;
  String? _currentPower;
  String? _currentProtocol;
  // Valores iniciales de batería y temperatura
  String? _battery = '';
  String? _temp = '';
  //Banco de memoria a leer - 0:EPC, 1:TID, 2:User
  int _memBank = 0;

  // Método para inicializar
  @override
  void initState() {
    super.initState();
    // Obtener valor actual de los campos de selección
    _initFields();
  }

  // Método para limpiar
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capturar dispositivo BT
    final myDevice = context.watch<BluetoothModel>();

    // Retornar los campos
    return Column(
      children: [
        // Separador de secciones
        const Divider(thickness: 4, color: Colors.amber),
        // Título
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Text('Configuración del lector',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        // Batería
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Row(
            children: [
              const Text('Nivel de batería: '),
              Text('$_battery %',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        // Temperatura
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Row(
            children: [
              const Text('Temperatura del lector: '),
              Text('$_temp °C',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: const Divider(thickness: 2),
        ),
        // Frecuencia
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Banda de frecuencia:'),
              SizedBox(
                width: 200,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: DropdownButton<String>(
                    value: _currentFreq,
                    icon: const Icon(Icons.arrow_downward,
                        color: Colors.blueAccent),
                    elevation: 16,
                    style: const TextStyle(fontSize: 14, color: Colors.brown),
                    onChanged: (newValue) async {
                      setState(() {
                        _currentFreq = newValue;
                      });
                      final thisResponse = await r6_plugin
                          .setFrequency(_frecuencias.indexOf(newValue!));
                      if (thisResponse != null) {
                        if (thisResponse) {
                          HenutsenDialogs.showSnackbar(
                              'Banda de frecuencia '
                              'cambiada',
                              context);
                        } else {
                          HenutsenDialogs.showSnackbar(
                              'Fallo al cambiar '
                              'frecuencia',
                              context);
                        }
                      }
                    },
                    items: _frecuencias
                        .map<DropdownMenuItem<String>>((value) =>
                            DropdownMenuItem<String>(
                              value: value,
                              child: SizedBox(width: 150, child: Text(value)),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Potencia
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Potencia de salida (dBm):'),
              SizedBox(
                width: 100,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: DropdownButton<String>(
                    value: _currentPower,
                    icon: const Icon(Icons.arrow_downward,
                        color: Colors.blueAccent),
                    elevation: 16,
                    style: const TextStyle(fontSize: 14, color: Colors.brown),
                    onChanged: (newValue) async {
                      setState(() {
                        _currentPower = newValue;
                      });
                      final thisResponse =
                          await r6_plugin.setPower(int.parse(newValue!));
                      if (thisResponse != null) {
                        if (thisResponse) {
                          HenutsenDialogs.showSnackbar(
                              'Potencia '
                              'cambiada',
                              context);
                        } else {
                          HenutsenDialogs.showSnackbar(
                              'Fallo al cambiar '
                              'potencia',
                              context);
                        }
                      }
                    },
                    items: _potencias
                        .map<DropdownMenuItem<String>>((value) =>
                            DropdownMenuItem<String>(
                              value: value,
                              child: SizedBox(width: 50, child: Text(value)),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Protocolo
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Protocolo:'),
              SizedBox(
                width: 200,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: DropdownButton<String>(
                    value: _currentProtocol,
                    icon: const Icon(Icons.arrow_downward,
                        color: Colors.blueAccent),
                    elevation: 16,
                    style: const TextStyle(fontSize: 14, color: Colors.brown),
                    onChanged: (newValue) async {
                      setState(() {
                        _currentProtocol = newValue;
                      });
                      final thisResponse = await r6_plugin
                          .setProtocol(_protocolos.indexOf(newValue!));
                      if (thisResponse != null) {
                        if (thisResponse) {
                          HenutsenDialogs.showSnackbar(
                              'Protocolo '
                              'cambiado',
                              context);
                        } else {
                          HenutsenDialogs.showSnackbar(
                              'Fallo al cambiar '
                              'protocolo',
                              context);
                        }
                      }
                    },
                    items: _protocolos
                        .map<DropdownMenuItem<String>>(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: SizedBox(
                              width: 150,
                              child: Text(value),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Banco de memoria a leer
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Banco de memoria a leer:'),
              SizedBox(
                width: 100,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: DropdownButton<String>(
                    value: _memBank.toString(),
                    icon: const Icon(Icons.arrow_downward,
                        color: Colors.blueAccent),
                    elevation: 16,
                    style: const TextStyle(fontSize: 14, color: Colors.brown),
                    onChanged: (newValue) async {
                      setState(() {
                        _memBank = int.parse(newValue!);
                        r6_plugin.setMode(_memBank);
                        // Pasarlo al modelo
                        myDevice.memBank = _memBank;
                      });
                    },
                    items: _memorias
                        .map<DropdownMenuItem<String>>((value) =>
                            DropdownMenuItem<String>(
                              value: (_memorias.indexOf(value)).toString(),
                              child: SizedBox(width: 50, child: Text(value)),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Inicializar campos de configuración
  Future<void> _initFields() async {
    final freqIdx = await r6_plugin.getFrequency();
    final power = await r6_plugin.getPower();
    final protIdx = await r6_plugin.getProtocol();
    _battery = await r6_plugin.getBattery();
    _temp = await r6_plugin.getTemperature();
    final myMode = await r6_plugin.getMode();

    if (_potencias.contains(power.toString())) {
      _currentPower = power.toString();
    } else {
      _currentPower = _potencias.first;
    }
    if (freqIdx != -1) {
      _currentFreq = freqIdx! > _frecuencias.length - 1
          ? _frecuencias.last
          : _frecuencias[freqIdx];
    } else {
      _currentFreq = _frecuencias.first;
    }
    if (protIdx != -1) {
      _currentProtocol = protIdx! > _protocolos.length - 1
          ? _protocolos.last
          : _protocolos[protIdx];
    } else {
      _currentProtocol = _protocolos.first;
    }
    if (myMode!.startsWith('EPC')) {
      _memBank = 0;
    } else if (myMode.startsWith('TID')) {
      _memBank = 1;
    } else if (myMode.startsWith('User')) {
      _memBank = 2;
    }
    setState(() {});
  }
}
