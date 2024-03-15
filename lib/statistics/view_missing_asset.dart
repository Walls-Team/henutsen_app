// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -----Reportes y estadísticas de los inventarios-----
// ----------------------------------------------------

import 'package:flutter/material.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

/// Clase principal
class MissingAssetsPage extends StatelessWidget {
  ///  Class Key
  const MissingAssetsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            appBar: ApplicationBar.appBar(context, PageList.informes),
            endDrawer: MenuDrawer.drawer(context, PageList.informes),
            body: const MissingAssetsView(),
            bottomNavigationBar: BottomBar.bottomBar(
                PageList.informes, context, PageList.informes,
                thisPage: true)),
      );
}

/// Lista los activos marcados como "No Econtrados"
class MissingAssetsView extends StatelessWidget {
  /// Constructor de MissingAssetView
  const MissingAssetsView({Key? key}) : super(key: key);

  // Tabla de activos faltantes
  Widget _assetTable(Asset asset) => DataTable(
        columns: const [
          DataColumn(
            label: Text(''),
          ),
          DataColumn(
            label: Text(''),
          ),
        ],
        rows: [
          DataRow(
            color: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(238, 237, 237, 30)),
            cells: [
              const DataCell(
                Text(
                  'Nombre activo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text(asset.name!))
            ],
          ),
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Serial',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text(asset.assetDetails!.serialNumber!))
            ],
          ),
          DataRow(
            color: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(238, 237, 237, 30)),
            cells: [
              const DataCell(
                Text(
                  'Descripción',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text(asset.description!))
            ],
          ),
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Código',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(
                    asset.assetCode ?? '(No asignado)',
                  ),
                ),
              ),
            ],
          ),
          DataRow(
            color: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(238, 237, 237, 30)),
            cells: [
              const DataCell(
                Text(
                  'Ubicación',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(asset.locationName!),
                ),
              ),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Modelo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(asset.assetDetails!.model!),
                ),
              ),
            ],
          ),
          DataRow(
            color: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(238, 237, 237, 30)),
            cells: [
              const DataCell(
                Text(
                  'Fabricante',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(asset.assetDetails!.make!),
                ),
              )
            ],
          ),
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Responsable',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(asset.custody!),
                ),
              )
            ],
          ),
          DataRow(
            color: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(238, 237, 237, 30)),
            cells: [
              const DataCell(
                Text(
                  'Estado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(SizedBox(width: 100, child: Text(asset.status!)))
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final mainStatisticsStatusProvider = Provider.of<StatisticsModel>(context);

    return ListView(
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Activos faltantes',
              style: Theme.of(context).textTheme.headline3),
        ),
        // Buscador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            onChanged: mainStatisticsStatusProvider.filterMissingAssets,
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
              labelText: 'Buscar',
            ),
          ),
        ),
        // Títulos de tabla
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text(
                  'Ubicación',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataColumn(
                label: Text(
                  'Nombre activo',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataColumn(
                label: Text(
                  'Reponsable conteo',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataColumn(
                label: Text(
                  'Estado',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataColumn(
                label: Text(
                  'Más información',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            rows:
                mainStatisticsStatusProvider.filteredMissingAssetsList.map((e) {
              // Revisar integridad de los datos
              e.description ??= '';
              e.custody ??= '';
              e.assetDetails ??= AssetDetails();
              e.assetDetails!.model ??= '';
              e.assetDetails!.make ??= '';
              e.status ??= '';
              e.lastStocktaking ??= LastStocktaking();
              return DataRow(
                color:
                    MaterialStateProperty.resolveWith<Color?>((final states) {
                  if (mainStatisticsStatusProvider.filteredMissingAssetsList
                      .indexOf(e)
                      .isEven) {
                    return const Color.fromRGBO(238, 237, 237, 30);
                  }
                  return null;
                }),
                cells: [
                  DataCell(
                    Text(e.locationName!),
                  ),
                  DataCell(
                    Text(e.name!),
                  ),
                  DataCell(
                    Text(e.lastStocktaking!.userName),
                  ),
                  DataCell(
                    Text(e.status!),
                  ),
                  DataCell(
                    GestureDetector(
                      onTap: () async {
                        final showModal = AlertDialogModal(context: context);
                        Widget title;
                        if (e.images == null) {
                          title = Column(
                            children: const [
                              Text('Descripción activo'),
                              Text('\n(No hay foto del activo)')
                            ],
                          );
                        } else if (e.images!.isEmpty) {
                          title = Column(
                            children: const [
                              Text('Descripción activo'),
                              Text('\n(No hay foto del activo)')
                            ],
                          );
                        } else {
                          title = Column(
                            children: [
                              const Text('Descripción activo'),
                              SizedBox(
                                width: 100,
                                height: 150,
                                child: PhotoViewGallery.builder(
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  builder: (final context, final index) =>
                                      PhotoViewGalleryPageOptions(
                                    imageProvider:
                                        NetworkImage(e.images![index].picture!),
                                    initialScale:
                                        PhotoViewComputedScale.contained * 0.8,
                                    minScale:
                                        PhotoViewComputedScale.contained * 0.8,
                                    maxScale:
                                        PhotoViewComputedScale.covered * 1.1,
                                  ),
                                  itemCount: e.images!.length,
                                  loadingBuilder: (context, progress) =>
                                      const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  backgroundDecoration:
                                      const BoxDecoration(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        }
                        await showModal.showDataModal(
                          title: title,
                          body: _assetTable(e),
                        );
                      },
                      child: const Center(child: Icon(Icons.more_horiz)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Contiene el modal de despliegue
class AlertDialogModal {
  ///Constructor de  [AlertDialogModal]
  AlertDialogModal({this.context});

  /// Contexto
  final BuildContext? context;

  /// Datos
  Future<void> showDataModal({Widget? title, Widget? body}) async {
    await showDialog(
      context: context!,
      builder: (buildcontext) => AlertDialog(
        title: title,
        scrollable: true,
        actionsOverflowButtonSpacing: double.maxFinite,
        content: body,
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(buildcontext).pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
