// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// ------------Modelo de Rol para Provider------------
// ----------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:http/http.dart' as http;

/// Modelo para el rol
class RoleModel extends ChangeNotifier {
  /// Mapa de recursos vs. nombre de vista
  static const Map resourcesAndViews = <String, String>{
    'Reports-0': 'Acceder a reportes',
    'Reports-1': 'Filtrar por ubicación',
    'Reports-2': 'Estadísticas avanzadas',
    'Reports-3': 'Descargar reportes',
    'MassLoad-1': 'Cargar archivo',
    'MassLoad-2': 'Visualizar cargas',
    'MassLoad-3': 'Eliminar carga',
    'Stocktaking-0': 'Acceder a conteo',
    'Print-0': 'Acceder a impresión',
    'Encode-0': 'Acceder a codificación',
    'Encode-1': 'Proteger etiqueta',
    'Management-0': 'Ver activos',
    'Management-1': 'Crear activo',
    'Management-2': 'Modificar activo',
    'Management-3': 'Eliminar activo',
    'Management-15': 'Dar de baja a un activo',
    'Management-16': 'Préstamos internos',
    'Management-17': 'Ingreso de activos',
    'Management-4': 'Leer etiqueta',
    'Management-6': 'Ver autorizaciones',
    'Management-7': 'Ver solicitudes de autorizaciones',
    'Management-8': 'Crear autorización',
    'Management-9': 'Modificar autorización',
    'Management-10': 'Eliminar autorización',
    'Management-11': 'Modificar categoría',
    'Management-13': 'Solicitar autorizaciones',
    'Management-14': 'Salida de autorizaciones',
    'Configuration-1': 'Ver empresas',
    'Configuration-2': 'Crear empresa',
    'Configuration-3': 'Modificar empresa',
    'Configuration-4': 'Eliminar empresa',
    'Configuration-5': 'Ver usuarios',
    'Configuration-6': 'Crear usuario',
    'Configuration-7': 'Modificar usuario',
    'Configuration-8': 'Eliminar usuario',
    'Configuration-9': 'Ver ubicaciones',
    'Configuration-10': 'Crear ubicación',
    'Configuration-11': 'Modificar ubicación',
    'Configuration-12': 'Eliminar ubicación',
    'Configuration-14': 'Crear rol',
    'Configuration-15': 'Modificar rol',
    'Configuration-16': 'Eliminar rol',
  };

  /// Rol actual en creación/modificación
  CompanyRole tempRole = CompanyRole();

  /// En modo creación de rol
  bool creationMode = true;

  /// Listado de roles a mostrar por empresa
  List<CompanyRole> rolesList = <CompanyRole>[];

  ///compañia temporal para mostrar las ubicaciones a asignar
  Company companyTemp = Company();

  /// Variable para campo de texto de búsqueda
  String currentSearchField = '';

  /// Búsqueda por empresa
  String? currentSearchCompany;

  /// Mapa de recursos accesibles por rol
  Map resourcesList = <String, Map<String, bool>>{
    'Reportes': {
      'Acceder a reportes': false,
      'Filtrar por ubicación': false,
      'Estadísticas avanzadas': false,
      'Descargar reportes': false,
    },
    'Carga Masiva': {
      'Cargar archivo': false,
      'Visualizar cargas': false,
      'Eliminar carga': false,
    },
    'Conteo': {
      'Acceder a conteo': false,
    },
    'Impresión': {
      'Acceder a impresión': false,
    },
    'Codificación': {
      'Acceder a codificación': false,
      'Proteger etiqueta': false,
    },
    'Gestión de activos': {
      'Ver activos': false,
      'Crear activo': false,
      'Modificar activo': false,
      'Eliminar activo': false,
      'Dar de baja a un activo': false,
      'Ingreso de activos': false,
      'Préstamos internos': false,
      'Leer etiqueta': false,
      'Ver autorizaciones': false,
      'Ver solicitudes de autorizaciones': false,
      'Solicitar autorizaciones': false,
      'Salida de autorizaciones': false,
      'Crear autorización': false,
      'Modificar autorización': false,
      'Eliminar autorización': false,
      'Modificar categoría': false,
    },
    'Configuración': {
      'Ver empresas': false,
      'Crear empresa': false,
      'Modificar empresa': false,
      'Eliminar empresa': false,
      'Ver usuarios': false,
      'Crear usuario': false,
      'Modificar usuario': false,
      'Eliminar usuario': false,
      'Ver ubicaciones': false,
      'Crear ubicación': false,
      'Modificar ubicación': false,
      'Eliminar ubicación': false,
      'Crear rol': false,
      'Modificar rol': false,
      'Eliminar rol': false,
    },
  };

  ///lista que guarda las ubicaciones asignadas
  List<String> resourceLocations = [];

