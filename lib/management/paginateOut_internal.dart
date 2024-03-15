// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// ------------------Agregar autorizaciones internas------------------
// --------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/assetOut_internal.dart';
import 'package:henutsen_cli/management/authorization_internal.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:provider/provider.dart';

/// Clase principal
class TableAssetOut extends StatelessWidget {
  ///  Class Key
  const TableAssetOut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    final _company = context.watch<CompanyModel>();
    return WillPopScope(
        onWillPop: () async => true,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: ApplicationBar.appBar(context, PageList.gestion),
            endDrawer: MenuDrawer.drawer(context, PageList.gestion),
            body: SafeArea(
              child: Column(
                children: [
                  TabBar(
                    indicatorPadding: const EdgeInsets.all(8),
                    indicatorColor: Colors.blue,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      const Tab(
                        text: '1.Captura de activos',
                      ),
                      Tab(
                        text: mediaSize.width < screenSizeLimit
                            ? '2.Solicitud de\n'
                                ' autorización'
                            : '2.Solicitud de autorización',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        CountPageBody(),
                        BodyDataInternal(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomBar.bottomBar(
                PageList.inicio, context, PageList.gestion,
                thisPage: true),
          ),
        ));
  }
}
