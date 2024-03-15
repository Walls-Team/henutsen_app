// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// --------------------------------------------------------
// ------------------Gestión de categorías-----------------
// --------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/category_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/utils/data_table_items.dart';
import 'package:provider/provider.dart';

/// Clase principal
class CategoryManagement extends StatelessWidget {
  ///  Class Key
  const CategoryManagement({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.gestion),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: CategoryList(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

/// --------------- Para mostrar las categorias ------------------
class CategoryList extends StatelessWidget {
  ///  Class Key
  CategoryList({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _searchBoxWidth = (mediaSize.width < screenSizeLimit)
        ? mediaSize.width * 0.7 - 20
        : mediaSize.width * 0.4 - 20;
    // Capturar modelo de categoría
    final category = context.watch<CategoryModel>();

    // ----Widgets----
    // Campo de búsqueda
    final _searchField = SizedBox(
      width: _searchBoxWidth,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: TextFormField(
          decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              labelText: 'Buscar por nombre'),
          onChanged: category.changeSearchName,
          validator: (value) => null,
        ),
      ),
    );

    // Botón de limpiar búsqueda
    final _cleanButton = Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.reset();
            category.changeSearchName('');
            FocusScope.of(context).unfocus();
          }
        },
        child: const Text('Limpiar'),
      ),
    );
    // ----Widgets---- FIN

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
                Text('Gestión de categorías',
                    style: Theme.of(context).textTheme.headline2),
                Text(
                  'Modifique las categorías del inventario de su empresa',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          // Filtros de búsqueda
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Búsqueda genérica
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      // Texto "buscar"
                      const SizedBox(
                        width: 70,
                        child: Text('Buscar:'),
                      ),
                      // Campo de búsqueda
                      _searchField,
                    ]),
                  ),
                  // Botón de limpiar buscador
                  _cleanButton,
                ],
              ),
            ),
          ),
          // Información de categorías
          const InfoToShow(),
        ],
      ),
    );
  }
}

/// Clase para devolver la información de categorías a mostrar
class InfoToShow extends StatelessWidget {
  /// Class Key
  const InfoToShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar modelo de categoría
    final category = context.watch<CategoryModel>();
    // Capturar el modelo de inventario
    final inventory = context.watch<InventoryModel>();

    // Presentamos lista de categorías
    if (inventory.categories.isNotEmpty) {
      // Llenar la lista
      final categories2show = <String>[];
      for (final item in inventory.categories) {
        // Revisar filtros
        if (category.currentSearchName == '' ||
            item
                .trim()
                .toLowerCase()
                .contains(category.currentSearchName.trim().toLowerCase())) {
          categories2show.add(item);
        }
      }

      if (categories2show.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          // Tabla de ubicaciones
          child: PaginatedDataTable(
            source: DataTableItems(
                context: context,
                generalData: categories2show,
                modelSource: category,
                dataToPrint: DataToPrint.categories),
            header: const Text('Lista de Categorias'),
            columns: [
              const DataColumn(label: Text('No.')),
              const DataColumn(label: Text('Categoría')),
              DataColumn(
                  label: Expanded(
                child: Text('Total de Categorias: ${categories2show.length}',
                    textAlign: TextAlign.center),
              )),
            ],
            columnSpacing: 50,
            horizontalMargin: 10,
            rowsPerPage:
                categories2show.length <= 10 ? categories2show.length : 10,
            showCheckboxColumn: false,
          ),
        );
      } else {
        return const SizedBox(
          height: 200,
          width: 200,
          child: Text(
            'No se encontraron categorias',
            textAlign: TextAlign.center,
          ),
        );
      }
    } else {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Text(
          'No se encontraron categorias',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
