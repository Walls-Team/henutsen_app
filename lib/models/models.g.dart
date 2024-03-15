// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Asset _$AssetFromJson(Map<String, dynamic> json) {
  return Asset(
    id: json['Id'] as String?,
    assetCode: json['AssetCode'] as String?,
    assetCodeLegacy: (json['AssetCodeLegacy'] as List<dynamic>?)
        ?.map((e) => LegacyCode.fromJson(e as Map<String, dynamic>))
        .toList(),
    companyCode: json['CompanyCode'] as String?,
    locationName: json['LocationName'] as String?,
    name: json['Name'] as String?,
    description: json['Description'] as String?,
    categories: (json['Categories'] as List<dynamic>?)
        ?.map((e) => AssetCategory.fromJson(e as Map<String, dynamic>))
        .toList(),
    assetDetails: json['AssetDetails'] == null
        ? null
        : AssetDetails.fromJson(json['AssetDetails'] as Map<String, dynamic>),
    custody: json['Custody'] as String?,
    downAnotation: json['DownAnotation'] as String?,
    status: json['Status'] as String?,
    lastStocktaking: json['LastStocktaking'] == null
        ? null
        : LastStocktaking.fromJson(
            json['LastStocktaking'] as Map<String, dynamic>),
    outOfLocation: json['OutOfLocation'] as bool?,
    lastTransferDate: json['LastTransferDate'] as String?,
    images: (json['Images'] as List<dynamic>?)
        ?.map((e) => AssetPhoto.fromJson(e as Map<String, dynamic>))
        .toList(),
    isNearAntenna: json['IsNearAntenna'] as bool?,
    tagEncoded: json['TagEncoded'] as bool?,
  );
}

AssetHistory _$AssetHistoryFromJson(Map<String, dynamic> json) {
  return AssetHistory(
    id: json['Id'] as String?,
    idAsset: json['IdAsset'],
    assetCode: json['AssetCode'] as String?,
    assetCodeLegacy: (json['AssetCodeLegacy'] as List<dynamic>?)
        ?.map((e) => LegacyCode.fromJson(e as Map<String, dynamic>))
        .toList(),
    date: json['Date'] as String?,
    userName: json['UserName'] as String?,
    companyCode: json['CompanyCode'] as String?,
    locationName: json['LocationName'] as String?,
    name: json['Name'] as String?,
    description: json['Description'] as String?,
    categories: (json['Categories'] as List<dynamic>?)
        ?.map((e) => AssetCategory.fromJson(e as Map<String, dynamic>))
        .toList(),
    assetDetails: json['AssetDetails'] == null
        ? null
        : AssetDetails.fromJson(json['AssetDetails'] as Map<String, dynamic>),
    custody: json['Custody'] as String?,
    downAnotation: json['DownAnotation'] as String?,
    status: json['Status'] as String?,
    lastStocktaking: json['LastStocktaking'] == null
        ? null
        : LastStocktaking.fromJson(
            json['LastStocktaking'] as Map<String, dynamic>),
    outOfLocation: json['OutOfLocation'] as bool?,
    lastTransferDate: json['LastTransferDate'] as String?,
    images: (json['Images'] as List<dynamic>?)
        ?.map((e) => AssetPhoto.fromJson(e as Map<String, dynamic>))
        .toList(),
    isNearAntenna: json['IsNearAntenna'] as bool?,
    tagEncoded: json['TagEncoded'] as bool?,
  );
}

Map<String, dynamic> _$AssetToJson(Asset instance) => <String, dynamic>{
      'Id': instance.id,
      'AssetCode': instance.assetCode,
      'AssetCodeLegacy':
          instance.assetCodeLegacy?.map((e) => e.toJson()).toList(),
      'CompanyCode': instance.companyCode,
      'LocationName': instance.locationName,
      'Name': instance.name,
      'Description': instance.description,
      'Categories': instance.categories?.map((e) => e.toJson()).toList(),
      'AssetDetails': instance.assetDetails?.toJson(),
      'Custody': instance.custody,
      'Status': instance.status,
      'Images': instance.images?.map((e) => e.toJson()).toList(),
      'LastStocktaking': instance.lastStocktaking?.toJson(),
      'OutOfLocation': instance.outOfLocation,
      'LastTransferDate': instance.lastTransferDate,
      'IsNearAntenna': instance.isNearAntenna,
      'DownAnotation': instance.downAnotation,
      'TagEncoded': instance.tagEncoded,
    };

