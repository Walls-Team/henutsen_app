// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// -------------------------------------------------------------------
// --------------Clase para visualización de cargas masivas-----------
// -------------------------------------------------------------------

import 'package:henutsen_cli/models/models.dart';

/// Clase para ver cargas
class ViewLoads {
  /// Constructor
  ViewLoads(
      {this.date,
      this.fileName,
      this.userName,
      this.quantity,
      this.locations,
      this.reports});

  /// Fecha de carga
  String? date;

  /// Nombre del archivo
  String? fileName;

  /// Nombre de usuario que hizo la carga
  String? userName;

  /// Cantidad de activos cargados
  int? quantity;

  /// Cantidad de ubicaciones donde se hicieron cargas
  int? locations;

  /// Listado de reportes de carga
  List<Stocktaking>? reports;
}
