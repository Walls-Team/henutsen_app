import 'package:flutter/material.dart';
import 'package:henutsen_cli/provider/inventory_out.dart';
import 'package:henutsen_cli/provider/role_model.dart';
import 'package:provider/provider.dart';

///modal para asignar activos manualmente a una autorizacion
class ModalAsset extends StatelessWidget {
  ///constructor
  const ModalAsset({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final inventory = context.watch<InventoryOutModel>();

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Lista de activos',
              style: TextStyle(fontSize: 22, color: Colors.black)),
        ),
        Scrollbar(
          controller: scrollController,
          isAlwaysShown: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: inventory.fullInventory.map((e) {
              var findAsset = false;
              if (inventory.assetsId.isNotEmpty) {
                if (inventory.assetsId.contains(e.assetCode)) {
                  findAsset = true;
                }
              }
              final serial = e.assetDetails!.serialNumber == null
                  ? 'sin serial'
                  : e.assetDetails!.serialNumber!.isEmpty
                      ? 'sin serial'
                      : e.assetDetails!.serialNumber;
              return Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 200,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nombre: ${e.name!}'),
                                const SizedBox(
                                  height: 04,
                                ),
                                Text('Serial: $serial'),
                              ]),
                        ),
                        Checkbox(
                          value: findAsset,
                          activeColor: Colors.lightBlue,
                          onChanged: (newValue) {
                            inventory.addAssetId(e, newValue);
                          },
                        ),
                        const SizedBox(
                          width: 03,
                        )
                      ]),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(color: Theme.of(context).primaryColor),
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