Map<String, dynamic> _$AssetHistoryToJson(AssetHistory instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'AssetCode': instance.assetCode,
      'AssetCodeLegacy':
          instance.assetCodeLegacy?.map((e) => e.toJson()).toList(),
      'CompanyCode': instance.companyCode,
      'LocationName': instance.locationName,
      'Name': instance.name,
      'Description': instance.description,
      'Categories': instance.categories?.map((e) => e.toJson()).toList(),
      'AssetDetails': instance.assetDetails?.toJson(),
      'Custody': instance.custody,
      'Status': instance.status,
      'Images': instance.images?.map((e) => e.toJson()).toList(),
      'LastStocktaking': instance.lastStocktaking?.toJson(),
      'OutOfLocation': instance.outOfLocation,
      'LastTransferDate': instance.lastTransferDate,
      'IsNearAntenna': instance.isNearAntenna,
      'DownAnotation': instance.downAnotation,
      'TagEncoded': instance.tagEncoded,
      'IdAsset': instance.idAsset,
      'Date': instance.date,
      'UserName': instance.userName
    };

LegacyCode _$LegacyCodeFromJson(Map<String, dynamic> json) {
  return LegacyCode(
    system: json['System'] as String?,
    value: json['Value'] as String?,
  );
}

Map<String, dynamic> _$LegacyCodeToJson(LegacyCode instance) =>
    <String, dynamic>{
      'System': instance.system,
      'Value': instance.value,
    };

AssetCategory _$AssetCategoryFromJson(Map<String, dynamic> json) {
  return AssetCategory(
    name: json['Name'] as String?,
    value: json['Value'] as String?,
  );
}

Map<String, dynamic> _$AssetCategoryToJson(AssetCategory instance) =>
    <String, dynamic>{
      'Name': instance.name,
      'Value': instance.value,
    };

AssetDetails _$AssetDetailsFromJson(Map<String, dynamic> json) {
  return AssetDetails(
    model: json['Model'] as String?,
    serialNumber: json['SerialNumber'] as String?,
    make: json['Make'] as String?,
  );
}

Map<String, dynamic> _$AssetDetailsToJson(AssetDetails instance) =>
    <String, dynamic>{
      'Model': instance.model,
      'SerialNumber': instance.serialNumber,
      'Make': instance.make,
    };

AssetPhoto _$AssetPhotoFromJson(Map<String, dynamic> json) {
  return AssetPhoto(
    picture: json['Picture'] as String?,
    author: json['Author'] as String?,
    date: json['Date'] as String?,
  );
}

Map<String, dynamic> _$AssetPhotoToJson(AssetPhoto instance) =>
    <String, dynamic>{
      'Picture': instance.picture,
      'Author': instance.author,
      'Date': instance.date,
    };

LastStocktaking _$LastStocktakingFromJson(Map<String, dynamic> json) {
  return LastStocktaking(
    stocktakingId: json['StocktakingId'] as String,
    timeStamp: json['TimeStamp'] as String,
    userName: json['UserName'] as String,
    currentLocationName: json['CurrentLocationName'] as String,
    findStatus: json['FindStatus'] as String,
  );
}

Map<String, dynamic> _$LastStocktakingToJson(LastStocktaking instance) =>
    <String, dynamic>{
      'StocktakingId': instance.stocktakingId,
      'TimeStamp': instance.timeStamp,
      'UserName': instance.userName,
      'CurrentLocationName': instance.currentLocationName,
      'FindStatus': instance.findStatus,
    };

AssetsReport _$AssetsReportFromJson(Map<String, dynamic> json) {
  return AssetsReport(
    totalAssetsNumber: json['TotalAssetsNumber'] as int?,
    locationsWithAssets: json['LocationsWithAssets'] as int?,
    assetsNumber: json['AssetsNumber'] as int?,
    missingAssets: json['MissingAssets'] as int?,
    lastInventory: json['LastInventory'] as String?,
    missingAssetsList: (json['MissingAssetsList'] as List<dynamic>?)
        ?.map((e) => Asset.fromJson(e as Map<String, dynamic>))
        .toList(),
    outOfLocationAssetsList: (json['OutOfLocationAssetsList'] as List<dynamic>?)
        ?.map((e) => Asset.fromJson(e as Map<String, dynamic>))
        .toList(),
    inAutorizationAssetsList:
        (json['inAutorizationAssetsList'] as List<dynamic>?)
            ?.map((e) => Asset.fromJson(e as Map<String, dynamic>))
            .toList(),
  );
}

