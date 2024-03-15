import 'package:flutter/material.dart';
import 'package:henutsen_cli/provider/role_model.dart';
import 'package:provider/provider.dart';

///modal para asignar las ubicaciones en el rol
class ModalLocations extends StatelessWidget {
  ///constructor
  const ModalLocations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final roles = Provider.of<RoleModel>(context);

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Ubicaciones de la empresa: ${roles.companyTemp.name}',
              style: const TextStyle(fontSize: 22, color: Colors.black)),
        ),
        Row(children: [
          const SizedBox(
            width: 180,
            child: Text('Todas'),
          ),
          Checkbox(
            value: roles.checkAll,
            activeColor: Colors.lightBlue,
            onChanged: (newValue) {
              roles.asigneLocationInResouces(
                  roles.companyTemp.locations!, newValue);
            },
          ),
        ]),
        Scrollbar(
          controller: scrollController,
          isAlwaysShown: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: roles.companyTemp.locations!.map((e) {
              var flagLocation = false;
              if (roles.resourceLocations.isNotEmpty) {
                if (roles.resourceLocations.contains(e)) {
                  flagLocation = true;
                }
              }
              return Row(children: [
                SizedBox(
                  width: 180,
                  child: Text(e),
                ),
                Checkbox(
                  value: flagLocation,
                  activeColor: Colors.lightBlue,
                  onChanged: (newValue) {
                    roles.asigneLocationInResouce(e, newValue);
                  },
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
