// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// ----------------Modificar categoría-----------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/category_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class CategoryDataPage extends StatelessWidget {
  ///  Class Key
  const CategoryDataPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(context, PageList.gestion),
          endDrawer: MenuDrawer.drawer(context, PageList.gestion),
          body: CategoryData(),
          bottomNavigationBar:
              BottomBar.bottomBar(PageList.inicio, context, PageList.gestion),
        ),
      );
}

/// Datos de categoría
class CategoryData extends StatelessWidget {
  ///  Class Key
  CategoryData({Key? key}) : super(key: key);

  // Llave para el formulario de captura de datos
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Capturar modelo de categoría
    final category = context.watch<CategoryModel>();

    return Scrollbar(
      isAlwaysShown: kIsWeb,
      child: ListView(
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Detalles de la categoría',
                style: Theme.of(context).textTheme.headline3),
          ),
          // Nota de campos requeridos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.only(bottom: 10),
            child: const Text('Los campos con (*) son requeridos.'),
          ),
          // Formulario para nueva categoría
          Form(
            key: _formKey,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Fila de nombre
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Nombre (*)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: TextFormField(
                        initialValue: category.tempCategory?.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 5),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp('[\n\t\r]'))
                        ],
                        onChanged: (value) {
                          category.tempCategory?.value = value;
                        },
                        maxLength: 30,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ingrese dato';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botones
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón de cancelar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                // Botón de crear
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).highlightColor,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Capturar el modelo de usuario
                        final user = context.read<UserModel>();
                        // Capturar el modelo de inventario
                        final inventory = context.read<InventoryModel>();
                        // Capturar el modelo de empresa
                        final company = context.read<CompanyModel>();
                        final _userName = user.name2show;
                        //Response _result;
                        var _success = false;
                        var _dialogText = '';
                        // Acciones dependen si se crea o se modifica categoría
                        if (category.creationMode) {
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma creación de la categoría '
                              '${category.tempCategory?.value}?')) {
                            /*
                            _result = await category.createCategory(
                                jsonEncode(category.loadedCategory), true);
                            if (_result.statusCode == 201) {
                              _success = true;
                              category.categoriesBase.clear();
                              category.getCategories(
                                  company.currentCompany.companyCode!);
                            }
                            _dialogText = _result.message!;
                            */
                            _success = true;
                            _dialogText = 'Las categorías se crean en el '
                                'módulo de creación de activos.';
                          }
                        } else {
                          // Se espera confirmación del usuario
                          if (await HenutsenDialogs.confirmationMessage(
                              context,
                              '¿Confirma modificación de la categoría '
                              '${category.tempCategory?.value}?')) {
                            /*
                            _result = await category.createCategory(
                                jsonEncode(category.loadedCategory), false);
                            if (_result.statusCode == 200) {
                              _success = true;
                              category.categoriesBase.clear();
                              category.getCategories(
                                  company.currentCompany.companyCode!);
                            }
                            _dialogText = _result.message!;
                            */
                            final chain = jsonEncode(category.tempCategory);
                            final _result = await category.modifyCategory(
                                chain,
                                company.currentCompany.companyCode!,
                                _userName,
                                category.oldName);
                            if (_result == 'Ok') {
                              _success = true;
                              _dialogText = 'Categoría modificada exitosamente';
                            } else {
                              _dialogText = 'Error modificando categoría.\n'
                                  '$_result.\n'
                                  'Revise e intente nuevamente.';
                            }
                          }
                        }
                        if (_dialogText.isNotEmpty) {
                          await showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Text(
                                  _dialogText,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).highlightColor,
                                  ),
                                  onPressed: () async {
                                    if (_success) {
                                      // Actualizar inventario con cambio de
                                      // categoría
                                      if (!category.creationMode) {
                                        inventory.categories
                                            .remove(category.oldName);
                                      }
                                      inventory.categories
                                          .add(category.tempCategory!.value!);
                                      // Actualizar inventario
                                      inventory.initInventory();
                                      await inventory.loadInventory(
                                          company.currentCompany.companyCode!);
                                      inventory.getCategories();
                                      Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                            '/gestion-categorias'),
                                      );
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text('Aceptar'),
                                )
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: category.creationMode
                        ? const Text('Crear')
                        : const Text('Modificar'),
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