Map<String, dynamic> _$AssetsReportToJson(AssetsReport instance) =>
    <String, dynamic>{
      'TotalAssetsNumber': instance.totalAssetsNumber,
      'AssetsNumber': instance.assetsNumber,
      'MissingAssets': instance.missingAssets,
      'LastInventory': instance.lastInventory,
      'LocationsWithAssets': instance.locationsWithAssets,
      'MissingAssetsList': instance.missingAssetsList,
      'OutOfLocationAssetsList': instance.outOfLocationAssetsList,
      'inAutorizationAssetsList': instance.inAutorizationAssetsList
    };

Stocktaking _$StocktakingFromJson(Map<String, dynamic> json) {
  return Stocktaking(
    companyCode: json['CompanyCode'] as String?,
    locationName: json['LocationName'] as String?,
    timeStamp: json['TimeStamp'] as String?,
    userName: json['UserName'] as String?,
    origin: json['Origin'] as String?,
    fileName: json['FileName'] as String?,
    assets: (json['Assets'] as List<dynamic>?)
        ?.map((e) => AssetStatus.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$StocktakingToJson(Stocktaking instance) =>
    <String, dynamic>{
      'CompanyCode': instance.companyCode,
      'LocationName': instance.locationName,
      'TimeStamp': instance.timeStamp,
      'UserName': instance.userName,
      'Origin': instance.origin,
      'FileName': instance.fileName,
      'Assets': instance.assets,
    };

AssetStatus _$AssetStatusFromJson(Map<String, dynamic> json) {
  return AssetStatus(
    assetId: json['AssetId'] as String?,
    serialNumber: json['SerialNumber'],
    findStatus: json['FindStatus'] as String?,
  )..assetName = json['AssetName'] as String?;
}

Map<String, dynamic> _$AssetStatusToJson(AssetStatus instance) =>
    <String, dynamic>{
      'AssetId': instance.assetId,
      'AssetName': instance.assetName,
      'SerialNumber': instance.serialNumber,
      'FindStatus': instance.findStatus,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as String?,
    userName: json['userName'] as String?,
    name: json['name'] == null
        ? null
        : Name.fromJson(json['name'] as Map<String, dynamic>),
    externalId: json['externalId'] as String?,
    codeCarnet: json['codeCarnet'] as String?,
    password: json['password'] as String?,
    photos: (json['photos'] as List<dynamic>?)
        ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
        .toList(),
    emails: (json['emails'] as List<dynamic>?)
        ?.map((e) => Email.fromJson(e as Map<String, dynamic>))
        .toList(),
    active: json['active'] as bool?,
    company: json['company'] == null
        ? null
        : CompanyID.fromJson(json['company'] as Map<String, dynamic>),
    roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
    helpScreens: (json['helpScreens'] as List<dynamic>?)
        ?.map((e) => HelpScreen.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'name': instance.name?.toJson(),
      'externalId': instance.externalId,
      'codeCarnet': instance.codeCarnet,
      'password': instance.password,
      'photos': instance.photos?.map((e) => e.toJson()).toList(),
      'emails': instance.emails?.map((e) => e.toJson()).toList(),
      'active': instance.active,
      'company': instance.company?.toJson(),
      'roles': instance.roles,
      'helpScreens': instance.helpScreens?.map((e) => e.toJson()).toList(),
    };

Name _$NameFromJson(Map<String, dynamic> json) {
  return Name(
    givenName: json['givenName'] as String?,
    middleName: json['middleName'] as String?,
    familyName: json['familyName'] as String?,
    additionalFamilyNames: json['additionalFamilyNames'] as String?,
  );
}

Map<String, dynamic> _$NameToJson(Name instance) => <String, dynamic>{
      'givenName': instance.givenName,
      'middleName': instance.middleName,
      'familyName': instance.familyName,
      'additionalFamilyNames': instance.additionalFamilyNames,
    };

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return Photo(
    value: json['value'] as String?,
    type: json['type'] as String?,
    primary: json['primary'] as bool?,
  );
}

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'value': instance.value,
      'type': instance.type,
      'primary': instance.primary,
    };

Email _$EmailFromJson(Map<String, dynamic> json) {
  return Email(
    value: json['value'] as String?,
    type: json['type'] as String?,
    primary: json['primary'] as bool?,
  );
}

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
      'value': instance.value,
      'type': instance.type,
      'primary': instance.primary,
    };

HelpScreen _$HelpScreenFromJson(Map<String, dynamic> json) {
  return HelpScreen(
    name: json['name'] as String?,
    active: json['active'] as bool?,
  );
}

Map<String, dynamic> _$HelpScreenToJson(HelpScreen instance) =>
    <String, dynamic>{
      'name': instance.name,
      'active': instance.active,
    };
AuthenticationData _$AuthenticationDataFromJson(Map<String, dynamic> json) {
  return AuthenticationData(
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    token: json['token'] as String?,
  );
}

Company _$CompanyFromJson(Map<String, dynamic> json) {
  return Company(
    id: json['id'] as String?,
    companyCode: json['companyCode'] as String?,
    name: json['name'] as String?,
    addresses: (json['addresses'] as List<dynamic>?)
        ?.map((e) => CompanyAddress.fromJson(e as Map<String, dynamic>))
        .toList(),
    externalId: json['externalId'] as String?,
    locations:
        (json['locations'] as List<dynamic>?)?.map((e) => e as String).toList(),
    businessLines: (json['busineesLines'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    logo: json['logo'] as String?,
    roles: (json['roles'] as List<dynamic>?)
        ?.map((e) => CompanyRole.fromJson(e as Map<String, dynamic>))
        .toList(),
    active: json['active'] as bool?,
  );
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'id': instance.id,
      'companyCode': instance.companyCode,
      'name': instance.name,
      'addresses': instance.addresses?.map((e) => e.toJson()).toList(),
      'externalId': instance.externalId,
      'locations': instance.locations,
      'busineesLines': instance.businessLines,
      'logo': instance.logo,
      'roles': instance.roles?.map((e) => e.toJson()).toList(),
      'active': instance.active,
    };

CompanyAddress _$CompanyAddressFromJson(Map<String, dynamic> json) {
  return CompanyAddress(
    primary: json['primary'] as bool?,
    streetAddress: json['streetAddress'] as String?,
    locality: json['locality'] as String?,
    region: json['region'] as String?,
    country: json['country'] as String?,
  );
}

Map<String, dynamic> _$CompanyAddressToJson(CompanyAddress instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'streetAddress': instance.streetAddress,
      'locality': instance.locality,
      'region': instance.region,
      'country': instance.country,
    };

CompanyRole _$CompanyRoleFromJson(Map<String, dynamic> json) {
  return CompanyRole(
    name: json['name'] as String?,
    roleId: json['roleId'] as String?,
    resources:
        (json['resources'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$CompanyRoleToJson(CompanyRole instance) =>
    <String, dynamic>{
      'name': instance.name,
      'roleId': instance.roleId,
      'resources': instance.resources,
    };

Campus _$CampusFromJson(Map<String, dynamic> json) {
  return Campus(
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => CompanyAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
      businessLine: json["BusinessLine"] as String,
      companyCode: json["CompanyCode"] as String,
      id: json["Id"] as String,
      logo: json["Logo"] as String,
      areas:
          (json['Areas'] as List<dynamic>?)?.map((e) => e as String).toList(),
      name: json['Name'] as String);
}

Map<String, dynamic> _$CampusToJson(Campus instance) => <String, dynamic>{
      'Id': instance.id,
      'addresses': instance.addresses,
      'BusinessLine': instance.businessLine,
      'CompanyCode': instance.companyCode,
      'Logo': instance.logo,
      'Name': instance.name,
      'Areas': instance.areas
    };

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    name: json['Name'] as String?,
    address: json['Address'] as String?,
    city: json['City'] as String?,
    department: json['Department'] as String?,
    country: json['Country'] as String?,
    images:
        (json['Images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'Name': instance.name,
      'Address': instance.address,
      'City': instance.city,
      'Department': instance.department,
      'Country': instance.country,
      'Images': instance.images,
    };

Authorization _$AuthorizationFromJson(Map<String, dynamic> json) {
  return Authorization(
    id: json['Id'] as String?,
    companyCode: json['CompanyCode'] as String?,
    number: json['Number'] as int?,
    dateIssued: json['DateIssued'] as String?,
    authorizedStartDate: json['AuthorizedStartDate'] as String?,
    authorizedEndDate: json['AuthorizedEndDate'] as String?,
    assets:
        (json['Assets'] as List<dynamic>?)?.map((e) => e as String).toList(),
    person: json['Person'] as String?,
    isPermanent: json['IsPermanent'] as bool?,
    revoked: json['Revoked'] as bool?,
    transferLocation: json['TransferLocation'] as String?,
    supervisor: json['Supervisor'] as String?,
  );
}

Map<String, dynamic> _$AuthorizationToJson(Authorization instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'CompanyCode': instance.companyCode,
      'Number': instance.number,
      'DateIssued': instance.dateIssued,
      'AuthorizedStartDate': instance.authorizedStartDate,
      'AuthorizedEndDate': instance.authorizedEndDate,
      'Assets': instance.assets,
      'Person': instance.person,
      'IsPermanent': instance.isPermanent,
      'Revoked': instance.revoked,
      'TransferLocation': instance.transferLocation,
      'Supervisor': instance.supervisor
    };

AuthorizationPendient _$AuthorizationPendientFromJson(
    Map<String, dynamic> json) {
  return AuthorizationPendient(
    id: json['Id'] as String?,
    companyCode: json['CompanyCode'] as String?,
    number: json['Number'] as int?,
    dateIssued: json['DateIssued'] as String?,
    authorizedStartDate: json['AuthorizedStartDate'] as String?,
    authorizedEndDate: json['AuthorizedEndDate'] as String?,
    assets:
        (json['Assets'] as List<dynamic>?)?.map((e) => e as String).toList(),
    person: json['Person'] as String?,
    isPermanent: json['IsPermanent'] as bool?,
    revoked: json['Revoked'] as bool?,
    transferLocation: json['TransferLocation'] as String?,
    status: json['Status'] as String?,
  );
}

Map<String, dynamic> _$AuthorizationPendientToJson(
        AuthorizationPendient instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'CompanyCode': instance.companyCode,
      'Number': instance.number,
      'DateIssued': instance.dateIssued,
      'AuthorizedStartDate': instance.authorizedStartDate,
      'AuthorizedEndDate': instance.authorizedEndDate,
      'Assets': instance.assets,
      'Person': instance.person,
      'IsPermanent': instance.isPermanent,
      'Revoked': instance.revoked,
      'TransferLocation': instance.transferLocation,
      'Status': instance.status
    };

AssetTransfer _$AssetTransferFromJson(Map<String, dynamic> json) {
  return AssetTransfer(
    id: json['Id'] as String?,
    ePC: json['EPC'] as String?,
    assetCode: json['AssetCode'] as String?,
    name: json['Name'] as String?,
    companyCode: json['CompanyCode'] as String?,
    locationName: json['LocationName'] as String?,
    antenna: json['Antenna'] as int?,
    count: json['Count'] as int?,
    lastTimeStamp: json['LastTimeStamp'] as String?,
    lastTimeStamp1: json['LastTimeStamp1'] as String?,
    lastTimeStamp2: json['LastTimeStamp2'] as String?,
    lastTimeStamp3: json['LastTimeStamp3'] as String?,
    lastTimeStamp4: json['LastTimeStamp4'] as String?,
    antennaCount1: json['AntennaCount1'] as int?,
    antennaCount2: json['AntennaCount2'] as int?,
    antennaCount3: json['AntennaCount3'] as int?,
    antennaCount4: json['AntennaCount4'] as int?,
    status: json['Status'] as String?,
    alarmed: json['Alarmed'] as bool?,
  );
}

Map<String, dynamic> _$AssetTransferToJson(AssetTransfer instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'EPC': instance.ePC,
      'AssetCode': instance.assetCode,
      'Name': instance.name,
      'CompanyCode': instance.companyCode,
      'LocationName': instance.locationName,
      'Antenna': instance.antenna,
      'Count': instance.count,
      'LastTimeStamp': instance.lastTimeStamp,
      'LastTimeStamp1': instance.lastTimeStamp1,
      'LastTimeStamp2': instance.lastTimeStamp2,
      'LastTimeStamp3': instance.lastTimeStamp3,
      'LastTimeStamp4': instance.lastTimeStamp4,
      'AntennaCount1': instance.antennaCount1,
      'AntennaCount2': instance.antennaCount2,
      'AntennaCount3': instance.antennaCount3,
      'AntennaCount4': instance.antennaCount4,
      'Status': instance.status,
      'Alarmed': instance.alarmed,
    };

HttpHenutsenResponse _$HttpHenutsenResponseFromJson(Map<String, dynamic> json) {
  return HttpHenutsenResponse(
    statusCode: json['statusCode'] as int?,
    error: json['error'] as bool?,
    message: json['message'] as String?,
    content: json['content'],
  );
}

Map<String, dynamic> _$HttpHenutsenResponseToJson(
        HttpHenutsenResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'error': instance.error,
      'message': instance.message,
      'content': instance.content,
    };

EmailToSend _$EmailToSendFromJson(Map<String, dynamic> json) {
  return EmailToSend(
    to: (json['To'] as List<dynamic>?)?.map((e) => e as String).toList(),
    from: json['From'] as String?,
    subject: json['Subject'] as String?,
    body: json['Body'] as String?,
    client: json['Client'] as String?,
    henutsenReport: json['HenutsenReport'] == null
        ? null
        : HenutsenReport.fromJson(
            json['HenutsenReport'] as Map<String, dynamic>),
    henutsenWelcome: json['HenutsenWelcome'] == null
        ? null
        : HenutsenWelcome.fromJson(
            json['HenutsenWelcome'] as Map<String, dynamic>),
    passwordRecovery: json['PasswordRecovery'] == null
        ? null
        : PasswordRecovery.fromJson(
            json['PasswordRecovery'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$EmailToSendToJson(EmailToSend instance) =>
    <String, dynamic>{
      'To': instance.to,
      'From': instance.from,
      'Subject': instance.subject,
      'Body': instance.body,
      'Client': instance.client,
      'HenutsenReport': instance.henutsenReport,
      'HenutsenWelcome': instance.henutsenWelcome,
      'PasswordRecovery': instance.passwordRecovery,
    };

HenutsenReport _$HenutsenReportFromJson(Map<String, dynamic> json) {
  return HenutsenReport(
    reportId: json['ReportId'] as String?,
    company: json['Company'] as String?,
    location: json['Location'] as String?,
    timeStamp: json['TimeStamp'] as String?,
    user: json['User'] as String?,
    nofoundAssets: json['NoFoundAssets'],
    foundAssets: json['FoundAssets'],
    otherLocationAssets: json['OtherLocationsAssets'],
    assets1: (json['Assets1'] as List<dynamic>?)
        ?.map((e) => AssetStatus.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$HenutsenReportToJson(HenutsenReport instance) =>
    <String, dynamic>{
      'ReportId': instance.reportId,
      'Company': instance.company,
      'Location': instance.location,
      'TimeStamp': instance.timeStamp,
      'User': instance.user,
      'NoFoundAssets': instance.nofoundAssets,
      'FoundAssets': instance.foundAssets,
      'OtherLocationsAssets': instance.otherLocationAssets,
      'Assets1': instance.assets1,
    };

HenutsenWelcome _$HenutsenWelcomeFromJson(Map<String, dynamic> json) {
  return HenutsenWelcome(
    company: json['Company'] as String?,
    userName: json['UserName'] as String?,
    fullName: json['FullName'] as String?,
  );
}

Map<String, dynamic> _$HenutsenWelcomeToJson(HenutsenWelcome instance) =>
    <String, dynamic>{
      'Company': instance.company,
      'UserName': instance.userName,
      'FullName': instance.fullName,
    };

PasswordRecovery _$PasswordRecoveryFromJson(Map<String, dynamic> json) {
  return PasswordRecovery(
    userName: json['UserName'] as String?,
    fullName: json['FullName'] as String?,
    token: json['Token'] as String?,
  );
}

Map<String, dynamic> _$PasswordRecoveryToJson(PasswordRecovery instance) =>
    <String, dynamic>{
      'UserName': instance.userName,
      'FullName': instance.fullName,
      'Token': instance.token,
    };
