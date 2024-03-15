// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -----------------Traslado interno de activos--------------------
// --------------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/pendient_Authorization.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Clase principal
class AssetOutInternal extends StatelessWidget {
  ///  Class Key
  const AssetOutInternal({Key? key}) : super(key: key);
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
          body: const AssetBody(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

/// --------------- Para mostrar los activos ------------------
class AssetBody extends StatelessWidget {
  ///  Class Key
  const AssetBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _textBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.4
        : mediaSize.width * 0.3;
    // Leemos cambios en el modelo de traslados y autorizaciones
    final transfer = context.watch<TransferModel>();
    // Leemos cambios en el modelo de traslados y autorizaciones
    final pendient = context.watch<PendientModel>();

    // Capturar modelo de inventario
    final inventory = context.watch<InventoryModel>();

    // Capturar modelo de la empresa
    final company = context.watch<CompanyModel>();
    // Capturar modelo de usuario
    final user = context.watch<UserModel>();
    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Préstamo interno',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Controle las autorizaciones de los activos de su inventario'
                  ' y gestione sus traslados internos',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),

          // Gestión de autorizaciones
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón de nueva autorización
              Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/internal-data');
                  },
                  child: const Text('Nueva autorización'),
                ),
              ),
            ],
          ),
          const InfoToShow(),
          // Botones
          Container(
            margin: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón de volver
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Clase para devolver la información de autorizaciones
class InfoToShow extends StatelessWidget {
  /// Class Key
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Leemos cambios en el modelo de traslados de activos
    final transfer = context.watch<TransferModel>();
    // Presentamos lista de autorizaciones
    if (transfer.authorizationsList.isNotEmpty) {
      // Guardar en lista para visualización
      final auth2show = <Authorization>[];

      for (final item in transfer.authorizationsList) {
        if (item.transferLocation != '') {
          auth2show.add(item);
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        // Tabla de activos
        child: PaginatedDataTable(
          source: DataTableItems(
              context: context,
              generalData: auth2show,
              modelSource: transfer,
              type: '3',
              dataToPrint: DataToPrint.authorizationsInternal),
          header: const Text('Lista de Autorizaciones'),
          columns: [
            const DataColumn(label: Text('No.')),
            const DataColumn(label: Text('Número de autorización')),
            const DataColumn(label: Text('Estado')),
            const DataColumn(label: Text('Responsable')),
            const DataColumn(label: Text('Activos')),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Total de autorizaciones: ${auth2show.length}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          columnSpacing: 50,
          horizontalMargin: 10,
          rowsPerPage: auth2show.length <= 10
              ? auth2show.isEmpty
                  ? 1
                  : auth2show.length
              : 10,
          showCheckboxColumn: false,
        ),
      );
    } else {
      return const Center(
        child: Text('No hay información de autorizaciones.'),
      );
    }
  }
}