  ///Indicador de check para todas las ubicaciones o en particular
  bool checkAll = false;

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    checkAll = false;
    tempRole = CompanyRole();
    companyTemp = Company();
    creationMode = true;
    rolesList.clear();
    resourceLocations = [];
    currentSearchField = '';
    currentSearchCompany = null;
    clearResourceSelection();
  }

  /// Actualizar campo de búsqueda de rol
  void changeSearchField(String value) {
    currentSearchField = value;
    notifyListeners();
  }

  /// Búsqueda de rol por empresa
  void changeSearchCompany(String company) {
    currentSearchCompany = company;
    notifyListeners();
  }

  /// Asignar empresa
  void changeCompany(Company companyValue) {
    companyTemp = companyValue;
    notifyListeners();
  }

  /// asignar una ubicacion
  void asigneLocationInResouce(String locationValue, dynamic valueFlag) {
    final value = valueFlag as bool;
    if (value) {
      resourceLocations.add(locationValue);
    } else {
      resourceLocations.remove(locationValue);
    }
    notifyListeners();
  }

  /// asignar todas las ubicaciones
  void asigneLocationInResouces(List<String> locationValue, dynamic valueFlag) {
    final value = valueFlag as bool;
    if (value) {
      resourceLocations.addAll(locationValue);
      checkAll = true;
    } else {
      if (resourceLocations.isNotEmpty) {
        resourceLocations.removeRange(0, resourceLocations.length - 1);
        checkAll = false;
      }
    }
    notifyListeners();
  }

  ///asignar ubicaciones ya creadas
  void asigneResourcesL(List<String> resources, Company company) {
    for (final item in company.locations!) {
      for (final res in resources) {
        if (item == res) {
          resourceLocations.add(item);
        }
      }
    }
    notifyListeners();
  }

  /// Finalizó edición de rol
  void editDone() {
    notifyListeners();
  }

  /// Actualizar selección de recursos
  // ignore: avoid_positional_boolean_parameters
  void updateResourceSelection(String field, String subfield, bool value) {
    (resourcesList[field] as Map<String, bool>)[subfield] = value;
    notifyListeners();
  }

  /// Limpiar mapa de selección de recursos
  void clearResourceSelection() {
    resourcesList.forEach((key, value) {
      value as Map<String, bool>;
      for (final subkey in value.keys) {
        (resourcesList[key] as Map)[subkey] = false;
      }
    });
  }

  /// Actualizar mapa de visualización de permisos con recursos del rol
  void loadSelectedResources(List<String> resources) {
    for (final item in resources) {
      resourcesList.forEach((key, value) {
        if ((value as Map).keys.contains(resourcesAndViews[item])) {
          (resourcesList[key] as Map)[resourcesAndViews[item]] = true;
        }
      });
    }
  }

  /// Armar listado de recursos del rol según permisos seleccionados
  List<String> createResourcesList() {
    final roleResources = <String>[];
    resourcesList.forEach((key, value) {
      value as Map<String, bool>;
      value.forEach((subkey, subvalue) {
        if (subvalue) {
          resourcesAndViews.forEach((otherKey, otherValue) {
            if (subkey == otherValue) {
              roleResources.add(otherKey);
            }
          });
        }
      });
    });
    return roleResources;
  }

  /// Método para filtrar roles en búsqueda
  List<CompanyRole> filterRoles(String? value, List<CompanyRole> initialList) {
    var _filteredList = <CompanyRole>[];
    if (value != null && value != '') {
      // Acepta búsqueda por nombre o id
      _filteredList = initialList
          .where((role) =>
              role.name!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()) ||
              role.roleId!
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase()))
          .toList();
    } else {
      _filteredList = initialList;
    }
    return _filteredList;
  }

  /// Función para crear nuevo rol
  Future<String> saveNewRole(String thingToSend) async {
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response = await http.post(
        Uri.parse(Config.newRoleURL),
        body: thingToSend,
        headers: Config.authorizationHeader(Config.userToken),
      );

      // Se espera una respuesta 200
      if (response.statusCode == 200) {
        if (response.body.contains('Nuevo rol agregado')) {
          return 'Ok';
        } else {
          return response.body;
        }
      } else {
        return response.body;
      }
    } on Exception catch (e) {
      return 'Error del Servidor: $e';
    }
  }

  /// Función para modificar rol
  Future<String> modifyRole(String thingToSend) async {
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response = await http.put(
        Uri.parse(Config.modifyRoleURL),
        body: thingToSend,
        headers: Config.authorizationHeader(Config.userToken),
      );

      // Se espera una respuesta 200
      if (response.statusCode == 200) {
        if (response.body.contains('Rol modificado')) {
          return 'Ok';
        } else {
          return response.body;
        }
      } else {
        return response.body;
      }
    } on Exception catch (e) {
      return 'Error del Servidor: $e';
    }
  }

  /// Función para eliminar rol
  Future<String> deleteRole(String thingToSend) async {
    try {
      // Armar la solicitud con la URL de la página y el parámetro
      final response = await http.delete(
        Uri.parse(Config.deleteRoleURL),
        body: thingToSend,
        headers: Config.authorizationHeader(Config.userToken),
      );

      // Se espera una respuesta 200
      if (response.statusCode == 200) {
        if (response.body.contains('Rol eliminado')) {
          return 'Ok';
        } else {
          return response.body;
        }
      } else {
        return response.body;
      }
    } on Exception catch (e) {
      return 'Error del Servidor: $e';
    }
  }
}
