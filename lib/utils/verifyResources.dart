import 'package:flutter/cupertino.dart';
import 'package:henutsen_cli/management/resourcesAsset.dart';

import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';

///verify value Resource
bool verifyResourceAsset(
    UserModel user, CompanyModel company, BuildContext context) {
  var flag = false;
//para activos
  final deleteAsset =
      verifyResource(user.currentUser.roles!, company, 'DeleteAsset');
  final modAsset = verifyResource(user.currentUser.roles!, company, 'ModAsset');
  final saveAsset =
      verifyResource(user.currentUser.roles!, company, 'SaveNewAsset');
  final viewInventory =
      verifyResource(user.currentUser.roles!, company, 'LoadInventory');
  final readEtiquete =
      verifyResource(user.currentUser.roles!, company, 'ReadEtiquete');
  final viewAuthorization =
      verifyResource(user.currentUser.roles!, company, 'GetAuthorizations');
  final viewTransfer =
      verifyResource(user.currentUser.roles!, company, 'GetPendient');
  final newAuthorize = verifyResource(
      user.currentUser.roles!, company, 'CreateNewAuthorization');
  final modAuthorize =
      verifyResource(user.currentUser.roles!, company, 'ModifyAuthorization');
  final deleteAuthorize =
      verifyResource(user.currentUser.roles!, company, 'DeleteAuthorization');
  final modCategory =
      verifyResource(user.currentUser.roles!, company, 'ModifyCategory');

  if (deleteAsset ||
      modAsset ||
      saveAsset ||
      viewInventory ||
      readEtiquete ||
      viewAuthorization ||
      viewTransfer ||
      newAuthorize ||
      modCategory ||
      modAuthorize ||
      deleteAuthorize) {
    flag = true;
  }

  return flag;
}

///verify value Resource
bool verifyResourceCompanies(
    UserModel user, CompanyModel company, BuildContext context) {
  var flag = false;
//para activos
  final getListCompany =
      verifyResource(user.currentUser.roles!, company, 'GetCompanyList');
  final creatCompany =
      verifyResource(user.currentUser.roles!, company, 'CreateGroup');
  final replaceCompany =
      verifyResource(user.currentUser.roles!, company, 'ReplaceGroup');
  final deleteCompany =
      verifyResource(user.currentUser.roles!, company, 'DeleteGroup');

  if (getListCompany || creatCompany || replaceCompany || deleteCompany) {
    flag = true;
  }

  return flag;
}

///verify value Resource
bool verifyResourceUsers(
    UserModel user, CompanyModel company, BuildContext context) {
  var flag = false;
//para activos
  final getListUser =
      verifyResource(user.currentUser.roles!, company, 'GetListUser');
  final creatUser =
      verifyResource(user.currentUser.roles!, company, 'CreateUser');
  final replaceUser =
      verifyResource(user.currentUser.roles!, company, 'ReplaceUser');
  final deleteUser =
      verifyResource(user.currentUser.roles!, company, 'DeleteUser');

  if (getListUser || creatUser || replaceUser || deleteUser) {
    flag = true;
  }

  return flag;
}

///verify value Resource
bool verifyResourceLocation(
    UserModel user, CompanyModel company, BuildContext context) {
  var flag = false;
//para activos
  final getListLocation =
      verifyResource(user.currentUser.roles!, company, 'ViewLocation');
  final creatLocation =
      verifyResource(user.currentUser.roles!, company, 'SaveNewLocation');
  final replaceLocation =
      verifyResource(user.currentUser.roles!, company, 'ModifyLocation');
  final deleteLocation =
      verifyResource(user.currentUser.roles!, company, 'DeleteLocation');

  if (getListLocation || creatLocation || replaceLocation || deleteLocation) {
    flag = true;
  }

  return flag;
}

///verify value Resource
bool verifyResourceRoles(
    UserModel user, CompanyModel company, BuildContext context) {
  var flag = false;
//para activos
  final saveRole =
      verifyResource(user.currentUser.roles!, company, 'SaveNewRole');
  final creatRole =
      verifyResource(user.currentUser.roles!, company, 'ModifyRole');
  final replaceRole =
      verifyResource(user.currentUser.roles!, company, 'DeleteRole');

  if (saveRole || creatRole || replaceRole) {
    flag = true;
  }

  return flag;
}

///verify value Resource
bool verifyResourceConfg(
    UserModel user, CompanyModel company, BuildContext context) {
  var flag = false;

//empresas
  final getListCompany =
      verifyResource(user.currentUser.roles!, company, 'GetCompanyList');
  final creatCompany =
      verifyResource(user.currentUser.roles!, company, 'CreateGroup');
  final replaceCompany =
      verifyResource(user.currentUser.roles!, company, 'ReplaceGroup');
  final deleteCompany =
      verifyResource(user.currentUser.roles!, company, 'DeleteGroup');
  //usuarios
  final getListUser =
      verifyResource(user.currentUser.roles!, company, 'GetListUser');
  final creatUser =
      verifyResource(user.currentUser.roles!, company, 'CreateUser');
  final replaceUser =
      verifyResource(user.currentUser.roles!, company, 'ReplaceUser');
  final deleteUser =
      verifyResource(user.currentUser.roles!, company, 'DeleteUser');

  //ubicaciones
  final getListLocation =
      verifyResource(user.currentUser.roles!, company, 'ViewLocation');
  final creatLocation =
      verifyResource(user.currentUser.roles!, company, 'SaveNewLocation');
  final replaceLocation =
      verifyResource(user.currentUser.roles!, company, 'ModifyLocation');
  final deleteLocation =
      verifyResource(user.currentUser.roles!, company, 'DeleteLocation');
  //roles
  final saveRole =
      verifyResource(user.currentUser.roles!, company, 'SaveNewRole');
  final creatRole =
      verifyResource(user.currentUser.roles!, company, 'ModifyRole');
  final replaceRole =
      verifyResource(user.currentUser.roles!, company, 'DeleteRole');

  if (getListCompany ||
      creatCompany ||
      replaceCompany ||
      deleteCompany ||
      saveRole ||
      creatRole ||
      getListUser ||
      creatUser ||
      replaceUser ||
      deleteUser ||
      getListLocation ||
      creatLocation ||
      replaceLocation ||
      deleteLocation ||
      replaceRole) {
    flag = true;
  }

  return flag;
}
