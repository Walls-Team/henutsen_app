// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// -------Modelo de Categoría para Provider------------
// ----------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;

/// Modelo de categoría
class CategoryModel extends ChangeNotifier {
  /// Categoría actual en edición
  AssetCategory? tempCategory;

  /// En modo creación de categoría
  bool creationMode = true;

  /// Nombre antiguo (para modificar categoría)
  String oldName = '';

  /// Valor antiguo (para modificar valor)
  String oldValue = '';

  // Variables para campos de texto de búsqueda
  /// Búsqueda por nombre
  String currentSearchName = '';

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    tempCategory = null;
    creationMode = true;
    oldName = '';
    oldValue = '';
    currentSearchName = '';
  }

  /// Búsqueda de categoría por nombre
  void changeSearchName(String name) {
    currentSearchName = name;
    notifyListeners();
  }

  /// Finalizó edición de categoría
  void editDone() {
    notifyListeners();
  }

  /// Función para hacer petición PATCH y modificar la categoría
  Future<String> modifyCategory(String thingToSend, String companyCode,
      String userName, String oldCategoryName) async {
    // Armar la solicitud con los campos adecuados
    final bodyData = {
      'CategoryData': thingToSend,
      'CompanyCode': companyCode,
      'UserName': userName,
      'OldCategoryName': oldCategoryName
    };
    final headers = Config.authorizationHeader(Config.userToken)
      ..addAll({'Content-Type': 'application/json'});
    try {
      final response = await http.patch(Uri.parse(Config.modifyCategoryURL),
          body: json.encode(bodyData), headers: headers);

      // Se espera una respuesta 200
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response:
        if (response.body == 'Categoría modificada') {
          return 'Ok';
        } else {
          return response.body;
        }
      } else {
        return 'Error de petición';
      }
    } on Exception {
      return 'Error del Servidor';
    }
  }

  /*
  /// Lista de todas las categorías
  List<dynamic> allCategories = [];

  /// List of categories
  List<String> categories = [];

  /// List of categories base
  List<String> categoriesBase = [];

  /// Mode
  bool isCreate = true;

  /// Loaded category
  CategoryM loadedCategory = CategoryM();

  /// Loded categories
  bool isLoaded = false;

  /// Init
  void init() {
    isCreate = true;
    isLoaded = false;
    loadedCategory = CategoryM();
  }

  /// Category search by name
  void onChangeSearchCategoryName(String query) {
    if (categoriesBase.isNotEmpty) {
      categories = categoriesBase
          .where((c) => c.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    } else {
      categories.clear();
      categories.addAll(categoriesBase);
    }
    notifyListeners();
  }

  /// Function to create or edit a new category
  Future<Response> createCategory(String thingToSend, bool isCreate) async {
    final response = isCreate
        ? await http.post(Uri.parse(Config.createOrEditCategoryURL),
            body: thingToSend, headers: {'Content-Type': 'application/json'})
        : await http.put(Uri.parse(Config.createOrEditCategoryURL),
            body: thingToSend, headers: {'Content-Type': 'application/json'});
    print(response.body);
    return Response.fromJson(jsonDecode(response.body));
  }

  /// Function to delete a new category
  Future<Response> deleteCategory(String thingToSend) async {
    final response = await http.delete(Uri.parse(Config.deleteCategoryURL),
        body: thingToSend, headers: {'Content-Type': 'application/json'});
    return Response.fromJson(jsonDecode(response.body));
  }

  /// Function to fetch all categories a new category
  Future<void> getCategories(String companyCode) async {
    if (categoriesBase.isEmpty) {
      final response = await http.get(
          Uri.parse(Config.getCategoriesURL + "/" + companyCode),
          headers: {'Content-Type': 'application/json'});
      Response result = Response.fromJson(jsonDecode(response.body));
      if (result.statusCode == 200) {
        allCategories.clear();
        categories.clear();
        categoriesBase.clear();
        allCategories = result.content;
        for (dynamic c in allCategories) {
          categories.add(c["value"]);
        }
        categoriesBase.addAll(categories);
        isLoaded = true;
        notifyListeners();
      }
    }
  }

  /// Function to fetch category a new category
  Future<void> getCategoryById(String thingToSend) async {
    final response = await http.post(Uri.parse(Config.getCategoryByIdURL),
        body: thingToSend, headers: {'Content-Type': 'application/json'});
    Response result = Response.fromJson(jsonDecode(response.body));
    if (result.statusCode == 200) {
      loadedCategory = CategoryM(
        id: result.content["id"] as String?,
        value: result.content["value"] as String?,
        author: result.content["author"] as String?,
      );
      notifyListeners();
    }
  }
  */
}
