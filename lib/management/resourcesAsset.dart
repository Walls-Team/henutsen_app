import 'package:henutsen_cli/provider/company_model.dart';

///verify value Resource
bool verifyResource(
    List<String> roles, CompanyModel companyModel, String nameResource) {
  var flag = false;

  for (final itemRol in roles) {
    for (final itemRC in companyModel.currentCompany.roles!) {
      if (itemRC.roleId == itemRol) {
        for (final itemRes in ResourcesPerService[nameResource]!) {
          if (itemRC.resources!.contains(itemRes)) {
            flag = true;
          }
        }
      }
    }
  }

  return flag;
}

// ignore: public_member_api_docs, constant_identifier_names
const Map<String, List<String>> ResourcesPerService = <String, List<String>>{
  'ReadGroup': ['Home-0'],
  'GetManagementIndicator': ['Home-0', 'Reports-0'],
  'LoadScreenHelp': ['Home-0'],
  'GetStocktakingReports': ['Reports-2'],
  'GetInventory': [
    'Reports-3',
    'Stocktaking-0',
    'Print-0',
    'Encode-0',
    'Management-0'
  ],
  'FilterReports': ['Reports-1'],
  'Reports0': ['Reports-0'],
  'Reports3': ['Reports-3'],
  'ViewPrint': ['Print-0'],
  'ViewEncode': ['Encode-0'],
  'ViewEncode1': ['Encode-1'],
  'ReviewFile': ['MassLoad-1'],
  'SaveNewLocations': ['MassLoad-1'],
  'FileLoad': ['MassLoad-1'],
  'ObtainLoads': ['MassLoad-2'],
  'DeleteFile': ['MassLoad-3'],
  'SaveStocktakingReport': ['Stocktaking-0'],
  'ModifyAsset': ['Print-0', 'Encode-0', 'Management-2'],
  'ModifySeveralAssets': ['Print-0', 'Management-7'],
  'ModAsset': ['Management-2'],
  'LoadInventory': ['Management-0'],
  'SaveNewAsset': ['Management-1'],
  'DeleteAsset': ['Management-3'],
  'ReadEtiquete': ['Management-4'],
  'GetAuthorizations': ['Management-6'],
  'GetPendient': ['Management-7'],
  'NewPendient': ['Management-13'],
  'OutPendient': ['Management-14'],
  'InAsset': ['Management-17'],
  'DownAsset': ['Management-15'],
  'InternalAutho': ['Management-16'],
  'GetUsersList': ['Management-8', 'Configuration-5'],
  'CreateNewAuthorization': ['Management-8'],
  'ModifyAuthorization': ['Management-9'],
  'DeleteAuthorization': ['Management-10'],
  'ModifyCategory': ['Management-11'],
  'GetCompanyList': ['Configuration-1'],
  'CreateGroup': ['Configuration-2'],
  'ReplaceGroup': ['Configuration-3'],
  'DeleteGroup': ['Configuration-4'],
  'GetListUser': ['Configuration-5'],
  'CreateUser': ['Configuration-6'],
  'ReplaceUser': ['Configuration-7'],
  'DeleteUser': ['Configuration-8'],
  'ViewLocation': ['Configuration-9'],
  'SaveNewLocation': ['Configuration-10'],
  'ModifyLocation': ['Configuration-11'],
  'DeleteLocation': ['Configuration-12'],
  'SaveNewRole': ['Configuration-14'],
  'ModifyRole': ['Configuration-15'],
  'DeleteRole': ['Configuration-16'],
};
