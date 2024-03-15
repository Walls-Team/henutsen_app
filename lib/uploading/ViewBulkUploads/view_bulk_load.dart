// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------
// ----------Ver información cargada en archivo-------------------
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/load_data.dart';
import 'package:henutsen_cli/uploading/ViewBulkUploads/bulk_class.dart';
import 'package:henutsen_cli/uploading/ViewBulkUploads/bulk_load.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Ver cargas masivas
class ViewBulkLoad extends StatelessWidget {
  ///  Class Key
  const ViewBulkLoad({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.cargasMasivas),
          endDrawer: MenuDrawer.drawer(context, PageList.cargasMasivas),
          body: _BulkLoadDataTable(),
          bottomNavigationBar: BottomBar.bottomBar(
            PageList.cargasMasivas,
            context,
            PageList.cargasMasivas,
            thisPage: true,
          ),
        ),
      );
}

class _BulkLoadDataTable extends StatelessWidget {
  final ScrollController _horizontalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final company = context.watch<CompanyModel>();
    final user = context.watch<UserModel>();
    final delete =
        verifyResource(user.currentUser.roles!, company, 'DeleteFile');

    final bulkLoadProvider = Provider.of<BulkLoad>(context);
    final configureService = ConfigureService(Config.serviceURL);

    Future<void> _executeBulkLoad() async {
      final company = context.watch<CompanyModel>();
      await bulkLoadProvider.viewLoads(configureService,
          companyCode: company.currentCompany.companyCode);
    }

    switch (bulkLoadProvider.bulkLoadStatus) {
      case BulkLoadStatus.idle:
        _executeBulkLoad();
        return Column(
          children: const [Text('Cargando...')],
        );
      case BulkLoadStatus.finished:
        bulkLoadProvider.clearBulkLoadStatus();
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text(
                'Cargas masivas',
                style: Theme.of(context).textTheme.headline6,
              ),
              pinned: true,
              centerTitle: true,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (final context, final index) => Scrollbar(
                        controller: _horizontalController,
                        isAlwaysShown: true,
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                                // sortColumnIndex: 5,
                                columns: const [
                                  DataColumn(
                                    label: Text('Nombre Archivo'),
                                    //onSort: true,
                                    tooltip: 'Nombre Archivo',
                                  ),
                                  DataColumn(
                                    label: Text('Fecha'),
                                    tooltip: 'Fecha',
                                  ),
                                  DataColumn(
                                    label: Text('Total Activos'),
                                    tooltip: 'Cantidad',
                                  ),
                                  DataColumn(
                                    label: Text('Ubicaciones'),
                                    tooltip: 'Ubicaciones',
                                  ),
                                  DataColumn(
                                    label: Text('Usuario'),
                                    tooltip: 'Usuario',
                                  ),
                                  DataColumn(
                                    label: Text('Acción'),
                                    tooltip: 'Eliminar',
                                  ),
                                ],
                                rows: bulkLoadProvider.listViews
                                    .map(
                                      (e) => DataRow(
                                        cells: [
                                          DataCell(
                                            Text(e.fileName!),
                                          ),
                                          DataCell(
                                            Text(e.date!),
                                          ),
                                          DataCell(Text(e.quantity.toString())),
                                          DataCell(
                                              Text(e.locations.toString())),
                                          DataCell(
                                            Text(e.userName!),
                                          ),
                                          DataCell(
                                            Column(
                                              children: [
                                                IconButton(
                                                  icon: Image.asset(
                                                    'images/iconoEliminar.png',
                                                    width: 25,
                                                    height: 25,
                                                    color: !delete
                                                        ? Colors.grey
                                                            .withAlpha(50)
                                                        : null,
                                                  ),
                                                  onPressed: () {
                                                    if (delete) {
                                                      _deleteButtonAction(
                                                          context, e);
                                                    } else {
                                                      HenutsenDialogs
                                                          .showSnackbar(
                                                              'Su rol actual no'
                                                              ' tiene permisos'
                                                              ' para eliminar '
                                                              ' esta carga',
                                                              context);
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList()),
                          ),
                        ),
                      ),
                  childCount: 1),
            ),
          ],
        );
      case BulkLoadStatus.empty:
        bulkLoadProvider.clearBulkLoadStatus();
        return Center(
          child: Column(
            children: [
              Image.asset(
                'images/iconoSinCargas.png',
                width: 60,
                height: 60,
              ),
              Text(
                'No se registran cargas masivas en la información actual de '
                'la empresa',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case BulkLoadStatus.reload:
        bulkLoadProvider.clearBulkLoadStatus();
        _executeBulkLoad();
        break;
      case BulkLoadStatus.erasing:
        bulkLoadProvider.clearBulkLoadStatus();
        return Center(
          child: Text(
            'Eliminando carga...',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        );
      case BulkLoadStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error obteniendo cargas masivas',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: _executeBulkLoad,
                child: const Text('Volver a intentar'),
              ),
            ],
          ),
        );
    }
    return Column(
      children: const [Text('Borrando...')],
    );
  }

  // Acciones del botón "Eliminar"
  void _deleteButtonAction(BuildContext context, ViewLoads e) {
    final bulkLoadProvider = Provider.of<BulkLoad>(context, listen: false);
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: const [
              Text('Va a eliminar esta carga'),
            ],
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
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).highlightColor,
                      ),
                      child: const Text('Aceptar'),
                      onPressed: () async {
                        Navigator.pop(context);
                        final configureService =
                            ConfigureService(Config.serviceURL);
                        final loadedData = Provider.of<LoadDataProvider>(
                            context,
                            listen: false);
                        final delete = await loadedData.deleteFile(
                            configureService, e.fileName!);
                        if (delete == 'Archivo eliminado') {
                          bulkLoadProvider.reloadStatus();
                          // Capturar estadísticas
                          context.read<StatisticsModel>().clearStatus();
                        }
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
  }
}
