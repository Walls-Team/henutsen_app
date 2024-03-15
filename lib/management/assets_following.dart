// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// -----------------Traslado de activos--------------------
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
class AssetFollowingPage extends StatelessWidget {
  ///  Class Key
  const AssetFollowingPage({Key? key}) : super(key: key);
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
          body: const AssetFollowing(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

/// --------------- Para mostrar los activos ------------------
class AssetFollowing extends StatelessWidget {
  ///  Class Key
  const AssetFollowing({Key? key}) : super(key: key);

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
    final newPendient =
        verifyResource(user.currentUser.roles!, company, 'NewPendient');
    final getPendient =
        verifyResource(user.currentUser.roles!, company, 'GetPendient');
    final newAuthorize = verifyResource(
        user.currentUser.roles!, company, 'CreateNewAuthorization');

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
                Text('Control de activos',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Controle las autorizaciones de los activos de su inventario'
                  ' y gestione sus traslados',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),

          // Gestión de autorizaciones
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 30, top: 20),
                child: Text(
                  'Autorizaciones de traslado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(
                height: 05,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: transfer.filterAutho,
                      icon: Icon(Icons.arrow_downward,
                          color: Theme.of(context).highlightColor),
                      elevation: 16,
                      style: const TextStyle(fontSize: 14, color: Colors.brown),
                      onChanged: (newValue) {
                        transfer.asigneFilter(newValue!);
                      },
                      items: ['Todas', 'A cargo', 'A supervisar']
                          .map<DropdownMenuItem<String>>((value) =>
                              DropdownMenuItem<String>(
                                  value: value, child: Text(value)))
                          .toList(),
                    ),
                  ),
                ),
              ),
              if (newPendient)
                // Botón de nueva autorización
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      final pendients = context.read<PendientModel>();
                      final aux = '${user.currentUser.name?.givenName}'
                          ' ${user.currentUser.name?.familyName} '
                          '(${user.currentUser.userName})';
                      await pendients.getAuthorizations(
                          company.currentCompany.companyCode!);
                      inventory.asigneAssetPendiet(aux);
                      company.asigneLocations(user.currentUser);

                      await Navigator.pushNamed(
                          context, '/solicitar-autorizacion');
                    },
                    child: const Text('Solicitar autorización'),
                  ),
                ),
              if (getPendient)
                // Botón de nueva autorización
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await pendient.getAuthorizations(
                          company.currentCompany.companyCode!);
                      await transfer.getAuthorizations(
                          company.currentCompany.companyCode!);
                      await Navigator.pushNamed(context, '/datos-traslados');
                    },
                    child: const Text('Autorizaciones pendientes'),
                  ),
                ),
              if (newAuthorize)
                // Botón de nueva autorización
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      transfer.resetAll();
                      transfer.currentAuthorization.assets = <String>[];
                      // Capturar modelo de usuario
                      final user = context.read<UserModel>();
                      // Se captura el rol. Solo el coordinador (o más) puede
                      // crear autorizaciones
                      final _userRole = user.currentUserRole;

                      // Capturar modelo de empresa
                      final company = context.read<CompanyModel>();
                      // Llenar usuarios de la empresa
                      await user.loadLocalUsers(company.currentCompany.id!);
                      await Navigator.pushNamed(context, '/datos-autorizar');
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
    final user = context.watch<UserModel>();
    // Presentamos lista de autorizaciones
    if (transfer.authorizationsList.isNotEmpty) {
      // Guardar en lista para visualización
      final auth2show = <Authorization>[];

      for (final item in transfer.authorizationsList) {
        if (transfer.filterAutho != 'Todas') {
          if (transfer.filterAutho == 'A cargo') {
            if (item.person!.contains(user.currentUser.userName!)) {
              auth2show.add(item);
            }
          }
          if (transfer.filterAutho == 'A supervisar') {
            if (item.supervisor!.contains(user.currentUser.userName!)) {
              auth2show.add(item);
            }
          }
        } else {
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
              type: '2',
              dataToPrint: DataToPrint.authorizations),
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
