// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ---------------------------------------------------------------------
// --------------------Opciones de gestión------------------------------
// ---------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:henutsen_cli/models/models.dart';
import 'package:henutsen_cli/navigation.dart';
import 'package:henutsen_cli/provider/area_model.dart';
import 'package:henutsen_cli/provider/campus_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/location_model.dart';
import 'package:henutsen_cli/provider/role_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';
import 'package:henutsen_cli/utils/verifyResources.dart';
import 'package:henutsen_cli/widgets/henutsen_dialogs.dart';
import 'package:provider/provider.dart';

/// Clase principal
class ConfigPage extends StatelessWidget {
  ///  Class Key
  const ConfigPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: ApplicationBar.appBar(
            context,
            PageList.configuracion,
            leavingBlock: true,
          ),
          endDrawer: MenuDrawer.drawer(context, PageList.configuracion),
          body: const Options(),
          bottomNavigationBar: BottomBar.bottomBar(
              PageList.inicio, context, PageList.configuracion),
        ),
      );
}

/// Clase para selección de opciones de gestión
class Options extends StatelessWidget {
  ///  Class Key
  const Options({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Capturar el usuario actual
    final user = context.watch<UserModel>();
    final company = context.read<CompanyModel>();
    final campus = context.read<CampusModel>();
    //para empresas
    final companies = verifyResourceCompanies(user, company, context);
    //para usuarios
    final users = verifyResourceUsers(user, company, context);
    //para ubicaciones
    final locations = verifyResourceLocation(user, company, context);
    //para roles
    final roles = verifyResourceRoles(user, company, context);

    // Se captura el rol. Las opciones se mostrarán según el mismo:
    // - Vendedor: Permite crear empresas, usuarios y ubicaciones
    // - Coordinador: Permite crear ubicaciones y usuarios solo para la empresa
    // de este usuario
    // - Analista: No deja hacer nada de configuración
    final _userRole = user.currentUserRole;

    // Botón de empresas
    final _empresas = InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Image.asset(
            'images/iconoEmpresa.png',
            height: 100,
            semanticLabel: 'Empresas',
            color: !companies ? Colors.grey.withAlpha(50) : null,
          ),
          Text('Empresas', style: Theme.of(context).textTheme.headline5),
        ]),
      ),
      onTap: () async {
        if (companies) {
          // Capturar modelo de empresa

          // Obtener lista de empresas
          await company.loadCompanies();
          company
            ..sortListCompany()
            ..status = CompanyStatus.idle;

          await Navigator.pushNamed(context, '/gestion-empresas');
        } else {
          HenutsenDialogs.showSnackbar(
              'Su rol actual no tiene permisos para acceder '
              'al módulo de "Empresas".',
              context);
        }
      },
    );

    // Botón de usuarios
    final _usuarios = InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Image.asset(
            'images/iconoUsuario.png',
            height: 100,
            semanticLabel: 'Usuarios',
            color: !users ? Colors.grey.withAlpha(50) : null,
          ),
          Text('Usuarios', style: Theme.of(context).textTheme.headline5),
        ]),
      ),
      onTap: () async {
        if (users) {
          // Capturar el usuario
          final user = context.read<UserModel>();
          // Capturar la empresa
          final company = context.read<CompanyModel>();
          // Obtener lista de usuarios
          await user.getUsersList();
          // Obtener lista de empresas
          // Dependiendo el rol, se obtienen todas las empresas o solo la actual
          if (_userRole.contains('Vendedor')) {
            await company.loadCompanies();
            company
              ..sortListCompany()
              ..status = CompanyStatus.idle;
          } else {
            if (!company.fullCompanyList.contains(company.currentCompany)) {
              company.fullCompanyList.add(company.currentCompany);
            }
            user
              ..currentSearchCompany = company.currentCompany.name!
              ..currentSearchCompanyID = company.currentCompany.id;
          }
          await Navigator.pushNamed(context, '/gestion-usuarios');
        } else {
          HenutsenDialogs.showSnackbar(
              'Su rol actual no tiene permisos para acceder '
              'al módulo de "Usuarios".',
              context);
        }
      },
    );

    // Botón de ubicaciones
    final _ubicaciones = InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Image.asset(
            'images/iconoUbicacion.png',
            height: 100,
            semanticLabel: 'Ubicaciones',
            color: !locations ? Colors.grey.withAlpha(50) : null,
          ),
          Text('Ubicaciones', style: Theme.of(context).textTheme.headline5),
        ]),
      ),
      onTap: () async {
        if (locations) {
          // Capturar modelo de ubicación
          final location = context.read<LocationModel>();
          // Capturar modelo de empresa
          final company = context.read<CompanyModel>();
          // Iniciar con empresa actual
          location.currentSearchCompany = company.currentCompany;
          // Obtener lista de empresas
          // Dependiendo el rol, se obtienen todas las empresas o solo la actual
          if (_userRole.contains('Vendedor')) {
            await company.loadCompanies();
            company
              ..sortListCompany()
              ..status = CompanyStatus.idle;
          } else {
            if (!company.fullCompanyList.contains(company.currentCompany)) {
              company.fullCompanyList.add(company.currentCompany);
            }
          }
          await Navigator.pushNamed(context, '/gestion-ubicaciones');
        } else {
          HenutsenDialogs.showSnackbar(
              'Su rol actual no tiene permisos para acceder '
              'al módulo de "Ubicaciones".',
              context);
        }
      },
    );

    // Botón de roles
    final _roles = InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Image.asset(
            'images/iconoRol.png',
            height: 100,
            semanticLabel: 'Roles',
            color: !roles ? Colors.grey.withAlpha(50) : null,
          ),
          Text('Roles', style: Theme.of(context).textTheme.headline5),
        ]),
      ),
      onTap: () async {
        if (roles) {
          // Capturar la empresa
          final company = context.read<CompanyModel>();
          // Capturar modelo de rol
          final role = context.read<RoleModel>();
          // Obtener lista de empresas
          // Dependiendo el rol, se obtienen todas las empresas o solo la actual
          if (_userRole.contains('Vendedor')) {
            await company.loadCompanies();
            company
              ..sortListCompany()
              ..status = CompanyStatus.idle;
          } else {
            if (!company.fullCompanyList.contains(company.currentCompany)) {
              company.fullCompanyList.add(company.currentCompany);
            }
          }
          role.currentSearchCompany = company.currentCompany.name;
          await Navigator.pushNamed(context, '/gestion-roles');
        } else {
          HenutsenDialogs.showSnackbar(
              'Su rol actual no tiene permisos para acceder '
              'al módulo de "Roles".',
              context);
        }
      },
    );

    // Botón de lineas de negocio
    final _businessLines = InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Image.asset(
            'images/iconoModificar.png',
            height: 100,
            semanticLabel: 'BusinessLines',
            //color: !roles ? Colors.grey.withAlpha(50) : null,
          ),
          Text('Lineas de\nnegocio',
              style: Theme.of(context).textTheme.headline5),
        ]),
      ),
      onTap: () async {
        // Capturar la empresa
        final company = context.read<CompanyModel>();
        // Capturar modelo de rol
        final role = context.read<RoleModel>();
        // Obtener lista de empresas
        // Dependiendo el rol, se obtienen todas las empresas o solo la actual
        if (_userRole.contains('Vendedor')) {
          await company.loadCompanies();
          company
            ..sortListCompany()
            ..status = CompanyStatus.idle;
        } else {
          if (!company.fullCompanyList.contains(company.currentCompany)) {
            company.fullCompanyList.add(company.currentCompany);
          }
        }

        company.asigneNewNameBusiness(
            company.currentCompany.name!, company.currentCompany);
        await Navigator.pushNamed(context, '/gestion-negocios');
        /* } else {
          HenutsenDialogs.showSnackbar(
              'Su rol actual no tiene permisos para acceder '
              'al módulo de "Roles".',
              context);
        }*/
      },
    );

    // Botón de áreas
    final _areas = InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Image.asset(
            'images/iconoModificar.png',
            height: 100,
            semanticLabel: 'Áreas',
            //color: !roles ? Colors.grey.withAlpha(50) : null,
          ),
          Text('Áreas', style: Theme.of(context).textTheme.headline5),
        ]),
      ),
      onTap: () async {
        // Capturar la empresa
        final company = context.read<CompanyModel>();
        // Capturar la empresa
        final campus = context.read<CampusModel>();
        final areaModel = context.read<AreaModel>();
        var camp = Campus();
        final camps = <Campus>[];
        await campus.getListCampus();

        if (company.currentCompany.name == 'Audisoft' ||
            company.currentCompany.name == 'Ideas Control') {
          await company.getCompanyList();
          areaModel.initFilter(campus.campusList, company.fullCompanyList);
          for (final item in campus.campusList) {
            if (item.companyCode == company.currentCompany.companyCode) {
              camp = item;
              break;
            }
          }
        } else {
          areaModel.initFilter(campus.campusList, [company.currentCompany]);
          for (final item in campus.campusList) {
            if (item.companyCode == company.currentCompany.companyCode) {
              camp = item;
              break;
            }
          }
        }
        for (final item in campus.campusList) {
          if (item.companyCode == company.currentCompany.companyCode) {
            camps.add(item);
          }
        }
        areaModel
          ..asigneCampus(camp)
          ..changeNameC(company.currentCompany.name!)
          ..asingeNewNames(camps);
        await Navigator.pushNamed(context, '/area-page');
      },
    );

    // Botón de lineas de negocio
    final _campus = InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Image.asset(
            'images/iconoUbicacion.png',
            height: 100,
            semanticLabel: 'Campus',
            //color: !roles ? Colors.grey.withAlpha(50) : null,
          ),
          Text('Sedes', style: Theme.of(context).textTheme.headline5),
        ]),
      ),
      onTap: () async {
        await campus.getListCampus();
        await company.getCompanyList();
        final valueOpt = company.currentCompany.name != 'Audisoft' &&
                company.currentCompany.name != 'Ideas Control'
            ? 0
            : 1;
        campus.initFilters(company.currentCompany.name!, company.currentCompany,
            company.fullCompanyList, valueOpt);
        await Navigator.pushNamed(context, '/campus-page');
      },
    );

    return ListView(
      children: [
        // Título
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración',
                style: Theme.of(context).textTheme.headline2,
              ),
              Text(
                'Agregue, modifique o elimine empresas, usuarios,  '
                'ubicaciones y roles',
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
        // Primera fila de opciones
        Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_empresas, _usuarios],
            )),
        // Segunda fila de opciones
        Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_ubicaciones, _roles],
          ),
        ),
        //tercera fila de opciones
        /* Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [, _campus],
          ),
        ),*/
        /*Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_areas],
          ),
        ),*/
      ],
    );
  }
}
